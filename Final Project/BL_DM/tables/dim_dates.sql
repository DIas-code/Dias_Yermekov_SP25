CREATE SCHEMA IF NOT EXISTS BL_DM;

-- DIM_DATES
CREATE TABLE IF NOT EXISTS bl_dm.dim_dates (
    date_id DATE PRIMARY KEY,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day INT NOT NULL,
    day_of_week INT NOT NULL,
    day_name VARCHAR(20) NOT NULL
);