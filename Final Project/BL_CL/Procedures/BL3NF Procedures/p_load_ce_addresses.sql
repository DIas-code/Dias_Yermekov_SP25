CREATE OR REPLACE PROCEDURE bl_cl.p_load_ce_addresses()
LANGUAGE plpgsql
AS 
$$
DECLARE 
	v_rows_inserted INTEGER := 0; 
	v_rows_total INTEGER := 0;
	v_rows_skipped INTEGER := 0;
	v_tmp INTEGER := 0;
BEGIN 
	-- Count distinct addresses from card_orders
	SELECT COUNT(DISTINCT point_address|| '||' || point_country)
	INTO v_tmp
	FROM sa_cash_orders.src_cash_orders
	WHERE point_address IS NOT NULL AND point_city IS NOT NULL;
	v_rows_total := v_rows_total + v_tmp;

	-- Insert adres from src_cash_orders
	INSERT INTO bl_3nf.ce_addresses (
	    address_id,
	    address_src_id,
	    address,
	    city_id,
	    source_system,
	    source_entity,
	    ta_insert_dt,
	    ta_update_dt
	)
	SELECT 
	    NEXTVAL('bl_3nf.seq_ce_address'),
	    COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.'),
	    COALESCE(sc.point_address, 'n.a.'),
	    COALESCE(ci.city_id, -1),
	    'cash_orders',
	    'src_cash_orders',
	    CURRENT_DATE,
	    CURRENT_DATE
	FROM (
	    SELECT DISTINCT point_address, point_city, point_country
	    FROM sa_cash_orders.src_cash_orders
	    WHERE point_address IS NOT NULL AND point_city IS NOT NULL
	) sc
	LEFT JOIN bl_3nf.ce_cities ci
	    ON ci.city_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.')
	   AND ci.source_system = 'cash_orders'
	   AND ci.source_entity = 'src_cash_orders'
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM bl_3nf.ce_addresses a
	    WHERE a.address_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.')
	      AND a.source_system = 'cash_orders'
	      AND a.source_entity = 'src_cash_orders'
	);
	
	GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;
	v_rows_skipped := v_rows_total - v_rows_inserted;
	
	-- Count from card_orders
	SELECT count( DISTINCT point_address|| '||' || point_country)
	INTO v_tmp
	FROM sa_card_orders.src_card_orders
	WHERE point_address IS NOT NULL AND point_city IS NOT NULL;
	v_rows_total := v_rows_total + v_tmp;
	
-- Insert addreses from src_card_orders
	INSERT INTO bl_3nf.ce_addresses (
	    address_id,
	    address_src_id,
	    address,
	    city_id,
	    source_system,
	    source_entity,
	    ta_insert_dt,
	    ta_update_dt
	)
	SELECT 
	    NEXTVAL('bl_3nf.seq_ce_address'),
	    COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.'),
	    COALESCE(sc.point_address, 'n.a.'),
	    COALESCE(ci.city_id, -1),
	    'card_orders',
	    'src_card_orders',
	    CURRENT_DATE,
	    CURRENT_DATE
	FROM (
	    SELECT DISTINCT point_address, point_city, point_country
	    FROM sa_card_orders.src_card_orders
	    WHERE point_address IS NOT NULL AND point_city IS NOT NULL
	) sc
	LEFT JOIN bl_3nf.ce_cities ci
	    ON ci.city_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.')
	   AND ci.source_system = 'card_orders'
	   AND ci.source_entity = 'src_card_orders'
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM bl_3nf.ce_addresses a
	    WHERE a.address_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.')
	      AND a.source_system = 'card_orders'
	      AND a.source_entity = 'src_card_orders'
	);
	
	GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;
	
-- Calculate skipped
    v_rows_skipped := v_rows_total - v_rows_inserted;

    -- Log success
    CALL bl_cl.p_log_event(
        'load_ce_addresses',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );
EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'load_ce_addresses',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;	
	