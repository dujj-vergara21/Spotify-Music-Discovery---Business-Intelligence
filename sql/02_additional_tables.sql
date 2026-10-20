
-- ============================================================
-- MUSIC DISCOVERY & ARTIST VISIBILITY DASHBOARD
-- File: sql/02_additional_tables.sql
-- Database: music_discovery
-- MySQL: 8.0.43 compatible
-- Creates tables 11-20 and connects the date dimension
-- Requires sql/01_database_setup.sql first
-- ============================================================

USE music_discovery;

-- 11. COUNTRIES
CREATE TABLE IF NOT EXISTS countries (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_code VARCHAR(10) NOT NULL UNIQUE,
    country_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. DATE DIMENSION
CREATE TABLE IF NOT EXISTS dim_dates (
    date_id INT PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,
    year_num SMALLINT NOT NULL,
    month_num TINYINT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    quarter_num TINYINT NOT NULL,
    day_num TINYINT NULL,
    day_name VARCHAR(20) NULL,
    week_num TINYINT NULL,
    is_weekend BOOLEAN NULL
);

-- 13. GENRES
CREATE TABLE IF NOT EXISTS genres (
    genre_id INT AUTO_INCREMENT PRIMARY KEY,
    genre_name VARCHAR(100) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 14. ARTIST-GENRE BRIDGE
CREATE TABLE IF NOT EXISTS artist_genres (
    artist_id INT NOT NULL,
    genre_id INT NOT NULL,
    source_name VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (artist_id, genre_id),

    CONSTRAINT fk_artist_genres_artist
        FOREIGN KEY (artist_id)
        REFERENCES artists (artist_id),

    CONSTRAINT fk_artist_genres_genre
        FOREIGN KEY (genre_id)
        REFERENCES genres (genre_id)
);

-- 15. TRACK-GENRE BRIDGE
CREATE TABLE IF NOT EXISTS track_genres (
    track_id VARCHAR(50) NOT NULL,
    genre_id INT NOT NULL,
    source_name VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (track_id, genre_id),

    CONSTRAINT fk_track_genres_track
        FOREIGN KEY (track_id)
        REFERENCES tracks (track_id),

    CONSTRAINT fk_track_genres_genre
        FOREIGN KEY (genre_id)
        REFERENCES genres (genre_id)
);

-- 16. TRACK POPULARITY SNAPSHOTS
CREATE TABLE IF NOT EXISTS track_popularity (
    popularity_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    track_id VARCHAR(50) NOT NULL,
    source_id INT NULL,
    snapshot_date DATE NOT NULL,
    popularity_score DECIMAL(6,2) NULL,
    popularity_source VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_track_popularity_snapshot
        (track_id, snapshot_date, popularity_source),

    CONSTRAINT fk_track_popularity_track
        FOREIGN KEY (track_id)
        REFERENCES tracks (track_id),

    CONSTRAINT fk_track_popularity_source
        FOREIGN KEY (source_id)
        REFERENCES data_sources (source_id)
);

-- 17. DATA QUALITY CHECKS
CREATE TABLE IF NOT EXISTS data_quality_checks (
    check_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    batch_id BIGINT NULL,
    table_name VARCHAR(100) NOT NULL,
    check_name VARCHAR(150) NOT NULL,
    check_status VARCHAR(30) NOT NULL,
    records_checked BIGINT DEFAULT 0,
    records_failed BIGINT DEFAULT 0,
    check_details TEXT NULL,
    checked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_quality_checks_batch
        FOREIGN KEY (batch_id)
        REFERENCES import_batches (batch_id)
);

-- 18. IMPORT ERRORS
CREATE TABLE IF NOT EXISTS import_errors (
    error_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    batch_id BIGINT NULL,
    source_name VARCHAR(150) NULL,
    source_row_number BIGINT NULL,
    table_name VARCHAR(100) NULL,
    error_type VARCHAR(100) NOT NULL,
    error_message TEXT NOT NULL,
    raw_record JSON NULL,
    logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_import_errors_batch
        FOREIGN KEY (batch_id)
        REFERENCES import_batches (batch_id)
);

-- 19. REFRESH LOGS
CREATE TABLE IF NOT EXISTS refresh_logs (
    refresh_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    batch_id BIGINT NULL,
    process_name VARCHAR(150) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NULL,
    refresh_status VARCHAR(30) NOT NULL,
    records_processed BIGINT DEFAULT 0,
    error_message TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_refresh_logs_batch
        FOREIGN KEY (batch_id)
        REFERENCES import_batches (batch_id)
);

-- 20. ARTIST DISCOVERY METRICS
CREATE TABLE IF NOT EXISTS artist_discovery_metrics (
    metric_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    artist_id INT NOT NULL,
    metric_date DATE NOT NULL,
    total_chart_entries INT DEFAULT 0,
    distinct_tracks INT DEFAULT 0,
    distinct_regions INT DEFAULT 0,
    average_chart_rank DECIMAL(10,2) NULL,
    best_chart_rank INT NULL,
    total_streams BIGINT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_artist_discovery_metric
        (artist_id, metric_date),

    CONSTRAINT fk_discovery_metrics_artist
        FOREIGN KEY (artist_id)
        REFERENCES artists (artist_id)
);

-- ADD date_id TO DAILY TRACK CHARTS IF MISSING
SET @date_col_exists = (
    SELECT COUNT(*)
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'daily_track_charts'
      AND COLUMN_NAME = 'date_id'
);

SET @date_col_sql = IF(
    @date_col_exists = 0,
    'ALTER TABLE daily_track_charts ADD COLUMN date_id INT NULL',
    'SELECT ''date_id column already exists'' AS status'
);

PREPARE date_col_stmt FROM @date_col_sql;
EXECUTE date_col_stmt;
DEALLOCATE PREPARE date_col_stmt;

-- ADD DATE FOREIGN KEY IF MISSING
SET @date_fk_exists = (
    SELECT COUNT(*)
    FROM information_schema.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'daily_track_charts'
      AND CONSTRAINT_NAME = 'fk_daily_charts_dates'
);

SET @date_fk_sql = IF(
    @date_fk_exists = 0,
    'ALTER TABLE daily_track_charts
       ADD CONSTRAINT fk_daily_charts_dates
       FOREIGN KEY (date_id)
       REFERENCES dim_dates (date_id)',
    'SELECT ''Date foreign key already exists'' AS status'
);

PREPARE date_fk_stmt FROM @date_fk_sql;
EXECUTE date_fk_stmt;
DEALLOCATE PREPARE date_fk_stmt;

-- VERIFY TABLE COUNT
SELECT
    COUNT(*) AS total_tables,
    CASE
        WHEN COUNT(*) >= 20 THEN '20-TABLE TARGET REACHED'
        ELSE 'MORE TABLES REQUIRED'
    END AS verification_status
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_TYPE = 'BASE TABLE';

-- LIST ALL TABLES
SELECT TABLE_NAME
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;
