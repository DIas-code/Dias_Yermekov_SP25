--default rows 5th row, inserts from src nearly 400th row

-- ce_customers
INSERT
	INTO
	bl_3nf.ce_customers (
    customer_id,
	customer_src_id,
	first_name,
	last_name,
	phone_number,
	source_system,
	source_entity,
	ta_insert_dt,
	ta_update_dt
)
SELECT
	-1,
	'n.a.',
	'n.a.',
	'n.a.',
	'n.a.',
	'manual',
	'manual',
	CURRENT_DATE,
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		bl_3nf.ce_customers
	WHERE
		customer_id = -1
);
--ce_discounts
INSERT
	INTO
	bl_3nf.ce_discounts (
	discount_id,
	discount_percentage,
	discount_date,
	source_id,
	source_system,
	source_entity,
	ta_insert_dt,
	ta_update_dt
)
SELECT
	-1,
	-1,
	DATE '1990-01-01',
	'n.a.',
	'manual',
	'manual',
	CURRENT_DATE,
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		bl_3nf.ce_discounts
	WHERE
		discount_id = -1
);
-- ce_employees
INSERT
	INTO
	bl_3nf.ce_employees (
    emp_id,
	emp_src_id,
	first_name,
	last_name,
	dob,
	personal_id,
	phone_number,
	source_system,
	source_entity,
	ta_insert_dt,
	ta_update_dt
)
SELECT
	-1,
	'n.a.',
	'n.a.',
	'n.a.',
	DATE '1990-01-01',
	'n.a.',
	'n.a.',
	'manual',
	'manual',
	CURRENT_DATE,
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		bl_3nf.ce_employees
	WHERE
		emp_id = -1
);


-- ce_countries
INSERT
	INTO
	bl_3nf.ce_countries (
    country_id,
	country_src_id,
	country_name,
	source_system,
	source_entity,
	ta_insert_dt,
	ta_update_dt
)
SELECT
	-1,
	'n.a.',
	'n.a.',
	'manual',
	'manual',
	CURRENT_DATE,
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		bl_3nf.ce_countries
	WHERE
		country_id = -1
);
-- ce_cities
INSERT
	INTO
	bl_3nf.ce_cities (
    city_id,
	city_src_id,
	city_name,
	country_id,
	source_system,
	source_entity,
	ta_insert_dt,
	ta_update_dt
)
SELECT
	-1,
	'n.a.',
	'n.a.',
	-1,
	'manual',
	'manual',
	CURRENT_DATE,
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		bl_3nf.ce_cities
	WHERE
		city_id = -1
);
-- ce_addresses
INSERT
	INTO
	bl_3nf.ce_addresses (
    address_id,
	address_src_id,
	address,
	city_id,
	source_system,
	source_entity,
	ta_insert_dt,
	ta_update_dt
)
SELECT
	-1,
	'n.a.',
	'n.a.',
	-1,
	'manual',
	'manual',
	CURRENT_DATE,
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		bl_3nf.ce_addresses
	WHERE
		address_id = -1
);
-- ce_points
INSERT
	INTO
	bl_3nf.ce_points (
    point_id,
	point_src_id,
	point_name,
	address_id,
	source_system,
	source_entity,
	ta_insert_dt,
	ta_update_dt
)
SELECT
	-1,
	'n.a.',
	'n.a.',
	-1,
	'manual',
	'manual',
	CURRENT_DATE,
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		bl_3nf.ce_points
	WHERE
		point_id = -1
);
-- ce_banks
INSERT
	INTO
	bl_3nf.ce_banks (
    bank_id,
	bank_src_id,
	bank_name,
	source_system,
	source_entity,
	ta_insert_dt,
	ta_update_dt
)
SELECT
	-1,
	'n.a.',
	'n.a.',
	'manual',
	'manual',
	CURRENT_DATE,
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		bl_3nf.ce_banks
	WHERE
		bank_id = -1
);
-- ce_card_types
INSERT
	INTO
	bl_3nf.ce_card_types (
    card_type_id,
	card_type_src_id,
	card_type_name,
	source_system,
	source_entity,
	ta_insert_dt,
	ta_update_dt
)
SELECT
	-1,
	'n.a.',
	'n.a.',
	'manual',
	'manual',
	CURRENT_DATE,
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		bl_3nf.ce_card_types
	WHERE
		card_type_id = -1
);
-- ce_card_informations
INSERT
	INTO
	bl_3nf.ce_card_informations (
    card_information_id,
	card_information_src_id,
	bank_id,
	card_type_id,
	source_system,
	source_entity,
	ta_insert_dt,
	ta_update_dt
)
SELECT
	-1,
	'n.a.',
	-1,
	-1,
	'manual',
	'manual',
	CURRENT_DATE,
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		bl_3nf.ce_card_informations
	WHERE
		card_information_id = -1
);
-- ce_categories
INSERT
	INTO
	bl_3nf.ce_categories (
    category_id,
	category_src_id,
	category_name,
	source_system,
	source_entity,
	ta_insert_dt,
	ta_update_dt
)
SELECT
	-1,
	'n.a.',
	'n.a.',
	'manual',
	'manual',
	CURRENT_DATE,
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		bl_3nf.ce_categories
	WHERE
		category_id = -1
);
-- ce_products_scd
INSERT
	INTO
	bl_3nf.ce_products_scd (
    product_id,
	product_src_id,
	product_name,
	category_id,
	start_dt,
	end_dt,
	is_active,
	source_id,
	source_system,
	source_entity,
	ta_insert_dt
)
SELECT
	-1,
	'n.a.',
	'n.a.',
	-1,
	DATE '1990-01-01',
	DATE '9999-12-31',
	'N',
	'n.a.',
	'manual',
	'manual',
	CURRENT_DATE
WHERE
	NOT EXISTS (
	SELECT
		1
	FROM
		bl_3nf.ce_products_scd
	WHERE
		product_id = -1
		AND start_dt = DATE '1990-01-01'
);

COMMIT;

--DEFAULT ROWS CHECK
--SELECT address_id, address_src_id, address, city_id, source_system, source_entity, ta_insert_dt, ta_update_dt FROM bl_3nf.ce_addresses;
--SELECT bank_id, bank_src_id, bank_name, source_system, source_entity, ta_insert_dt, ta_update_dt FROM bl_3nf.ce_banks;
--SELECT card_information_id, card_information_src_id, bank_id, card_type_id, source_system, source_entity, ta_insert_dt, ta_update_dt FROM bl_3nf.ce_card_informations;
--SELECT card_type_id, card_type_src_id, card_type_name, source_system, source_entity, ta_insert_dt, ta_update_dt FROM bl_3nf.ce_card_types;
--SELECT category_id, category_src_id, category_name, source_system, source_entity, ta_insert_dt, ta_update_dt FROM bl_3nf.ce_categories;
--SELECT city_id, city_src_id, city_name, country_id, source_system, source_entity, ta_insert_dt, ta_update_dt FROM bl_3nf.ce_cities;
--SELECT country_id, country_src_id, country_name, source_system, source_entity, ta_insert_dt, ta_update_dt FROM bl_3nf.ce_countries;
--SELECT customer_id, customer_src_id, first_name, last_name, phone_number, source_system, source_entity, ta_insert_dt, ta_update_dt FROM bl_3nf.ce_customers;
--SELECT discount_id, discount_percentage, discount_date, source_id, source_system, source_entity, ta_insert_dt, ta_update_dt FROM bl_3nf.ce_discounts;
--SELECT emp_id, emp_src_id, first_name, last_name, dob, personal_id, phone_number, source_system, source_entity, ta_insert_dt, ta_update_dt FROM bl_3nf.ce_employees;
--SELECT point_id, point_src_id, point_name, address_id, source_system, source_entity, ta_insert_dt, ta_update_dt FROM bl_3nf.ce_points;
--SELECT product_id, product_src_id, product_name, category_id, start_dt, end_dt, is_active, source_id, source_system, source_entity, ta_insert_dt FROM bl_3nf.ce_products_scd;
--SELECT sales_id, event_dt, product_id, discount_id, product_price, payment_amount, payment_type, point_id, customer_id, employee_id, card_type_id, source_id, source_system, source_entity, ta_insert_dt, ta_update_dt FROM bl_3nf.ce_sales;



--INSERTING DATA FROM SRC TABLES

--CE_CUSTOMERS
-- Insert customers from src_cash_orders
INSERT INTO bl_3nf.ce_customers (
    customer_id,
    customer_src_id,
    first_name,
    last_name,
    phone_number,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_customers'),
    COALESCE('cash_orders_' || cust_phone_number, 'n.a.'),
    COALESCE(cust_first_name, 'n.a.'),
    COALESCE(cust_last_name, 'n.a.'),
    COALESCE(cust_phone_number, 'n.a.'),
    'cash_orders',
    'src_cash_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM sa_cash_orders.src_cash_orders sc
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_customers c
    WHERE c.customer_src_id = COALESCE('cash_orders_' || sc.cust_phone_number, 'n.a.')
);

-- Insert customers from src_card_orders
INSERT INTO bl_3nf.ce_customers (
    customer_id,
    customer_src_id,
    first_name,
    last_name,
    phone_number,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_customers'),
    COALESCE('card_orders_' || cust_phone_number, 'n.a.'),
    COALESCE(cust_first_name, 'n.a.'),
    COALESCE(cust_last_name, 'n.a.'),
    COALESCE(cust_phone_number, 'n.a.'),
    'card_orders',
    'src_card_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM sa_card_orders.src_card_orders sc
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_customers c
    WHERE c.customer_src_id = COALESCE('card_orders_' || sc.cust_phone_number, 'n.a.')
);


--SELECT * FROM bl_3nf.ce_customers;

--CE_EMPLOYEES
-- Insert employees from src_cash_orders

-- From src_cash_orders
INSERT INTO bl_3nf.ce_employees (
    emp_id,
    emp_src_id,
    first_name,
    last_name,
    dob,
    personal_id,
    phone_number,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_employees'),
    COALESCE(employee_personal_id, 'n.a.'),
    COALESCE(employee_first_name, 'n.a.'),
    COALESCE(employee_last_name, 'n.a.'),
    COALESCE(NULLIF(employee_dob, '')::date, DATE '1990-01-01'),
    COALESCE(employee_personal_id, 'n.a.'),
    COALESCE(employee_phone_number, 'n.a.'),
    'cash_orders',
    'src_cash_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT
        employee_personal_id,
        employee_first_name,
        employee_last_name,
        employee_dob,
        employee_phone_number
    FROM sa_cash_orders.src_cash_orders
    WHERE employee_personal_id IS NOT NULL
) sc
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_employees e
    WHERE e.personal_id = sc.employee_personal_id
);

-- From src_card_orders
INSERT INTO bl_3nf.ce_employees (
    emp_id,
    emp_src_id,
    first_name,
    last_name,
    dob,
    personal_id,
    phone_number,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_employees'),
    COALESCE(emp_personal_id, 'n.a.'),
    COALESCE(emp_first_name, 'n.a.'),
    COALESCE(emp_last_name, 'n.a.'),
    COALESCE(NULLIF(emp_dob, '')::date, DATE '1990-01-01'),
    COALESCE(emp_personal_id, 'n.a.'),
    COALESCE(emp_phone_number, 'n.a.'),
    'card_orders',
    'src_card_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT
        emp_personal_id,
        emp_first_name,
        emp_last_name,
        emp_dob,
        emp_phone_number
    FROM sa_card_orders.src_card_orders
    WHERE emp_personal_id IS NOT NULL
) sc
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_employees e
    WHERE e.personal_id = sc.emp_personal_id
);


SELECT * FROM bl_3nf.ce_employees;


--CE_DISCOUNTS
-- Insert discounts from src_cash_orders
INSERT INTO bl_3nf.ce_discounts (
    discount_id,
    discount_percentage,
    discount_date,
    source_id,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_discount'),
    COALESCE(NULLIF(discount_percentage, '')::DECIMAL, 0.00),
    COALESCE(NULLIF(discount_date, '')::DATE, DATE '1990-01-01'),
    COALESCE(order_id, 'n.a.'),
    'cash_orders',
    'src_cash_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT
        order_id,
        discount_percentage,
        discount_date
    FROM sa_cash_orders.src_cash_orders
    WHERE order_id IS NOT NULL
) sc
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_discounts d
    WHERE d.source_id = sc.order_id
      AND d.source_system = 'cash_orders'
      AND d.source_entity = 'src_cash_orders'
);
SELECT * FROM bl_3NF.ce_discounts;
-- Insert discounts from src_card_orders
INSERT INTO bl_3nf.ce_discounts (
    discount_id,
    discount_percentage,
    discount_date,
    source_id,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_discount'),
    COALESCE(NULLIF(discount_percentage, '')::DECIMAL, 0.00),
    COALESCE(NULLIF(discount_date, '')::DATE, DATE '1990-01-01'),
    COALESCE(order_id, 'n.a.'),
    'card_orders',
    'src_card_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT
        order_id,
        discount_percentage,
        discount_date
    FROM sa_card_orders.src_card_orders
    WHERE order_id IS NOT NULL
) sc
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_discounts d
    WHERE d.source_id = sc.order_id
      AND d.source_system = 'card_orders'
      AND d.source_entity = 'src_card_orders'
);

--CE_COUNTRIES
-- Insert countries from src_cash_orders
INSERT INTO bl_3nf.ce_countries (
    country_id,
    country_src_id,
    country_name,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_country'),
    COALESCE(point_country, 'n.a.'),
    COALESCE(point_country, 'n.a.'),
    'cash_orders',
    'src_cash_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT point_country
    FROM sa_cash_orders.src_cash_orders
    WHERE point_country IS NOT NULL
) sc
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_countries c
    WHERE c.country_src_id = sc.point_country
      AND c.source_system = 'cash_orders'
      AND c.source_entity = 'src_cash_orders'
);

-- Insert countries from src_card_orders
INSERT INTO bl_3nf.ce_countries (
    country_id,
    country_src_id,
    country_name,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_country'),
    COALESCE(point_country, 'n.a.'),
    COALESCE(point_country, 'n.a.'),
    'card_orders',
    'src_card_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT point_country
    FROM sa_card_orders.src_card_orders
    WHERE point_country IS NOT NULL
) sc
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_countries c
    WHERE c.country_src_id = sc.point_country
      AND c.source_system = 'card_orders'
      AND c.source_entity = 'src_card_orders'
);


SELECT * FROM bl_3nf.ce_countries;

--CE_CITIES
-- Insert countries from src_cash_orders
INSERT INTO bl_3nf.ce_cities (
    city_id,
    city_src_id,
    city_name,
    country_id,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_country'),
    COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.'),
    COALESCE(sc.point_city, 'n.a.'),
    COALESCE(c.country_id, -1),
    'cash_orders',
    'src_cash_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT point_city, point_country
    FROM sa_cash_orders.src_cash_orders
    WHERE point_city IS NOT NULL AND point_country IS NOT NULL
) sc
LEFT JOIN bl_3nf.ce_countries c
    ON c.country_src_id = sc.point_country
   AND c.source_system = 'cash_orders'
   AND c.source_entity = 'src_cash_orders'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_cities ci
    WHERE ci.city_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.')
      AND ci.source_system = 'cash_orders'
      AND ci.source_entity = 'src_cash_orders'
);


-- Insert countries from src_card_orders
INSERT INTO bl_3nf.ce_cities (
    city_id,
    city_src_id,
    city_name,
    country_id,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_country'),
    COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.'),
    COALESCE(sc.point_city, 'n.a.'),
    COALESCE(c.country_id, -1),
    'card_orders',
    'src_card_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT point_city, point_country
    FROM sa_card_orders.src_card_orders
    WHERE point_city IS NOT NULL AND point_country IS NOT NULL
) sc
LEFT JOIN bl_3nf.ce_countries c
    ON c.country_src_id = sc.point_country
   AND c.source_system = 'card_orders'
   AND c.source_entity = 'src_card_orders'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_cities ci
    WHERE ci.city_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.')
      AND ci.source_system = 'card_orders'
      AND ci.source_entity = 'src_card_orders'
);

SELECT * FROM bl_3nf.ce_cities;

--CE_addresse
-- Insert adres from src_cash_orders
INSERT INTO bl_3nf.ce_addresses (
    address_id,
    address_src_id,
    address,
    city_id,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_address'),
    COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.'),
    COALESCE(sc.point_address, 'n.a.'),
    COALESCE(ci.city_id, -1),
    'cash_orders',
    'src_cash_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT point_address, point_city, point_country
    FROM sa_cash_orders.src_cash_orders
    WHERE point_address IS NOT NULL AND point_city IS NOT NULL
) sc
LEFT JOIN bl_3nf.ce_cities ci
    ON ci.city_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.')
   AND ci.source_system = 'cash_orders'
   AND ci.source_entity = 'src_cash_orders'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_addresses a
    WHERE a.address_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.')
      AND a.source_system = 'cash_orders'
      AND a.source_entity = 'src_cash_orders'
);



-- Insert addreses from src_card_orders
INSERT INTO bl_3nf.ce_addresses (
    address_id,
    address_src_id,
    address,
    city_id,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_address'),
    COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.'),
    COALESCE(sc.point_address, 'n.a.'),
    COALESCE(ci.city_id, -1),
    'card_orders',
    'src_card_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT point_address, point_city, point_country
    FROM sa_card_orders.src_card_orders
    WHERE point_address IS NOT NULL AND point_city IS NOT NULL
) sc
LEFT JOIN bl_3nf.ce_cities ci
    ON ci.city_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.')
   AND ci.source_system = 'card_orders'
   AND ci.source_entity = 'src_card_orders'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_addresses a
    WHERE a.address_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.')
      AND a.source_system = 'card_orders'
      AND a.source_entity = 'src_card_orders'
);


SELECT * FROM bl_3nf.ce_addresses ca ;

--CE_POINTS
--from cash src
INSERT INTO bl_3nf.ce_points (
    point_id,
    point_src_id,
    point_name,
    address_id,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_points'),
    COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.') || '|' || COALESCE(sc.point_name, 'n.a.'),
    COALESCE(sc.point_name, 'n.a.'),
    COALESCE(a.address_id, -1),
    'cash_orders',
    'src_cash_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT point_name, point_address, point_city, point_country
    FROM sa_cash_orders.src_cash_orders
    WHERE point_name IS NOT NULL
) sc
LEFT JOIN bl_3nf.ce_addresses a
    ON a.address_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.')
   AND a.source_system = 'cash_orders'
   AND a.source_entity = 'src_cash_orders'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_points p
    WHERE p.point_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.') || '|' || COALESCE(sc.point_name, 'n.a.')
      AND p.source_system = 'cash_orders'
      AND p.source_entity = 'src_cash_orders'
);

--from card src
INSERT INTO bl_3nf.ce_points (
    point_id,
    point_src_id,
    point_name,
    address_id,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_points'),
    COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.') || '|' || COALESCE(sc.point_name, 'n.a.'),
    COALESCE(sc.point_name, 'n.a.'),
    COALESCE(a.address_id, -1),
    'card_orders',
    'src_card_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT point_name, point_address, point_city, point_country
    FROM sa_card_orders.src_card_orders
    WHERE point_name IS NOT NULL
) sc
LEFT JOIN bl_3nf.ce_addresses a
    ON a.address_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.')
   AND a.source_system = 'card_orders'
   AND a.source_entity = 'src_card_orders'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_points p
    WHERE p.point_src_id = COALESCE(sc.point_country, 'n.a.') || '|' || COALESCE(sc.point_city, 'n.a.') || '|' || COALESCE(sc.point_address, 'n.a.') || '|' || COALESCE(sc.point_name, 'n.a.')
      AND p.source_system = 'card_orders'
      AND p.source_entity = 'src_card_orders'
);

SELECT * FROM bl_3nf.ce_points cp ;


--CE_BANKS only from card source
INSERT INTO bl_3nf.ce_banks (
    bank_id,
    bank_src_id,
    bank_name,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_banks'),
    COALESCE(bank_of_card, 'n.a.'),
    COALESCE(bank_of_card, 'n.a.'),
    'card_orders',
    'src_card_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT bank_of_card
    FROM sa_card_orders.src_card_orders
    WHERE bank_of_card IS NOT NULL
) sc
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_banks b
    WHERE b.bank_src_id = sc.bank_of_card
      AND b.source_system = 'card_orders'
      AND b.source_entity = 'src_card_orders'
);
SELECT * FROM bl_3nf.ce_banks ;


--CE_CARD_TYPES only from card source
INSERT INTO bl_3nf.ce_card_types (
    card_type_id,
    card_type_src_id,
    card_type_name,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_card_types'),
    COALESCE(card_type, 'n.a.'),
    COALESCE(card_type, 'n.a.'),
    'card_orders',
    'src_card_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT card_type
    FROM sa_card_orders.src_card_orders
    WHERE card_type IS NOT NULL
) sc
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_card_types ct
    WHERE ct.card_type_src_id = sc.card_type
      AND ct.source_system = 'card_orders'
      AND ct.source_entity = 'src_card_orders'
);

SELECT * FROM bl_3nf.ce_card_types cct ;


--CE_CARD_INFORMATIONS only from card source
INSERT INTO bl_3nf.ce_card_informations (
    card_information_id,
    card_information_src_id,
    bank_id,
    card_type_id,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_card_information'),
    COALESCE(sc.bank_of_card, 'n.a.') || '|' || COALESCE(sc.card_type, 'n.a.'),
    COALESCE(b.bank_id, -1),
    COALESCE(ct.card_type_id, -1),
    'card_orders',
    'src_card_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT bank_of_card, card_type
    FROM sa_card_orders.src_card_orders
    WHERE bank_of_card IS NOT NULL AND card_type IS NOT NULL
) sc
LEFT JOIN bl_3nf.ce_banks b
    ON b.bank_src_id = sc.bank_of_card
   AND b.source_system = 'card_orders'
   AND b.source_entity = 'src_card_orders'
LEFT JOIN bl_3nf.ce_card_types ct
    ON ct.card_type_src_id = sc.card_type
   AND ct.source_system = 'card_orders'
   AND ct.source_entity = 'src_card_orders'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_card_informations ci
    WHERE ci.card_information_src_id = COALESCE(sc.bank_of_card, 'n.a.') || '|' || COALESCE(sc.card_type, 'n.a.')
      AND ci.source_system = 'card_orders'
      AND ci.source_entity = 'src_card_orders'
);

SELECT * FROM bl_3nf.ce_card_informations cci ;


--CE_CATEGORIES
--from cash source
INSERT INTO bl_3nf.ce_categories (
    category_id,
    category_src_id,
    category_name,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_categories'),
    COALESCE(prod_category, 'n.a.'),
    COALESCE(prod_category, 'n.a.'),
    'cash_orders',
    'src_cash_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT prod_category
    FROM sa_cash_orders.src_cash_orders
    WHERE prod_category IS NOT NULL
) sc
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_categories c
    WHERE c.category_src_id = sc.prod_category
      AND c.source_system = 'cash_orders'
      AND c.source_entity = 'src_cash_orders'
);

--from card source
INSERT INTO bl_3nf.ce_categories (
    category_id,
    category_src_id,
    category_name,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_categories'),
    COALESCE(prod_category, 'n.a.'),
    COALESCE(prod_category, 'n.a.'),
    'card_orders',
    'src_card_orders',
    CURRENT_DATE,
    CURRENT_DATE
FROM (
    SELECT DISTINCT prod_category
    FROM sa_card_orders.src_card_orders
    WHERE prod_category IS NOT NULL
) sc
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_categories c
    WHERE c.category_src_id = sc.prod_category
      AND c.source_system = 'card_orders'
      AND c.source_entity = 'src_card_orders'
);

SELECT * FROM bl_3nf.ce_categories cc ;

--CE_PRODUCTS_SCD
--from cash source
INSERT INTO bl_3nf.ce_products_scd (
    product_id,
    product_src_id,
    product_name,
    category_id,
    start_dt,
    end_dt,
    is_active,
    source_id,
    source_system,
    source_entity,
    ta_insert_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_products_scd'),
    COALESCE(prod_code, 'n.a.'),
    COALESCE(prod_name, 'n.a.'),
    COALESCE(c.category_id, -1),
    CURRENT_DATE,
    DATE '9999-12-31',
    'Y',
    COALESCE(prod_code, 'n.a.'),  -- used as source_id
    'cash_orders',
    'src_cash_orders',
    CURRENT_DATE
FROM (
    SELECT DISTINCT prod_code, prod_name, prod_category
    FROM sa_cash_orders.src_cash_orders
    WHERE prod_code IS NOT NULL
) sc
LEFT JOIN bl_3nf.ce_categories c
    ON c.category_src_id = sc.prod_category
   AND c.source_system = 'cash_orders'
   AND c.source_entity = 'src_cash_orders'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_products_scd p
    WHERE p.product_src_id = sc.prod_code
      AND p.product_name = sc.prod_name
      AND p.category_id = COALESCE(c.category_id, -1)
      AND p.source_system = 'cash_orders'
      AND p.source_entity = 'src_cash_orders'
);

--from card source
INSERT INTO bl_3nf.ce_products_scd (
    product_id,
    product_src_id,
    product_name,
    category_id,
    start_dt,
    end_dt,
    is_active,
    source_id,
    source_system,
    source_entity,
    ta_insert_dt
)
SELECT 
    NEXTVAL('bl_3nf.seq_ce_products_scd'),
    COALESCE(prod_code, 'n.a.'),
    COALESCE(prod_name, 'n.a.'),
    COALESCE(c.category_id, -1),
    CURRENT_DATE,
    DATE '9999-12-31',
    'Y',
    COALESCE(prod_code, 'n.a.'),  -- used as source_id
    'card_orders',
    'src_card_orders',
    CURRENT_DATE
FROM (
    SELECT DISTINCT prod_code, prod_name, prod_category
    FROM sa_card_orders.src_card_orders
    WHERE prod_code IS NOT NULL
) sc
LEFT JOIN bl_3nf.ce_categories c
    ON c.category_src_id = sc.prod_category
   AND c.source_system = 'card_orders'
   AND c.source_entity = 'src_card_orders'
WHERE NOT EXISTS (
    SELECT 1
    FROM bl_3nf.ce_products_scd p
    WHERE p.product_src_id = sc.prod_code
      AND p.product_name = sc.prod_name
      AND p.category_id = COALESCE(c.category_id, -1)
      AND p.source_system = 'card_orders'
      AND p.source_entity = 'src_card_orders'
);

SELECT * FROM bl_3nf.ce_products_scd cps ;

--CE_SALES

INSERT INTO bl_3nf.ce_sales (
    sales_id,
    event_dt,
    product_id,
    discount_id,
    product_price,
    payment_amount,
    payment_type,
    point_id,
    customer_id,
    employee_id,
    card_information_id,
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
    COALESCE(NULLIF(payment_amount, '')::decimal, 0.00),
    'CASH',
    COALESCE(pt.point_id, -1),
    COALESCE(c.customer_id, -1),
    COALESCE(e.emp_id, -1),
    -1,  -- no card info for cash
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
    ON d.source_id = sc.order_id
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

--from card source 
INSERT INTO bl_3nf.ce_sales (
    sales_id,
    event_dt,
    product_id,
    discount_id,
    product_price,
    payment_amount,
    payment_type,
    point_id,
    customer_id,
    employee_id,
    card_information_id,
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
    COALESCE(NULLIF(payment_amount, '')::decimal, 0.00),
    'CARD',
    COALESCE(pt.point_id, -1),
    COALESCE(c.customer_id, -1),
    COALESCE(e.emp_id, -1),
    COALESCE(ci.card_information_id, -1),
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
    ON d.source_id = sc.order_id
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
    ON e.personal_id = sc.emp_personal_id
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
SELECT * FROM bl_3nf.ce_sales;

COMMIT;


