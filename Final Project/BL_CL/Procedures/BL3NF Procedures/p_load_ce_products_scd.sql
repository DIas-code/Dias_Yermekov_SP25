 
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
