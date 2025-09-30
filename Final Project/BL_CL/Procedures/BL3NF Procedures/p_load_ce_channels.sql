CREATE OR REPLACE PROCEDURE bl_cl.p_load_ce_channels()
LANGUAGE plpgsql
AS
$$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_total INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_tmp INTEGER := 0;
BEGIN
    -- Count distinct channels from card_orders
    SELECT COUNT(DISTINCT channel_name)
    INTO v_rows_total
    FROM sa_card_orders.src_card_orders
    WHERE channel_name IS NOT NULL;

    -- Insert unique channels from card_orders only
    INSERT INTO bl_3nf.ce_channels (
        channel_id,
        channel_src_id,
        channel_name,
        channel_desc,
        source_system,
        source_entity,
        ta_insert_dt,
        ta_update_dt
    )
    SELECT 
        NEXTVAL('bl_3nf.seq_ce_channels'),
        channel_name,
        COALESCE(channel_name, 'n.a.'),
        COALESCE(channel_desc, 'n.a.'),
        'card_orders',
        'src_card_orders',
        CURRENT_DATE,
        CURRENT_DATE
    FROM (
        SELECT DISTINCT channel_name, channel_desc
        FROM sa_card_orders.src_card_orders
        WHERE channel_name IS NOT NULL
    ) sc
    WHERE NOT EXISTS (
        SELECT 1
        FROM bl_3nf.ce_channels c
        WHERE c.channel_src_id = sc.channel_name
    );

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;
    v_rows_skipped := v_rows_total - v_rows_inserted;

    -- Logging
    CALL bl_cl.p_log_event(
        'load_ce_channels',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'load_ce_channels',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;
