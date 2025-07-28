-- change role
SET ROLE bl_cl_user;

-- check role
SELECT current_user;


TRUNCATE TABLE 
--    bl_dm.dim_card_informations,
--    bl_dm.dim_channels,
--    bl_dm.dim_customers,
--    bl_dm.dim_discounts,
--    bl_dm.dim_employees,
--    bl_dm.dim_points,
    bl_dm.dim_products_scd
RESTART IDENTITY CASCADE;

-- test procedures
CALL bl_cl.p_load_dim_channels();
SELECT * FROM bl_dm.dim_channels;

CALL bl_cl.p_load_dim_customers();
SELECT * FROM bl_dm.dim_customers;

CALL bl_cl.p_load_dim_employees();
SELECT * FROM bl_dm.dim_employees;

CALL bl_cl.p_load_dim_discounts();
SELECT * FROM bl_dm.dim_discounts;

CALL bl_cl.p_load_dim_card_informations();
SELECT * FROM bl_dm.dim_card_informations;

CALL bl_cl.p_load_dim_points();
SELECT * FROM bl_dm.dim_points;

CALL bl_cl.p_load_dim_products_scd();
SELECT * FROM bl_dm.dim_products_scd ORDER BY product_src_id, start_dt;

--CALL bl_cl.p_load_fct_sales_dd();
--SELECT * FROM bl_dm.fct_sales_dd f ;




-- check logs
SELECT *
FROM bl_cl.etl_log ORDER BY log_id DESC;
