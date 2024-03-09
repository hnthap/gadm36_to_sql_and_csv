
CREATE TABLE geo_entity_type (
      geo_entity_type_id INTEGER NOT NULL
    , primary_name TEXT NOT NULL
    , eng_name TEXT
    , CONSTRAINT pk_geo_entity_type PRIMARY KEY (geo_entity_type_id)
    , CONSTRAINT uq_geo_entity_type
      UNIQUE (primary_name, eng_name)
    , CONSTRAINT ck_geo_entity_not_null_all_names
      CHECK (primary_name IS NOT NULL AND eng_name IS NOT NULL)
) STRICT;

CREATE INDEX ix_geo_entity_type ON geo_entity_type (geo_entity_type_id);

CREATE TABLE geo_entity (
      geo_entity_id INTEGER NOT NULL
    , gadm36_code TEXT NOT NULL
    , primary_name TEXT
    , native_name TEXT
    , geo_entity_type_id INTEGER
    , parent_geo_entity_id INTEGER
    , CONSTRAINT pk_geo_entity PRIMARY KEY (geo_entity_id)
    , CONSTRAINT uq_geo_entity_gadm36_code UNIQUE (gadm36_code)
    -- , CONSTRAINT uq_geo_entity_primary_name_native_name
    --   UNIQUE (primary_name, native_name)
    , CONSTRAINT fk_geo_entity_geo_entity_type
      FOREIGN KEY (geo_entity_type_id)
      REFERENCES geo_entity_type ON DELETE SET NULL
    , CONSTRAINT fk_geo_entity_geo_entity_type
      FOREIGN KEY (parent_geo_entity_id)
      REFERENCES geo_entity ON DELETE SET NULL
) STRICT;

CREATE INDEX ix_geo_entity ON geo_entity (geo_entity_id);

CREATE TABLE geo_entity_var_name (
      geo_entity_id INTEGER NOT NULL
    , var_name TEXT NOT NULL
    , CONSTRAINT uq_geo_entity_var_name UNIQUE (geo_entity_id, var_name)
    , CONSTRAINT fk_geo_entity_var_name_geo_entity
      FOREIGN KEY (geo_entity_id) REFERENCES geo_entity ON DELETE CASCADE 
) STRICT;

CREATE INDEX ix_geo_entity_var_name ON geo_entity_var_name (geo_entity_id);
