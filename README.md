# Music Discovery & Artist Visibility Dashboard

## Overview

This Business Intelligence (BI) project explores music popularity, chart movements, and artist visibility using historical Spotify chart data and track metadata.

The project aims to help listeners discover music beyond mainstream hits while providing insights into how tracks and artists perform across regions and over time. Through data preparation, database design, analytics, and interactive dashboards, the project will examine music trends and identify opportunities to improve the visibility of artists and tracks.

## Project Objectives

- Analyze historical music chart rankings and stream counts.
- Compare music popularity across regions and dates.
- Examine chart movements, trends, and track performance.
- Enrich chart records with Spotify track metadata.
- Design a structured relational database in MySQL.
- Develop analytical measures and interactive visualizations.
- Generate evidence-based insights and recommendations for music discovery and artist visibility.


## Data Sources

### Source 1: Spotify Charts — Kaggle CSV
- **Purpose:** Historical chart performance analysis.
- **Fields:** Track title, artist, rank, date, region, chart type, trend, and stream counts.
- **Access:** Full CSV shared through the project Google Drive; sample CSV files are in `data/`.
- **Use:** Main source for chart rankings and historical stream observations.

### Source 2: MusicBrainz API
- **Purpose:** Enrich chart records with music metadata.
- **Fields:** MusicBrainz recording ID, recording title, artist name, release date, and available artist information.
- **Access:** https://musicbrainz.org/doc/MusicBrainz_API
- **Implementation:** `src/musicbrainz_api.py`
- **Usage requirements:** Use a descriptive User-Agent and respect API rate limits.
- **Matching:** Match chart records to metadata using reliable identifiers where available; otherwise treat name-based matches as tentative.

### Excluded from the approved pipeline
- Spotify Web API is not currently part of the approved data pipeline. Its use must be reviewed against applicable developer policies before adoption.

## Technology Stack

- **Programming:** Python
- **Data processing:** pandas
- **API integration:** Requests and Spotify Web API
- **Database:** MySQL
- **Database management:** MySQL Workbench
- **Version control and collaboration:** GitHub
- **Dashboard platform:** Power BI or Tableau (to be finalized)

## Project Structure

```text
Spotify-Music-Discovery---Business-Intelligence/
├── .github/
│   └── workflows/
│       └── python-check.yml
├── data/
│   ├── charts.csv
│   ├── spotify_track_metadata_sample.csv
│   └── charts_cleaned_sample.csv
├── notebooks/
│   └── spotify_music_discovery.ipynb
├── src/
│   ├── spotify_api.py
│   ├── mysql_loader.py
│   ├── data_loader.py
│   ├── data_cleaning.py
│   ├── data_validation.py
│   └── main.py
├── sql/
│   ├── 01_database_setup.sql
│   ├── 02_additional_tables.sql
│   └── 03_data_validation.sql
├── .gitignore
├── requirements.txt
└── README.md
```

*Note: The structure above describes the intended project organization. File availability and database implementation should be verified against the current repository.*

## Data Access and Collaboration

### Sample Datasets

Small sample datasets for testing are available in the [`data/`](data/) folder:

- [`charts_cleaned_sample.csv`](data/charts_cleaned_sample.csv) — cleaned Spotify chart records.
- [`spotify_track_metadata_sample.csv`](data/spotify_track_metadata_sample.csv) — sample Spotify track metadata.

### Full Dataset

The complete Spotify Charts dataset is stored in Google Drive because of its large file size.

[Access the full dataset](https://drive.google.com/file/d/1khFo6BXLkgggcwEch1lvVxl_okNkAxxP/view?usp=drive_link)

Replace the placeholder with the shared Google Drive link. Team members should use the same dataset version for consistent results.

## Data Preparation Workflow

The current Python workflow is designed to:

1. Load a sample of the Spotify Charts dataset.
2. Load previously saved Spotify track metadata.
3. Extract Spotify track IDs from track URLs when necessary.
4. Convert dates, rankings, and stream counts to appropriate data types.
5. Remove invalid and duplicate chart records.
6. Validate chart data and track metadata.
7. Export the cleaned chart sample for subsequent analysis.

The current workflow processes a sample of the chart dataset. Full-scale processing will require additional validation, efficient data loading, and chunk-based processing to accommodate the dataset's size.

## Database Design

The project uses MySQL for structured data storage and analytical preparation.

The planned database design will include at least 20 tables, subject to the final approved schema. The design will organize chart facts, track and artist information, dates, regions, chart types, metadata sources, data quality checks, and other supporting entities.

Planned database work includes:

- Defining primary and foreign keys.
- Designing fact and dimension tables.
- Establishing relationships between entities.
- Loading and validating cleaned data.
- Documenting the schema through an entity-relationship diagram (ERD).

## Current Progress

### Completed

- [x] Created the GitHub repository and initial project structure.
- [x] Prepared the Python requirements file and GitHub Actions syntax-check workflow.
- [x] Loaded and inspected a sample of Spotify Charts data.
- [x] Extracted Spotify track IDs from track URLs in the prototype workflow.
- [x] Retrieved and saved a sample of Spotify track metadata.
- [x] Created Python modules for data loading, cleaning, and validation.
- [x] Prepared a main script to connect the data preparation steps.

### In Progress

- [ ] Verify the latest versions of all Python modules and run the workflow locally.
- [ ] Validate the shared dataset and establish a reproducible data preparation process.
- [ ] Finalize the MySQL schema containing at least 20 tables.
- [ ] Load and validate data in MySQL.
- [ ] Develop at least eight analytical measures, including non-trivial calculations.
- [ ] Build at least three interactive dashboard pages.
- [ ] Prepare the ERD, data dictionary, project report, and evidence-based recommendations.
- [ ] Publish the dashboard using the instructor-approved platform.

## Data Security and Usage

- Do not commit Spotify API client secrets, access tokens, passwords, or other credentials to GitHub.
- Store credentials in environment variables or an appropriate local secrets file excluded from version control.
- Keep large datasets and generated files in the designated shared storage location when appropriate.
- Follow the applicable dataset terms, Spotify developer policies, and course requirements when accessing, processing, storing, and sharing data.

## Project Status

**Current stage:** Prototype development and data integration testing.

The project is progressing from initial data exploration toward reproducible data preparation, relational database implementation, and interactive Business Intelligence dashboard development.


## Spotify API Setup

The project uses the Spotify Web API to retrieve available track metadata.

### Setup

1. Create or access an eligible Spotify Developer app.
2. Copy `.env.example` to a local file named `.env`.
3. Replace the placeholder values with your own authorized app credentials.
4. Keep `.env` private. Never commit API secrets to GitHub.
5. Install dependencies using `pip install -r requirements.txt`.

### Example

Run the API client with:

`python -m src.spotify_api`

The API client searches for tracks and returns available track, artist, album, release-date, and Spotify URL fields.

API access depends on Spotify's developer eligibility, permissions, and current policies.
