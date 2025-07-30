
CREATE OR REPLACE PROCEDURE bl_cl.p_load_ce_card_types()
LANGUAGE plpgsql
AS
$$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_total INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_tmp INTEGER := 0;
BEGIN
    -- Count distinct card types from card_orders
    SELECT COUNT(DISTINCT card_type)
    INTO v_rows_total
    FROM sa_card_orders.src_card_orders
    WHERE card_type IS NOT NULL;

    -- Insert unique types from card_orders only
	INSERT INTO bl_3nf.ce_card_types (
	    card_type_id,
	    card_type_src_id,
	    card_type_name,
	    source_system,
	    source_entity,
	    ta_insert_dt,
	    ta_update_dt
	)
	SELECT 
	    NEXTVAL('bl_3nf.seq_ce_card_types'),
	    COALESCE(card_type, 'n.a.'),
	    COALESCE(card_type, 'n.a.'),
	    'card_orders',
	    'src_card_orders',
	    CURRENT_DATE,
	    CURRENT_DATE
	FROM (
	    SELECT DISTINCT card_type
	    FROM sa_card_orders.src_card_orders
	    WHERE card_type IS NOT NULL
	) sc
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM bl_3nf.ce_card_types ct
	    WHERE ct.card_type_src_id = sc.card_type
	      AND ct.source_system = 'card_orders'
	      AND ct.source_entity = 'src_card_orders'
	);

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;
    v_rows_skipped := v_rows_total - v_rows_inserted;

    -- Logging
    CALL bl_cl.p_log_event(
        'load_ce_card_types',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'load_ce_card_types',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;
