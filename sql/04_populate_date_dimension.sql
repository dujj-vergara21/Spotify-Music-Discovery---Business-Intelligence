-- =========================================================
-- MUSIC DISCOVERY & ARTIST VISIBILITY DASHBOARD
-- File: sql/04_populate_date_dimension.sql
-- Purpose: Populate dates from existing chart observations
-- =========================================================

USE music_discovery;

-- Insert one calendar record for each distinct chart date.
INSERT IGNORE INTO dim_dates (
    date_id,
    full_date,
    year_num,
    month_num,
    month_name,
    quarter_num
)
SELECT DISTINCT
    YEAR(chart_date) * 10000
        + MONTH(chart_date) * 100
        + DAY(chart_date) AS date_id,
    chart_date AS full_date,
    YEAR(chart_date) AS year_num,
    MONTH(chart_date) AS month_num,
    MONTHNAME(chart_date) AS month_name,
    QUARTER(chart_date) AS quarter_num
FROM daily_track_charts
WHERE chart_date IS NOT NULL;

-- Link existing chart observations to their calendar records.
UPDATE daily_track_charts c
JOIN dim_dates d
    ON d.full_date = c.chart_date
SET c.date_id = d.date_id
WHERE c.date_id IS NULL;

-- Verify date dimension and chart coverage.
SELECT
    (SELECT COUNT(*) FROM dim_dates) AS calendar_dates,
    COUNT(*) AS chart_records,
    SUM(c.date_id IS NULL) AS charts_missing_date_id
FROM daily_track_charts c;
