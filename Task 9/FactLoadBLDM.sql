--DROP TABLE bl_dm.fct_sales_dd;
--DROP SEQUENCE BL_DM.SEQ_DIM_SALES;
CREATE SEQUENCE IF NOT EXISTS BL_DM.SEQ_DIM_SALES START WITH 1;
CREATE TABLE IF NOT EXISTS BL_DM.FCT_SALES_DD (
    SALES_ID BIGINT NOT NULL,
    EVENT_DT DATE NOT NULL,
    PRODUCT_ID BIGINT NOT NULL,
    DISCOUNT_ID BIGINT NOT NULL,
    FCT_QUANTITY INT NOT NULL,
    FCT_PRODUCT_PRICE DECIMAL(6, 2) NOT NULL,
    FCT_PAYMENT_AMOUNT DECIMAL(6, 2) NOT NULL,
    PAYMENT_TYPE VARCHAR(4) NOT NULL CHECK (PAYMENT_TYPE IN ('CASH', 'CARD')),
    POINT_ID BIGINT NOT NULL,
    CUSTOMER_ID BIGINT NOT NULL,
    EMPLOYEE_ID BIGINT NOT NULL,
    CARD_INFORMATION_ID BIGINT NOT NULL,
    CHANNEL_ID BIGINT NOT NULL,
    SOURCE_ID VARCHAR(255) NOT NULL,
    SOURCE_SYSTEM VARCHAR(255) NOT NULL,
    SOURCE_ENTITY VARCHAR(255) NOT NULL,
    TA_INSERT_DT DATE NOT NULL,
    TA_UPDATE_DT DATE NOT NULL,
    CONSTRAINT fct_sales_dd_pkey PRIMARY KEY (sales_id, event_dt)
) PARTITION BY RANGE (event_dt);

-- Q1 2024
CREATE TABLE IF NOT EXISTS bl_dm.fct_sales_dd_2024_q1
PARTITION OF bl_dm.fct_sales_dd
FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

-- Q2 2024
CREATE TABLE IF NOT EXISTS bl_dm.fct_sales_dd_2024_q2
PARTITION OF bl_dm.fct_sales_dd
FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

-- Q3 2024
CREATE TABLE IF NOT EXISTS bl_dm.fct_sales_dd_2024_q3
PARTITION OF bl_dm.fct_sales_dd
FOR VALUES FROM ('2024-07-01') TO ('2024-10-01');

-- Q4 2024
CREATE TABLE IF NOT EXISTS bl_dm.fct_sales_dd_2024_q4
PARTITION OF bl_dm.fct_sales_dd
FOR VALUES FROM ('2024-10-01') TO ('2025-01-01');

-- Q1 2025
CREATE TABLE IF NOT EXISTS bl_dm.fct_sales_dd_2025_q1
PARTITION OF bl_dm.fct_sales_dd
FOR VALUES FROM ('2025-01-01') TO ('2025-04-01');

-- Q2 2025
CREATE TABLE IF NOT EXISTS bl_dm.fct_sales_dd_2025_q2
PARTITION OF bl_dm.fct_sales_dd
FOR VALUES FROM ('2025-04-01') TO ('2025-07-01');

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
        da.date_id,
        p.product_id,
        d.discount_id,
        s.product_quantity,
        s.product_price,
        s.payment_amount,
        s.payment_type,
        pt.point_id,
        c.customer_id,
        e.emp_id,
        ci.card_information_id,
        ch.channel_id,
        s.source_id,
        s.source_system,
        s.source_entity,
        CURRENT_DATE,
        CURRENT_DATE
    FROM bl_3nf.ce_sales s
	LEFT JOIN bl_dm.dim_dates da on da.date_id = s.event_dt
	LEFT JOIN bl_3nf.ce_products_scd p3nf ON s.product_id = p3nf.product_id
    LEFT JOIN bl_dm.dim_products_scd p
        ON p.product_src_id = p3nf.product_src_id
       AND p.source_system = s.source_system
       AND p.source_entity = s.source_entity
       AND s.event_dt BETWEEN p.start_dt AND p.end_dt
	LEFT JOIN bl_3nf.ce_discounts d3nf ON s.discount_id = d3nf.discount_id
    LEFT JOIN bl_dm.dim_discounts d
        ON d.source_id = d3nf.source_id
       AND d.source_system = d3nf.source_system
       AND d.source_entity = d3nf.source_entity
	LEFT JOIN bl_3nf.ce_points pt3nf ON s.point_id = pt3nf.point_id
    LEFT JOIN bl_dm.dim_points pt
        ON pt.point_src_id = pt3nf.point_src_id
       AND pt.source_system = pt3nf.source_system
       AND pt.source_entity = pt3nf.source_entity
	LEFT JOIN bl_3nf.ce_customers c3nf ON s.customer_id = c3nf.customer_id
    LEFT JOIN bl_dm.dim_customers c
        ON c.customer_src_id = c3nf.customer_src_id
       AND c.source_system = c3nf.source_system
       AND c.source_entity = c3nf.source_entity
	LEFT JOIN bl_3nf.ce_employees e3nf ON s.employee_id = e3nf.emp_id
    LEFT JOIN bl_dm.dim_employees e
        ON e.emp_src_id = e3nf.emp_src_id
       AND e.source_system = e3nf.source_system
       AND e.source_entity = e3nf.source_entity
	LEFT JOIN bl_3nf.ce_card_informations ci3nf 
		ON s.card_information_id = ci3nf.card_information_id
    LEFT JOIN bl_dm.dim_card_informations ci
        ON ci.card_information_src_id = ci3nf.card_information_src_id
       AND ci.source_system = ci3nf.source_system
       AND ci.source_entity = ci3nf.source_entity
	LEFT JOIN bl_3nf.ce_channels ch3nf ON s.channel_id = ch3nf.channel_id
    LEFT JOIN bl_dm.dim_channels ch
        ON ch.channel_src_id = ch3nf.channel_src_id
       AND ch.source_system = ch3nf.source_system
       AND ch.source_entity = ch3nf.source_entity
    WHERE NOT EXISTS (
        SELECT 1
        FROM bl_dm.fct_sales_dd f
        WHERE f.sales_id = s.sales_id
          AND f.source_id = s.source_id
          AND f.source_system = s.source_system
          AND f.source_entity = s.source_entity
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
SELECT * FROM bl_dm.dim_discounts ;
SELECT count(*) FROM bl_3nf.ce_sales c  
WHERE c.discount_id = -1;
CALL bl_cl.p_load_fct_sales_dd();
SELECT * FROM bl_dm.fct_sales_dd;
SELECT * FROM bl_cl.etl_log e ORDER BY e.log_id desc;
SELECT * FROM bl_dm.fct_sales_dd_2024_q1 ;
SELECT * FROM bl_dm.fct_sales_dd_2024_q2 ;
SELECT * FROM bl_dm.fct_sales_dd_2024_q3 ;
SELECT * FROM bl_dm.fct_sales_dd_2024_q4 ;
SELECT * FROM bl_dm.fct_sales_dd_2025_q1 ;
SELECT * FROM bl_dm.fct_sales_dd_2025_q2 ;

SELECT count(source_id) FROM bl_dm.fct_sales_dd f ;
--SELECT * FROM 
--bl_3nf.ce_sales s 
--LEFT JOIN bl_3nf.ce_discounts d3nf ON s.discount_id = d3nf.discount_id
--    LEFT JOIN bl_dm.dim_discounts d
--        ON d.source_id = d3nf.source_id
--       AND d.source_system = d3nf.source_system
--       AND d.source_entity = d3nf.source_entity;


--SELECT count(DISTINCT date_id) FROM bl_dm.dim_dates d ;
--TRUNCATE bl_dm.fct_sales_dd;