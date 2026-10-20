
"""Import the full Spotify Charts CSV into MySQL in batches.

Expected source columns:
title, rank, date, artist, url, region, chart, trend, stream(s)

Set CHARTS_CSV_PATH to the full CSV location.
Never commit the full CSV or database credentials to GitHub.
"""

import os
import re
from pathlib import Path
from urllib.parse import urlparse

import pandas as pd
import mysql.connector
from dotenv import load_dotenv

PROJECT_ROOT = Path(__file__).resolve().parent.parent
load_dotenv(PROJECT_ROOT / ".env")

DATA_PATH = Path(
    os.getenv(
        "CHARTS_CSV_PATH",
        str(PROJECT_ROOT / "data" / "charts.csv"),
    )
)

CHUNK_SIZE = int(os.getenv("CHARTS_CHUNK_SIZE", "10000"))
SOURCE_NAME = "Spotify Charts Kaggle Dataset"


def normalize_text(value):
    if pd.isna(value):
        return None
    value = str(value).strip()
    return value if value else None


def extract_track_id(url):
    """Extract a Spotify track ID from a track URL."""
    url = normalize_text(url)
    if not url:
        return None

    match = re.search(r"/track/([A-Za-z0-9]+)", url)
    if match:
        return match.group(1)[:50]

    return None


def parse_streams(value):
    if pd.isna(value):
        return None
    try:
        return int(float(str(value).replace(",", "").strip()))
    except (TypeError, ValueError):
        return None


def get_artist_names(value):
    """Split the source's comma-separated artist names."""
    value = normalize_text(value)
    if not value:
        return []
    return [name.strip() for name in value.split(",") if name.strip()]


def get_connection():
    password = os.getenv("MYSQL_PASSWORD")
    if not password:
        raise RuntimeError(
            "MYSQL_PASSWORD is missing. Set it in your local .env "
            "or the authorized execution environment."
        )

    return mysql.connector.connect(
        host=os.getenv("MYSQL_HOST", "127.0.0.1"),
        port=int(os.getenv("MYSQL_PORT", "3310")),
        user=os.getenv("MYSQL_USER", "music_app"),
        password=password,
        database=os.getenv("MYSQL_DATABASE", "music_discovery"),
    )


def load_reference_data(cursor):
    """Seed chart types, trends, and retrieve lookup dictionaries."""
    cursor.executemany(
        """
        INSERT IGNORE INTO chart_types (chart_name, chart_description)
        VALUES (%s, %s)
        """,
        [
            ("top200", "Daily Top 200 chart"),
            ("viral50", "Daily Viral 50 chart"),
        ],
    )

    cursor.executemany(
        "INSERT IGNORE INTO chart_trends (trend_name) VALUES (%s)",
        [
            ("MOVE_UP",),
            ("MOVE_DOWN",),
            ("SAME_POSITION",),
            ("NEW_ENTRY",),
            ("UNKNOWN",),
        ],
    )

    cursor.execute(
        """
        SELECT source_id
        FROM data_sources
        WHERE source_name = %s
        LIMIT 1
        """,
        (SOURCE_NAME,),
    )
    source = cursor.fetchone()

    if source:
        source_id = source[0]
    else:
        cursor.execute(
            """
            INSERT INTO data_sources
                (source_name, source_type, source_url, source_notes)
            VALUES (%s, %s, %s, %s)
            """,
            (
                SOURCE_NAME,
                "CSV",
                "https://www.kaggle.com/datasets/dhruvildave/spotify-charts",
                "Daily Spotify chart observations",
            ),
        )
        source_id = cursor.lastrowid

    cursor.execute("SELECT chart_type_id, chart_name FROM chart_types")
    chart_types = {name: key for key, name in cursor.fetchall()}

    cursor.execute("SELECT trend_id, trend_name FROM chart_trends")
    trends = {name: key for key, name in cursor.fetchall()}

    cursor.execute("SELECT region_id, region_code FROM chart_regions")
    regions = {code: key for key, code in cursor.fetchall()}

    return source_id, chart_types, trends, regions


def import_chunk(cursor, conn, chunk, lookups):
    source_id, chart_types, trends, regions = lookups

    # Support the original source column names and cleaned equivalents.
    rename_map = {
        "stream(s)": "streams",
        "Stream(s)": "streams",
        "title": "title",
        "rank": "rank",
        "date": "date",
        "artist": "artist",
        "url": "url",
        "region": "region",
        "chart": "chart",
        "trend": "trend",
    }
    chunk = chunk.rename(columns=rename_map)

    required = [
        "title", "rank", "date", "artist",
        "url", "region", "chart", "trend", "streams",
    ]
    missing = [column for column in required if column not in chunk.columns]
    if missing:
        raise ValueError(f"CSV is missing required columns: {missing}")

    chunk["track_id"] = chunk["url"].map(extract_track_id)
    chunk["chart_date"] = pd.to_datetime(
        chunk["date"], errors="coerce"
    ).dt.date

    chunk["chart_rank"] = pd.to_numeric(
        chunk["rank"], errors="coerce"
    )
    chunk["streams"] = chunk["streams"].map(parse_streams)

    chunk["region"] = chunk["region"].map(normalize_text)
    chunk["chart"] = chunk["chart"].map(normalize_text)
    chunk["trend"] = chunk["trend"].map(normalize_text)
    chunk["title"] = chunk["title"].map(normalize_text)
    chunk["artist"] = chunk["artist"].map(normalize_text)
    chunk["url"] = chunk["url"].map(normalize_text)

    # Reject rows without essential identifiers or valid chart dates.
    chunk = chunk.dropna(
        subset=[
            "track_id", "chart_date", "chart_rank",
            "region", "chart", "title",
        ]
    ).copy()

    chunk["chart_rank"] = chunk["chart_rank"].astype(int)

    # Keep only chart types supported by the database.
    chunk = chunk[chunk["chart"].isin(chart_types)].copy()

    if chunk.empty:
        return 0, 0

    # Register regions in a repeatable manner.
    region_names = sorted(set(chunk["region"].dropna()))
    for region_name in region_names:
        cursor.execute(
            """
            INSERT INTO chart_regions (region_code, region_name)
            VALUES (%s, %s)
            ON DUPLICATE KEY UPDATE region_name = VALUES(region_name)
            """,
            (region_name, region_name),
        )

    cursor.execute("SELECT region_id, region_code FROM chart_regions")
    regions = {code: key for key, code in cursor.fetchall()}

    # Insert artists before tracks.
    artist_names = set()
    for value in chunk["artist"].dropna():
        artist_names.update(get_artist_names(value))

    cursor.executemany(
        """
        INSERT IGNORE INTO artists (artist_name)
        VALUES (%s)
        """,
        [(name,) for name in sorted(artist_names)],
    )

    cursor.execute("SELECT artist_id, artist_name FROM artists")
    artist_ids = {name: key for key, name in cursor.fetchall()}

    # Use the first listed artist as the primary artist.
    track_records = {}
    for row in chunk.itertuples(index=False):
        names = get_artist_names(row.artist)
        primary_artist_id = artist_ids.get(names[0]) if names else None

        track_records[row.track_id] = (
            row.track_id,
            row.title[:255],
            primary_artist_id,
        )

    cursor.executemany(
        """
        INSERT IGNORE INTO tracks
            (track_id, track_name, artist_id)
        VALUES (%s, %s, %s)
        """,
        list(track_records.values()),
    )

    # Register import batch metadata.
    cursor.execute(
        """
        INSERT INTO import_batches
            (source_id, file_name, rows_processed, batch_status, notes)
        VALUES (%s, %s, %s, %s, %s)
        """,
        (
            source_id,
            DATA_PATH.name,
            len(chunk),
            "PROCESSING",
            "Chunked Spotify Charts CSV import",
        ),
    )
    batch_id = cursor.lastrowid

    # Populate the date dimension for this chunk.
    dates = sorted(set(chunk["chart_date"]))
    date_rows = []
    for day in dates:
        date_rows.append(
            (
                day.year * 10000 + day.month * 100 + day.day,
                day,
                day.year,
                day.month,
                day.strftime("%B"),
                (day.month - 1) // 3 + 1,
                day.day,
                day.strftime("%A"),
                int(day.strftime("%W")),
                day.weekday() >= 5,
            )
        )

    cursor.executemany(
        """
        INSERT INTO dim_dates (
            date_id, full_date, year_num, month_num, month_name,
            quarter_num, day_num, day_name, week_num, is_weekend
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON DUPLICATE KEY UPDATE
            year_num = VALUES(year_num),
            month_num = VALUES(month_num),
            month_name = VALUES(month_name),
            quarter_num = VALUES(quarter_num),
            day_num = VALUES(day_num),
            day_name = VALUES(day_name),
            week_num = VALUES(week_num),
            is_weekend = VALUES(is_weekend)
        """,
        date_rows,
    )

    # Deduplicate observations within this chunk before insertion.
    chunk = chunk.drop_duplicates(
        subset=[
            "track_id", "chart_date", "chart_rank",
            "region", "chart",
        ]
    )

    chart_rows = []
    for row in chunk.itertuples(index=False):
        chart_rows.append(
            (
                row.track_id,
                row.chart_date,
                row.chart_rank,
                regions[row.region],
                chart_types[row.chart],
                trends.get(row.trend or "UNKNOWN", trends["UNKNOWN"]),
                row.streams,
                row.url,
                row.chart_date.year * 10000
                    + row.chart_date.month * 100
                    + row.chart_date.day,
            )
        )

    # Insert observations; the unique chart key prevents duplicates
    # when the same source data is imported again.
    cursor.executemany(
        """
        INSERT IGNORE INTO daily_track_charts (
            track_id, chart_date, chart_rank, region_id,
            chart_type_id, trend_id, streams, source_track_url, date_id
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        """,
        chart_rows,
    )

    inserted = cursor.rowcount

    cursor.execute(
        """
        UPDATE import_batches
        SET rows_processed = %s, batch_status = %s
        WHERE batch_id = %s
        """,
        (inserted, "COMPLETED", batch_id),
    )

    conn.commit()
    return len(chunk), inserted


def main():
    if not DATA_PATH.exists():
        raise FileNotFoundError(
            f"CSV not found: {DATA_PATH}\n"
            "Set CHARTS_CSV_PATH to the full CSV file path."
        )

    print(f"Source file: {DATA_PATH}")
    print(f"Chunk size: {CHUNK_SIZE:,}")

    conn = get_connection()
    cursor = conn.cursor()

    total_valid = 0
    total_inserted = 0
    chunks_processed = 0

    try:
        lookups = load_reference_data(cursor)
        conn.commit()

        # The original dataset may be several gigabytes; do not load
        # the entire CSV into memory.
        for chunk in pd.read_csv(
            DATA_PATH,
            chunksize=CHUNK_SIZE,
            low_memory=False,
        ):
            chunks_processed += 1
            valid, inserted = import_chunk(
                cursor, conn, chunk, lookups
            )
            total_valid += valid
            total_inserted += inserted

            print(
                f"Chunk {chunks_processed}: "
                f"valid rows={valid:,}, inserted={inserted:,}, "
                f"total inserted={total_inserted:,}"
            )

        print("\nImport finished.")
        print(f"Chunks processed: {chunks_processed:,}")
        print(f"Valid chart rows processed: {total_valid:,}")
        print(f"New chart rows inserted: {total_inserted:,}")
        print("Existing duplicate chart rows are ignored.")

    except Exception:
        conn.rollback()
        raise

    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    main()
