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

