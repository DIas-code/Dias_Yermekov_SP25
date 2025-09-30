CREATE OR REPLACE PROCEDURE bl_cl.p_load_ce_customers()
LANGUAGE plpgsql
AS
$$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_tmp INTEGER := 0;
BEGIN
    -- Count rows with NULL phone number in cash_orders
    SELECT COUNT(*) INTO v_tmp
    FROM sa_cash_orders.src_cash_orders
    WHERE cust_phone_number IS NULL;
    v_rows_skipped := v_rows_skipped + v_tmp;

    -- Insert valid customers from sa_cash_orders
    INSERT INTO bl_3nf.ce_customers (
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
    SELECT 
        NEXTVAL('bl_3nf.seq_ce_customers'),
        cust_phone_number,
        COALESCE(cust_first_name, 'n.a.'),
        COALESCE(cust_last_name, 'n.a.'),
        cust_phone_number,
        'cash_orders',
        'src_cash_orders',
        CURRENT_DATE,
        CURRENT_DATE
    FROM sa_cash_orders.src_cash_orders src
    WHERE cust_phone_number IS NOT NULL
      AND NOT EXISTS (
        SELECT 1
        FROM bl_3nf.ce_customers c
        WHERE c.customer_src_id = src.cust_phone_number
          AND c.source_system = 'cash_orders'
          AND c.source_entity = 'src_cash_orders'
    );

    GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;

    -- Count rows with NULL phone number in card_orders
    SELECT COUNT(*) INTO v_tmp
    FROM sa_card_orders.src_card_orders
    WHERE cust_phone_number IS NULL;
    v_rows_skipped := v_rows_skipped + v_tmp;

    -- Insert valid customers from sa_card_orders
    INSERT INTO bl_3nf.ce_customers (
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
    SELECT 
        NEXTVAL('bl_3nf.seq_ce_customers'),
        cust_phone_number,
        COALESCE(cust_first_name, 'n.a.'),
        COALESCE(cust_last_name, 'n.a.'),
        cust_phone_number,
        'card_orders',
        'src_card_orders',
        CURRENT_DATE,
        CURRENT_DATE
    FROM sa_card_orders.src_card_orders src
    WHERE cust_phone_number IS NOT NULL
      AND NOT EXISTS (
        SELECT 1
        FROM bl_3nf.ce_customers c
        WHERE c.customer_src_id = src.cust_phone_number
          AND c.source_system = 'card_orders'
          AND c.source_entity = 'src_card_orders'
    );

    GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;

    -- Log success
    CALL bl_cl.p_log_event(
        'load_ce_customers',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );
	--fail log
EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'load_ce_customers',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;

CREATE OR REPLACE PROCEDURE bl_cl.p_load_ce_employees()
LANGUAGE plpgsql
AS
$$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_total INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_tmp INTEGER := 0;
BEGIN
    -- Count distinct employees from cash_orders
    SELECT COUNT(DISTINCT employee_personal_id)
    INTO v_tmp
    FROM sa_cash_orders.src_cash_orders
    WHERE employee_personal_id IS NOT NULL;
    v_rows_total := v_rows_total + v_tmp;

    -- Insert from cash_orders
    INSERT INTO bl_3nf.ce_employees (
        emp_id,
        emp_src_id,
        first_name,
        last_name,
        dob,
        personal_id,
        phone_number,
        source_system,
        source_entity,
        ta_insert_dt,
        ta_update_dt
    )
    SELECT 
        NEXTVAL('bl_3nf.seq_ce_employees'),
        COALESCE(employee_personal_id, 'n.a.'),
        COALESCE(employee_first_name, 'n.a.'),
        COALESCE(employee_last_name, 'n.a.'),
        COALESCE(NULLIF(employee_dob, '')::DATE, DATE '1990-01-01'),
        COALESCE(employee_personal_id, 'n.a.'),
        COALESCE(employee_phone_number, 'n.a.'),
        'cash_orders',
        'src_cash_orders',
        CURRENT_DATE,
        CURRENT_DATE
    FROM (
        SELECT DISTINCT
            employee_personal_id,
            employee_first_name,
            employee_last_name,
            employee_dob,
            employee_phone_number
        FROM sa_cash_orders.src_cash_orders
        WHERE employee_personal_id IS NOT NULL
    ) sc
    WHERE NOT EXISTS (
        SELECT 1
        FROM bl_3nf.ce_employees e
        WHERE e.personal_id = COALESCE(sc.employee_personal_id, 'n.a.')
          AND e.source_system = 'cash_orders'
          AND e.source_entity = 'src_cash_orders'
    );

    GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;

    -- Count distinct employees from card_orders
    SELECT COUNT(DISTINCT emp_personal_id)
    INTO v_tmp
    FROM sa_card_orders.src_card_orders
    WHERE emp_personal_id IS NOT NULL;
    v_rows_total := v_rows_total + v_tmp;

    -- Insert from card_orders
    INSERT INTO bl_3nf.ce_employees (
        emp_id,
        emp_src_id,
        first_name,
        last_name,
        dob,
        personal_id,
        phone_number,
        source_system,
        source_entity,
        ta_insert_dt,
        ta_update_dt
    )
    SELECT 
        NEXTVAL('bl_3nf.seq_ce_employees'),
        COALESCE(emp_personal_id, 'n.a.'),
        COALESCE(emp_first_name, 'n.a.'),
        COALESCE(emp_last_name, 'n.a.'),
        COALESCE(NULLIF(emp_dob, '')::DATE, DATE '1990-01-01'),
        'card' || '||' || COALESCE(emp_personal_id, 'n.a.'),
        'card' || '||' || COALESCE(emp_phone_number, 'n.a.'),
        'card_orders',
        'src_card_orders',
        CURRENT_DATE,
        CURRENT_DATE
    FROM (
        SELECT DISTINCT
            emp_personal_id,
            emp_first_name,
            emp_last_name,
            emp_dob,
            emp_phone_number
        FROM sa_card_orders.src_card_orders
        WHERE emp_personal_id IS NOT NULL
    ) sc
    WHERE NOT EXISTS (
        SELECT 1
        FROM bl_3nf.ce_employees e
        WHERE e.personal_id = 'card' || '||' || COALESCE(sc.emp_personal_id, 'n.a.')
          AND e.source_system = 'card_orders'
          AND e.source_entity = 'src_card_orders'
    );

    GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;

    v_rows_skipped := v_rows_total - v_rows_inserted;

    -- Log success
    CALL bl_cl.p_log_event(
        'load_ce_employees',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'load_ce_employees',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;


CREATE OR REPLACE  PROCEDURE bl_cl.p_load_ce_discounts()
LANGUAGE plpgsql
AS
$$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_total INTEGER := 0;
   v_rows_skipped INTEGER := 0;
	v_tmp INTEGER := 0;
BEGIN
    -- Count valid from cash_orders
    SELECT COUNT(DISTINCT discount_date || '_' || discount_percentage)
    INTO v_tmp
    FROM sa_cash_orders.src_cash_orders
    WHERE discount_date IS NOT NULL AND discount_date <> ''
      AND discount_percentage IS NOT NULL AND discount_percentage <> '';
    v_rows_total := v_rows_total + v_tmp;

    -- Insert from cash_orders
    INSERT INTO bl_3nf.ce_discounts (
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
        NEXTVAL('bl_3nf.seq_ce_discount'),
        COALESCE(NULLIF(discount_percentage, '')::DECIMAL, 0.00),
        discount_date::DATE,
        discount_date || '_' || COALESCE(NULLIF(discount_percentage, '')::DECIMAL, 0.00)::TEXT,
        'cash_orders',
        'src_cash_orders',
        CURRENT_DATE,
        CURRENT_DATE
    FROM (
        SELECT DISTINCT discount_date, discount_percentage
        FROM sa_cash_orders.src_cash_orders
        WHERE discount_date IS NOT NULL AND discount_date <> ''
          AND discount_percentage IS NOT NULL AND discount_percentage <> ''
    ) sc
    WHERE NOT EXISTS (
        SELECT 1
        FROM bl_3nf.ce_discounts d
        WHERE d.source_id = sc.discount_date || '_' || COALESCE(NULLIF(sc.discount_percentage, '')::DECIMAL, 0.00)::TEXT
          AND d.source_system = 'cash_orders'
          AND d.source_entity = 'src_cash_orders'
    );

    GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;

    -- Count valid rows from card_orders
    SELECT COUNT(DISTINCT discount_date || '_' || discount_percentage)
    INTO v_tmp
    FROM sa_card_orders.src_card_orders
    WHERE discount_date IS NOT NULL AND discount_date <> ''
      AND discount_percentage IS NOT NULL AND discount_percentage <> '';
    v_rows_total := v_rows_total + v_tmp;

    -- Insert from card_orders
    INSERT INTO bl_3nf.ce_discounts (
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
        NEXTVAL('bl_3nf.seq_ce_discount'),
        COALESCE(NULLIF(discount_percentage, '')::DECIMAL, 0.00),
        discount_date::DATE,
        discount_date || '_' || COALESCE(NULLIF(discount_percentage, '')::DECIMAL, 0.00)::TEXT,
        'card_orders',
        'src_card_orders',
        CURRENT_DATE,
        CURRENT_DATE
    FROM (
        SELECT DISTINCT discount_date, discount_percentage
        FROM sa_card_orders.src_card_orders
        WHERE discount_date IS NOT NULL AND discount_date <> ''
          AND discount_percentage IS NOT NULL AND discount_percentage <> ''
    ) sc
    WHERE NOT EXISTS (
        SELECT 1
        FROM bl_3nf.ce_discounts d
        WHERE d.source_id = sc.discount_date || '_' || COALESCE(NULLIF(sc.discount_percentage, '')::DECIMAL, 0.00)::TEXT
          AND d.source_system = 'card_orders'
          AND d.source_entity = 'src_card_orders'
    );

    GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;

    -- Calculate skipped
    v_rows_skipped := v_rows_total - v_rows_inserted;

    -- Log success
    CALL bl_cl.p_log_event(
        'load_ce_discounts',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'load_ce_discounts',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;


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
--channels 3rd, banks 75, types 147, card_info 219

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

CREATE OR REPLACE  PROCEDURE bl_cl.p_load_ce_categories()
LANGUAGE plpgsql
AS
$$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_total INTEGER := 0;
   v_rows_skipped INTEGER := 0;
	v_tmp INTEGER := 0;
BEGIN
    -- Count valid from cash_orders
    SELECT COUNT(DISTINCT prod_category_code)
    INTO v_tmp
    FROM sa_cash_orders.src_cash_orders
    WHERE prod_category_code IS NOT NULL;
    v_rows_total := v_rows_total + v_tmp;

	-- Update existing categories if name changed
    UPDATE bl_3nf.ce_categories c
    SET
        category_name = COALESCE(sc.prod_category, 'n.a.'),
        ta_update_dt  = CURRENT_DATE
    FROM (
        SELECT DISTINCT prod_category_code, prod_category
        FROM sa_cash_orders.src_cash_orders
        WHERE prod_category_code IS NOT NULL
    ) sc
    WHERE c.category_src_id = sc.prod_category_code
      AND c.source_system = 'cash_orders'
      AND c.source_entity = 'src_cash_orders'
      AND c.category_name IS DISTINCT FROM COALESCE(sc.prod_category, 'n.a.');

    -- Insert from cash_orders
	INSERT INTO bl_3nf.ce_categories (
	    category_id,
	    category_src_id,
	    category_name,
	    source_system,
	    source_entity,
	    ta_insert_dt,
	    ta_update_dt
	)
	SELECT 
	    NEXTVAL('bl_3nf.seq_ce_categories'),
	    prod_category_code,
	    COALESCE(prod_category, 'n.a.'),
	    'cash_orders',
	    'src_cash_orders',
	    CURRENT_DATE,
	    CURRENT_DATE
	FROM (
	    SELECT DISTINCT prod_category_code, prod_category
	    FROM sa_cash_orders.src_cash_orders
	    WHERE prod_category_code IS NOT NULL
	) sc
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM bl_3nf.ce_categories c
	    WHERE c.category_src_id = sc.prod_category_code
	      AND c.source_system = 'cash_orders'
	      AND c.source_entity = 'src_cash_orders'
	);

    GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;

    -- Count valid rows from card_orders
    SELECT COUNT(DISTINCT prod_category_code)
    INTO v_tmp
    FROM sa_card_orders.src_card_orders
    WHERE prod_category_code IS NOT NULL;
    v_rows_total := v_rows_total + v_tmp;

	-- Update existing categories if name changed
    UPDATE bl_3nf.ce_categories c
    SET
        category_name = COALESCE(sc.prod_category, 'n.a.'),
        ta_update_dt  = CURRENT_DATE
    FROM (
        SELECT DISTINCT prod_category_code, prod_category
        FROM sa_card_orders.src_card_orders
        WHERE prod_category_code IS NOT NULL
    ) sc
    WHERE c.category_src_id = sc.prod_category_code
      AND c.source_system = 'card_orders'
      AND c.source_entity = 'src_card_orders'
      AND c.category_name IS DISTINCT FROM COALESCE(sc.prod_category, 'n.a.');

    -- Insert from cash_orders
	INSERT INTO bl_3nf.ce_categories (
	    category_id,
	    category_src_id,
	    category_name,
	    source_system,
	    source_entity,
	    ta_insert_dt,
	    ta_update_dt
	)
	SELECT 
	    NEXTVAL('bl_3nf.seq_ce_categories'),
	    prod_category_code,
	    COALESCE(prod_category, 'n.a.'),
	    'card_orders',
	    'src_card_orders',
	    CURRENT_DATE,
	    CURRENT_DATE
	FROM (
	    SELECT DISTINCT prod_category_code, prod_category
	    FROM sa_card_orders.src_card_orders
	    WHERE prod_category_code IS NOT NULL
	) sc
	WHERE NOT EXISTS (
	    SELECT 1
	    FROM bl_3nf.ce_categories c
	    WHERE c.category_src_id = sc.prod_category_code
	      AND c.source_system = 'card_orders'
	      AND c.source_entity = 'src_card_orders'
	);

    GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;

    -- Calculate skipped
    v_rows_skipped := v_rows_total - v_rows_inserted;

    -- Log success
    CALL bl_cl.p_log_event(
        'load_ce_categories',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'load_ce_categories',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;

 
CREATE OR REPLACE PROCEDURE bl_cl.p_load_ce_products_scd()
LANGUAGE plpgsql
AS
$$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_updated INTEGER := 0;
    v_tmp INTEGER := 0;
BEGIN
    -- creating staging table
    CREATE TEMP TABLE stg_products ON COMMIT DROP AS
    SELECT DISTINCT
        src.prod_code AS product_src_id,
        COALESCE(src.prod_name, 'n.a.') AS product_name,
        COALESCE(cat.category_id, -1) AS category_id,
        MIN(src.order_date) OVER (
            PARTITION BY src.prod_code, src.prod_name, src.prod_category_code
        )::DATE AS start_dt,
        DATE '9999-12-31' AS end_dt,
        'Y' AS is_active,
        COALESCE(src.prod_code, 'n.a.') AS source_id,
        'cash_orders' AS source_system,
        'src_cash_orders' AS source_entity,
        MIN(src.order_date) OVER (
            PARTITION BY src.prod_code, src.prod_name, src.prod_category_code
        )::date AS ta_insert_dt
    FROM sa_cash_orders.src_cash_orders src
    LEFT JOIN bl_3nf.ce_categories cat
        ON cat.category_src_id = src.prod_category_code
       AND cat.source_system = 'cash_orders'
       AND cat.source_entity = 'src_cash_orders'

    UNION ALL

    SELECT DISTINCT
        src.prod_code AS product_src_id,
        COALESCE(src.prod_name, 'n.a.') AS product_name,
        COALESCE(cat.category_id, -1) AS category_id,
        MIN(src.order_date) OVER (
            PARTITION BY src.prod_code, src.prod_name, src.prod_category_code
        )::DATE AS start_dt,
        DATE '9999-12-31' AS end_dt,
        'Y' AS is_active,
        COALESCE(src.prod_code, 'n.a.') AS source_id,
        'card_orders' AS source_system,
        'src_card_orders' AS source_entity,
        MIN(src.order_date) OVER (
            PARTITION BY src.prod_code, src.prod_name, src.prod_category_code
        )::date AS ta_insert_dt
    FROM sa_card_orders.src_card_orders src
    LEFT JOIN bl_3nf.ce_categories cat
        ON cat.category_src_id = src.prod_category_code
       AND cat.source_system = 'card_orders'
       AND cat.source_entity = 'src_card_orders';

    -- Update old records with correct end_dt from new start_dt
	UPDATE bl_3nf.ce_products_scd tgt
	SET end_dt = stg.start_dt - INTERVAL '1 day',
	    is_active = 'N'
	FROM stg_products stg
	WHERE tgt.product_src_id = stg.product_src_id
	  AND tgt.source_system = stg.source_system
	  AND tgt.source_entity = stg.source_entity
	  AND tgt.is_active = 'Y'
	  AND (
	      tgt.product_name IS DISTINCT FROM stg.product_name OR
	      tgt.category_id IS DISTINCT FROM stg.category_id
	  )
	  AND stg.start_dt > tgt.start_dt;

    GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_updated := v_rows_updated + v_tmp;

    -- insertion
	
	INSERT INTO bl_3nf.ce_products_scd (
	    product_id,
	    product_src_id,
	    product_name,
	    category_id,
	    start_dt,
	    end_dt,
	    is_active,
	    source_id,
	    source_system,
	    source_entity,
	    ta_insert_dt
	)
	SELECT 
	    NEXTVAL('bl_3nf.seq_ce_products_scd'),
	    product_src_id,
	    product_name,
	    category_id,
	    start_dt,
	    LEAD(start_dt, 1, DATE '9999-12-31') OVER (
	        PARTITION BY product_src_id, source_system, source_entity
	        ORDER BY start_dt
	    ) - INTERVAL '1 day' AS end_dt,
	    CASE 
	        WHEN ROW_NUMBER() OVER (
	            PARTITION BY product_src_id, source_system, source_entity
	            ORDER BY start_dt DESC
	        ) = 1 THEN 'Y'
	        ELSE 'N'
	    END AS is_active,
	    source_id,
	    source_system,
	    source_entity,
	    ta_insert_dt
	FROM (
	    SELECT * ,
	           ROW_NUMBER() OVER (
	               PARTITION BY product_src_id, product_name, category_id, source_system, source_entity 
	               ORDER BY ta_insert_dt DESC
	           ) AS rn
	    FROM stg_products
	) ranked
	WHERE rn = 1
	  AND NOT EXISTS (
	    SELECT 1
	    FROM bl_3nf.ce_products_scd tgt
	    WHERE tgt.product_src_id = ranked.product_src_id
	      AND tgt.source_system = ranked.source_system
	      AND tgt.source_entity = ranked.source_entity
	      AND tgt.product_name = ranked.product_name
	      AND tgt.category_id = ranked.category_id
	);

    GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;

    -- log
    CALL bl_cl.p_log_event(
        'load_ce_products_scd',
        v_rows_inserted,
        v_rows_updated,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Updated: ' || v_rows_updated
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'load_ce_products_scd',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;
