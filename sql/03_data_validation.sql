-- =========================================================
-- MUSIC DISCOVERY & ARTIST VISIBILITY DASHBOARD
-- File: sql/03_data_validation.sql
-- =========================================================

USE music_discovery;

-- 1. TOTAL TABLE COUNT (EXPECTED: 20)
SELECT COUNT(*) AS total_tables
FROM information_schema.tables
WHERE table_schema = 'music_discovery'
  AND table_type = 'BASE TABLE';

-- 2. LIST ALL TABLES
SHOW TABLES;

-- 3. PRIMARY AND FOREIGN KEY RELATIONSHIPS
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

-- 4. ROW COUNTS FOR CORE TABLES
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
SELECT 'chart_trends', COUNT(*) FROM chart_trends
UNION ALL
SELECT 'data_sources', COUNT(*) FROM data_sources;

-- 5. CHART RECORDS WITH MISSING TRACK IDS
SELECT COUNT(*) AS charts_with_missing_track_id
FROM daily_track_charts
WHERE track_id IS NULL OR track_id = '';

-- 6. CHART DATE RANGE AND TOTAL RECORDS
SELECT
    MIN(chart_date) AS earliest_date,
    MAX(chart_date) AS latest_date,
    COUNT(*) AS total_chart_records
FROM daily_track_charts;

-- 7. DUPLICATE CHART OBSERVATIONS
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

-- 8. CHART RECORDS BY REGION
SELECT
    r.region_name,
    COUNT(*) AS chart_records,
    SUM(c.streams) AS total_streams
FROM daily_track_charts c
JOIN chart_regions r
    ON c.region_id = r.region_id
GROUP BY r.region_id, r.region_name
ORDER BY total_streams DESC;

-- 9. DAILY CHART ACTIVITY
SELECT
    chart_date,
    COUNT(*) AS chart_records,
    SUM(streams) AS total_streams
FROM daily_track_charts
GROUP BY chart_date
ORDER BY chart_date;

-- 10. TOP TRACKS IN THE IMPORTED DATA
SELECT
    t.track_name,
    SUM(c.streams) AS total_streams,
    COUNT(*) AS chart_appearances,
    MIN(c.chart_rank) AS best_rank
FROM daily_track_charts c
JOIN tracks t
    ON c.track_id = t.track_id
GROUP BY t.track_id, t.track_name
ORDER BY total_streams DESC
LIMIT 20;
