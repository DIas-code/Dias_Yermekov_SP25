--Countries 3rd row, cities 140, addresses 268, pints 397

CREATE OR REPLACE FUNCTION bl_cl.f_get_countries(
    p_source TEXT,
    p_entity TEXT,
    p_table TEXT
)
RETURNS TABLE (
    country_src_id TEXT,
    country_name TEXT,
    source_system TEXT,
    source_entity TEXT
) AS
$$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := format(
        'SELECT 
            point_country::TEXT AS country_src_id,
            COALESCE(point_country, ''n.a.'')::TEXT AS country_name,
            %L::TEXT AS source_system,
            %L::TEXT AS source_entity
         FROM (
             SELECT DISTINCT point_country
             FROM %s
             WHERE point_country IS NOT NULL
         ) sub',
        p_source, p_entity, p_table
    );

    RETURN QUERY EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE bl_cl.p_load_ce_countries()
LANGUAGE plpgsql
AS
$$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_total INTEGER := 0;
    v_rows_skipped INTEGER := 0;
	record RECORD;
BEGIN
	for record in select * 
	from 
	bl_cl.f_get_countries('cash_orders', 'src_cash_orders', 'sa_cash_orders.src_cash_orders')
	LOOP
		v_rows_total := v_rows_total + 1;
		if not exists(
		        SELECT 1
		        FROM bl_3nf.ce_countries c
		        WHERE c.country_src_id = record.country_src_id
		      	AND c.source_system = record.source_system
		      	AND c.source_entity = record.source_entity
		    ) THEN
			INSERT INTO bl_3nf.ce_countries (
		        country_id,
		        country_src_id,
		        country_name,
		        source_system,
		        source_entity,
		        ta_insert_dt,
		        ta_update_dt
		    )
			values (
				NEXTVAL('bl_3nf.seq_ce_country'),
				record.country_src_id,
		        record.country_name,
		        record.source_system,
		        record.source_entity,
		        CURRENT_DATE,
		        CURRENT_DATE		
			);
				v_rows_inserted := v_rows_inserted + 1;
	    END IF;
	END LOOP;    


    -- Count from card_orders
    for record in select * 
	from 
	bl_cl.f_get_countries('card_orders', 'src_card_orders', 'sa_card_orders.src_card_orders')
	LOOP
		v_rows_total := v_rows_total + 1;
		if not exists(
		        SELECT 1
		        FROM bl_3nf.ce_countries c
		        WHERE c.country_src_id = record.country_src_id
		      	AND c.source_system = record.source_system
		      	AND c.source_entity = record.source_entity
		    ) THEN
			INSERT INTO bl_3nf.ce_countries (
		        country_id,
		        country_src_id,
		        country_name,
		        source_system,
		        source_entity,
		        ta_insert_dt,
		        ta_update_dt
		    )
			values (
				NEXTVAL('bl_3nf.seq_ce_country'),
				record.country_src_id,
		        record.country_name,
		        record.source_system,
		        record.source_entity,
		        CURRENT_DATE,
		        CURRENT_DATE		
			);
				v_rows_inserted := v_rows_inserted + 1;
	    END IF;
	END LOOP;    

    -- Calculate skipped
    v_rows_skipped := v_rows_total - v_rows_inserted;

    -- Log success
    CALL bl_cl.p_log_event(
        'load_ce_countries',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );
EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'load_ce_countries',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.p_load_ce_cities()
LANGUAGE plpgsql
AS
$$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_total INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_tmp INTEGER := 0;
BEGIN
    -- Count distinct cities from cash_orders
    SELECT COUNT(DISTINCT point_country|| '||'|| point_city)
    INTO v_tmp
    FROM sa_cash_orders.src_cash_orders
    WHERE point_city IS NOT NULL AND point_country IS NOT NULL;
    v_rows_total := v_rows_total + v_tmp;

    -- Insert from cash_orders
    INSERT INTO bl_3nf.ce_cities (
    city_id,
    city_src_id,
    city_name,
    country_id,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_city'),
    COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.'),
    COALESCE(sc.point_city, 'n.a.'),
    COALESCE(c.country_id, -1),
    'cash_orders',
    'src_cash_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT point_city, point_country
    FROM sa_cash_orders.src_cash_orders
    WHERE point_city IS NOT NULL AND point_country IS NOT NULL
) sc
LEFT JOIN bl_3nf.ce_countries c
    ON c.country_src_id = sc.point_country
   AND c.source_system = 'cash_orders'
   AND c.source_entity = 'src_cash_orders'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_cities ci
    WHERE ci.city_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.')
      AND ci.source_system = 'cash_orders'
      AND ci.source_entity = 'src_cash_orders'
);

    GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;

    -- Count from card_orders
    SELECT COUNT(DISTINCT point_country|| '||'|| point_city)
    INTO v_tmp
    FROM sa_card_orders.src_card_orders
    WHERE point_city IS NOT NULL AND point_country IS NOT NULL;
    v_rows_total := v_rows_total + v_tmp;

    -- Insert from card_orders
    INSERT INTO bl_3nf.ce_cities (
    city_id,
    city_src_id,
    city_name,
    country_id,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_city'),
    COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.'),
    COALESCE(sc.point_city, 'n.a.'),
    COALESCE(c.country_id, -1),
    'card_orders',
    'src_card_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT point_city, point_country
    FROM sa_card_orders.src_card_orders
    WHERE point_city IS NOT NULL AND point_country IS NOT NULL
) sc
LEFT JOIN bl_3nf.ce_countries c
    ON c.country_src_id = sc.point_country
   AND c.source_system = 'card_orders'
   AND c.source_entity = 'src_card_orders'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_cities ci
    WHERE ci.city_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.')
      AND ci.source_system = 'card_orders'
      AND ci.source_entity = 'src_card_orders'
);

    GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;

    -- Calculate skipped
    v_rows_skipped := v_rows_total - v_rows_inserted;

    -- Log success
    CALL bl_cl.p_log_event(
        'load_ce_cities',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );
EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'load_ce_cities',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;

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
