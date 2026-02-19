-- ALIAS in PL/pgSQL
DO $$ DECLARE x ALIAS FOR $1; BEGIN NULL; END; $$;
--              ^^^^^ keyword

-- REVERSE in FOR loop
DO $$ BEGIN FOR i IN REVERSE 10..1 LOOP NULL; END LOOP; END; $$;
--                   ^^^^^^^ keyword

-- SLICE in FOREACH
DO $$ BEGIN FOREACH x SLICE 1 IN ARRAY arr LOOP NULL; END LOOP; END; $$;
--                    ^^^^^ keyword

-- CHAIN in COMMIT/ROLLBACK
DO $$ BEGIN COMMIT AND CHAIN; END; $$;
--                     ^^^^^ keyword
DO $$ BEGIN ROLLBACK AND CHAIN; END; $$;
--                       ^^^^^ keyword

-- RAISE USING option keywords
DO $$ BEGIN RAISE EXCEPTION 'err' USING MESSAGE = 'msg'; END; $$;
--                                       ^^^^^^^ keyword
DO $$ BEGIN RAISE EXCEPTION 'err' USING DETAIL = 'dtl'; END; $$;
--                                       ^^^^^^ keyword
DO $$ BEGIN RAISE EXCEPTION 'err' USING HINT = 'hnt'; END; $$;
--                                       ^^^^ keyword
DO $$ BEGIN RAISE EXCEPTION 'err' USING ERRCODE = 'P0001'; END; $$;
--                                       ^^^^^^^ keyword

-- GET DIAGNOSTICS items
DO $$ DECLARE v text; BEGIN GET STACKED DIAGNOSTICS v = RETURNED_SQLSTATE; EXCEPTION WHEN OTHERS THEN NULL; END; $$;
--                                                      ^^^^^^^^^^^^^^^^^^ support.function
DO $$ DECLARE v text; BEGIN GET STACKED DIAGNOSTICS v = MESSAGE_TEXT; EXCEPTION WHEN OTHERS THEN NULL; END; $$;
--                                                      ^^^^^^^^^^^^ support.function
DO $$ DECLARE v text; BEGIN GET STACKED DIAGNOSTICS v = PG_EXCEPTION_DETAIL; EXCEPTION WHEN OTHERS THEN NULL; END; $$;
--                                                      ^^^^^^^^^^^^^^^^^^^ support.function
DO $$ DECLARE v text; BEGIN GET DIAGNOSTICS v = PG_ROUTINE_OID; END; $$;
--                                              ^^^^^^^^^^^^^^ support.function
