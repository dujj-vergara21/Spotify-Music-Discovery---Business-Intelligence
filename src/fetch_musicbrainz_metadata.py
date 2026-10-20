"""Fetch MusicBrainz metadata and save it as a CSV."""

import csv
import time
from pathlib import Path

from src.musicbrainz_api import search_artist

PROJECT_ROOT = Path(__file__).resolve().parent.parent
OUTPUT_PATH = PROJECT_ROOT / "data" / "musicbrainz_artist_metadata.csv"

# Start with a small set of artists found in the chart dataset.
ARTIST_NAMES = [
    "Ben&Ben",
    "Taylor Swift",
    "The Weeknd",
]


def main():
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    records = []
    seen_ids = set()

    for index, name in enumerate(ARTIST_NAMES):
        try:
            results = search_artist(name)

            for artist in results:
                artist_id = artist.get("musicbrainz_artist_id")
                if artist_id and artist_id not in seen_ids:
                    records.append(artist)
                    seen_ids.add(artist_id)

            print(f"Processed: {name} ({len(results)} results)")

        except Exception as exc:
            print(f"Could not fetch {name}: {exc}")

        # Respect MusicBrainz's rate limit between requests.
        if index < len(ARTIST_NAMES) - 1:
            time.sleep(1.1)

    fieldnames = [
        "musicbrainz_artist_id",
        "artist_name",
        "country",
        "type",
        "disambiguation",
    ]

    with OUTPUT_PATH.open("w", newline="", encoding="utf-8") as file:
        writer = csv.DictWriter(file, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(records)

    print(f"Saved {len(records)} artist records to {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
