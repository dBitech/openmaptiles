-- Get the first element of a semicolon-delimited list
CREATE OR REPLACE FUNCTION
  first_semi(input TEXT)
RETURNS TEXT
AS $$
DECLARE
    parts TEXT[];
BEGIN
    parts = string_to_array(input, ';');
    RETURN parts[1];
END
$$ LANGUAGE plpgsql
  IMMUTABLE
  STRICT
  PARALLEL SAFE;

CREATE OR REPLACE FUNCTION
  layer_power(bbox geometry, zoom_level int)
  RETURNS TABLE
  (
     osm_id     bigint,
     geometry   geometry,
     name       text,
     name_en    text,
     name_es    text,
     name_fr    text,
     name_hi    text,
     name_ur    text,
     name_zh    text,
     name_ru    text,
     name_pt    text,
     name_ja    text,
     operator   text,
     ref        text,
     frequency  text,
     wikidata   text,
     wikipedia  text,
     construction text,
     tunnel     text,
     location   text,
     line       text,
     ref_len    int,
     voltage    text,
     voltage_2  text,
     voltage_3  text,
     circuits   text,
     url        text
   )
   AS $$
   SELECT
    osm_id,
    geometry,
    tags -> 'name' AS name,
    tags -> 'name:en' AS name_en,
    tags -> 'name:es' AS name_es,
    tags -> 'name:de' AS name_de,
    tags -> 'name:fr' AS name_fr,
    tags -> 'name:hi' AS name_hi,
    tags -> 'name:ur' AS name_ur,
    tags -> 'name:zh' AS name_zh,
    tags -> 'name:ru' AS name_ru,
    tags -> 'name:pt' AS name_pt,
    tags -> 'name:ja' AS name_ja,
    tags -> 'operator' AS operator,
    tags -> 'ref' AS ref,
    first_semi(tags -> 'frequency') AS frequency,
    tags -> 'wikidata' AS wikidata,
    tags -> 'wikipedia' AS wikipedia,
    (tags -> 'construction:power') IS NOT NULL AS construction,
    tunnel,
    location,
    line,
    char_length(tags -> 'ref') AS ref_len,
    voltages[1] AS voltage,
    voltages[2] AS voltage_2,
    voltages[3] AS voltage_3,
    circuits,
    osm_url(tags) AS url
  FROM
    osm_power_lines
  WHERE geometry && bbox
ORDER BY z_order ASC;
$$ LANGUAGE SQL
  STABLE
  -- STRICT
  PARALLEL SAFE;
