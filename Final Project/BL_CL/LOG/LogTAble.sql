CREATE TABLE IF NOT EXISTS bl_cl.etl_log (
    log_id SERIAL PRIMARY KEY,
    log_dt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,-- date of log
	procedure_name TEXT NOT NULL,
    rows_inserted INTEGER DEFAULT 0,
    rows_affected_skipped INTEGER DEFAULT 0,-- skipped rows (e.g. null keys)
	status TEXT NOT NULL,
    message TEXT-- optional description or error
);


