DO $$
BEGIN
	IF NOT EXISTS (
		SELECT FROM pg_catalog.pg_roles WHERE rolname = 'bl_cl_user'
	) THEN
		CREATE ROLE bl_cl_user LOGIN PASSWORD 'blcl';
	END IF;
END
$$;
-- Reading priveleges in staging area SA
GRANT USAGE ON SCHEMA sa_cash_orders TO bl_cl_user;
GRANT USAGE ON SCHEMA sa_card_orders TO bl_cl_user;
GRANT SELECT ON ALL TABLES IN SCHEMA sa_cash_orders TO bl_cl_user;
GRANT SELECT ON ALL TABLES IN SCHEMA sa_card_orders TO bl_cl_user;

-- To be able work with data in 3nf layer tables + sequnces
GRANT USAGE ON SCHEMA bl_3nf TO bl_cl_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA bl_3nf TO bl_cl_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA bl_3nf TO bl_cl_user;

-- To be able work with data in dm layer tables + sequnces
GRANT USAGE ON SCHEMA bl_dm TO bl_cl_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA bl_dm TO bl_cl_user;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA bl_dm TO bl_cl_user;

-- Grant access to procedures, select, etl_log in bl_cl
GRANT USAGE ON SCHEMA bl_cl TO bl_cl_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA bl_cl TO bl_cl_user;
GRANT USAGE, SELECT ON SEQUENCE bl_cl.etl_log_log_id_seq TO bl_cl_user;
GRANT INSERT, SELECT, UPDATE ON bl_cl.etl_log TO bl_cl_user;
