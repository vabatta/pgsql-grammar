-- Boolean and null constants in a SELECT
SELECT NULL, TRUE, FALSE;
--     ^^^^ constant.language
--           ^^^^ constant.language
--                 ^^^^^ constant.language

-- UNKNOWN constant (three-valued logic)
SELECT UNKNOWN;
--     ^^^^^^^ constant.language

-- NULL in UPDATE SET (DML context)
UPDATE t SET x = NULL, y = TRUE, z = FALSE WHERE id = 1;
--               ^^^^ constant.language
--                         ^^^^ constant.language
--                                   ^^^^^ constant.language

-- NULL should NOT be highlighted as a keyword
UPDATE t SET x = NULL WHERE id = 1;
--               ^^^^ !keyword

-- NULL in PL/pgSQL body (dollar_quotes context)
DO $$ BEGIN UPDATE t SET x = NULL WHERE id = 1; END; $$;
--                           ^^^^ constant.language

-- TRUE/FALSE in IF condition (dollar_quotes context)
DO $$ BEGIN IF TRUE THEN RETURN NULL; END IF; END; $$;
--             ^^^^ constant.language
--                              ^^^^ constant.language

-- FALSE/TRUE as function arguments in DML
SELECT coalesce(FALSE, TRUE);
--              ^^^^^ constant.language
--                     ^^^^ constant.language

-- EXTRACT field names
SELECT extract(EPOCH FROM now());
--             ^^^^^ constant.language

SELECT extract(year FROM hire_date), extract(month FROM hire_date);
--             ^^^^ constant.language
--                                           ^^^^^ constant.language
