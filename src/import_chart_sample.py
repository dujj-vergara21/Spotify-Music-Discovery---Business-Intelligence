"""Import a chart sample into the MySQL database."""

import os
from pathlib import Path

import pandas as pd
import mysql.connector
from dotenv import load_dotenv

PROJECT_ROOT = Path(__file__).resolve().parent.parent
load_dotenv(PROJECT_ROOT / ".env")

DATA_PATH = PROJECT_ROOT / "data" / "charts_import_sample.csv"


def main():
    if not DATA_PATH.exists():
        raise FileNotFoundError(
            f"Sample file not found: {DATA_PATH}"
        )

    df = pd.read_csv(DATA_PATH)

    # Support either column name used for stream counts.
    if "streams" not in df.columns and "stream(s)" in df.columns:
        df = df.rename(columns={"stream(s)": "streams"})

    required = [
        "track_id", "title", "date", "rank", "region",
        "chart", "trend", "streams", "url"
    ]
    missing = [col for col in required if col not in df.columns]
    if missing:
        raise ValueError(f"Missing required columns: {missing}")

    conn = mysql.connector.connect(
        host=os.getenv("MYSQL_HOST", "127.0.0.1"),
        port=int(os.getenv("MYSQL_PORT", "3310")),
        user=os.getenv("MYSQL_USER", "music_app"),
        password=os.environ["MYSQL_PASSWORD"],
        database=os.getenv("MYSQL_DATABASE", "music_discovery"),
    )

    cursor = conn.cursor()

    try:
        # Add tracks without replacing existing track names.
        tracks = df[["track_id", "title"]].drop_duplicates("track_id")

        for row in tracks.itertuples(index=False, name=None):
            cursor.execute(
                """
                INSERT IGNORE INTO tracks (track_id, track_name)
                VALUES (%s, %s)
                """,
                row,
            )

        imported = 0
        skipped = 0

        for row in df.itertuples(index=False):
            params = (
                row.track_id, row.date, row.rank, row.region,
                row.chart, row.trend,
                None if pd.isna(row.streams) else row.streams,
                row.url,
            )

            # Skip a chart entry that is already in the database.
            cursor.execute(
                """
                SELECT 1
                FROM daily_track_charts d
                JOIN chart_regions r ON r.region_id = d.region_id
                JOIN chart_types c ON c.chart_type_id = d.chart_type_id
                WHERE d.track_id = %s
                  AND d.chart_date = %s
                  AND d.chart_rank = %s
                  AND r.region_code = %s
                  AND c.chart_name = %s
                LIMIT 1
                """,
                (row.track_id, row.date, row.rank, row.region, row.chart),
            )

            if cursor.fetchone():
                skipped += 1
                continue

            cursor.execute(
                """
                INSERT INTO daily_track_charts
                (track_id, chart_date, chart_rank, region_id,
                 chart_type_id, trend_id, streams, source_track_url)
                SELECT %s, %s, %s, r.region_id, c.chart_type_id,
                       t.trend_id, %s, %s
                FROM chart_regions r
                JOIN chart_types c ON c.chart_name = %s
                JOIN chart_trends t ON t.trend_name = %s
                WHERE r.region_code = %s
                """,
                (
                    row.track_id, row.date, row.rank,
                    params[6], row.url,
                    row.chart, row.trend, row.region,
                ),
            )

            if cursor.rowcount == 1:
                imported += 1
            else:
                raise ValueError(
                    f"Could not map region/chart/trend for track "
                    f"{row.track_id}: {row.region}, {row.chart}, {row.trend}"
                )

        conn.commit()
        print("Unique tracks processed:", len(tracks))
        print("New chart records imported:", imported)
        print("Existing chart records skipped:", skipped)

    except Exception:
        conn.rollback()
        raise

    finally:
        cursor.close()
        conn.close()


if __name__ == "__main__":
    main()
