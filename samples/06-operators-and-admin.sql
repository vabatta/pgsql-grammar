-- =============================================
-- Operators, EXPLAIN, VACUUM, PREPARE,
-- cursors, transactions, LISTEN/NOTIFY, etc.
-- =============================================

-- ---- E-strings (backslash escapes) ----
SELECT E'hello\nworld';
SELECT E'tab\there';
SELECT E'it\'s escaped';
SELECT E'backslash: \\';
SELECT E'unicode: \u0041';
SELECT E'hex: \x41';
SELECT E'octal: \101';
SELECT E'carriage return\r\nnewline';
SELECT E'bell: \a (control character)';
SELECT E'mixed: hello\tworld\n\'quoted\'\\path';

-- Regular strings: backslash is literal, '' is the escape
SELECT 'it''s a regular string';
SELECT 'C:\Users\path\to\file';
SELECT 'no \n escape here';
SELECT 'hello%world' LIKE 'hello\%world' ESCAPE '\';

-- ---- JSON operators ----
SELECT
  '{"a":1}'::JSONB -> 'a',
  '{"a":1}'::JSONB ->> 'a',
  '{"a":{"b":2}}'::JSONB #> '{a,b}',
  '{"a":{"b":2}}'::JSONB #>> '{a,b}';

-- ---- Containment operators ----
SELECT
  '{"a":1,"b":2}'::JSONB @> '{"a":1}'::JSONB,
  '{"a":1}'::JSONB <@ '{"a":1,"b":2}'::JSONB,
  '{"a":1}'::JSONB ? 'a',
  '{"a":1,"b":2}'::JSONB ?| ARRAY['a','c'],
  '{"a":1,"b":2}'::JSONB ?& ARRAY['a','b'];

-- ---- Cast operator ----
SELECT '42'::INTEGER, now()::DATE, 'hello'::VARCHAR(10);

-- ---- LIKE operators (operator form) ----
SELECT 'hello' ~~ 'hel%';
SELECT 'hello' ~~* 'HEL%';
SELECT 'hello' !~~ 'xyz%';
SELECT 'hello' !~~* 'XYZ%';

-- ---- Regex operators ----
SELECT 'hello' ~ '^h';
SELECT 'hello' ~* '^H';
SELECT 'hello' !~ '^x';
SELECT 'hello' !~* '^X';

-- ---- Concatenation ----
SELECT 'hello' || ' ' || 'world';
SELECT ARRAY[1,2] || ARRAY[3,4];

-- ---- Comparison operators ----
SELECT 1 = 1, 1 <> 2, 1 != 2, 1 < 2, 1 > 0, 1 <= 1, 1 >= 1;

-- ---- Math operators ----
SELECT 10 + 5, 10 - 5, 10 * 5, 10 / 3, 10 % 3;
SELECT -42, +42;

-- ---- OVERLAPS ----
SELECT (DATE '2024-01-01', DATE '2024-06-30') OVERLAPS
       (DATE '2024-03-01', DATE '2024-09-30');

-- ---- EXPLAIN / ANALYZE ----
EXPLAIN SELECT * FROM users WHERE id = 1;
EXPLAIN ANALYZE SELECT * FROM users WHERE email LIKE '%@example.com';
EXPLAIN (VERBOSE, ANALYZE, BUFFERS, FORMAT JSON)
  SELECT u.*, o.total
  FROM users u
  JOIN orders o ON o.user_id = u.id;

-- EXPLAIN extended options
EXPLAIN (COSTS true, TIMING true, SUMMARY true) SELECT 1;
EXPLAIN (SETTINGS true, MEMORY true, WAL true) SELECT 1;
EXPLAIN (FORMAT YAML) SELECT * FROM users;
EXPLAIN (SERIALIZE BINARY) SELECT * FROM users;
EXPLAIN (SERIALIZE NONE) SELECT * FROM users;
EXPLAIN (GENERIC_PLAN true) SELECT * FROM users WHERE id = $1;
EXPLAIN (COSTS OFF) SELECT 1;

-- ---- VACUUM ----
VACUUM users;
VACUUM (VERBOSE) users;
VACUUM (ANALYZE) users;
VACUUM (VERBOSE, ANALYZE) users;
VACUUM (FREEZE) users;
VACUUM FULL users;

-- VACUUM extended options
VACUUM (DISABLE_PAGE_SKIPPING true) users;
VACUUM (INDEX_CLEANUP true) users;
VACUUM (PROCESS_MAIN true) users;
VACUUM (PROCESS_TOAST true) users;
VACUUM (SKIP_LOCKED true) users;
VACUUM (BUFFER_USAGE_LIMIT '128MB') users;
VACUUM (SKIP_DATABASE_STATS true) users;
VACUUM (ONLY_DATABASE_STATS true) users;

-- ---- ANALYZE ----
ANALYZE users;
ANALYZE users (email, created_at);

-- ---- LISTEN / NOTIFY ----
LISTEN order_events;
LISTEN user_events;
NOTIFY order_events, '{"action":"created","id":42}';
UNLISTEN order_events;
UNLISTEN *;

-- ---- PREPARE / EXECUTE / DEALLOCATE ----
PREPARE user_by_id (BIGINT) AS
  SELECT * FROM users WHERE id = $1;

EXECUTE user_by_id(42);
DEALLOCATE user_by_id;
DEALLOCATE ALL;

-- ---- Transaction control ----
BEGIN;
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SET LOCAL work_mem = '256MB';

SAVEPOINT sp1;
INSERT INTO orders (user_id, total) VALUES (1, 99.99);

SAVEPOINT sp2;
INSERT INTO order_items (order_id, product_id) VALUES (1, 1);
ROLLBACK TO SAVEPOINT sp2;

RELEASE SAVEPOINT sp1;
COMMIT;

-- Transaction with different isolation levels
BEGIN TRANSACTION ISOLATION LEVEL READ COMMITTED;
COMMIT WORK;

BEGIN ISOLATION LEVEL REPEATABLE READ;
ABORT;

BEGIN ISOLATION LEVEL READ UNCOMMITTED;
COMMIT;

-- Transaction with READ WRITE
BEGIN TRANSACTION ISOLATION LEVEL READ WRITE;
COMMIT;

-- SET SESSION CHARACTERISTICS
SET SESSION CHARACTERISTICS AS TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- SET TRANSACTION SNAPSHOT
BEGIN TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SET TRANSACTION SNAPSHOT 'snap_id_000001';
COMMIT;

-- Deferrable transaction
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE READ ONLY DEFERRABLE;
SELECT * FROM large_table;
COMMIT;

-- ---- Cursors (SQL-level) ----
BEGIN;

DECLARE order_cursor SCROLL CURSOR WITH HOLD FOR
  SELECT * FROM orders ORDER BY created_at;

FETCH NEXT FROM order_cursor;
FETCH FORWARD 10 FROM order_cursor;
FETCH BACKWARD 5 FROM order_cursor;
FETCH FIRST FROM order_cursor;
FETCH LAST FROM order_cursor;
FETCH ABSOLUTE 5 FROM order_cursor;
FETCH RELATIVE -2 FROM order_cursor;
FETCH PRIOR FROM order_cursor;

MOVE FORWARD ALL IN order_cursor;

CLOSE order_cursor;
COMMIT;

-- ---- LOCK ----
BEGIN;
LOCK TABLE orders IN SHARE MODE;
LOCK TABLE users IN ACCESS EXCLUSIVE MODE NOWAIT;
COMMIT;

-- ---- SET / RESET / SHOW ----
SET search_path TO app, public;
SET work_mem = '512MB';
SET LOCAL statement_timeout = '30s';
SET NAMES 'UTF8';
SET SEED TO 0.5;
SHOW search_path;
SHOW work_mem;
RESET work_mem;
RESET ALL;

-- ---- DISCARD ----
DISCARD ALL;
DISCARD PLANS;
DISCARD SEQUENCES;
DISCARD TEMPORARY;

-- ---- CLUSTER ----
CLUSTER users USING idx_users_email;

-- ---- REINDEX ----
REINDEX SYSTEM mydb;

-- ---- CHECKPOINT ----
CHECKPOINT;

-- ---- Advisory locks ----
SELECT pg_advisory_lock(12345);
SELECT pg_advisory_lock_shared(12345);
SELECT pg_try_advisory_lock(12345);
SELECT pg_try_advisory_xact_lock(12345);
SELECT pg_advisory_unlock(12345);
SELECT pg_advisory_unlock_all();

-- ---- Partition inspection ----
SELECT * FROM pg_partition_tree('events');
SELECT * FROM pg_partition_ancestors('events_2024q1');
SELECT pg_partition_root('events_2024q1');

-- ---- WAIT FOR LSN (PG18) ----
WAIT FOR LSN '0/1A2B3C4D';

-- ---- Schema-qualified identifiers ----
SELECT
  public.users.id,
  app.orders.total,
  pg_catalog.pg_class.relname
FROM public.users
JOIN app.orders ON app.orders.user_id = public.users.id
JOIN pg_catalog.pg_class ON pg_catalog.pg_class.oid = 'users'::REGCLASS;

-- ---- psql meta-commands ----
\dt public.*
\d+ users
\di+ users
\df+ my_function
\l+
\conninfo
\timing on
\x auto
