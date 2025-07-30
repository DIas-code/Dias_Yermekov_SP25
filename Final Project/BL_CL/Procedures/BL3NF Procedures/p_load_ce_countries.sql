
CREATE OR REPLACE PROCEDURE bl_cl.p_load_ce_countries()
LANGUAGE plpgsql
AS
$$
DECLARE
    v_rows_inserted INTEGER := 0;
    v_rows_total INTEGER := 0;
    v_rows_skipped INTEGER := 0;
	record RECORD;
BEGIN
	for record in select * 
	from 
	bl_cl.f_get_countries('cash_orders', 'src_cash_orders', 'sa_cash_orders.src_cash_orders')
	LOOP
		v_rows_total := v_rows_total + 1;
		if not exists(
		        SELECT 1
		        FROM bl_3nf.ce_countries c
		        WHERE c.country_src_id = record.country_src_id
		      	AND c.source_system = record.source_system
		      	AND c.source_entity = record.source_entity
		    ) THEN
			INSERT INTO bl_3nf.ce_countries (
		        country_id,
		        country_src_id,
		        country_name,
		        source_system,
		        source_entity,
		        ta_insert_dt,
		        ta_update_dt
		    )
			values (
				NEXTVAL('bl_3nf.seq_ce_country'),
				record.country_src_id,
		        record.country_name,
		        record.source_system,
		        record.source_entity,
		        CURRENT_DATE,
		        CURRENT_DATE		
			);
				v_rows_inserted := v_rows_inserted + 1;
	    END IF;
	END LOOP;    


    -- Count from card_orders
    for record in select * 
	from 
	bl_cl.f_get_countries('card_orders', 'src_card_orders', 'sa_card_orders.src_card_orders')
	LOOP
		v_rows_total := v_rows_total + 1;
		if not exists(
		        SELECT 1
		        FROM bl_3nf.ce_countries c
		        WHERE c.country_src_id = record.country_src_id
		      	AND c.source_system = record.source_system
		      	AND c.source_entity = record.source_entity
		    ) THEN
			INSERT INTO bl_3nf.ce_countries (
		        country_id,
		        country_src_id,
		        country_name,
		        source_system,
		        source_entity,
		        ta_insert_dt,
		        ta_update_dt
		    )
			values (
				NEXTVAL('bl_3nf.seq_ce_country'),
				record.country_src_id,
		        record.country_name,
		        record.source_system,
		        record.source_entity,
		        CURRENT_DATE,
		        CURRENT_DATE		
			);
				v_rows_inserted := v_rows_inserted + 1;
	    END IF;
	END LOOP;    

    -- Calculate skipped
    v_rows_skipped := v_rows_total - v_rows_inserted;

    -- Log success
    CALL bl_cl.p_log_event(
        'load_ce_countries',
        v_rows_inserted,
        v_rows_skipped,
        'SUCCESS',
        'Inserted: ' || v_rows_inserted || ', Skipped: ' || v_rows_skipped
    );
EXCEPTION
    WHEN OTHERS THEN
        CALL bl_cl.p_log_event(
            'load_ce_countries',
            0,
            0,
            'FAIL',
            SQLERRM
        );
        RAISE;
END;
$$;
