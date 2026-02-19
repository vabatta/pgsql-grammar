-- COLLATE in DDL
CREATE TABLE t (name TEXT COLLATE "en_US");
--                       ^^^^^^^ keyword

-- PARTITION BY HASH / LIST
CREATE TABLE t (id INT) PARTITION BY HASH (id);
--                                   ^^^^ keyword
CREATE TABLE t (id INT) PARTITION BY LIST (id);
--                                   ^^^^ keyword

-- EXCLUDING in LIKE
CREATE TABLE t2 (LIKE t1 EXCLUDING INDEXES);
--                       ^^^^^^^^^ keyword

-- MATCH SIMPLE / PARTIAL
CREATE TABLE t (x INT REFERENCES p(id) MATCH SIMPLE);
--                                      ^^^^^ keyword
--                                            ^^^^^^ keyword
CREATE TABLE t (x INT REFERENCES p(id) MATCH PARTIAL);
--                                      ^^^^^ keyword
--                                            ^^^^^^^ keyword

-- STORAGE types
ALTER TABLE t ALTER COLUMN c SET STORAGE PLAIN;
--                               ^^^^^^^ keyword
--                                       ^^^^^ keyword
ALTER TABLE t ALTER COLUMN c SET STORAGE EXTERNAL;
--                                       ^^^^^^^^ keyword
ALTER TABLE t ALTER COLUMN c SET STORAGE EXTENDED;
--                                       ^^^^^^^^ keyword
ALTER TABLE t ALTER COLUMN c SET STORAGE MAIN;
--                                       ^^^^ keyword

-- COMPRESSION
ALTER TABLE t ALTER COLUMN c SET COMPRESSION lz4;
--                               ^^^^^^^^^^^ keyword

-- VALIDATE CONSTRAINT
ALTER TABLE t VALIDATE CONSTRAINT my_check;
--            ^^^^^^^^ keyword

-- CLUSTER ON
ALTER TABLE t CLUSTER ON idx;
--            ^^^^^^^ keyword

-- REPLICA trigger
ALTER TABLE t ENABLE REPLICA TRIGGER my_trig;
--                   ^^^^^^^ keyword

-- MODULUS / REMAINDER
CREATE TABLE t PARTITION OF p FOR VALUES WITH (MODULUS 4, REMAINDER 0);
--                                             ^^^^^^^ keyword
--                                                       ^^^^^^^^^ keyword

-- FINALIZE
ALTER TABLE t DETACH PARTITION p FINALIZE;
--                               ^^^^^^^^ keyword

-- EXPRESSION
ALTER TABLE t ALTER COLUMN c SET EXPRESSION AS (a + b);
--                               ^^^^^^^^^^ keyword

-- ROW LEVEL SECURITY
ALTER TABLE t ENABLE ROW LEVEL SECURITY;
--                   ^^^^^^^^^^^^^^^^^^ keyword

-- AUTHORIZATION
CREATE SCHEMA myschema AUTHORIZATION myuser;
--                      ^^^^^^^^^^^^^ keyword

-- VERSION
CREATE EXTENSION hstore WITH VERSION '1.8';
--                           ^^^^^^^ keyword

-- CASCADED check option
CREATE VIEW v AS SELECT 1 WITH CASCADED CHECK OPTION;
--                             ^^^^^^^^ keyword

-- CREATE POLICY keywords
CREATE POLICY p ON t AS PERMISSIVE FOR SELECT TO current_user;
--                      ^^^^^^^^^^ keyword
CREATE POLICY p ON t AS RESTRICTIVE FOR ALL TO current_user;
--                      ^^^^^^^^^^^ keyword

-- GRANT keywords
GRANT CONNECT ON DATABASE mydb TO myrole;
--    ^^^^^^^ keyword
GRANT MAINTAIN ON TABLE t TO myrole;
--    ^^^^^^^^ keyword

-- SECURITY LABEL
SECURITY LABEL ON TABLE t IS 'secret';
--       ^^^^^ keyword

-- PROCEDURAL LANGUAGE
COMMENT ON PROCEDURAL LANGUAGE plpgsql IS 'PL/pgSQL';
--         ^^^^^^^^^^ keyword

-- ROUTINE
GRANT EXECUTE ON ROUTINE myfunc TO myrole;
--                ^^^^^^^ keyword

-- IMPORT FOREIGN SCHEMA
IMPORT FOREIGN SCHEMA public FROM SERVER myserver INTO myschema;
--^^^^ keyword

-- TRANSFORM
CREATE FUNCTION f() RETURNS void LANGUAGE plpgsql TRANSFORM FOR TYPE jsonb AS $$ BEGIN END; $$;
--                                                ^^^^^^^^^ keyword

-- ATOMIC function body
CREATE FUNCTION f() RETURNS int LANGUAGE sql BEGIN ATOMIC; RETURN 1; END;
--                                                ^^^^^^ keyword

-- CONSTANT in PL/pgSQL
DO $$ DECLARE x CONSTANT int := 5; BEGIN NULL; END; $$;
--              ^^^^^^^^ keyword

-- TEXT SEARCH
COMMENT ON TEXT SEARCH CONFIGURATION english IS 'English config';
--         ^^^^^^^^^^^ keyword
--                     ^^^^^^^^^^^^^ keyword

-- NONE
ALTER SEQUENCE s OWNED BY NONE;
--                        ^^^^ keyword

-- CONNECTION
CREATE SUBSCRIPTION s CONNECTION 'host=h dbname=d' PUBLICATION p;
--                    ^^^^^^^^^^ keyword

-- ADMIN
GRANT myrole TO otherrole WITH ADMIN OPTION;
--                              ^^^^^ keyword

-- GRANTED BY
GRANT myrole TO otherrole GRANTED BY grantor;
--                         ^^^^^^^ keyword

-- CREATE TYPE parameters
CREATE TYPE mytype AS RANGE (SUBTYPE = int4, CANONICAL = my_canonical);
--                           ^^^^^^^ keyword
--                                           ^^^^^^^^^ keyword

-- CREATE AGGREGATE parameters
CREATE AGGREGATE myagg (int) (SFUNC = mysfunc, STYPE = int, FINALFUNC = myfinalfunc);
--                                                          ^^^^^^^^^ keyword
