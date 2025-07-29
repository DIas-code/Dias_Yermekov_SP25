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

CREATE OR REPLACE PROCEDURE bl_cl.p_load_dim_dates()
LANGUAGE plpgsql
AS $$
DECLARE
    new_date DATE := DATE '2024-01-22';
    end_date DATE := current_date;
BEGIN
    WHILE new_date <= end_date LOOP
        INSERT INTO bl_dm.dim_dates (
            date_id,
            year,
            quarter,
            month,
            month_name,
            day,
            day_of_week,
            day_name
        )
        VALUES (
            new_date,
            EXTRACT(YEAR FROM new_date)::INT,
            EXTRACT(QUARTER FROM current_date)::INT,
            EXTRACT(MONTH FROM current_date)::INT,
            TO_CHAR(new_date, 'Month'),
            EXTRACT(DAY FROM new_date)::INT,
            EXTRACT(ISODOW FROM new_date)::INT, -- 1 (Mon) to 7 (Sun)
            TO_CHAR(new_date, 'Day')
        )
        ON CONFLICT (date_id) DO NOTHING;


        new_date := new_date + INTERVAL '1 day';
    END LOOP;

END;
$$;

CALL bl_cl.p_load_dim_dates();
