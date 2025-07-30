--creating source cash table to be able manipulate with data from external src
CREATE TABLE IF NOT EXISTS sa_cash_orders.src_cash_orders (
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
);

--DROP TABLE sa_cash_orders.src_cash_orders;

--inserting data into src table from external table
INSERT
	INTO
	sa_cash_orders.src_cash_orders
SELECT DISTINCT --added distinct updated
	*
FROM
	sa_cash_orders.ext_cash_orders ;

INSERT INTO sa_cash_orders.src_cash_orders
SELECT DISTINCT *
FROM sa_cash_orders.ext_cash_orders ext
WHERE TO_DATE(ext.Order_date, 'YYYY-MM-DD') >
      COALESCE((
          SELECT MAX(TO_DATE(src.Order_date, 'YYYY-MM-DD'))
          FROM sa_cash_orders.src_cash_orders src
          WHERE src.Order_date IS NOT NULL
      ), TO_DATE('1900-01-01', 'YYYY-MM-DD'));

SELECT count(*) FROM sa_cash_orders.src_cash_orders s ;