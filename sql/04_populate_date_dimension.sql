
-- =========================================================
-- MUSIC DISCOVERY & ARTIST VISIBILITY DASHBOARD
-- File: sql/04_populate_date_dimension.sql
-- MySQL 8.0.43
-- Purpose: Populate dates and link chart observations
-- =========================================================

USE music_discovery;

-- Populate one calendar record per distinct chart date.
INSERT INTO dim_dates (
    date_id,
    full_date,
    year_num,
    month_num,
    month_name,
    quarter_num,
    day_num,
    day_name,
    week_num,
    is_weekend
)
SELECT DISTINCT
    YEAR(chart_date) * 10000
        + MONTH(chart_date) * 100
        + DAY(chart_date) AS date_id,
    chart_date AS full_date,
    YEAR(chart_date) AS year_num,
    MONTH(chart_date) AS month_num,
    MONTHNAME(chart_date) AS month_name,
    QUARTER(chart_date) AS quarter_num,
    DAYOFMONTH(chart_date) AS day_num,
    DAYNAME(chart_date) AS day_name,
    WEEK(chart_date, 3) AS week_num,
    CASE
        WHEN DAYOFWEEK(chart_date) IN (1, 7) THEN TRUE
        ELSE FALSE
    END AS is_weekend
FROM daily_track_charts
WHERE chart_date IS NOT NULL
ON DUPLICATE KEY UPDATE
    year_num = VALUES(year_num),
    month_num = VALUES(month_num),
    month_name = VALUES(month_name),
    quarter_num = VALUES(quarter_num),
    day_num = VALUES(day_num),
    day_name = VALUES(day_name),
    week_num = VALUES(week_num),
    is_weekend = VALUES(is_weekend);

-- Link chart observations to their calendar records.
UPDATE daily_track_charts c
JOIN dim_dates d
    ON d.full_date = c.chart_date
SET c.date_id = d.date_id
WHERE c.date_id IS NULL
   OR c.date_id <> d.date_id;

-- Verify date dimension and chart coverage.
SELECT
    (SELECT COUNT(*) FROM dim_dates) AS calendar_dates,
    COUNT(*) AS chart_records,
    COALESCE(SUM(c.date_id IS NULL), 0) AS charts_missing_date_id,
    COALESCE(SUM(d.date_id IS NULL), 0) AS charts_without_date_dimension
FROM daily_track_charts c
LEFT JOIN dim_dates d
    ON d.date_id = c.date_id
   AND d.full_date = c.chart_date;
