-- Standalone fallbacks for multi-word keywords split across lines.
-- These verify that individual words still highlight when a line break
-- splits a multi-word keyword (TextMate match patterns are line-based).

-- ORDER (from ORDER BY)
SELECT * FROM t
ORDER
--^^^ keyword
BY id;
--keyword

-- GROUP (from GROUP BY)
SELECT dept, count(*) FROM t
GROUP
--^^^ keyword
BY dept;

-- NULLS (from NULLS FIRST / NULLS LAST)
SELECT * FROM t ORDER BY name
NULLS
--^^^ keyword
FIRST;
--^^^ keyword

-- SIMILAR (from SIMILAR TO)
SELECT 'hello'
SIMILAR
--^^^^^ keyword
TO 'h%';

-- WITHIN / GROUP (from WITHIN GROUP)
SELECT percentile_cont(0.5)
WITHIN
--^^^^ keyword
GROUP (ORDER BY salary) FROM t;

-- GROUPING / SETS (from GROUPING SETS)
SELECT count(*) FROM t GROUP BY
GROUPING
--^^^^^^ keyword
SETS ((dept), ());
--^^ keyword

-- CONFLICT (from ON CONFLICT)
INSERT INTO t (id) VALUES (1) ON
CONFLICT
--^^^^^^ keyword
(id) DO UPDATE SET id = 1;

-- TIME (from AT TIME ZONE)
SELECT now() AT
TIME
--^^ keyword
ZONE 'UTC';

-- SKIP / LOCKED (from SKIP LOCKED)
SELECT * FROM t FOR UPDATE
SKIP
--^^ keyword
LOCKED;
--^^^^ keyword

-- QUERY (from RETURN QUERY)
DO $$ BEGIN RETURN
QUERY
--^^^ keyword
SELECT 1; END; $$;

-- GET / DIAGNOSTICS (from GET DIAGNOSTICS)
DO $$ DECLARE v int; BEGIN
GET
--^ keyword
DIAGNOSTICS
--^^^^^^^^^ keyword
v = ROW_COUNT; END; $$;

-- STACKED (from GET STACKED DIAGNOSTICS)
DO $$ BEGIN EXCEPTION WHEN OTHERS THEN DECLARE v text; BEGIN GET
STACKED
--^^^^^ keyword
DIAGNOSTICS v = MESSAGE_TEXT; END; END; $$;

-- TEXT (from TEXT SEARCH)
CREATE
TEXT
--^^ keyword
SEARCH CONFIGURATION my_cfg (COPY = simple);

-- WITHOUT (from WITHOUT OVERLAPS)
CREATE TABLE t (id int, valid_from date, valid_to date, PRIMARY KEY (id,
WITHOUT
--^^^^^ keyword
OVERLAPS));

-- COMMENT (from COMMENT ON)
COMMENT
--^^^^^ keyword
ON TABLE t IS 'A table';

-- EVENT (from EVENT TRIGGER)
CREATE
EVENT
--^^^ keyword
TRIGGER trg ON ddl_command_end EXECUTE FUNCTION f();

-- STATEMENT (from FOR EACH STATEMENT)
CREATE TRIGGER t AFTER INSERT ON tbl FOR EACH
STATEMENT
--^^^^^^^ keyword
EXECUTE FUNCTION f();

-- METHOD (from ACCESS METHOD)
CREATE ACCESS
METHOD
--^^^^ keyword
am TYPE TABLE HANDLER handler;

-- RESTRICTED / UNSAFE / SAFE (from PARALLEL ...)
CREATE FUNCTION f() RETURNS void LANGUAGE sql PARALLEL
RESTRICTED
--^^^^^^^^ keyword
AS $$ SELECT; $$;
CREATE FUNCTION g() RETURNS void LANGUAGE sql PARALLEL
UNSAFE
--^^^^ keyword
AS $$ SELECT; $$;
CREATE FUNCTION h() RETURNS void LANGUAGE sql PARALLEL
SAFE
--^^ keyword
AS $$ SELECT; $$;

-- DOUBLE / PRECISION type fallbacks
CREATE TABLE t (
  x DOUBLE
--  ^^^^^^ entity.name.tag
PRECISION
--^^^^^^^ entity.name.tag
);

-- VARYING type fallback
CREATE TABLE t (
  x CHARACTER
VARYING
--^^^^^ entity.name.tag
(100));
