DROP TABLE IF EXISTS place_var_name;
DROP TABLE IF EXISTS place;
DROP TABLE IF EXISTS place_type;
CREATE TABLE place_type (
    place_type_id INTEGER NOT NULL,
    CONSTRAINT pk_place_type
        PRIMARY KEY (place_type_id)
) STRICT;
CREATE TABLE place_type_name (
    place_type_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    native INTEGER,
    CONSTRAINT uq_place_type_name
        UNIQUE (place_type_id, name, native),
    CONSTRAINT fk_place_type_name_place_type
        FOREIGN KEY (place_type_id)
        REFERENCES place_type (place_type_id)
        ON DELETE CASCADE,
    CONSTRAINT ck_place_type_name_native_is_boolean
        CHECK (native IN (0, 1))
) STRICT;
CREATE TABLE place (
    place_id INTEGER NOT NULL,
    gadm36_code TEXT NOT NULL,
    name TEXT NOT NULL,
    place_type_id INTEGER NOT NULL,
    parent_place_id INTEGER,
    CONSTRAINT pk_place
        PRIMARY KEY (place_id),
    CONSTRAINT uq_place_gadm36_code
        UNIQUE (gadm36_code),
    CONSTRAINT fk_place_place_type
        FOREIGN KEY (place_type_id)
        REFERENCES place_type (place_type_id) 
        ON DELETE SET NULL,
    CONSTRAINT fk_place_place 
        FOREIGN KEY (parent_place_id)
        REFERENCES place (place_id)
        ON DELETE SET NULL
) STRICT;
CREATE TABLE place_var_name (
    place_id INTEGER NOT NULL,
    var_name TEXT NOT NULL,
    CONSTRAINT uq_place_var_name
        UNIQUE (place_id, var_name),
    CONSTRAINT fk_place_var_name_place
        FOREIGN KEY (place_id)
        REFERENCES place (place_id)
        ON DELETE CASCADE
) STRICT;
CREATE TABLE place_native_name (
    place_id INTEGER NOT NULL,
    native_name TEXT NOT NULL,
    CONSTRAINT uq_place_native_name
        UNIQUE (place_id, native_name),
    CONSTRAINT fk_place_native_name_place
        FOREIGN KEY (place_id)
        REFERENCES place (place_id)
        ON DELETE CASCADE
) STRICT;
CREATE INDEX ix_place_type ON place_type (place_type_id);
CREATE INDEX ix_place ON place (place_id);
