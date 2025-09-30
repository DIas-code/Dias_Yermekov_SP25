-- DIM_CARD_INFORMATIONS
CREATE OR REPLACE PROCEDURE bl_cl.p_load_dim_card_informations()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_total_rows INTEGER := 0;
BEGIN
    -- count all rows from source
    SELECT COUNT(*) INTO v_total_rows FROM bl_3nf.ce_card_informations;

    -- insert new rows; on conflict do nothing
    INSERT INTO bl_dm.dim_card_informations (
        card_information_id,
        card_information_src_id,
        card_bank_id,
        card_bank_name,
        card_type_id,
        card_type_name,
        source_system,
        source_entity,
        ta_insert_dt,
        ta_update_dt
    )
    SELECT
        nextval('bl_dm.seq_dim_card_information'),
        ci.card_information_src_id,
        b.bank_id,
        b.bank_name,
        ct.card_type_id,
        ct.card_type_name,
        ci.source_system,
        ci.source_entity,
        CURRENT_DATE,
        CURRENT_DATE
    FROM bl_3nf.ce_card_informations ci
    LEFT JOIN bl_3nf.ce_banks b
        ON b.bank_id = ci.bank_id
    LEFT JOIN bl_3nf.ce_card_types ct
        ON ct.card_type_id = ci.card_type_id
    ON CONFLICT (card_information_src_id, source_system, source_entity)
    DO NOTHING;

    -- row count for inserted rows
    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- skipped rows = total rows - inserted rows
    v_rows_skipped := v_total_rows - v_rows_inserted;

    -- log event
    CALL bl_cl.p_log_event(
        'p_load_dim_card_informations',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'p_load_dim_card_informations',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;
