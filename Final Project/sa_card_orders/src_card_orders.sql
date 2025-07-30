--creating source card table to be able manipulate with data from external src
CREATE TABLE IF NOT EXISTS sa_card_orders.src_card_orders (
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
Bank_of_card VARCHAR,
Card_type VARCHAR,
Point_name VARCHAR,
Point_address VARCHAR,
Point_city VARCHAR,
Point_country VARCHAR,
Cust_first_name VARCHAR,
Cust_last_name VARCHAR,
Cust_phone_number VARCHAR,
Emp_first_name VARCHAR,
Emp_last_name VARCHAR,
Emp_DOB VARCHAR,
Emp_personal_ID VARCHAR,
Emp_phone_number VARCHAR,
Channel_Name VARCHAR,
Channel_Desc VARCHAR
);

--DROP TABLE sa_cash_orders.src_car_orders;

--inserting data into src table from external table
INSERT
	INTO
	sa_card_orders.src_card_orders
SELECT DISTINCT --added distinct updated
	*
FROM
	sa_card_orders.ext_card_orders ;

INSERT INTO sa_card_orders.src_card_orders
SELECT DISTINCT *
FROM sa_card_orders.ext_card_orders ext
WHERE TO_DATE(ext.Order_date, 'YYYY-MM-DD') >
      COALESCE((
          SELECT MAX(TO_DATE(src.Order_date, 'YYYY-MM-DD'))
          FROM sa_card_orders.src_card_orders src
          WHERE src.Order_date IS NOT NULL
      ), TO_DATE('1900-01-01', 'YYYY-MM-DD'));

SELECT count(*) FROM sa_card_orders.src_card_orders;

