.mode csv

.header on
.output "out/geo_entity_type.csv"
SELECT * FROM geo_entity_type;
.output "out/geo_entity.csv"
SELECT * FROM geo_entity;
.output "out/geo_entity_var_name.csv"
SELECT * FROM geo_entity_var_name;
