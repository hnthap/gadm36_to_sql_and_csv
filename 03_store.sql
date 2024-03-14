.mode csv

.header on
.output "out/place_type.csv"
SELECT * FROM place_type;
.output "out/place_type_name.csv"
SELECT * FROM place_type_name;
.output "out/place.csv"
SELECT * FROM place;
.output "out/place_var_name.csv"
SELECT * FROM place_var_name;
.output "out/place_native_name.csv"
SELECT * FROM place_native_name;
