"""Validate chart data and track metadata."""

import pandas as pd


def validate_chart_data(df):
    """Summarize data types, missing values, and duplicates."""
    report = pd.DataFrame({
        "data_type": df.dtypes.astype(str),
        "missing_values": df.isna().sum(),
        "unique_values": df.nunique(),
    })

    print("Chart data validation")
    display_report = report
    print(display_report.to_string())

    print("\nDuplicate rows:", df.duplicated().sum())

    if "date" in df.columns:
        print("Invalid dates:", df["date"].isna().sum())

    if "track_id" in df.columns:
        print("Missing track IDs:", df["track_id"].isna().sum())

    if "date" in df.columns and not df.empty:
        print("Date range:", df["date"].min(), "to", df["date"].max())

    return report


def validate_track_metadata(df):
    """Check metadata completeness and duplicate track IDs."""
    print("\nTrack metadata validation")
    print("Metadata records:", len(df))

    if "track_id" in df.columns:
        print("Unique track IDs:", df["track_id"].nunique())
        print("Missing track IDs:", df["track_id"].isna().sum())

    print("Duplicate rows:", df.duplicated().sum())

    return df.isna().sum()
