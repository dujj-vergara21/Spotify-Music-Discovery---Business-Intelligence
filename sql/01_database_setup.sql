-- =========================================================
-- MUSIC DISCOVERY & ARTIST VISIBILITY DASHBOARD
-- Database: MySQL
-- File: sql/01_database_setup.sql
-- Creates tables 1-10
-- =========================================================

CREATE DATABASE IF NOT EXISTS music_discovery;
USE music_discovery;

-- 1. ARTISTS
CREATE TABLE IF NOT EXISTS artists (
    artist_id INT AUTO_INCREMENT PRIMARY KEY,
    artist_name VARCHAR(255) NOT NULL,
    artist_type VARCHAR(50),
    country VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_artist_name (artist_name)
);

-- 2. ALBUMS
CREATE TABLE IF NOT EXISTS albums (
    album_id INT AUTO_INCREMENT PRIMARY KEY,
    album_name VARCHAR(255) NOT NULL,
    release_date DATE,
    album_type VARCHAR(50),
    artist_id INT,
    CONSTRAINT fk_albums_artists
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

-- 3. TRACKS
CREATE TABLE IF NOT EXISTS tracks (
    track_id VARCHAR(50) PRIMARY KEY,
    track_name VARCHAR(255) NOT NULL,
    album_id INT,
    release_date DATE,
    artist_id INT,
    CONSTRAINT fk_tracks_albums
        FOREIGN KEY (album_id) REFERENCES albums(album_id),
    CONSTRAINT fk_tracks_artists
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id)
);

-- 4. CHART REGIONS
CREATE TABLE IF NOT EXISTS chart_regions (
    region_id INT AUTO_INCREMENT PRIMARY KEY,
    region_code VARCHAR(50) NOT NULL UNIQUE,
    region_name VARCHAR(150)
);

-- 5. CHART TYPES
CREATE TABLE IF NOT EXISTS chart_types (
    chart_type_id INT AUTO_INCREMENT PRIMARY KEY,
    chart_name VARCHAR(50) NOT NULL UNIQUE,
    chart_description VARCHAR(255)
);

-- 6. CHART TRENDS
CREATE TABLE IF NOT EXISTS chart_trends (
    trend_id INT AUTO_INCREMENT PRIMARY KEY,
    trend_name VARCHAR(50) NOT NULL UNIQUE
);

-- 7. DAILY TRACK CHARTS (FACT TABLE)
CREATE TABLE IF NOT EXISTS daily_track_charts (
    chart_record_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    track_id VARCHAR(50) NOT NULL,
    chart_date DATE NOT NULL,
    chart_rank INT NOT NULL,
    region_id INT NOT NULL,
    chart_type_id INT NOT NULL,
    trend_id INT,
    streams BIGINT,
    source_track_url VARCHAR(500),

    CONSTRAINT fk_daily_charts_tracks
        FOREIGN KEY (track_id) REFERENCES tracks(track_id),
    CONSTRAINT fk_daily_charts_regions
        FOREIGN KEY (region_id) REFERENCES chart_regions(region_id),
    CONSTRAINT fk_daily_charts_types
        FOREIGN KEY (chart_type_id) REFERENCES chart_types(chart_type_id),
    CONSTRAINT fk_daily_charts_trends
        FOREIGN KEY (trend_id) REFERENCES chart_trends(trend_id),

    INDEX idx_chart_date (chart_date),
    INDEX idx_track_date (track_id, chart_date),
    INDEX idx_region_date (region_id, chart_date),

    -- Prevent duplicate entries for the same track,
    -- date, rank, region, and chart type.
    UNIQUE KEY uq_daily_chart_entry
        (track_id, chart_date, chart_rank, region_id, chart_type_id)
);

-- 8. DATA SOURCES
CREATE TABLE IF NOT EXISTS data_sources (
    source_id INT AUTO_INCREMENT PRIMARY KEY,
    source_name VARCHAR(150) NOT NULL,
    source_type VARCHAR(50),
    source_url VARCHAR(500),
    retrieved_at DATETIME,
    source_notes TEXT
);

-- 9. IMPORT BATCHES
CREATE TABLE IF NOT EXISTS import_batches (
    batch_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    source_id INT,
    file_name VARCHAR(255),
    imported_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    rows_processed BIGINT DEFAULT 0,
    batch_status VARCHAR(50),
    notes TEXT,
    CONSTRAINT fk_import_batches_sources
        FOREIGN KEY (source_id) REFERENCES data_sources(source_id)
);

-- 10. TRACK SOURCE MAPPING
CREATE TABLE IF NOT EXISTS track_source_mapping (
    mapping_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    track_id VARCHAR(50) NOT NULL,
    source_id INT NOT NULL,
    source_track_identifier VARCHAR(255),
    source_track_url VARCHAR(500),

    CONSTRAINT fk_track_mapping_tracks
        FOREIGN KEY (track_id) REFERENCES tracks(track_id),
    CONSTRAINT fk_track_mapping_sources
        FOREIGN KEY (source_id) REFERENCES data_sources(source_id),

    UNIQUE KEY uq_source_track
        (source_id, source_track_identifier)
);

-- SEED REFERENCE DATA
INSERT IGNORE INTO chart_types (chart_name, chart_description)
VALUES
    ('top200', 'Daily Top 200 chart'),
    ('viral50', 'Daily Viral 50 chart');

INSERT IGNORE INTO chart_trends (trend_name)
VALUES
    ('MOVE_UP'),
    ('MOVE_DOWN'),
    ('SAME_POSITION'),
    ('NEW_ENTRY'),
    ('UNKNOWN');

-- Register the Kaggle source only if absent.
INSERT INTO data_sources
    (source_name, source_type, source_url, source_notes)
SELECT
    'Spotify Charts Kaggle Dataset',
    'CSV',
    'https://www.kaggle.com/datasets/dhruvildave/spotify-charts',
    'Daily Spotify chart observations'
WHERE NOT EXISTS (
    SELECT 1
    FROM data_sources
    WHERE source_name = 'Spotify Charts Kaggle Dataset'
);

-- Register MusicBrainz as the selected metadata source.
INSERT INTO data_sources
    (source_name, source_type, source_url, source_notes)
SELECT
    'MusicBrainz API',
    'API',
    'https://musicbrainz.org/doc/MusicBrainz_API',
    'Artist and recording metadata; candidate matches require review'
WHERE NOT EXISTS (
    SELECT 1
    FROM data_sources
    WHERE source_name = 'MusicBrainz API'
);

-- BASIC VALIDATION
SHOW TABLES;

DESCRIBE artists;
DESCRIBE albums;
DESCRIBE tracks;
DESCRIBE daily_track_charts;

-- Show foreign-key relationships.
SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'music_discovery'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, COLUMN_NAME;
