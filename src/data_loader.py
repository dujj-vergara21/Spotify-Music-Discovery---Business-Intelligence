"""Load the Spotify Charts dataset and saved track metadata."""

from pathlib import Path

import pandas as pd


PROJECT_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_ROOT / "data"


def load_chart_data(nrows=1000):
    """Load a sample of the Spotify Charts CSV."""
    csv_path = DATA_DIR / "charts.csv"

    if not csv_path.exists():
        raise FileNotFoundError(
            f"Chart dataset not found: {csv_path}"
        )

    return pd.read_csv(csv_path, nrows=nrows)


def load_track_metadata():
    """Load previously saved Spotify track metadata."""
    metadata_path = DATA_DIR / "spotify_track_metadata_sample.csv"

    if not metadata_path.exists():
        raise FileNotFoundError(
            f"Metadata file not found: {metadata_path}"
        )

    return pd.read_csv(metadata_path)
