CREATE SCHEMA IF NOT EXISTS BL_DM;

-- DIM_DISCOUNTS: SCD1 table with source triplet; stores discount percentage and discount date.

CREATE SEQUENCE IF NOT EXISTS BL_DM.SEQ_DIM_DISCOUNT START WITH 1;

CREATE TABLE IF NOT EXISTS BL_DM.DIM_DISCOUNTS (
    DISCOUNT_ID BIGINT PRIMARY KEY,
    DISCOUNT_PERCENTAGE DECIMAL(5, 2) NOT NULL,
    DISCOUNT_DATE DATE NOT NULL,
    SOURCE_ID VARCHAR(255) NOT NULL,
    SOURCE_SYSTEM VARCHAR(255) NOT NULL,
    SOURCE_ENTITY VARCHAR(255) NOT NULL,
    TA_INSERT_DT DATE NOT NULL,
    TA_UPDATE_DT DATE NOT NULL
);

DO $$
BEGIN

    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint
        WHERE conname = 'uq_dim_discounts_src'
    ) THEN
        ALTER TABLE bl_dm.dim_discounts
        ADD CONSTRAINT uq_dim_discounts_src UNIQUE (source_id, source_system, source_entity);
    END IF;

END
$$;