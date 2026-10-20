"""Verify MusicBrainz artist candidates against chart artist names."""

import csv
import time
from pathlib import Path

from src.musicbrainz_api import search_artist

PROJECT_ROOT = Path(__file__).resolve().parent.parent
INPUT_PATH = PROJECT_ROOT / "data" / "artist_match_review.csv"
OUTPUT_PATH = PROJECT_ROOT / "data" / "artist_match_verification.csv"


def normalize(value):
    return " ".join((value or "").casefold().split())


def main():
    verified_rows = []

    with INPUT_PATH.open("r", encoding="utf-8-sig", newline="") as file:
        reader = csv.DictReader(file)
        rows = list(reader)

    for index, row in enumerate(rows):
        chart_artist = row["chart_artist_name"].strip()

        try:
            candidates = search_artist(chart_artist)
            exact_matches = [
                candidate for candidate in candidates
                if normalize(candidate.get("artist_name")) == normalize(chart_artist)
            ]

            if len(exact_matches) == 1:
                candidate = exact_matches[0]
                suggested_id = candidate.get("musicbrainz_artist_id", "")
                suggested_name = candidate.get("artist_name", "")
                suggested_country = candidate.get("country", "")
                note = "EXACT_NAME_MATCH_REVIEW_REQUIRED"
            elif exact_matches:
                suggested_id = ""
                suggested_name = ""
                suggested_country = ""
                note = "MULTIPLE_EXACT_MATCHES_REVIEW_REQUIRED"
            else:
                suggested_id = ""
                suggested_name = ""
                suggested_country = ""
                note = "NO_EXACT_MATCH_REVIEW_CANDIDATES"

            verified_rows.append({
                "chart_artist_name": chart_artist,
                "current_musicbrainz_artist_id": row.get("musicbrainz_artist_id", ""),
                "suggested_musicbrainz_artist_id": suggested_id,
                "suggested_artist_name": suggested_name,
                "suggested_country": suggested_country,
                "verification_status": note,
            })

            print(f"{chart_artist}: {note}")

        except Exception as exc:
            verified_rows.append({
                "chart_artist_name": chart_artist,
                "current_musicbrainz_artist_id": row.get("musicbrainz_artist_id", ""),
                "suggested_musicbrainz_artist_id": "",
                "suggested_artist_name": "",
                "suggested_country": "",
                "verification_status": f"API_ERROR: {exc}",
            })
            print(f"{chart_artist}: API error")

        if index < len(rows) - 1:
            time.sleep(1.1)

    fields = [
        "chart_artist_name",
        "current_musicbrainz_artist_id",
        "suggested_musicbrainz_artist_id",
        "suggested_artist_name",
        "suggested_country",
        "verification_status",
    ]

    with OUTPUT_PATH.open("w", encoding="utf-8", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=fields)
        writer.writeheader()
        writer.writerows(verified_rows)

    print(f"Saved verification report to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
