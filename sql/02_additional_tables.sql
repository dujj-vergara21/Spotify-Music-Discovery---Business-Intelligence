-- =========================================================
-- MUSIC DISCOVERY & ARTIST VISIBILITY DASHBOARD
-- File: sql/02_additional_tables.sql
-- Creates tables 11-20
-- =========================================================

USE music_discovery;

-- 11. COUNTRIES
CREATE TABLE IF NOT EXISTS countries (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_code VARCHAR(10) NOT NULL UNIQUE,
    country_name VARCHAR(100) NOT NULL
);

-- 12. CALENDAR DATES
CREATE TABLE IF NOT EXISTS dim_dates (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year_num SMALLINT NOT NULL,
    month_num TINYINT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter_num TINYINT NOT NULL
);

-- 13. GENRES
CREATE TABLE IF NOT EXISTS genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(100) NOT NULL UNIQUE
);

-- 14. ARTIST-GENRE MAPPING
CREATE TABLE IF NOT EXISTS artist_genres (
    artist_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (artist_id, genre_id),
    CONSTRAINT fk_artist_genres_artist
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id),
    CONSTRAINT fk_artist_genres_genre
        FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

-- 15. TRACK-GENRE MAPPING
CREATE TABLE IF NOT EXISTS track_genres (
    track_id VARCHAR(50) NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (track_id, genre_id),
    CONSTRAINT fk_track_genres_track
        FOREIGN KEY (track_id) REFERENCES tracks(track_id),
    CONSTRAINT fk_track_genres_genre
        FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);

-- 16. TRACK POPULARITY SNAPSHOTS
CREATE TABLE IF NOT EXISTS track_popularity (
    popularity_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    track_id VARCHAR(50) NOT NULL,
    snapshot_date DATE NOT NULL,
    popularity_score INT,
    CONSTRAINT fk_popularity_track
        FOREIGN KEY (track_id) REFERENCES tracks(track_id),
    UNIQUE KEY uq_track_snapshot (track_id, snapshot_date)
);

-- 17. DATA QUALITY CHECKS
CREATE TABLE IF NOT EXISTS data_quality_checks (
    check_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    batch_id BIGINT,
    check_name VARCHAR(150) NOT NULL,
    records_checked BIGINT DEFAULT 0,
    records_failed BIGINT DEFAULT 0,
    checked_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_quality_batch
        FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
);

-- 18. IMPORT ERRORS
CREATE TABLE IF NOT EXISTS import_errors (
    error_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    batch_id BIGINT,
    source_row_number BIGINT,
    error_message TEXT,
    logged_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_errors_batch
        FOREIGN KEY (batch_id) REFERENCES import_batches(batch_id)
);

-- 19. DASHBOARD REFRESH LOGS
CREATE TABLE IF NOT EXISTS refresh_logs (
    refresh_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    started_at DATETIME NOT NULL,
    completed_at DATETIME,
    refresh_status VARCHAR(50),
    rows_processed BIGINT DEFAULT 0,
    notes TEXT
);

-- 20. ARTIST DISCOVERY METRICS
CREATE TABLE IF NOT EXISTS artist_discovery_metrics (
    metric_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    artist_id INT NOT NULL,
    metric_date DATE NOT NULL,
    chart_appearances BIGINT DEFAULT 0,
    unique_tracks INT DEFAULT 0,
    total_streams BIGINT DEFAULT 0,
    CONSTRAINT fk_discovery_artist
        FOREIGN KEY (artist_id) REFERENCES artists(artist_id),
    UNIQUE KEY uq_artist_metric_date (artist_id, metric_date)
);

-- VERIFY TABLE COUNT
SELECT COUNT(*) AS total_tables
FROM information_schema.tables
WHERE table_schema = 'music_discovery'
  AND table_type = 'BASE TABLE';
