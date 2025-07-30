--DIM_PRODUCTS
CREATE OR REPLACE PROCEDURE bl_cl.p_load_dim_products_scd()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_total_rows INTEGER := 0;
BEGIN
    -- get count of rows
    SELECT COUNT(*) INTO v_total_rows FROM bl_3nf.ce_products_scd;

    -- update only changed products
	WITH changed_rows AS (
    SELECT
        tgt.product_id,
        COALESCE(cat.ta_update_dt, src.start_dt) AS actual_start_dt
    FROM bl_dm.dim_products_scd tgt
    JOIN bl_3nf.ce_products_scd src
      ON tgt.product_src_id = src.product_src_id
     AND tgt.source_system = src.source_system
     AND tgt.source_entity = src.source_entity
     AND tgt.is_active = 'Y'
    LEFT JOIN bl_3nf.ce_categories cat
      ON src.category_id = cat.category_id
     AND src.source_system = cat.source_system
     AND src.source_entity = cat.source_entity
    WHERE
        tgt.product_name IS DISTINCT FROM src.product_name OR
        tgt.product_category_id IS DISTINCT FROM src.category_id OR
        tgt.product_category_name IS DISTINCT FROM COALESCE(cat.category_name, 'n.a.')
	)
	UPDATE bl_dm.dim_products_scd tgt
	SET
	    end_dt = cr.actual_start_dt - INTERVAL '1 day',
	    is_active = 'N',
	    ta_insert_dt = CURRENT_DATE
	FROM changed_rows cr
	WHERE tgt.product_id = cr.product_id
	  AND cr.actual_start_dt - INTERVAL '1 day' >= tgt.start_dt;


    -- insert new rows
    WITH ranked_products AS (
        SELECT
            p.product_src_id,
            p.product_name,
            p.category_id AS product_category_id,
            c.category_name AS product_category_name,
            p.start_dt,
            p.end_dt,
            p.is_active,
            p.source_id,
            p.source_system,
            p.source_entity,
            p.ta_insert_dt,
            ROW_NUMBER() OVER (
                PARTITION BY p.product_src_id, p.source_system, p.source_entity
                ORDER BY p.start_dt DESC, p.ta_insert_dt DESC
            ) AS rn
        FROM bl_3nf.ce_products_scd p
        LEFT JOIN bl_3nf.ce_categories c
          ON p.category_id = c.category_id
         AND p.source_system = c.source_system
         AND p.source_entity = c.source_entity
    )
    INSERT INTO bl_dm.dim_products_scd (
        product_id,
        product_src_id,
        product_name,
        product_category_id,
        product_category_name,
        start_dt,
        end_dt,
        is_active,
        source_id,
        source_system,
        source_entity,
        ta_insert_dt
    )
    SELECT
        nextval('bl_dm.seq_dim_products_scd'),
        product_src_id,
        product_name,
        product_category_id,
        COALESCE(product_category_name, 'n.a.'),
        start_dt,
        end_dt,
        CASE WHEN rn = 1 THEN 'Y' ELSE 'N' END,
        source_id,
        source_system,
        source_entity,
        CURRENT_DATE
    FROM ranked_products
    WHERE NOT EXISTS (
        SELECT 1
        FROM bl_dm.dim_products_scd tgt
        WHERE tgt.product_src_id        = ranked_products.product_src_id
          AND tgt.source_system         = ranked_products.source_system
          AND tgt.source_entity         = ranked_products.source_entity
          AND tgt.product_name          = ranked_products.product_name
          AND tgt.product_category_id   = ranked_products.product_category_id
          AND tgt.product_category_name = COALESCE(ranked_products.product_category_name, 'n.a.')
          AND tgt.start_dt              = ranked_products.start_dt
    );

    -- log
    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;
    v_rows_skipped := v_total_rows - v_rows_inserted;

    CALL bl_cl.p_log_event(
        'p_load_dim_products_scd',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'p_load_dim_products_scd',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;
