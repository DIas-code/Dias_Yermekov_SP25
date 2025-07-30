--DIM_DISCOUNTS
CREATE OR REPLACE PROCEDURE bl_cl.p_load_dim_discounts()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_total_rows INTEGER := 0;
BEGIN
    -- count all rows from source
    SELECT COUNT(*) INTO v_total_rows FROM bl_3nf.ce_discounts;

    -- insert new rows; on conflict do nothing
    INSERT INTO bl_dm.dim_discounts (
        discount_id,
        discount_percentage,
        discount_date,
        source_id,
        source_system,
        source_entity,
        ta_insert_dt,
        ta_update_dt
    )
    SELECT
        nextval('bl_dm.seq_dim_discount'),
        discount_percentage,
        discount_date,
        source_id,
        source_system,
        source_entity,
        CURRENT_DATE,
        CURRENT_DATE
    FROM bl_3nf.ce_discounts d
    ON CONFLICT (source_id, source_system, source_entity)
    DO NOTHING;

    -- row count for inserted rows
    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- skipped rows = total rows - inserted rows
    v_rows_skipped := v_total_rows - v_rows_inserted;

    -- log event
    CALL bl_cl.p_log_event(
        'p_load_dim_discounts',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'p_load_dim_discounts',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;
