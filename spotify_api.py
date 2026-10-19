"""Helpers for accessing Spotify track metadata."""

import requests


def get_track_metadata(track_id, access_token):
    """Return metadata for one Spotify track."""
    url = f"https://api.spotify.com/v1/tracks/{track_id}"
    headers = {"Authorization": f"Bearer {access_token}"}

    response = requests.get(url, headers=headers, timeout=30)
    response.raise_for_status()

    track = response.json()

    return {
        "track_id": track["id"],
        "track_name": track["name"],
        "artists": ", ".join(
            artist["name"] for artist in track["artists"]
        ),
        "album": track["album"]["name"],
        "release_date": track["album"]["release_date"],
    }
