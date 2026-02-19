-- TG_* trigger variables
CREATE FUNCTION f() RETURNS trigger LANGUAGE plpgsql AS $$ BEGIN
  IF tg_op = 'INSERT' THEN RETURN NEW; END IF;
--   ^^^^^ support.function
  INSERT INTO log (tbl, tag) VALUES (tg_table_name, tg_tag);
--                                   ^^^^^^^^^^^^^ support.function
--                                                  ^^^^^^ support.function
  RAISE NOTICE '%', tg_when;
--                  ^^^^^^^ support.function
  RAISE NOTICE '%', tg_level;
--                  ^^^^^^^^ support.function
  RAISE NOTICE '%', tg_relid;
--                  ^^^^^^^^ support.function
  RAISE NOTICE '%', tg_nargs;
--                  ^^^^^^^^ support.function
  RAISE NOTICE '%', tg_argv;
--                  ^^^^^^^ support.function
  RAISE NOTICE '%', tg_event;
--                  ^^^^^^^^ support.function
  RAISE NOTICE '%', tg_table_schema;
--                  ^^^^^^^^^^^^^^^ support.function
  RAISE NOTICE '%', tg_relname;
--                  ^^^^^^^^^^ support.function
  RETURN NEW;
END; $$;

-- Session/user constants
SELECT current_catalog, current_role, current_schema;
--     ^^^^^^^^^^^^^^^ support.function
--                      ^^^^^^^^^^^^ support.function
--                                    ^^^^^^^^^^^^^^ support.function
SELECT current_user, session_user, system_user;
--     ^^^^^^^^^^^^ support.function
--                   ^^^^^^^^^^^^ support.function
--                                 ^^^^^^^^^^^ support.function
SELECT current_date, current_time, current_timestamp;
--     ^^^^^^^^^^^^ support.function
--                   ^^^^^^^^^^^^ support.function
--                                 ^^^^^^^^^^^^^^^^^ support.function
SELECT localtime, localtimestamp;
--     ^^^^^^^^^ support.function
--                ^^^^^^^^^^^^^^ support.function

-- Error handling constants
DO $$ BEGIN RAISE NOTICE '%', sqlstate; EXCEPTION WHEN OTHERS THEN NULL; END; $$;
--                            ^^^^^^^^ support.function
DO $$ BEGIN RAISE NOTICE '%', sqlerrm; EXCEPTION WHEN OTHERS THEN NULL; END; $$;
--                            ^^^^^^^ support.function

-- GET DIAGNOSTICS items
DO $$ DECLARE v text; BEGIN GET DIAGNOSTICS v = row_count; END; $$;
--                                              ^^^^^^^^^ support.function
DO $$ DECLARE v text; BEGIN GET DIAGNOSTICS v = pg_context; END; $$;
--                                              ^^^^^^^^^^ support.function
