--DIM_CHANNELS
--composite types for channel
DROP TYPE IF EXISTS bl_cl.channel_type;
CREATE TYPE bl_cl.channel_type AS (
    channel_src_id VARCHAR(255),
    channel_name VARCHAR(64),
    channel_desc VARCHAR(255),
    source_system VARCHAR(255),
    source_entity VARCHAR(255)
);

CREATE OR REPLACE PROCEDURE bl_cl.p_load_dim_channels()
LANGUAGE plpgsql
AS
$$
DECLARE
    v_channel        bl_cl.channel_type;
    v_rows_inserted  INT := 0;
    v_rows_updated   INT := 0;
BEGIN
    FOR v_channel IN
        SELECT 
            channel_src_id,
            channel_name,
            channel_desc,
            source_system,
            source_entity
        FROM bl_3nf.ce_channels
    LOOP
        -- upsert: inser on coflict update
        INSERT INTO bl_dm.dim_channels (
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
			nextval('bl_dm.seq_dim_channels'),
            v_channel.channel_src_id,
            v_channel.channel_name,
            v_channel.channel_desc,
            v_channel.source_system,
            v_channel.source_entity,
            CURRENT_DATE,
            CURRENT_DATE
        )
        ON CONFLICT (channel_src_id, source_system, source_entity) DO UPDATE
        SET
            channel_name   = EXCLUDED.channel_name,
            channel_desc   = EXCLUDED.channel_desc,
            source_system  = EXCLUDED.source_system,
            source_entity  = EXCLUDED.source_entity,
            ta_update_dt   = CURRENT_DATE;

		-- count in case of update or insert
        IF EXISTS (
            SELECT 1
            FROM bl_dm.dim_channels
            WHERE channel_src_id = v_channel.channel_src_id
              AND ta_update_dt = CURRENT_DATE
              AND ta_insert_dt <> CURRENT_DATE  -- this meant updated
        ) THEN
            v_rows_updated := v_rows_updated + 1;
        ELSE
            v_rows_inserted := v_rows_inserted + 1;
        END IF;
    END LOOP;

    -- log
    CALL bl_cl.p_log_event(
        'p_load_dim_channels',
        v_rows_inserted,
        v_rows_updated,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Updated: ' || v_rows_updated
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'p_load_dim_channels',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;


SELECT * FROM bl_3nf.ce_customers ;
--DIM_CUSTOMERS
CREATE OR REPLACE PROCEDURE bl_cl.p_load_dim_customers()
LANGUAGE plpgsql
AS $$
DECLARE
    v_customer        RECORD;
    v_rows_inserted   INTEGER := 0;
    v_rows_updated    INTEGER := 0;
    v_sql             TEXT;
BEGIN
    FOR v_customer IN
        SELECT
            customer_src_id,
            first_name,
            last_name,
            phone_number,
            source_system,
            source_entity
        FROM bl_3nf.ce_customers
    LOOP
        -- Dynamic upsert using format + USING
        v_sql := format($f$
            INSERT INTO bl_dm.dim_customers (
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
            VALUES (
                nextval('bl_dm.seq_dim_customers'),
                $1, $2, $3, $4, $5, $6,
                CURRENT_DATE, CURRENT_DATE
            )
            ON CONFLICT (customer_src_id, source_system, source_entity) DO UPDATE
            SET
                first_name   = EXCLUDED.first_name,
                last_name    = EXCLUDED.last_name,
                ta_update_dt = CURRENT_DATE
        $f$);

        EXECUTE v_sql
        USING 
            v_customer.customer_src_id,
            v_customer.first_name,
            v_customer.last_name,
            v_customer.phone_number,
            v_customer.source_system,
            v_customer.source_entity;

        -- check if record was updated
        IF EXISTS (
            SELECT 1
            FROM bl_dm.dim_customers
            WHERE customer_src_id = v_customer.customer_src_id
              AND source_system = v_customer.source_system
              AND source_entity = v_customer.source_entity
              AND ta_update_dt = CURRENT_DATE
              AND ta_insert_dt <> CURRENT_DATE
        ) THEN
            v_rows_updated := v_rows_updated + 1;
        ELSE
            v_rows_inserted := v_rows_inserted + 1;
        END IF;
    END LOOP;

    -- log
    CALL bl_cl.p_log_event(
        'p_load_dim_customers',
        v_rows_inserted,
        v_rows_updated,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Updated: ' || v_rows_updated
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'p_load_dim_customers',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;


--DIM_EMPLOYEES
CREATE OR REPLACE PROCEDURE bl_cl.p_load_dim_employees()
LANGUAGE plpgsql
AS $$
DECLARE
    v_row RECORD;
    v_rows_inserted INTEGER := 0;
    v_rows_updated INTEGER := 0;
BEGIN
    -- loop through all source rows
    FOR v_row IN
        SELECT
            emp_src_id,
            first_name,
            last_name,
            dob,
            personal_id,
            phone_number,
            source_system,
            source_entity
        FROM bl_3nf.ce_employees
    LOOP
        -- insert new rows; on conflict do update
        INSERT INTO bl_dm.dim_employees (
            emp_id,
            emp_src_id,
            first_name,
            last_name,
            dob_dt,
            personal_id,
            phone_number,
            source_system,
            source_entity,
            ta_insert_dt,
            ta_update_dt
        )
        VALUES (
            nextval('bl_dm.seq_dim_employees'),
            v_row.emp_src_id,
            v_row.first_name,
            v_row.last_name,
            v_row.dob,
            v_row.personal_id,
            v_row.phone_number,
            v_row.source_system,
            v_row.source_entity,
            CURRENT_DATE,
            CURRENT_DATE
        )
        ON CONFLICT (personal_id, source_system, source_entity) DO UPDATE
        SET
            first_name     = EXCLUDED.first_name,
            last_name      = EXCLUDED.last_name,
            dob_dt         = EXCLUDED.dob_dt,
            phone_number   = EXCLUDED.phone_number,
            emp_src_id     = EXCLUDED.emp_src_id,
            ta_update_dt   = CURRENT_DATE;

        -- check if updated or inserted
        IF EXISTS (
            SELECT 1
            FROM bl_dm.dim_employees
            WHERE personal_id    = v_row.personal_id
              AND source_system  = v_row.source_system
              AND source_entity  = v_row.source_entity
              AND ta_update_dt   = CURRENT_DATE
              AND ta_insert_dt  <> CURRENT_DATE
        ) THEN
            v_rows_updated := v_rows_updated + 1;
        ELSE
            v_rows_inserted := v_rows_inserted + 1;
        END IF;
    END LOOP;

    -- log event
    CALL bl_cl.p_log_event(
        'p_load_dim_employees',
        v_rows_inserted,
        v_rows_updated,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Updated: ' || v_rows_updated
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'p_load_dim_employees',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;




--DIM_DISCOUNTS
CREATE OR REPLACE PROCEDURE bl_cl.p_load_dim_discounts()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_total_rows INTEGER := 0;
BEGIN
    -- count all rows from source
    SELECT COUNT(*) INTO v_total_rows FROM bl_3nf.ce_discounts;

    -- insert new rows; on conflict do nothing
    INSERT INTO bl_dm.dim_discounts (
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
        nextval('bl_dm.seq_dim_discount'),
        discount_percentage,
        discount_date,
        source_id,
        source_system,
        source_entity,
        CURRENT_DATE,
        CURRENT_DATE
    FROM bl_3nf.ce_discounts d
    ON CONFLICT (source_id, source_system, source_entity)
    DO NOTHING;

    -- row count for inserted rows
    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- skipped rows = total rows - inserted rows
    v_rows_skipped := v_total_rows - v_rows_inserted;

    -- log event
    CALL bl_cl.p_log_event(
        'p_load_dim_discounts',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'p_load_dim_discounts',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;


-- DIM_CARD_INFORMATIONS
CREATE OR REPLACE PROCEDURE bl_cl.p_load_dim_card_informations()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_total_rows INTEGER := 0;
BEGIN
    -- count all rows from source
    SELECT COUNT(*) INTO v_total_rows FROM bl_3nf.ce_card_informations;

    -- insert new rows; on conflict do nothing
    INSERT INTO bl_dm.dim_card_informations (
        card_information_id,
        card_information_src_id,
        card_bank_id,
        card_bank_name,
        card_type_id,
        card_type_name,
        source_system,
        source_entity,
        ta_insert_dt,
        ta_update_dt
    )
    SELECT
        nextval('bl_dm.seq_dim_card_information'),
        ci.card_information_src_id,
        b.bank_id,
        b.bank_name,
        ct.card_type_id,
        ct.card_type_name,
        ci.source_system,
        ci.source_entity,
        CURRENT_DATE,
        CURRENT_DATE
    FROM bl_3nf.ce_card_informations ci
    LEFT JOIN bl_3nf.ce_banks b
        ON b.bank_id = ci.bank_id
    LEFT JOIN bl_3nf.ce_card_types ct
        ON ct.card_type_id = ci.card_type_id
    ON CONFLICT (card_information_src_id, source_system, source_entity)
    DO NOTHING;

    -- row count for inserted rows
    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- skipped rows = total rows - inserted rows
    v_rows_skipped := v_total_rows - v_rows_inserted;

    -- log event
    CALL bl_cl.p_log_event(
        'p_load_dim_card_informations',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'p_load_dim_card_informations',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;


-- DIM_POINTS
CREATE OR REPLACE PROCEDURE bl_cl.p_load_dim_points()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_total_rows INTEGER := 0;
BEGIN
    -- count all rows from source
    SELECT COUNT(*) INTO v_total_rows FROM bl_3nf.ce_points;

    -- insert with join to get address/city/country info
    INSERT INTO bl_dm.dim_points (
        point_id,
        point_src_id,
        point_name,
        point_address_id,
        point_address,
        point_city_id,
        point_city_name,
        point_country_id,
        point_country_name,
        source_system,
        source_entity,
        ta_insert_dt,
        ta_update_dt
    )
    SELECT
        nextval('bl_dm.seq_dim_points'),
        p.point_src_id,
        p.point_name,
        a.address_id,
        a.address,
        c.city_id,
        c.city_name,
        co.country_id,
        co.country_name,
        p.source_system,
        p.source_entity,
        CURRENT_DATE,
        CURRENT_DATE
    FROM bl_3nf.ce_points p
    LEFT JOIN bl_3nf.ce_addresses a ON a.address_id = p.address_id
    LEFT JOIN bl_3nf.ce_cities c ON c.city_id = a.city_id
    LEFT JOIN bl_3nf.ce_countries co ON co.country_id = c.country_id
    ON CONFLICT (point_src_id, source_system, source_entity)
    DO NOTHING;

    -- row count for inserted rows
    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;

    -- skipped rows = total rows - inserted rows
    v_rows_skipped := v_total_rows - v_rows_inserted;

    -- log event
    CALL bl_cl.p_log_event(
        'p_load_dim_points',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'p_load_dim_points',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;


--DIM_PRODUCTS
CREATE OR REPLACE PROCEDURE bl_cl.p_load_dim_products_scd()
LANGUAGE plpgsql
AS $$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_skipped INTEGER := 0;
    v_total_rows INTEGER := 0;
BEGIN
    -- get count of rows
    SELECT COUNT(*) INTO v_total_rows FROM bl_3nf.ce_products_scd;

    -- update only changed products
	WITH changed_rows AS (
    SELECT
        tgt.product_id,
        COALESCE(cat.ta_update_dt, src.start_dt) AS actual_start_dt
    FROM bl_dm.dim_products_scd tgt
    JOIN bl_3nf.ce_products_scd src
      ON tgt.product_src_id = src.product_src_id
     AND tgt.source_system = src.source_system
     AND tgt.source_entity = src.source_entity
     AND tgt.is_active = 'Y'
    LEFT JOIN bl_3nf.ce_categories cat
      ON src.category_id = cat.category_id
     AND src.source_system = cat.source_system
     AND src.source_entity = cat.source_entity
    WHERE
        tgt.product_name IS DISTINCT FROM src.product_name OR
        tgt.product_category_id IS DISTINCT FROM src.category_id OR
        tgt.product_category_name IS DISTINCT FROM COALESCE(cat.category_name, 'n.a.')
	)
	UPDATE bl_dm.dim_products_scd tgt
	SET
	    end_dt = cr.actual_start_dt - INTERVAL '1 day',
	    is_active = 'N',
	    ta_insert_dt = CURRENT_DATE
	FROM changed_rows cr
	WHERE tgt.product_id = cr.product_id
	  AND cr.actual_start_dt - INTERVAL '1 day' >= tgt.start_dt;


    -- insert new rows
    WITH ranked_products AS (
        SELECT
            p.product_src_id,
            p.product_name,
            p.category_id AS product_category_id,
            c.category_name AS product_category_name,
            p.start_dt,
            p.end_dt,
            p.is_active,
            p.source_id,
            p.source_system,
            p.source_entity,
            p.ta_insert_dt,
            ROW_NUMBER() OVER (
                PARTITION BY p.product_src_id, p.source_system, p.source_entity
                ORDER BY p.start_dt DESC, p.ta_insert_dt DESC
            ) AS rn
        FROM bl_3nf.ce_products_scd p
        LEFT JOIN bl_3nf.ce_categories c
          ON p.category_id = c.category_id
         AND p.source_system = c.source_system
         AND p.source_entity = c.source_entity
    )
    INSERT INTO bl_dm.dim_products_scd (
        product_id,
        product_src_id,
        product_name,
        product_category_id,
        product_category_name,
        start_dt,
        end_dt,
        is_active,
        source_id,
        source_system,
        source_entity,
        ta_insert_dt
    )
    SELECT
        nextval('bl_dm.seq_dim_products_scd'),
        product_src_id,
        product_name,
        product_category_id,
        COALESCE(product_category_name, 'n.a.'),
        start_dt,
        end_dt,
        CASE WHEN rn = 1 THEN 'Y' ELSE 'N' END,
        source_id,
        source_system,
        source_entity,
        CURRENT_DATE
    FROM ranked_products
    WHERE NOT EXISTS (
        SELECT 1
        FROM bl_dm.dim_products_scd tgt
        WHERE tgt.product_src_id        = ranked_products.product_src_id
          AND tgt.source_system         = ranked_products.source_system
          AND tgt.source_entity         = ranked_products.source_entity
          AND tgt.product_name          = ranked_products.product_name
          AND tgt.product_category_id   = ranked_products.product_category_id
          AND tgt.product_category_name = COALESCE(ranked_products.product_category_name, 'n.a.')
          AND tgt.start_dt              = ranked_products.start_dt
    );

    -- log
    GET DIAGNOSTICS v_rows_inserted = ROW_COUNT;
    v_rows_skipped := v_total_rows - v_rows_inserted;

    CALL bl_cl.p_log_event(
        'p_load_dim_products_scd',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );

EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'p_load_dim_products_scd',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;

SELECT * FROM bl_3nf.ce_products_scd c;