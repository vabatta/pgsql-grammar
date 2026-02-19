-- Cast operator (::) should scope types
SELECT x::DATE, CAST(y AS INTEGER);
--        ^^^^ entity.name.tag
--                        ^^^^^^^ entity.name.tag

-- Type-literal cast: TYPE 'string'
SELECT DATE '2024-01-01', INTERVAL '1 day';
--     ^^^^ entity.name.tag
--                        ^^^^^^^^ entity.name.tag

-- DDL column types
CREATE TABLE t (id SERIAL, name TEXT, d TIMESTAMPTZ);
--                 ^^^^^^ entity.name.tag
--                              ^^^^ entity.name.tag
--                                      ^^^^^^^^^^^ entity.name.tag

-- Bare words in SELECT list should NOT be types
SELECT name, date FROM users;
--     ^^^^ !entity.name.tag
--           ^^^^ !entity.name.tag

-- PL/pgSQL DECLARE types
DO $$ DECLARE v_count INTEGER; BEGIN END; $$;
--                    ^^^^^^^ entity.name.tag
