-- Boolean and null constants
SELECT NULL, TRUE, FALSE;
--     ^^^^ entity.name.label
--           ^^^^ entity.name.label
--                 ^^^^^ entity.name.label

-- UNKNOWN constant (three-valued logic)
SELECT UNKNOWN;
--     ^^^^^^^ entity.name.label

-- EXTRACT field names
SELECT extract(EPOCH FROM now());
--             ^^^^^ entity.name.label
