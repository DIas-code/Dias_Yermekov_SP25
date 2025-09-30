--DIM_CUSTOMERS
CREATE OR REPLACE PROCEDURE bl_cl.p_load_dim_customers()
LANGUAGE plpgsql
AS $$
DECLARE
    v_customer        RECORD;
    v_rows_inserted   INTEGER := 0;
    v_rows_updated    INTEGER := 0;
    v_sql             TEXT;
BEGIN
    FOR v_customer IN
        SELECT
            customer_src_id,
            first_name,
            last_name,
            phone_number,
            source_system,
            source_entity
        FROM bl_3nf.ce_customers
    LOOP
        -- Dynamic upsert using format + USING
        v_sql := format($f$
            INSERT INTO bl_dm.dim_customers (
                customer_id,
                customer_src_id,
                first_name,
                last_name,
                phone_number,
                source_system,
                source_entity,
                ta_insert_dt,
                ta_update_dt
            )
            VALUES (
                nextval('bl_dm.seq_dim_customers'),
                $1, $2, $3, $4, $5, $6,
                CURRENT_DATE, CURRENT_DATE
            )
            ON CONFLICT (customer_src_id, source_system, source_entity) DO UPDATE
            SET
                first_name   = EXCLUDED.first_name,
                last_name    = EXCLUDED.last_name,
                ta_update_dt = CURRENT_DATE
        $f$);

        EXECUTE v_sql
        USING 
            v_customer.customer_src_id,
            v_customer.first_name,
            v_customer.last_name,
            v_customer.phone_number,
            v_customer.source_system,
            v_customer.source_entity;

        -- check if record was updated
        IF EXISTS (
            SELECT 1
            FROM bl_dm.dim_customers
            WHERE customer_src_id = v_customer.customer_src_id
              AND source_system = v_customer.source_system
              AND source_entity = v_customer.source_entity
              AND ta_update_dt = CURRENT_DATE
              AND ta_insert_dt <> CURRENT_DATE
        ) THEN
            v_rows_updated := v_rows_updated + 1;
        ELSE
            v_rows_inserted := v_rows_inserted + 1;
        END IF;
    END LOOP;

    -- log
    CALL bl_cl.p_log_event(
        'p_load_dim_customers',
        v_rows_inserted,
        v_rows_updated,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Updated: ' || v_rows_updated
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'p_load_dim_customers',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;
