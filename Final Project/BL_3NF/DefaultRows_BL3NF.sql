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

SELECT * FROM bl_cl.etl_log e ;
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
--ce_channels
INSERT INTO bl_3nf.ce_channels (
    channel_id,
    channel_src_id,
    channel_name,
    channel_desc,
    source_system,
    source_entity,
    ta_insert_dt,
    ta_update_dt
)
VALUES (
    -1,
    'n.a.',
    'n.a.',
    'n.a.',
    'n.a.',
    'n.a.',
    CURRENT_DATE,
    CURRENT_DATE
);