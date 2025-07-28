CREATE SCHEMA IF NOT EXISTS BL_CL;

--Checking existing tables
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'bl_3nf'
  AND table_name LIKE 'ce_%'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;



--ce_customer 14th row, ce_employees 140th row, discounts 272


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



	
	