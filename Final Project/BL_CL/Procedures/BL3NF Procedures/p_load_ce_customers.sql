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
