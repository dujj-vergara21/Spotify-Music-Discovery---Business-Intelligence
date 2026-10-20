
-- =========================================================
-- MUSIC DISCOVERY & ARTIST VISIBILITY DASHBOARD
-- File: sql/03_data_validation.sql
-- Database: music_discovery
-- MySQL: 8.0.43
-- Purpose: Validate schema, relationships, data quality,
--          date dimension, and chart analytics
-- Requires:
--   01_database_setup.sql
--   02_additional_tables.sql
--   04_populate_date_dimension.sql
-- =========================================================

USE music_discovery;

-- =========================================================
-- 1. TOTAL TABLE COUNT
-- Expected minimum: 20 base tables
-- =========================================================

SELECT
    COUNT(*) AS total_tables,
    CASE
        WHEN COUNT(*) >= 20 THEN 'PASS'
        ELSE 'CHECK REQUIRED'
    END AS validation_status
FROM information_schema.tables
WHERE table_schema = 'music_discovery'
  AND table_type = 'BASE TABLE';

-- =========================================================
-- 2. LIST ALL TABLES
-- =========================================================

SHOW TABLES;

-- =========================================================
-- 3. PRIMARY AND FOREIGN KEY RELATIONSHIPS
-- =========================================================

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'music_discovery'
  AND (
      CONSTRAINT_NAME = 'PRIMARY'
      OR REFERENCED_TABLE_NAME IS NOT NULL
  )
ORDER BY TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME;

-- =========================================================
-- 4. ROW COUNTS FOR ALL 20 TABLES
-- Empty tables are valid at schema-creation stage.
-- =========================================================

SELECT 'artists' AS table_name, COUNT(*) AS total_rows
FROM artists
UNION ALL
SELECT 'albums', COUNT(*) FROM albums
UNION ALL
SELECT 'tracks', COUNT(*) FROM tracks
UNION ALL
SELECT 'chart_regions', COUNT(*) FROM chart_regions
UNION ALL
SELECT 'chart_types', COUNT(*) FROM chart_types
UNION ALL
SELECT 'chart_trends', COUNT(*) FROM chart_trends
UNION ALL
SELECT 'daily_track_charts', COUNT(*) FROM daily_track_charts
UNION ALL
SELECT 'data_sources', COUNT(*) FROM data_sources
UNION ALL
SELECT 'import_batches', COUNT(*) FROM import_batches
UNION ALL
SELECT 'track_source_mapping', COUNT(*) FROM track_source_mapping
UNION ALL
SELECT 'countries', COUNT(*) FROM countries
UNION ALL
SELECT 'dim_dates', COUNT(*) FROM dim_dates
UNION ALL
SELECT 'genres', COUNT(*) FROM genres
UNION ALL
SELECT 'artist_genres', COUNT(*) FROM artist_genres
UNION ALL
SELECT 'track_genres', COUNT(*) FROM track_genres
UNION ALL
SELECT 'track_popularity', COUNT(*) FROM track_popularity
UNION ALL
SELECT 'data_quality_checks', COUNT(*) FROM data_quality_checks
UNION ALL
SELECT 'import_errors', COUNT(*) FROM import_errors
UNION ALL
SELECT 'refresh_logs', COUNT(*) FROM refresh_logs
UNION ALL
SELECT 'artist_discovery_metrics', COUNT(*) FROM artist_discovery_metrics
ORDER BY table_name;

-- =========================================================
-- 5. CHART RECORDS WITH MISSING TRACK IDS
-- =========================================================

SELECT
    COUNT(*) AS charts_with_missing_track_id
FROM daily_track_charts
WHERE track_id IS NULL
   OR TRIM(track_id) = '';

-- =========================================================
-- 6. CHART DATE RANGE AND TOTAL RECORDS
-- =========================================================

SELECT
    MIN(chart_date) AS earliest_date,
    MAX(chart_date) AS latest_date,
    COUNT(*) AS total_chart_records,
    COUNT(DISTINCT chart_date) AS distinct_chart_dates
FROM daily_track_charts;

-- =========================================================
-- 7. DUPLICATE CHART OBSERVATIONS
-- The unique key should prevent these duplicates.
-- =========================================================

SELECT
    track_id,
    chart_date,
    region_id,
    chart_type_id,
    chart_rank,
    COUNT(*) AS duplicate_count
FROM daily_track_charts
GROUP BY
    track_id,
    chart_date,
    region_id,
    chart_type_id,
    chart_rank
HAVING COUNT(*) > 1
LIMIT 20;

-- =========================================================
-- 8. DATE DIMENSION COVERAGE
-- Checks missing date IDs and unmatched calendar records.
-- =========================================================

SELECT
    COUNT(*) AS chart_records,
    COALESCE(SUM(c.date_id IS NULL), 0) AS missing_date_id,
    COALESCE(SUM(d.date_id IS NULL), 0)
        AS unmatched_date_dimension,
    MIN(c.chart_date) AS earliest_chart_date,
    MAX(c.chart_date) AS latest_chart_date
FROM daily_track_charts c
LEFT JOIN dim_dates d
    ON d.date_id = c.date_id
   AND d.full_date = c.chart_date;

-- =========================================================
-- 9. CHART RECORDS BY REGION
-- =========================================================

SELECT
    r.region_code,
    r.region_name,
    COUNT(*) AS chart_records,
    COALESCE(SUM(c.streams), 0) AS total_streams
FROM daily_track_charts c
JOIN chart_regions r
    ON c.region_id = r.region_id
GROUP BY
    r.region_id,
    r.region_code,
    r.region_name
ORDER BY total_streams DESC;

-- =========================================================
-- 10. DAILY CHART ACTIVITY
-- =========================================================

SELECT
    chart_date,
    COUNT(*) AS chart_records,
    COALESCE(SUM(streams), 0) AS total_streams
FROM daily_track_charts
GROUP BY chart_date
ORDER BY chart_date;

-- =========================================================
-- 11. TOP TRACKS IN THE IMPORTED DATA
-- Rankings are based on the sum of recorded chart streams.
-- =========================================================

SELECT
    t.track_name,
    SUM(c.streams) AS total_streams,
    COUNT(*) AS chart_appearances,
    MIN(c.chart_rank) AS best_rank
FROM daily_track_charts c
JOIN tracks t
    ON c.track_id = t.track_id
GROUP BY
    t.track_id,
    t.track_name
ORDER BY total_streams DESC
LIMIT 20;

-- =========================================================
-- 12. CHART DATES MISSING FROM THE DATE DIMENSION
-- =========================================================

SELECT DISTINCT
    c.chart_date
FROM daily_track_charts c
LEFT JOIN dim_dates d
    ON d.full_date = c.chart_date
WHERE d.date_id IS NULL
ORDER BY c.chart_date
LIMIT 20;

-- =========================================================
-- 13. ARTIST DISCOVERY METRICS COVERAGE
-- =========================================================

SELECT
    COUNT(*) AS metric_rows,
    COUNT(DISTINCT artist_id) AS artists_with_metrics,
    MIN(metric_date) AS first_metric_date,
    MAX(metric_date) AS last_metric_date
FROM artist_discovery_metrics;

-- =========================================================
-- 14. ORPHANED TRACK REFERENCES
-- Should return zero if foreign keys are enforced.
-- =========================================================

SELECT COUNT(*) AS orphaned_chart_track_references
FROM daily_track_charts c
LEFT JOIN tracks t
    ON c.track_id = t.track_id
WHERE t.track_id IS NULL;

-- =========================================================
-- 15. REQUIRED REFERENCE DATA
-- =========================================================

SELECT
    (SELECT COUNT(*) FROM chart_types) AS chart_type_count,
    (SELECT COUNT(*) FROM chart_trends) AS chart_trend_count,
    (SELECT COUNT(*) FROM data_sources) AS data_source_count;

-- =========================================================
-- 16. DATE DIMENSION ATTRIBUTE COMPLETENESS
-- =========================================================

SELECT
    COUNT(*) AS calendar_rows,
    COALESCE(SUM(year_num IS NULL), 0) AS missing_year,
    COALESCE(SUM(month_num IS NULL), 0) AS missing_month,
    COALESCE(SUM(day_num IS NULL), 0) AS missing_day,
    COALESCE(SUM(day_name IS NULL), 0) AS missing_day_name,
    COALESCE(SUM(week_num IS NULL), 0) AS missing_week_number,
    COALESCE(SUM(is_weekend IS NULL), 0) AS missing_weekend_flag
FROM dim_dates;

-- =========================================================
-- END OF VALIDATION
-- Review all result sets before declaring the database ready.
-- =========================================================
