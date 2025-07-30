CREATE OR REPLACE FUNCTION bl_cl.f_get_countries(
    p_source TEXT,
    p_entity TEXT,
    p_table TEXT
)
RETURNS TABLE (
    country_src_id TEXT,
    country_name TEXT,
    source_system TEXT,
    source_entity TEXT
) AS
$$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := format(
        'SELECT 
            point_country::TEXT AS country_src_id,
            COALESCE(point_country, ''n.a.'')::TEXT AS country_name,
            %L::TEXT AS source_system,
            %L::TEXT AS source_entity
         FROM (
             SELECT DISTINCT point_country
             FROM %s
             WHERE point_country IS NOT NULL
         ) sub',
        p_source, p_entity, p_table
    );

    RETURN QUERY EXECUTE v_sql;
END;
$$ LANGUAGE plpgsql;
