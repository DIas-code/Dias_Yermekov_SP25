--DIM_EMPLOYEES
CREATE OR REPLACE PROCEDURE bl_cl.p_load_dim_employees()
LANGUAGE plpgsql
AS $$
DECLARE
    v_row RECORD;
    v_rows_inserted INTEGER := 0;
    v_rows_updated INTEGER := 0;
BEGIN
    -- loop through all source rows
    FOR v_row IN
        SELECT
            emp_src_id,
            first_name,
            last_name,
            dob,
            personal_id,
            phone_number,
            source_system,
            source_entity
        FROM bl_3nf.ce_employees
    LOOP
        -- insert new rows; on conflict do update
        INSERT INTO bl_dm.dim_employees (
            emp_id,
            emp_src_id,
            first_name,
            last_name,
            dob_dt,
            personal_id,
            phone_number,
            source_system,
            source_entity,
            ta_insert_dt,
            ta_update_dt
        )
        VALUES (
            nextval('bl_dm.seq_dim_employees'),
            v_row.emp_src_id,
            v_row.first_name,
            v_row.last_name,
            v_row.dob,
            v_row.personal_id,
            v_row.phone_number,
            v_row.source_system,
            v_row.source_entity,
            CURRENT_DATE,
            CURRENT_DATE
        )
        ON CONFLICT (personal_id, source_system, source_entity) DO UPDATE
        SET
            first_name     = EXCLUDED.first_name,
            last_name      = EXCLUDED.last_name,
            dob_dt         = EXCLUDED.dob_dt,
            phone_number   = EXCLUDED.phone_number,
            emp_src_id     = EXCLUDED.emp_src_id,
            ta_update_dt   = CURRENT_DATE;

        -- check if updated or inserted
        IF EXISTS (
            SELECT 1
            FROM bl_dm.dim_employees
            WHERE personal_id    = v_row.personal_id
              AND source_system  = v_row.source_system
              AND source_entity  = v_row.source_entity
              AND ta_update_dt   = CURRENT_DATE
              AND ta_insert_dt  <> CURRENT_DATE
        ) THEN
            v_rows_updated := v_rows_updated + 1;
        ELSE
            v_rows_inserted := v_rows_inserted + 1;
        END IF;
    END LOOP;

    -- log event
    CALL bl_cl.p_log_event(
        'p_load_dim_employees',
        v_rows_inserted,
        v_rows_updated,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Updated: ' || v_rows_updated
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'p_load_dim_employees',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;
