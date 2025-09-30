--TRUNCATE TABLE
----    bl_3nf.ce_addresses,
----    bl_3nf.ce_banks,
----    bl_3nf.ce_card_informations,
----    bl_3nf.ce_card_types,
----    bl_3nf.ce_categories,
----    bl_3nf.ce_channels,
----    bl_3nf.ce_cities,
----    bl_3nf.ce_countries,
----    bl_3nf.ce_customers,
----    bl_3nf.ce_discounts,
----    bl_3nf.ce_employees,
----    bl_3nf.ce_points,
----    bl_3nf.ce_products_scd,
--    bl_3nf.ce_sales
--RESTART IDENTITY
--CASCADE;

SET ROLE bl_cl_user;

SELECT current_user;

CALL bl_cl.p_load_ce_customers();
--SELECT * FROM bl_3nf.ce_customers;
CALL bl_cl.p_load_ce_employees();
--SELECT * FROM bl_3nf.ce_employees;
CALL bl_cl.p_load_ce_channels();
--SELECT * FROM bl_3nf.ce_channels c ;
CALL bl_cl.p_load_ce_countries();
--SELECT * FROM bl_3nf.ce_countries c  ;
CALL bl_cl.p_load_ce_cities();
--SELECT * FROM bl_3nf.ce_cities c  ;
CALL bl_cl.p_load_ce_addresses();
--SELECT * FROM bl_3nf.ce_addresses c  ;
CALL bl_cl.p_load_ce_points();
--SELECT * FROM bl_3nf.ce_points c  ;
CALL bl_cl.p_load_ce_discounts();
--SELECT * FROM bl_3nf.ce_discounts c  ;
CALL bl_cl.p_load_ce_discounts();
--SELECT * FROM bl_3nf.ce_discounts c  ;
CALL bl_cl.p_load_ce_banks();
--SELECT * FROM bl_3nf.ce_banks c  ;
CALL bl_cl.p_load_ce_card_types();
--SELECT * FROM bl_3nf.ce_card_types c  ;
CALL bl_cl.p_load_ce_card_informations();
--SELECT * FROM bl_3nf.ce_card_informations c  ;
CALL bl_cl.p_load_ce_categories();
--SELECT * FROM bl_3nf.ce_categories c  ;
CALL bl_cl.p_load_ce_products_scd();
--SELECT * FROM bl_3nf.ce_products_scd c  ;
CALL bl_cl.p_load_ce_sales();
SELECT * FROM bl_cl.etl_log ORDER BY log_id desc;


SELECT address_id, address_src_id, address, city_id, source_system, source_entity, ta_insert_dt, ta_update_dt
FROM bl_3nf.ce_addresses;
SELECT bank_id, bank_src_id, bank_name, source_system, source_entity, ta_insert_dt, ta_update_dt
FROM bl_3nf.ce_banks;
SELECT card_information_id, card_information_src_id, bank_id, card_type_id, source_system, source_entity, ta_insert_dt, ta_update_dt
FROM bl_3nf.ce_card_informations;
SELECT card_type_id, card_type_src_id, card_type_name, source_system, source_entity, ta_insert_dt, ta_update_dt
FROM bl_3nf.ce_card_types;
SELECT category_id, category_src_id, category_name, source_system, source_entity, ta_insert_dt, ta_update_dt
FROM bl_3nf.ce_categories;
SELECT channel_id, channel_src_id, channel_name, channel_desc, source_system, source_entity, ta_insert_dt, ta_update_dt
FROM bl_3nf.ce_channels;
SELECT city_id, city_src_id, city_name, country_id, source_system, source_entity, ta_insert_dt, ta_update_dt
FROM bl_3nf.ce_cities;
SELECT country_id, country_src_id, country_name, source_system, source_entity, ta_insert_dt, ta_update_dt
FROM bl_3nf.ce_countries;
SELECT customer_id, customer_src_id, first_name, last_name, phone_number, source_system, source_entity, ta_insert_dt, ta_update_dt
FROM bl_3nf.ce_customers;
SELECT discount_id, discount_percentage, discount_date, source_id, source_system, source_entity, ta_insert_dt, ta_update_dt
FROM bl_3nf.ce_discounts;
SELECT emp_id, emp_src_id, first_name, last_name, dob, personal_id, phone_number, source_system, source_entity, ta_insert_dt, ta_update_dt
FROM bl_3nf.ce_employees;
SELECT point_id, point_src_id, point_name, address_id, source_system, source_entity, ta_insert_dt, ta_update_dt
FROM bl_3nf.ce_points;
SELECT product_id, product_src_id, product_name, category_id, start_dt, end_dt, is_active, source_id, source_system, source_entity, ta_insert_dt
FROM bl_3nf.ce_products_scd;

SELECT count(*) FROM bl_3nf.ce_customers c ;
SELECT count(*) FROM bl_3nf.ce_sales ;
