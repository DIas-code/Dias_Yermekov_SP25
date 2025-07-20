TRUNCATE TABLE
    bl_3nf.ce_addresses,
    bl_3nf.ce_banks,
    bl_3nf.ce_card_informations,
    bl_3nf.ce_card_types,
    bl_3nf.ce_categories,
    bl_3nf.ce_channels,
    bl_3nf.ce_cities,
    bl_3nf.ce_countries,
    bl_3nf.ce_customers,
    bl_3nf.ce_discounts,
    bl_3nf.ce_employees,
    bl_3nf.ce_points,
    bl_3nf.ce_products_scd,
    bl_3nf.ce_sales
RESTART IDENTITY
CASCADE;

SET ROLE bl_cl_user;

SELECT current_user;

CALL bl_cl.p_load_ce_customers();
SELECT * FROM bl_3nf.ce_customers;
CALL bl_cl.p_load_ce_employees();
SELECT * FROM bl_3nf.ce_employees;
CALL bl_cl.p_load_ce_channels();
SELECT * FROM bl_3nf.ce_channels c ;
CALL bl_cl.p_load_ce_countries();
SELECT * FROM bl_3nf.ce_countries c  ;
CALL bl_cl.p_load_ce_cities();
SELECT * FROM bl_3nf.ce_cities c  ;
CALL bl_cl.p_load_ce_addresses();
SELECT * FROM bl_3nf.ce_addresses c  ;
CALL bl_cl.p_load_ce_points();
SELECT * FROM bl_3nf.ce_points c  ;
CALL bl_cl.p_load_ce_discounts();
SELECT * FROM bl_3nf.ce_discounts c  ;
CALL bl_cl.p_load_ce_discounts();
SELECT * FROM bl_3nf.ce_discounts c  ;
CALL bl_cl.p_load_ce_banks();
SELECT * FROM bl_3nf.ce_banks c  ;
CALL bl_cl.p_load_ce_card_types();
SELECT * FROM bl_3nf.ce_card_types c  ;
CALL bl_cl.p_load_ce_card_informations();
SELECT * FROM bl_3nf.ce_card_informations c  ;
CALL bl_cl.p_load_ce_categories();
SELECT * FROM bl_3nf.ce_categories c  ;
CALL bl_cl.p_load_ce_products_scd();
INSERT INTO sa_cash_orders.src_cash_orders
(order_id, order_date, prod_code, prod_name, prod_category_code, prod_category, prod_price, quantity, discount_percentage, discount_date, payment_amount, payment_type, point_name, point_address, point_city, point_country, cust_first_name, cust_last_name, cust_phone_number, employee_first_name, employee_last_name, employee_dob, employee_personal_id, employee_phone_number)
VALUES('ORD-500002', '2025-03-29', 'P007', 'Sugarcane juice3', 'C001', 'Beverages', '29.0', '5', '0', NULL, '145', 'Cash', 'Balaji_1', 'Satpaeva 127', 'Atyrau', 'Kazakhstan', 'Tyler', 'Duffy', '525-287-3036x77950', 'Alex', 'Ivanov', '1985-03-15', 'EMP005', '87010000005');
SELECT * FROM bl_3nf.ce_products_scd c  ;
SELECT * FROM bl_cl.etl_log ;







