-- EXPLAIN option keywords
EXPLAIN (COSTS true, TIMING true, SUMMARY true) SELECT 1;
--       ^^^^^ keyword
--                   ^^^^^^ keyword
--                                 ^^^^^^^ keyword
EXPLAIN (SETTINGS true, MEMORY true, WAL true) SELECT 1;
--       ^^^^^^^^ keyword
--                      ^^^^^^ keyword
--                                   ^^^ keyword
EXPLAIN (FORMAT YAML) SELECT 1;
--             ^^^^ keyword
EXPLAIN (SERIALIZE BINARY) SELECT 1;
--       ^^^^^^^^^ keyword
--                 ^^^^^^ keyword
EXPLAIN (GENERIC_PLAN true) SELECT 1;
--       ^^^^^^^^^^^^ keyword

-- OFF as boolean option
EXPLAIN (COSTS OFF) SELECT 1;
--             ^^^ keyword

-- NONE
EXPLAIN (SERIALIZE NONE) SELECT 1;
--                 ^^^^ keyword

-- VACUUM options
VACUUM (DISABLE_PAGE_SKIPPING true) t;
--      ^^^^^^^^^^^^^^^^^^^^^ keyword
VACUUM (INDEX_CLEANUP true) t;
--      ^^^^^^^^^^^^^ keyword
VACUUM (PROCESS_MAIN true) t;
--      ^^^^^^^^^^^^ keyword
VACUUM (PROCESS_TOAST true) t;
--      ^^^^^^^^^^^^^ keyword
VACUUM (SKIP_LOCKED true) t;
--      ^^^^^^^^^^^ keyword
VACUUM (BUFFER_USAGE_LIMIT '128MB') t;
--      ^^^^^^^^^^^^^^^^^^ keyword
VACUUM (SKIP_DATABASE_STATS true) t;
--      ^^^^^^^^^^^^^^^^^^^ keyword
VACUUM (ONLY_DATABASE_STATS true) t;
--      ^^^^^^^^^^^^^^^^^^^ keyword

-- Transaction keywords
BEGIN TRANSACTION ISOLATION LEVEL READ WRITE;
--                                     ^^^^^ keyword
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE;
--  ^^^^^^^ keyword
--          ^^^^^^^^^^^^^^^ keyword
SET TRANSACTION SNAPSHOT 'snap_id';
--              ^^^^^^^^ keyword

-- CLUSTER
CLUSTER t USING idx;
--^^^^^ keyword

-- RESTART IDENTITY in TRUNCATE
TRUNCATE t RESTART IDENTITY CASCADE;
--         ^^^^^^^ keyword

-- SET options
SET NAMES 'UTF8';
--  ^^^^^ keyword
SET SEED TO 0.5;
--  ^^^^ keyword

-- SYSTEM in REINDEX
REINDEX SYSTEM mydb;
--      ^^^^^^ keyword

-- OBJECT
SECURITY LABEL ON LARGE OBJECT 12345 IS 'classified';
--                      ^^^^^^ keyword

-- BUFFERS and JSON in EXPLAIN
EXPLAIN (BUFFERS true) SELECT 1;
--       ^^^^^^^ keyword
EXPLAIN (FORMAT JSON) SELECT 1;
--             ^^^^ keyword

-- ANALYZE table(col) should NOT make table a function
ANALYZE users (email, created_at);
--      ^^^^^ !support.function

-- IMPORT FOREIGN SCHEMA: schema name should NOT be a keyword
IMPORT FOREIGN SCHEMA public FROM SERVER myserver INTO myschema;
--                    ^^^^^^ !keyword
