CREATE INDEX ix_raw_gadm36_0 ON raw_gadm36_0 (gadm36_0);
CREATE INDEX ix_raw_gadm36_1 ON raw_gadm36_1 (gadm36_1);
CREATE INDEX ix_raw_gadm36_2 ON raw_gadm36_2 (gadm36_2);
CREATE INDEX ix_raw_gadm36_3 ON raw_gadm36_3 (gadm36_3);

-- Populate the table place_type

CREATE TABLE raw_place_type (
    place_type_id INTEGER NOT NULL,
    names TEXT,
    native_names TEXT,
    CONSTRAINT pk_raw_place_type PRIMARY KEY (place_type_id),
    CONSTRAINT uq_raw_place_type UNIQUE (names, native_names)
    -- CONSTRAINT ck_raw_place_type_names_not_null
    --     CHECK (names IS NOT NULL AND native_names IS NOT NULL)
) STRICT;
INSERT INTO raw_place_type (names)
VALUES ('Country or Region');
INSERT OR REPLACE INTO raw_place_type (names, native_names)
SELECT DISTINCT ENGTYPE_1, TYPE_1 FROM raw_gadm36_1;
INSERT OR REPLACE INTO raw_place_type (names, native_names)
SELECT DISTINCT engtype_2, type_2 FROM raw_gadm36_2;
INSERT OR REPLACE INTO raw_place_type (names, native_names)
SELECT DISTINCT engtype_3, type_3 FROM raw_gadm36_3;

INSERT INTO place_type (place_type_id)
SELECT place_type_id FROM raw_place_type;

WITH RECURSIVE type_splitted (place_type_id, name, remained) AS (
    SELECT r.place_type_id, null, r.native_names || '|'
    FROM raw_place_type AS r
    UNION ALL
    SELECT
        place_type_id,
        substr(remained, 0, instr(remained, '|')),
        substr(remained, instr(remained, '|') + 1)
    FROM type_splitted WHERE remained != ''
)
INSERT INTO place_type_name (place_type_id, name, native)
SELECT s.place_type_id, s.name, 1
FROM type_splitted AS s
WHERE s.name IS NOT NULL AND s.name != '';

WITH RECURSIVE engtype_splitted (place_type_id, name, remained) AS (
    SELECT r.place_type_id, null, r.names || '|'
    FROM raw_place_type AS r
    UNION ALL
    SELECT
        place_type_id,
        substr(remained, 0, instr(remained, '|')),
        substr(remained, instr(remained, '|') + 1)
    FROM engtype_splitted WHERE remained != ''
)
INSERT INTO place_type_name (place_type_id, name, native)
SELECT s.place_type_id, s.name, 0
FROM engtype_splitted AS s
WHERE s.name IS NOT NULL AND s.name != '';

-- Populate the table place from raw_gadm36_0

INSERT INTO place (gadm36_code, name, place_type_id)
SELECT gadm36_0, name_0, 0
FROM raw_gadm36_0;

UPDATE place
SET place_type_id = (
    SELECT place_type_id
    FROM place_type_name
    WHERE name = 'Country or Region' AND native = 0
);

-- Populate from raw_gadm36_1

INSERT INTO place (gadm36_code, name, place_type_id, parent_place_id)
SELECT r1.gadm36_1, r1.NAME_1, rt.place_type_id, p.place_id
FROM raw_gadm36_1 AS r1
INNER JOIN raw_place_type AS rt
    ON r1.TYPE_1 = rt.native_names AND r1.ENGTYPE_1 = rt.names
INNER JOIN place AS p ON r1.GID_0_0 = p.gadm36_code;

WITH RECURSIVE split (gadm36_code, var_name, remained) AS (
    SELECT gadm36_1, NULL, VARNAME_1 || '|'
    FROM raw_gadm36_1
    UNION ALL
    SELECT
        gadm36_code,
        substr(remained, 0, instr(remained, '|')),
        substr(remained, instr(remained, '|') + 1)
    FROM split
    WHERE remained != ''
)
INSERT OR IGNORE INTO place_var_name (place_id, var_name)
SELECT p.place_id, s.var_name
FROM place AS p
INNER JOIN split AS s ON s.gadm36_code = p.gadm36_code
WHERE s.var_name IS NOT NULL AND s.var_name != '';

WITH RECURSIVE split (gadm36_code, native_name, remained) AS (
    SELECT gadm36_1, NULL, NL_NAME_1 || '|'
    FROM raw_gadm36_1
    UNION ALL
    SELECT
        gadm36_code,
        substr(remained, 0, instr(remained, '|')),
        substr(remained, instr(remained, '|') + 1)
    FROM split
    WHERE remained != ''
)
INSERT OR IGNORE INTO place_native_name (place_id, native_name)
SELECT p.place_id, s.native_name
FROM place AS p
INNER JOIN split AS s ON p.gadm36_code = s.gadm36_code
WHERE s.native_name IS NOT NULL AND s.native_name != '';

-- Populate from raw_gadm36_2

INSERT INTO place (gadm36_code, name, place_type_id, parent_place_id)
SELECT r1.gadm36_2, r1.name_2, rt.place_type_id, p.place_id
FROM raw_gadm36_2 AS r1
INNER JOIN raw_place_type AS rt
    ON r1.type_2 = rt.native_names AND r1.engtype_2 = rt.names
INNER JOIN place AS p ON r1.gid_1_1 = p.gadm36_code;

WITH RECURSIVE split (gadm36_code, var_name, remained) AS (
    SELECT gadm36_2, NULL, varname_2 || '|'
    FROM raw_gadm36_2
    UNION ALL
    SELECT
        gadm36_code,
        substr(remained, 0, instr(remained, '|')),
        substr(remained, instr(remained, '|') + 1)
    FROM split
    WHERE remained != ''
)
INSERT OR IGNORE INTO place_var_name (place_id, var_name)
SELECT p.place_id, s.var_name
FROM place AS p
INNER JOIN split AS s ON s.gadm36_code = p.gadm36_code
WHERE s.var_name IS NOT NULL AND s.var_name != '';

WITH RECURSIVE split (gadm36_code, native_name, remained) AS (
    SELECT gadm36_2, NULL, nl_name_2 || '|'
    FROM raw_gadm36_2
    UNION ALL
    SELECT
        gadm36_code,
        substr(remained, 0, instr(remained, '|')),
        substr(remained, instr(remained, '|') + 1)
    FROM split
    WHERE remained != ''
)
INSERT OR IGNORE INTO place_native_name (place_id, native_name)
SELECT p.place_id, s.native_name
FROM place AS p
INNER JOIN split AS s ON p.gadm36_code = s.gadm36_code
WHERE s.native_name IS NOT NULL AND s.native_name != '';

-- Populate from raw_gadm36_3

INSERT INTO place (gadm36_code, name, place_type_id, parent_place_id)
SELECT r1.gadm36_3, r1.name_3, rt.place_type_id, p.place_id
FROM raw_gadm36_3 AS r1
INNER JOIN raw_place_type AS rt
    ON r1.type_3 = rt.native_names AND r1.engtype_3 = rt.names
INNER JOIN place AS p ON r1.gid_2_2 = p.gadm36_code;

WITH RECURSIVE split (gadm36_code, var_name, remained) AS (
    SELECT gadm36_3, NULL, varname_3 || '|'
    FROM raw_gadm36_3
    UNION ALL
    SELECT
        gadm36_code,
        substr(remained, 0, instr(remained, '|')),
        substr(remained, instr(remained, '|') + 1)
    FROM split
    WHERE remained != ''
)
INSERT OR IGNORE INTO place_var_name (place_id, var_name)
SELECT p.place_id, s.var_name
FROM place AS p
INNER JOIN split AS s ON s.gadm36_code = p.gadm36_code
WHERE s.var_name IS NOT NULL AND s.var_name != '';

WITH RECURSIVE split (gadm36_code, native_name, remained) AS (
    SELECT gadm36_3, NULL, nl_name_3 || '|'
    FROM raw_gadm36_3
    UNION ALL
    SELECT
        gadm36_code,
        substr(remained, 0, instr(remained, '|')),
        substr(remained, instr(remained, '|') + 1)
    FROM split
    WHERE remained != ''
)
INSERT OR IGNORE INTO place_native_name (place_id, native_name)
SELECT p.place_id, s.native_name
FROM place AS p
INNER JOIN split AS s ON p.gadm36_code = s.gadm36_code
WHERE s.native_name IS NOT NULL AND s.native_name != '';

