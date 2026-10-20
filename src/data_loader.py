"""Load chart and track metadata datasets."""

from pathlib import Path
import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_ROOT / "data"


def load_chart_data(nrows=None):
    """Load the chart dataset or available sample."""
    sample_path = DATA_DIR / "charts_cleaned_sample.csv"
    full_path = DATA_DIR / "charts.csv"

    csv_path = sample_path if sample_path.exists() else full_path

    if not csv_path.exists():
        raise FileNotFoundError(
            "No chart CSV found. Add charts_cleaned_sample.csv "
            "to data/ or place the full charts.csv locally."
        )

    return pd.read_csv(csv_path, nrows=nrows)


def load_track_metadata():
    """Load saved Spotify track metadata."""
    metadata_path = DATA_DIR / "spotify_track_metadata_sample.csv"

    if not metadata_path.exists():
        raise FileNotFoundError(
            f"Metadata file not found: {metadata_path}"
        )

    return pd.read_csv(metadata_path)
