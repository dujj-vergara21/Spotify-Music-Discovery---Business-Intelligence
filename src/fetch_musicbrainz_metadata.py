"""Fetch MusicBrainz artist metadata and save search matches."""

import csv
import time
from pathlib import Path

from src.musicbrainz_api import search_artist

PROJECT_ROOT = Path(__file__).resolve().parent.parent
OUTPUT_PATH = PROJECT_ROOT / "data" / "musicbrainz_artist_metadata.csv"

ARTIST_NAMES = [
    "Shakira",
    "Ricky Martin",
    "CNCO",
    "J Balvin",
    "Daddy Yankee",
    "Maluma",
    "Ozuna",
    "The Weeknd",
]


def main():
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    records = []

    for index, chart_artist in enumerate(ARTIST_NAMES):
        try:
            results = search_artist(chart_artist)

            for artist in results:
                records.append({
                    "chart_artist_name": chart_artist,
                    "musicbrainz_artist_id": artist.get(
                        "musicbrainz_artist_id"
                    ),
                    "musicbrainz_artist_name": artist.get("artist_name"),
                    "country": artist.get("country"),
                    "type": artist.get("type"),
                    "disambiguation": artist.get("disambiguation"),
                    "match_status": "REVIEW_REQUIRED",
                })

            print(f"{chart_artist}: {len(results)} candidate matches")

        except Exception as exc:
            print(f"Could not fetch {chart_artist}: {exc}")

        if index < len(ARTIST_NAMES) - 1:
            time.sleep(1.1)

    fieldnames = [
        "chart_artist_name",
        "musicbrainz_artist_id",
        "musicbrainz_artist_name",
        "country",
        "type",
        "disambiguation",
        "match_status",
    ]

    with OUTPUT_PATH.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(records)

    print(f"Saved {len(records)} candidate matches to {OUTPUT_PATH}")
    print("Review candidate matches before using them in analysis.")


if __name__ == "__main__":
    main()
