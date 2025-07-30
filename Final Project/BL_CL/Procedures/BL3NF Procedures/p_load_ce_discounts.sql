
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
