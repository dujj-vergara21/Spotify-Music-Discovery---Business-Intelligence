# Music Discovery & Artist Visibility Dashboard

## Overview

This Business Intelligence (BI) project explores music popularity, chart movements, and artist visibility using historical Spotify chart data and supplementary music metadata.

The project aims to help listeners discover music beyond mainstream hits while providing insights into how tracks and artists perform across regions and over time.

## Project Objectives

- Analyze historical music chart rankings and stream counts.
- Compare chart performance across regions and dates.
- Examine chart movements and track performance.
- Enrich chart records with supplementary artist and recording metadata.
- Design a relational database in MySQL.
- Develop analytical measures and interactive visualizations.
- Generate evidence-based recommendations for music discovery and artist visibility.

## Data Sources

### Source 1: Spotify Charts — Kaggle CSV

**Purpose:** Historical chart performance analysis.

**Fields:** Track title, artist, rank, date, region, chart type, trend, and stream count where available.

**Dataset:** [Spotify Charts on Kaggle](https://www.kaggle.com/datasets/dhruvildave/spotify-charts)

The full dataset is shared through the project Google Drive. Small sample files are available in `data/`.

[Access the full dataset](https://drive.google.com/file/d/1khFo6BXLkgggcwEch1lvVxl_okNkAxxP/view?usp=drive_link)

The full dataset contains approximately 26 million original observations. The actual number retained after cleaning and import must be measured and documented.

### Source 2: MusicBrainz API

**Purpose:** Supplementary artist and recording metadata.

**Official documentation:** [MusicBrainz API](https://musicbrainz.org/doc/MusicBrainz_API)

**Implementation files:**
- `src/musicbrainz_api.py`
- `src/fetch_musicbrainz_metadata.py`

The metadata workflow searches for artists and exports candidate metadata. Candidate matches are marked `REVIEW_REQUIRED` and must be verified before they are integrated into the main analytical dataset.

MusicBrainz search results do not automatically prove that a candidate is the same artist as the chart record. Ambiguous and unmatched results must be retained for review rather than silently accepted.

Use a descriptive User-Agent and respect the API's request-rate limit and applicable data licensing terms.

### Spotify Web API Status

The Spotify Web API client is retained as prototype code in `src/spotify_api.py`. It is **not currently part of the approved analytical data pipeline**. Any future use must be reviewed against the applicable Spotify Developer Policy and access requirements.

## Data Integration Rules

- Preserve the original chart fields.
- Keep source identifiers and source URLs when available.
- Prefer verified identifiers for record matching.
- Treat name-based matches as candidates until reviewed.
- Flag ambiguous and unmatched records.
- Document missing values, transformations, and validation results.
- Follow the source dataset's license and API terms.

## Technology Stack

- **Programming:** Python
- **Data processing:** pandas
- **API requests:** requests
- **Database:** MySQL
- **Database management:** MySQL Workbench
- **Version control and collaboration:** GitHub
- **Dashboard platform:** Power BI or Tableau, pending instructor confirmation

## Project Structure

```text
Spotify-Music-Discovery---Business-Intelligence/
├── .github/
│   └── workflows/
│       └── python-check.yml
├── data/
│   ├── charts_cleaned_sample.csv
│   ├── spotify_track_metadata_sample.csv
│   └── README.md
├── notebooks/
│   └── spotify_music_discovery.ipynb
├── src/
│   ├── spotify_api.py
│   ├── musicbrainz_api.py
│   ├── fetch_musicbrainz_metadata.py
│   ├── import_chart_sample.py
│   ├── mysql_loader.py
│   ├── data_loader.py
│   ├── data_cleaning.py
│   ├── data_validation.py
│   └── main.py
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_additional_tables.sql
│   ├── 03_data_validation.sql
│   └── 04_populate_date_dimension.sql
├── .env.example
├── .gitignore
├── requirements.txt
└── README.md
```

This is the intended structure. Confirm the current repository contents before relying on every listed file being present.

## Data Access and Collaboration

### Sample Datasets

Small sample files are available in `data/`:

- `charts_cleaned_sample.csv` — sample chart observations used for development and validation.
- `spotify_track_metadata_sample.csv` — sample track metadata.

The importer expects a compatible chart CSV with the required columns. Check the actual file names and column names before running scripts.

### Full Dataset

The full Spotify Charts CSV is stored in Google Drive because of its size. It is not intended to be committed to GitHub.

Team members should use the same dataset version for consistent results. Full-scale processing requires appropriate memory management, bulk loading, and row-count validation.

## Python Environment

Install dependencies:

```bash
pip install -r requirements.txt
```

For MusicBrainz requests, run the API client or metadata export from the repository root using the Python module commands documented in the corresponding source files.

The MusicBrainz metadata CSV is generated by running the export script; it does not appear in GitHub merely because the script is committed.

## Database Design

The MySQL schema is designed with 20 tables covering:

- Artists, albums, and tracks
- Chart regions, chart types, trends, and daily chart facts
- Data sources, import batches, and track-source mappings
- Countries, calendar dates, and genres
- Track popularity snapshots
- Data quality checks and import errors
- Dashboard refresh logs and artist discovery metrics

The SQL scripts define the intended schema. Actual table creation, constraints, date-dimension population, and full-data loading must be verified against the target database.

### SQL Script Order

1. `sql/01_database_setup.sql` — create the database and first 10 tables.
2. `sql/02_additional_tables.sql` — create the additional tables and date relationship.
3. `sql/04_populate_date_dimension.sql` — populate calendar dates and backfill chart date keys after the schema is installed.
4. `sql/03_data_validation.sql` — validate the resulting schema and data.

Do not execute setup scripts against an existing database without first checking whether the required tables, columns, and constraints are already present.

## Data Preparation Workflow

The current Python workflow is designed to:

1. Load chart sample data.
2. Load available sample metadata.
3. Extract track IDs from source URLs when necessary.
4. Convert dates, ranks, and stream counts to appropriate data types.
5. Remove invalid and duplicate chart observations.
6. Validate chart data and metadata.
7. Export the cleaned sample for further analysis.

The workflow has been tested against sample data in GitHub Actions. This does not establish that the full CSV has been imported into MySQL or that the entire database workflow has been tested end to end.

## Current Progress

### Completed or prepared

- GitHub repository and initial project structure.
- Python dependency file and GitHub Actions workflow.
- Sample chart data and sample metadata.
- Python modules for data loading, cleaning, and validation.
- Prototype Spotify API client.
- MusicBrainz API client and metadata-export script.
- SQL scripts defining a 20-table schema.
- Initial local MySQL sample import of 1,000 chart records and 599 tracks.

### Remaining verification and deliverables

- Verify that the current SQL scripts execute together successfully.
- Populate and validate the date dimension.
- Verify MusicBrainz API responses and review candidate matches.
- Import the full chart dataset and document actual row counts.
- Validate the integrated data sources and the database relationships.
- Create the ERD and data dictionary.
- Develop at least eight analytical measures, including at least three non-trivial calculations.
- Build at least three interactive dashboard pages with eight or more visualizations.
- Prepare the project report and three evidence-backed recommendations.
- Confirm the instructor-approved publishing platform and publish the dashboard.

## Security and Usage

- Never commit API secrets, passwords, or access tokens to GitHub.
- Keep local `.env` files excluded from version control.
- Share the full dataset through the designated storage location rather than committing it to GitHub.
- Follow applicable data licenses, API terms, and course requirements.

## Project Status

**Current stage:** Data-source integration and database implementation.

The project has a working sample-data foundation and a proposed 20-table MySQL schema. Full-data loading, live metadata validation, dashboard development, and final deliverables remain to be completed.
