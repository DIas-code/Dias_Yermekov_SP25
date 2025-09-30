CREATE OR REPLACE PROCEDURE bl_cl.p_load_fct_sales_dd()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_inserted INTEGER := 0;
BEGIN
    -- insert from ce_sales into fct_sales_dd
    INSERT INTO bl_dm.fct_sales_dd (
        sales_id,
        event_dt,
        product_id,
        discount_id,
        fct_quantity,
        fct_product_price,
        fct_payment_amount,
        payment_type,
        point_id,
        customer_id,
        employee_id,
        card_information_id,
        channel_id,
        source_id,
        source_system,
        source_entity,
        ta_insert_dt,
        ta_update_dt
    )
    SELECT
        s.sales_id,
        s.event_dt,
        p.product_id,
        d.discount_id,
        s.product_quantity,
        s.product_price,
        s.payment_amount,
        s.payment_type,
        pt.point_id,
        c.customer_id,
        e.employee_id,
        ci.card_information_id,
        ch.channel_id,
        s.source_id,
        s.source_system,
        s.source_entity,
        CURRENT_DATE,
        CURRENT_DATE
    FROM bl_3nf.ce_sales s
    LEFT JOIN bl_dm.dim_products_scd p
        ON p.product_src_id = s.product_id::text
       AND p.source_system = s.source_system
       AND p.source_entity = s.source_entity
       AND s.event_dt BETWEEN p.start_dt AND p.end_dt
    LEFT JOIN bl_dm.dim_discounts d
        ON d.source_id = s.discount_id
       AND d.source_system = s.source_system
       AND d.source_entity = s.source_entity
    LEFT JOIN bl_dm.dim_points pt
        ON pt.point_src_id = s.point_id
       AND pt.source_system = s.source_system
       AND pt.source_entity = s.source_entity
    LEFT JOIN bl_dm.dim_customers c
        ON c.customer_src_id = s.customer_id
       AND c.source_system = s.source_system
       AND c.source_entity = s.source_entity
    LEFT JOIN bl_dm.dim_employees e
        ON e.emp_src_id = s.employee_id
       AND e.source_system = s.source_system
       AND e.source_entity = s.source_entity
    LEFT JOIN bl_dm.dim_card_information ci
        ON ci.card_information_src_id = s.card_information_id
       AND ci.source_system = s.source_system
       AND ci.source_entity = s.source_entity
    LEFT JOIN bl_dm.dim_channels ch
        ON ch.channel_src_id = s.channel_id
       AND ch.source_system = s.source_system
       AND ch.source_entity = s.source_entity
    WHERE NOT EXISTS (
        SELECT 1
        FROM bl_dm.fct_sales_dd f
        WHERE f.sales_id       = s.sales_id
          AND f.source_id      = s.source_id
          AND f.source_system  = s.source_system
          AND f.source_entity  = s.source_entity
    );

    -- count rows
    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- log
    CALL bl_cl.p_log_event(
        'p_load_fct_sales_dd',
        v_rows_inserted,
        0,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'p_load_fct_sales_dd',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;
