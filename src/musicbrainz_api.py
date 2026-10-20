"""MusicBrainz metadata client for Music Discovery."""

import time
import requests

API_BASE = "https://musicbrainz.org/ws/2"
USER_AGENT = "MusicDiscoveryBI/1.0 (student project)"


def search_recordings(query, limit=10):
    """Search MusicBrainz recordings by title or artist."""
    if not query or not query.strip():
        raise ValueError("Search query cannot be empty.")

    limit = max(1, min(int(limit), 100))

    response = requests.get(
        f"{API_BASE}/recording/",
        params={
            "query": query,
            "fmt": "json",
            "limit": limit,
        },
        headers={"User-Agent": USER_AGENT},
        timeout=30,
    )
    response.raise_for_status()

    recordings = response.json().get("recordings", [])

    return [
        {
            "musicbrainz_recording_id": item.get("id"),
            "recording_title": item.get("title"),
            "artists": [
                credit.get("name")
                for credit in item.get("artist-credit", [])
                if isinstance(credit, dict) and credit.get("name")
            ],
            "first_release_date": item.get("first-release-date"),
            "length_ms": item.get("length"),
        }
        for item in recordings
    ]


def search_artist(name):
    """Search MusicBrainz for matching artist records."""
    if not name or not name.strip():
        raise ValueError("Artist name cannot be empty.")

    response = requests.get(
        f"{API_BASE}/artist/",
        params={
            "query": name,
            "fmt": "json",
            "limit": 10,
        },
        headers={"User-Agent": USER_AGENT},
        timeout=30,
    )
    response.raise_for_status()

    return [
        {
            "musicbrainz_artist_id": artist.get("id"),
            "artist_name": artist.get("name"),
            "country": artist.get("country"),
            "type": artist.get("type"),
            "disambiguation": artist.get("disambiguation"),
        }
        for artist in response.json().get("artists", [])
    ]


if __name__ == "__main__":
    print(search_artist("Ben&Ben"))
    time.sleep(1.1)
    print(search_recordings("Leaves Ben&Ben"))
