"""Run the local Spotify data preparation workflow."""

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

    # Load chart data and saved metadata
    sample = load_chart_data(nrows=1000)
    track_metadata = load_track_metadata()

    print("\nData sources loaded")
    print("Spotify Charts rows:", len(sample))
    print("Saved metadata records:", len(track_metadata))

    # Clean chart data
    clean_df = clean_chart_data(sample)

    # Validate both datasets
    validate_chart_data(clean_df)
    validate_track_metadata(track_metadata)

    # Export cleaned chart sample
    output_path = DATA_DIR / "charts_cleaned_sample.csv"
    clean_df.to_csv(output_path, index=False)

    print("\nCleaned chart sample saved to:", output_path)
    print("Exported rows:", len(clean_df))
    print("\nLocal workflow completed successfully.")


if __name__ == "__main__":
    main()
