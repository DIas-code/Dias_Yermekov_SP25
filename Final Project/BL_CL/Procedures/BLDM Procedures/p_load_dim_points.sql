-- DIM_POINTS
CREATE OR REPLACE PROCEDURE bl_cl.p_load_dim_points()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_total_rows INTEGER := 0;
BEGIN
    -- count all rows from source
    SELECT COUNT(*) INTO v_total_rows FROM bl_3nf.ce_points;

    -- insert with join to get address/city/country info
    INSERT INTO bl_dm.dim_points (
        point_id,
        point_src_id,
        point_name,
        point_address_id,
        point_address,
        point_city_id,
        point_city_name,
        point_country_id,
        point_country_name,
        source_system,
        source_entity,
        ta_insert_dt,
        ta_update_dt
    )
    SELECT
        nextval('bl_dm.seq_dim_points'),
        p.point_src_id,
        p.point_name,
        a.address_id,
        a.address,
        c.city_id,
        c.city_name,
        co.country_id,
        co.country_name,
        p.source_system,
        p.source_entity,
        CURRENT_DATE,
        CURRENT_DATE
    FROM bl_3nf.ce_points p
    LEFT JOIN bl_3nf.ce_addresses a ON a.address_id = p.address_id
    LEFT JOIN bl_3nf.ce_cities c ON c.city_id = a.city_id
    LEFT JOIN bl_3nf.ce_countries co ON co.country_id = c.country_id
    ON CONFLICT (point_src_id, source_system, source_entity)
    DO NOTHING;

    -- row count for inserted rows
    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- skipped rows = total rows - inserted rows
    v_rows_skipped := v_total_rows - v_rows_inserted;

    -- log event
    CALL bl_cl.p_log_event(
        'p_load_dim_points',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'p_load_dim_points',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;
