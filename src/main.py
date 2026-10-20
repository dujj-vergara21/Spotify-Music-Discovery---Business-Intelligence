"""Run the Spotify data preparation workflow."""

from src.data_loader import (
    DATA_DIR,
    load_chart_data,
    load_track_metadata,
)
from src.data_cleaning import clean_chart_data
from src.data_validation import (
    validate_chart_data,
    validate_track_metadata,
)


def main():
    print("MUSIC DISCOVERY & ARTIST VISIBILITY PROJECT")
    print("=" * 48)

    charts = load_chart_data()
    metadata = load_track_metadata()

    print("\nData sources loaded")
    print("Chart records:", len(charts))
    print("Track metadata records:", len(metadata))

    clean_df = clean_chart_data(charts)

    validate_chart_data(clean_df)
    validate_track_metadata(metadata)

    output_path = DATA_DIR / "charts_cleaned_sample.csv"
    clean_df.to_csv(output_path, index=False)

    print("\nCleaned chart sample saved:", output_path)
    print("Cleaned rows:", len(clean_df))
    print("\nWorkflow completed successfully.")


if __name__ == "__main__":
    main()
