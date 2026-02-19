-- ASSERT in PL/pgSQL
DO $$ BEGIN ASSERT true, 'fail'; END; $$;
--          ^^^^^^ keyword

-- GET DIAGNOSTICS
DO $$ BEGIN GET DIAGNOSTICS x = ROW_COUNT; END; $$;
--         ^^^^^^^^^^^^^^^ keyword

-- GET STACKED DIAGNOSTICS
DO $$ BEGIN GET STACKED DIAGNOSTICS x = MESSAGE_TEXT; EXCEPTION WHEN OTHERS THEN NULL; END; $$;
--         ^^^^^^^^^^^^^^^^^^^^^^^^ keyword

-- NO ACTION in referential constraints
CREATE TABLE t (x INT REFERENCES p(id) ON DELETE NO ACTION);
--                                      ^^^^^^^^^ keyword
--                                                ^^ keyword
--                                                   ^^^^^^ keyword
