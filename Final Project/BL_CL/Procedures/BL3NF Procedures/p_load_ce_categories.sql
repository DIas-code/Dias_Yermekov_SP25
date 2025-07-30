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