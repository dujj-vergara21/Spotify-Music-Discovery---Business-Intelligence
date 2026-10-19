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

### 1. Spotify Charts Dataset

Historical Spotify chart records containing information such as track titles, artists, rankings, dates, regions, chart types, trends, Spotify URLs, and stream counts.

- Source: [Spotify Charts Dataset on Kaggle](https://www.kaggle.com/datasets/dhruvildave/spotify-charts)
- Format: CSV
- Use: Historical chart analysis, regional comparisons, trend analysis, and track performance measurement.

### 2. Spotify Web API

Track metadata retrieved using Spotify track IDs, including track names, artist information, album names, release dates, and other available track attributes.

- Source: [Spotify Web API Documentation](https://developer.spotify.com/documentation/web-api)
- Access method: Python and HTTP requests
- Use: Enriching chart records with additional track metadata.

**Source requirement note:** Although the project uses a Kaggle-hosted dataset and the Spotify Web API, both are associated with Spotify data. Whether they satisfy the course requirement for two distinct data sources will be confirmed with the instructor.

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

The full Spotify Charts dataset is large and is not stored directly in this GitHub repository.

The shared dataset will be made available through Google Drive:

**[Access the shared dataset][(https://drive.google.com/file/d/1khFo6BXLkgggcwEch1lvVxl_okNkAxxP/view?usp=sharing)]**

Replace the placeholder above with the actual shared Google Drive link.

Generated CSV files and other large data files may be excluded from Git version control. Team members should follow the shared data-access instructions and use the same dataset version when running the project.

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
