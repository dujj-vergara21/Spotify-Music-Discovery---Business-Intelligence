"""Clean Spotify Charts data."""

from urllib.parse import urlparse

import pandas as pd


def clean_chart_data(df):
    """Convert data types and remove invalid or duplicate chart rows."""
    clean_df = df.copy()

    if "track_id" not in clean_df.columns:
        if "url" not in clean_df.columns:
            raise ValueError("Dataset must contain 'track_id' or 'url'.")

        clean_df["track_id"] = clean_df["url"].apply(
            lambda url: urlparse(str(url)).path.rstrip("/").split("/")[-1]
            if pd.notna(url) and urlparse(str(url)).path.rstrip("/")
            else None
        )

    clean_df["date"] = pd.to_datetime(
        clean_df["date"], errors="coerce"
    )
    clean_df["rank"] = pd.to_numeric(
        clean_df["rank"], errors="coerce"
    )

    if "stream(s)" in clean_df.columns:
        clean_df["stream(s)"] = pd.to_numeric(
            clean_df["stream(s)"]
            .astype("string")
            .str.replace(",", "", regex=False),
            errors="coerce",
        )

    rows_before = len(clean_df)

    clean_df = clean_df.dropna(
        subset=["date", "rank", "track_id"]
    )

    clean_df = clean_df.drop_duplicates(
        subset=["date", "region", "chart", "rank", "track_id"]
    )

    print("Rows before cleaning:", rows_before)
    print("Rows after cleaning:", len(clean_df))
    print("Rows removed:", rows_before - len(clean_df))

    return clean_df
