
CREATE OR REPLACE PROCEDURE bl_cl.p_load_ce_banks()
LANGUAGE plpgsql
AS
$$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_total INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_tmp INTEGER := 0;
BEGIN
    -- Count distinct banks from card_orders
    SELECT COUNT(DISTINCT bank_of_card)
    INTO v_rows_total
    FROM sa_card_orders.src_card_orders
    WHERE bank_of_card IS NOT NULL;

    -- Insert unique banks from card_orders only
	INSERT INTO bl_3nf.ce_banks (
	    bank_id,
	    bank_src_id,
	    bank_name,
	    source_system,
	    source_entity,
	    ta_insert_dt,
	    ta_update_dt
	)
	SELECT 
	    NEXTVAL('bl_3nf.seq_ce_banks'),
	    COALESCE(bank_of_card, 'n.a.'),
	    COALESCE(bank_of_card, 'n.a.'),
	    'card_orders',
	    'src_card_orders',
	    CURRENT_DATE,
	    CURRENT_DATE
	FROM (
	    SELECT DISTINCT bank_of_card
	    FROM sa_card_orders.src_card_orders
	    WHERE bank_of_card IS NOT NULL
	) sc
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM bl_3nf.ce_banks b
	    WHERE b.bank_src_id = sc.bank_of_card
	      AND b.source_system = 'card_orders'
	      AND b.source_entity = 'src_card_orders'
	);

    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;
    v_rows_skipped := v_rows_total - v_rows_inserted;

    -- Logging
    CALL bl_cl.p_log_event(
        'load_ce_banks',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'load_ce_banks',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;
