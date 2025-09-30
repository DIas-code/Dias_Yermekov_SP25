CREATE SCHEMA IF NOT EXISTS sa_cash_orders; --creating schema for cash orders

CREATE EXTENSION IF NOT EXISTS file_fdw; 

CREATE SERVER IF NOT EXISTS csv_file_server FOREIGN DATA WRAPPER file_fdw;

--creating external cash table to get data from cash orders source
CREATE FOREIGN TABLE IF NOT EXISTS sa_cash_orders.ext_cash_orders(
Order_ID VARCHAR,
Order_date VARCHAR,
Prod_code VARCHAR,
Prod_name VARCHAR,
Prod_category_code VARCHAR,
Prod_category VARCHAR,
Prod_Price VARCHAR,
Quantity VARCHAR,
Discount_percentage VARCHAR,
Discount_date VARCHAR,
Payment_Amount VARCHAR,
Payment_Type VARCHAR,
Point_name VARCHAR,
Point_address VARCHAR,
Point_city VARCHAR,
Point_country VARCHAR,
Cust_first_name VARCHAR,
Cust_last_name VARCHAR,
Cust_phone_number VARCHAR,
Employee_first_name VARCHAR,
Employee_last_name VARCHAR,
Employee_DOB VARCHAR,
Employee_personal_ID VARCHAR,
Employee_phone_number VARCHAR
) SERVER csv_file_server OPTIONS (filename 'C:\Program Files\PostgreSQL\17\data\cash_source.csv', --path to the file
format 'csv',
HEADER 'true' );

ALTER FOREIGN TABLE sa_cash_orders.ext_cash_orders OPTIONS (SET filename 'C:\Program Files\PostgreSQL\17\data\cash_source_2.csv')

--DROP FOREIGN TABLE sa_cash_orders.ext_cash_orders;

SELECT * FROM sa_cash_orders.ext_cash_orders eco ;

