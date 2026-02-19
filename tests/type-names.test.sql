-- Numeric types in column definitions
CREATE TABLE t (
  a SMALLINT,
--  ^^^^^^^^ entity.name.tag
  b BIGINT,
--  ^^^^^^ entity.name.tag
  c NUMERIC(10,2),
--  ^^^^^^^ entity.name.tag
  d REAL,
--  ^^^^ entity.name.tag
  e DOUBLE PRECISION,
--  ^^^^^^^^^^^^^^^^ entity.name.tag
  f MONEY,
--  ^^^^^ entity.name.tag
  g BIGSERIAL
--  ^^^^^^^^^ entity.name.tag
);

-- Character types
CREATE TABLE t (
  a VARCHAR(255),
--  ^^^^^^^ entity.name.tag
  b CHARACTER VARYING(100),
--  ^^^^^^^^^^^^^^^^^^ entity.name.tag
  c NAME
--  ^^^^ entity.name.tag
);

-- Date/time types
CREATE TABLE t (
  a TIMESTAMPTZ,
--  ^^^^^^^^^^^ entity.name.tag
  b TIMESTAMP WITH TIME ZONE,
--  ^^^^^^^^^^^^^^^^^^^^^^^^ entity.name.tag
  c INTERVAL
--  ^^^^^^^^ entity.name.tag
);

-- Boolean / Binary
CREATE TABLE t (
  a BOOLEAN,
--  ^^^^^^^ entity.name.tag
  b BYTEA
--  ^^^^^ entity.name.tag
);

-- JSON / UUID / XML
CREATE TABLE t (
  a JSONB,
--  ^^^^^ entity.name.tag
  b UUID,
--  ^^^^ entity.name.tag
  c XML
--  ^^^ entity.name.tag
);

-- Range types
CREATE TABLE t (
  a INT4RANGE,
--  ^^^^^^^^^ entity.name.tag
  b TSTZRANGE,
--  ^^^^^^^^^ entity.name.tag
  c DATERANGE
--  ^^^^^^^^^ entity.name.tag
);

-- Network types
CREATE TABLE t (
  a INET,
--  ^^^^ entity.name.tag
  b CIDR,
--  ^^^^ entity.name.tag
  c MACADDR
--  ^^^^^^^ entity.name.tag
);

-- System types
CREATE TABLE t (
  a OID,
--  ^^^ entity.name.tag
  b REGCLASS,
--  ^^^^^^^^ entity.name.tag
  c PG_LSN
--  ^^^^^^ entity.name.tag
);

-- Type in cast
SELECT 42::BIGINT, now()::DATE, 'hello'::VARCHAR(10);
--        ^^^^^^ entity.name.tag
--                       ^^^^ entity.name.tag
--                                       ^^^^^^^ entity.name.tag

-- Type literal
SELECT DATE '2024-01-01', INTERVAL '1 day';
--     ^^^^ entity.name.tag
--                         ^^^^^^^^ entity.name.tag

-- ENUM keyword
CREATE TYPE status AS ENUM ('a', 'b');
--                    ^^^^ keyword
