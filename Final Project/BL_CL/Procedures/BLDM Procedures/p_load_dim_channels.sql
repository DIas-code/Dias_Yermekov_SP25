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
