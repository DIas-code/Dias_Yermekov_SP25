CREATE OR REPLACE PROCEDURE bl_cl.p_load_ce_points()
LANGUAGE plpgsql
AS $$
DECLARE 
	v_rows_inserted INTEGER := 0;
    v_rows_total INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_tmp INTEGER := 0;
BEGIN
	--count distinct points from cash source
	SELECT count(DISTINCT point_name)
	INTO v_tmp 
	FROM sa_cash_orders.src_cash_orders
	WHERE point_name IS NOT NULL;
    v_rows_total := v_rows_total + v_tmp;
	
	INSERT INTO bl_3nf.ce_points (
	    point_id,
	    point_src_id,
	    point_name,
	    address_id,
	    source_system,
	    source_entity,
	    ta_insert_dt,
	    ta_update_dt
	)
	SELECT 
	    NEXTVAL('bl_3nf.seq_ce_points'),
	    COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.') || '|' || COALESCE(sc.point_name, 'n.a.'),
	    COALESCE(sc.point_name, 'n.a.'),
	    COALESCE(a.address_id, -1),
	    'cash_orders',
	    'src_cash_orders',
	    CURRENT_DATE,
	    CURRENT_DATE
	FROM (
	    SELECT DISTINCT point_name, point_address, point_city, point_country
	    FROM sa_cash_orders.src_cash_orders
	    WHERE point_name IS NOT NULL
	) sc
	LEFT JOIN bl_3nf.ce_addresses a
	    ON a.address_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.')
	   AND a.source_system = 'cash_orders'
	   AND a.source_entity = 'src_cash_orders'
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM bl_3nf.ce_points p
	    WHERE p.point_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.') || '|' || COALESCE(sc.point_name, 'n.a.')
	      AND p.source_system = 'cash_orders'
	      AND p.source_entity = 'src_cash_orders'
	);
	
	GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;
	
	--count distinct points from card source
	SELECT count(DISTINCT point_name)
	INTO v_tmp 
	FROM sa_card_orders.src_card_orders
	WHERE point_name IS NOT NULL;
    v_rows_total := v_rows_total + v_tmp;
	
	--from card src
	INSERT INTO bl_3nf.ce_points (
	    point_id,
	    point_src_id,
	    point_name,
	    address_id,
	    source_system,
	    source_entity,
	    ta_insert_dt,
	    ta_update_dt
	)
	SELECT 
	    NEXTVAL('bl_3nf.seq_ce_points'),
	    COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.') || '|' || COALESCE(sc.point_name, 'n.a.'),
	    COALESCE(sc.point_name, 'n.a.'),
	    COALESCE(a.address_id, -1),
	    'card_orders',
	    'src_card_orders',
	    CURRENT_DATE,
	    CURRENT_DATE
	FROM (
	    SELECT DISTINCT point_name, point_address, point_city, point_country
	    FROM sa_card_orders.src_card_orders
	    WHERE point_name IS NOT NULL
	) sc
	LEFT JOIN bl_3nf.ce_addresses a
	    ON a.address_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.')
	   AND a.source_system = 'card_orders'
	   AND a.source_entity = 'src_card_orders'
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM bl_3nf.ce_points p
	    WHERE p.point_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.') || '|' || COALESCE(sc.point_name, 'n.a.')
	      AND p.source_system = 'card_orders'
	      AND p.source_entity = 'src_card_orders'
	);
	
	GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;

    -- Calculate skipped
    v_rows_skipped := v_rows_total - v_rows_inserted;

    -- Log success
    CALL bl_cl.p_log_event(
        'load_ce_points',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );
EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'load_ce_points',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
	
END;
$$;
