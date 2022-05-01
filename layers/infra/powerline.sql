CREATE OR REPLACE FUNCTION layer_powerline(bbox geometry, zoom_level int)
RETURNS TABLE
  (
    geometry geometry,
    class text, 
    name text
  ) 
  AS $$
    SELECT
      geometry, class, name
    FROM 
      osm_power_linestring
    WHERE 
      geometry && bbox;
$$ LANGUAGE SQL 
  STABLE
  PARALLEL SAFE;
