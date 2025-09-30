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

