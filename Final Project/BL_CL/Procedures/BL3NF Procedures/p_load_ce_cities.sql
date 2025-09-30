
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
