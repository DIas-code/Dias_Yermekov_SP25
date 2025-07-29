TRUNCATE TABLE
--    bl_3nf.ce_addresses,
--    bl_3nf.ce_banks,
--    bl_3nf.ce_card_informations,
--    bl_3nf.ce_card_types,
--    bl_3nf.ce_categories,
--    bl_3nf.ce_channels,
--    bl_3nf.ce_cities,
--    bl_3nf.ce_countries,
--    bl_3nf.ce_customers,
--    bl_3nf.ce_discounts,
--    bl_3nf.ce_employees,
--    bl_3nf.ce_points,
--    bl_3nf.ce_products_scd,
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
SELECT * FROM bl_3nf.ce_products_scd c  ;
SELECT * FROM bl_cl.etl_log ORDER BY log_id desc;



