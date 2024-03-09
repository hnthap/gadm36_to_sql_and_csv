CREATE INDEX ix_raw_gadm36_0 ON raw_gadm36_0 (gadm36_0);
CREATE INDEX ix_raw_gadm36_1 ON raw_gadm36_1 (gadm36_1);
CREATE INDEX ix_raw_gadm36_2 ON raw_gadm36_2 (gadm36_2);
CREATE INDEX ix_raw_gadm36_3 ON raw_gadm36_3 (gadm36_3);

-- Populate the table geo_entity_type

INSERT INTO geo_entity_type (primary_name, eng_name)
VALUES ('Country or Region', 'Country or Region');

-- WITH RECURSIVE splitted (gadm36_code, value, remained) AS (
--     SELECT r.gadm36_1, null, r.VARNAME_1 || '|'
--     FROM raw_gadm36_1 AS r
--     UNION ALL
--     SELECT
--         gadm36_code,
--         substr(remained, 0, instr(remained, '|')),
--         substr(remained, instr(remained, '|') + 1)
--     FROM splitted WHERE remained != ''
-- )

INSERT OR IGNORE INTO geo_entity_type (primary_name, eng_name)
SELECT TYPE_1, ENGTYPE_1 FROM raw_gadm36_1 GROUP BY TYPE_1;

INSERT OR IGNORE INTO geo_entity_type (primary_name, eng_name)
SELECT type_2, engtype_2 FROM raw_gadm36_2 GROUP BY type_2;

INSERT OR IGNORE INTO geo_entity_type (primary_name, eng_name)
SELECT type_3, engtype_3 FROM raw_gadm36_3 GROUP BY type_3;

-- Populate the table geo_entity from raw_gadm36_0

INSERT INTO geo_entity (gadm36_code, primary_name)
SELECT r.gadm36_0, r.name_0
FROM raw_gadm36_0 AS r;

UPDATE geo_entity
SET geo_entity_type_id = (
    SELECT t.geo_entity_type_id
    FROM geo_entity_type AS t
    WHERE t.eng_name = 'country/region'
);

-- Populate the table geo_entity from raw_gadm36_1

INSERT INTO geo_entity (
    gadm36_code, primary_name, native_name, geo_entity_type_id,
    parent_geo_entity_id
)
SELECT
    r.gadm36_1, r.NAME_1, r.NL_NAME_1, t.geo_entity_type_id, g.geo_entity_id
FROM raw_gadm36_1 AS r
    INNER JOIN geo_entity_type AS t ON
        r.TYPE_1 = t.primary_name AND r.ENGTYPE_1 = t.eng_name
    INNER JOIN geo_entity AS g ON
        r.GID_0_0 = g.gadm36_code;

WITH RECURSIVE splitted (gadm36_code, value, remained) AS (
    SELECT r.gadm36_1, null, r.VARNAME_1 || '|'
    FROM raw_gadm36_1 AS r
    UNION ALL
    SELECT
        gadm36_code,
        substr(remained, 0, instr(remained, '|')),
        substr(remained, instr(remained, '|') + 1)
    FROM splitted WHERE remained != ''
)
INSERT OR IGNORE INTO geo_entity_var_name (geo_entity_id, var_name)
SELECT g.geo_entity_id, s.value
FROM splitted AS s
    INNER JOIN geo_entity AS g ON s.gadm36_code = g.gadm36_code
WHERE s.value IS NOT NULL AND s.value != '';

-- Populate the table geo_entity from raw_gadm36_2

INSERT INTO geo_entity (
    gadm36_code, primary_name, native_name, geo_entity_type_id,
    parent_geo_entity_id
)
SELECT
    r.gadm36_2, r.name_2, r.nl_name_2, t.geo_entity_type_id, g.geo_entity_id
FROM raw_gadm36_2 AS r
    INNER JOIN geo_entity_type AS t ON
        r.type_2 = t.primary_name AND r.engtype_2 = t.eng_name
    INNER JOIN geo_entity AS g ON
        r.gid_1_1 = g.gadm36_code;

WITH RECURSIVE splitted (gadm36_code, value, remained) AS (
    SELECT r.gadm36_2, null, r.varname_2 || '|'
    FROM raw_gadm36_2 AS r
    UNION ALL
    SELECT
        gadm36_code,
        substr(remained, 0, instr(remained, '|')),
        substr(remained, instr(remained, '|') + 1)
    FROM splitted WHERE remained != ''
)
INSERT OR IGNORE INTO geo_entity_var_name (geo_entity_id, var_name)
SELECT g.geo_entity_id, s.value
FROM splitted AS s
    INNER JOIN geo_entity AS g ON s.gadm36_code = g.gadm36_code
WHERE s.value IS NOT NULL AND s.value != '';

-- Populate the table geo_entity from raw_gadm36_3

INSERT INTO geo_entity (
    gadm36_code, primary_name, native_name, geo_entity_type_id,
    parent_geo_entity_id
)
SELECT
    r.gadm36_3, r.name_3, r.nl_name_3, t.geo_entity_type_id, g.geo_entity_id
FROM raw_gadm36_3 AS r
    INNER JOIN geo_entity_type AS t ON
        r.type_3 = t.primary_name AND r.engtype_3 = t.eng_name
    INNER JOIN geo_entity AS g ON
        r.gid_2_2 = g.gadm36_code;

WITH RECURSIVE splitted (gadm36_code, value, remained) AS (
    SELECT r.gadm36_3, null, r.varname_3 || '|'
    FROM raw_gadm36_3 AS r
    UNION ALL
    SELECT
        gadm36_code,
        substr(remained, 0, instr(remained, '|')),
        substr(remained, instr(remained, '|') + 1)
    FROM splitted WHERE remained != ''
)
INSERT OR IGNORE INTO geo_entity_var_name (geo_entity_id, var_name)
SELECT g.geo_entity_id, s.value
FROM splitted AS s
    INNER JOIN geo_entity AS g ON s.gadm36_code = g.gadm36_code
WHERE s.value IS NOT NULL AND s.value != '';
