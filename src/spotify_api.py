"""Spotify Web API client for the Music Discovery project."""

import os
import time
import requests
from requests.auth import HTTPBasicAuth


API_BASE = "https://api.spotify.com/v1"
TOKEN_URL = "https://accounts.spotify.com/api/token"


def get_access_token():
    """Request an app access token using Client Credentials."""
    client_id = os.getenv("SPOTIFY_CLIENT_ID")
    client_secret = os.getenv("SPOTIFY_CLIENT_SECRET")

    if not client_id or not client_secret:
        raise RuntimeError(
            "Set SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET "
            "as environment variables."
        )

    response = requests.post(
        TOKEN_URL,
        auth=HTTPBasicAuth(client_id, client_secret),
        data={"grant_type": "client_credentials"},
        timeout=30,
    )
    response.raise_for_status()
    return response.json()["access_token"]


def search_tracks(query, limit=10):
    """Search for tracks and return available metadata."""
    if not query or not query.strip():
        raise ValueError("Search query cannot be empty.")

    limit = max(1, min(int(limit), 50))
    token = get_access_token()

    response = requests.get(
        f"{API_BASE}/search",
        headers={"Authorization": f"Bearer {token}"},
        params={
            "q": query,
            "type": "track",
            "limit": limit,
        },
        timeout=30,
    )
    response.raise_for_status()

    results = response.json().get("tracks", {}).get("items", [])

    return [
        {
            "track_id": track.get("id"),
            "track_name": track.get("name"),
            "artists": [
                artist.get("name")
                for artist in track.get("artists", [])
            ],
            "album_name": track.get("album", {}).get("name"),
            "release_date": track.get("album", {}).get("release_date"),
            "spotify_url": track.get("external_urls", {}).get("spotify"),
        }
        for track in results
    ]


if __name__ == "__main__":
    results = search_tracks("independent Filipino artists", limit=5)
    for item in results:
        print(item)
