
USE music_discovery;

-- 1. Count the database tables
SELECT COUNT(*) AS total_tables
FROM information_schema.tables
WHERE table_schema = 'music_discovery'
  AND table_type = 'BASE TABLE';

-- 2. List all tables
SHOW TABLES;

-- 3. Check primary and foreign key relationships
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
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- 4. Check row counts in the main tables
SELECT 'artists' AS table_name, COUNT(*) AS total_rows
FROM artists
UNION ALL
SELECT 'albums', COUNT(*) FROM albums
UNION ALL
SELECT 'tracks', COUNT(*) FROM tracks
UNION ALL
SELECT 'daily_track_charts', COUNT(*) FROM daily_track_charts
UNION ALL
SELECT 'chart_regions', COUNT(*) FROM chart_regions
UNION ALL
SELECT 'chart_types', COUNT(*) FROM chart_types
UNION ALL
SELECT 'chart_trends', COUNT(*) FROM chart_trends;

-- 5. Check for missing track IDs in chart records
SELECT COUNT(*) AS charts_with_missing_track_id
FROM daily_track_charts
WHERE track_id IS NULL OR track_id = '';

-- 6. Check chart date range
SELECT
    MIN(chart_date) AS earliest_date,
    MAX(chart_date) AS latest_date,
    COUNT(*) AS total_chart_records
FROM daily_track_charts;

-- 7. Check duplicate track/date/region/chart combinations
SELECT
    track_id,
    chart_date,
    region_id,
    chart_type_id,
    COUNT(*) AS duplicate_count
FROM daily_track_charts
GROUP BY track_id, chart_date, region_id, chart_type_id
HAVING COUNT(*) > 1
LIMIT 20;
