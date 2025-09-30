--procedure to insert data into log table from load procedures
CREATE OR REPLACE PROCEDURE bl_cl.p_log_event(
    p_procedure_name TEXT,
    p_rows_inserted INTEGER,
    p_rows_affected INTEGER,
    p_status TEXT,
    p_message TEXT
)
LANGUAGE plpgsql
AS
$$
BEGIN
    INSERT
	INTO
	bl_cl.etl_log (
        procedure_name,
		rows_inserted,
		rows_affected_skipped,
		status,
		message
    )
VALUES (
        p_procedure_name,
        p_rows_inserted,
        p_rows_affected,
        p_status,
        p_message
    );
END;

$$;