
CREATE OR REPLACE PROCEDURE bl_cl.p_load_ce_card_informations()
LANGUAGE plpgsql
AS
$$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_total INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_tmp INTEGER := 0;
BEGIN
    -- Count distinct card infos from card_orders
    SELECT COUNT(DISTINCT COALESCE(bank_of_card, 'n.a.') || '|' || COALESCE(card_type, 'n.a.'))
    INTO v_rows_total
    FROM sa_card_orders.src_card_orders
    WHERE card_type IS NOT NULL and bank_of_card IS NOT NULL;

    -- Insert unique card info from card_orders only
	INSERT INTO bl_3nf.ce_card_informations (
	    card_information_id,
	    card_information_src_id,
	    bank_id,
	    card_type_id,
	    source_system,
	    source_entity,
	    ta_insert_dt,
	    ta_update_dt
	)
	SELECT 
	    NEXTVAL('bl_3nf.seq_ce_card_information'),
	    COALESCE(sc.bank_of_card, 'n.a.') || '|' || COALESCE(sc.card_type, 'n.a.'),
	    COALESCE(b.bank_id, -1),
	    COALESCE(ct.card_type_id, -1),
	    'card_orders',
	    'src_card_orders',
	    CURRENT_DATE,
	    CURRENT_DATE
	FROM (
	    SELECT DISTINCT bank_of_card, card_type
	    FROM sa_card_orders.src_card_orders
	    WHERE bank_of_card IS NOT NULL AND card_type IS NOT NULL
	) sc
	LEFT JOIN bl_3nf.ce_banks b
	    ON b.bank_src_id = sc.bank_of_card
	   AND b.source_system = 'card_orders'
	   AND b.source_entity = 'src_card_orders'
	LEFT JOIN bl_3nf.ce_card_types ct
	    ON ct.card_type_src_id = sc.card_type
	   AND ct.source_system = 'card_orders'
	   AND ct.source_entity = 'src_card_orders'
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM bl_3nf.ce_card_informations ci
	    WHERE ci.card_information_src_id = COALESCE(sc.bank_of_card, 'n.a.') || '|' || COALESCE(sc.card_type, 'n.a.')
	      AND ci.source_system = 'card_orders'
	      AND ci.source_entity = 'src_card_orders'
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
