CREATE OR REPLACE PROCEDURE bl_cl.p_load_ce_sales()
LANGUAGE plpgsql
AS
$$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_tmp INTEGER := 0;
BEGIN
    -- INSERT from cash_orders
	INSERT INTO bl_3nf.ce_sales (
	    sales_id,
	    event_dt,
	    product_id,
	    discount_id,
	    product_price,
		product_quantity,
	    payment_amount,
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
	    NEXTVAL('bl_3nf.seq_ce_sales'),
	    COALESCE(NULLIF(order_date, '')::date, DATE '1990-01-01'),
	    COALESCE(p.product_id, -1),
	    COALESCE(d.discount_id, -1),
	    COALESCE(NULLIF(prod_price, '')::decimal, 0.00),
		COALESCE(NULLIF(quantity, '')::integer, 0),
	    COALESCE(NULLIF(payment_amount, '')::decimal, 0.00),
	    'CASH',
	    COALESCE(pt.point_id, -1),
	    COALESCE(c.customer_id, -1),
	    COALESCE(e.emp_id, -1),
	    -1,  -- no card info for cash
		-1, -- no channel for cash
	    COALESCE(sc.order_id, 'n.a.'),
	    'cash_orders',
	    'src_cash_orders',
	    CURRENT_DATE,
	    CURRENT_DATE
	FROM sa_cash_orders.src_cash_orders sc
	LEFT JOIN bl_3nf.ce_products_scd p
	    ON p.product_src_id = sc.prod_code
	   AND p.source_system = 'cash_orders'
	   AND p.source_entity = 'src_cash_orders'
	   AND p.is_active = 'Y'
	LEFT JOIN bl_3nf.ce_discounts d
	    ON d.source_id = sc.discount_date || '_' || sc.discount_percentage
	   AND d.source_system = 'cash_orders'
	   AND d.source_entity = 'src_cash_orders'
	LEFT JOIN bl_3nf.ce_points pt
	    ON pt.point_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.') || '|' || COALESCE(sc.point_name, 'n.a.')
	   AND pt.source_system = 'cash_orders'
	   AND pt.source_entity = 'src_cash_orders'
	LEFT JOIN bl_3nf.ce_customers c
	    ON c.customer_src_id = sc.cust_phone_number
	   AND c.source_system = 'cash_orders'
	   AND c.source_entity = 'src_cash_orders'
	LEFT JOIN bl_3nf.ce_employees e
	    ON e.personal_id = sc.employee_personal_id
	WHERE NOT EXISTS (
	    SELECT 1 FROM bl_3nf.ce_sales s
	    WHERE s.source_id = sc.order_id
	      AND s.source_system = 'cash_orders'
	      AND s.source_entity = 'src_cash_orders'
	);

    GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;

    -- INSERT from card_orders
	INSERT INTO bl_3nf.ce_sales (
	    sales_id,
	    event_dt,
	    product_id,
	    discount_id,
	    product_price,
		product_quantity,
	    payment_amount,
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
	    NEXTVAL('bl_3nf.seq_ce_sales'),
	    COALESCE(NULLIF(order_date, '')::date, DATE '1990-01-01'),
	    COALESCE(p.product_id, -1),
	    COALESCE(d.discount_id, -1),
	    COALESCE(NULLIF(prod_price, '')::decimal, 0.00),
		COALESCE(NULLIF(quantity, '')::integer, 0),
	    COALESCE(NULLIF(payment_amount, '')::decimal, 0.00),
	    'CARD',
	    COALESCE(pt.point_id, -1),
	    COALESCE(c.customer_id, -1),
	    COALESCE(e.emp_id, -1),
	    COALESCE(ci.card_information_id, -1),
	    COALESCE(ch.channel_id, -1),
		COALESCE(sc.order_id, 'n.a.'),
	    'card_orders',
	    'src_card_orders',
	    CURRENT_DATE,
	    CURRENT_DATE
	FROM sa_card_orders.src_card_orders sc
	LEFT JOIN bl_3nf.ce_products_scd p
	    ON p.product_src_id = sc.prod_code
	   AND p.source_system = 'card_orders'
	   AND p.source_entity = 'src_card_orders'
	   AND p.is_active = 'Y'
	LEFT JOIN bl_3nf.ce_discounts d
	    ON d.source_id = sc.discount_date || '_' || sc.discount_percentage
	   AND d.source_system = 'card_orders'
	   AND d.source_entity = 'src_card_orders'
	LEFT JOIN bl_3nf.ce_points pt
	    ON pt.point_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.') || '|' || COALESCE(sc.point_name, 'n.a.')
	   AND pt.source_system = 'card_orders'
	   AND pt.source_entity = 'src_card_orders'
	LEFT JOIN bl_3nf.ce_customers c
	    ON c.customer_src_id = sc.cust_phone_number
	   AND c.source_system = 'card_orders'
	   AND c.source_entity = 'src_card_orders'
	LEFT JOIN bl_3nf.ce_employees e
	    ON  e.personal_id = 'card||' || sc.emp_personal_id
	   AND e.source_system = 'card_orders'
	   AND e.source_entity = 'src_card_orders'
	LEFT JOIN bl_3nf.ce_channels ch
	    ON ch.channel_src_id = sc.channel_name
	   AND ch.source_system = 'card_orders'
	   AND ch.source_entity = 'src_card_orders'
	LEFT JOIN bl_3nf.ce_card_informations ci
	    ON ci.card_information_src_id = COALESCE(sc.bank_of_card, 'n.a.') || '|' || COALESCE(sc.card_type, 'n.a.')
	   AND ci.source_system = 'card_orders'
	   AND ci.source_entity = 'src_card_orders'
	WHERE NOT EXISTS (
	    SELECT 1 FROM bl_3nf.ce_sales s
	    WHERE s.source_id = sc.order_id
	      AND s.source_system = 'card_orders'
	      AND s.source_entity = 'src_card_orders'
	);

    GET DIAGNOSTICS v_tmp = ROW_COUNT;
    v_rows_inserted := v_rows_inserted + v_tmp;

    -- Log
    CALL bl_cl.p_log_event(
        'load_ce_sales',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'load_ce_sales',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;
SELECT count(*) FROM bl_3nf.ce_customers ;
SELECT * FROM bl_3nf.ce_sales ;
CALL bl_cl.p_load_ce_sales();
SELECT count(DISTINCT source_id) FROM bl_3nf.ce_sales ;
SELECT * FROM bl_cl.etl_log ORDER BY bl_cl.etl_log.log_id  desc;
TRUNCATE  bl_3nf.ce_sales;