-- =============================================
-- All PostgreSQL data types demonstrated
-- =============================================

-- Numeric types
CREATE TABLE type_demo_numeric (
  col_smallint       SMALLINT,
  col_int2           INT2,
  col_integer        INTEGER,
  col_int            INT,
  col_int4           INT4,
  col_bigint         BIGINT,
  col_int8           INT8,
  col_numeric        NUMERIC(20, 6),
  col_decimal        DECIMAL(10, 2),
  col_real           REAL,
  col_float4         FLOAT4,
  col_float          FLOAT,
  col_float8         FLOAT8,
  col_double         DOUBLE PRECISION,
  col_money          MONEY,
  col_smallserial    SMALLSERIAL,
  col_serial2        SERIAL2,
  col_serial         SERIAL,
  col_serial4        SERIAL4,
  col_bigserial      BIGSERIAL,
  col_serial8        SERIAL8
);

-- Character types
CREATE TABLE type_demo_character (
  col_text           TEXT,
  col_varchar        VARCHAR(255),
  col_char_varying   CHARACTER VARYING(100),
  col_char           CHAR(10),
  col_character      CHARACTER(5),
  col_name           NAME
);

-- Date/Time types
CREATE TABLE type_demo_datetime (
  col_timestamp      TIMESTAMP,
  col_timestamptz    TIMESTAMPTZ,
  col_ts_with_tz     TIMESTAMP WITH TIME ZONE,
  col_ts_without_tz  TIMESTAMP WITHOUT TIME ZONE,
  col_date           DATE,
  col_time           TIME,
  col_timetz         TIMETZ,
  col_time_with_tz   TIME WITH TIME ZONE,
  col_time_no_tz     TIME WITHOUT TIME ZONE,
  col_interval       INTERVAL
);

-- Boolean
CREATE TABLE type_demo_bool (
  col_boolean        BOOLEAN,
  col_bool           BOOL
);

-- Binary
CREATE TABLE type_demo_binary (
  col_bytea          BYTEA
);

-- Geometric types
CREATE TABLE type_demo_geometric (
  col_point          POINT,
  col_line           LINE,
  col_lseg           LSEG,
  col_box            BOX,
  col_path           PATH,
  col_polygon        POLYGON,
  col_circle         CIRCLE
);

-- Network types
CREATE TABLE type_demo_network (
  col_cidr           CIDR,
  col_inet           INET,
  col_macaddr        MACADDR,
  col_macaddr8       MACADDR8
);

-- Bit string types
CREATE TABLE type_demo_bit (
  col_bit            BIT(8),
  col_varbit         VARBIT(64),
  col_bit_varying    BIT VARYING(32)
);

-- Text search types
CREATE TABLE type_demo_textsearch (
  col_tsvector       TSVECTOR,
  col_tsquery        TSQUERY
);

-- JSON types
CREATE TABLE type_demo_json (
  col_json           JSON,
  col_jsonb          JSONB,
  col_jsonpath       JSONPATH
);

-- UUID and XML
CREATE TABLE type_demo_other (
  col_uuid           UUID,
  col_xml            XML
);

-- Range types
CREATE TABLE type_demo_ranges (
  col_int4range      INT4RANGE,
  col_int8range      INT8RANGE,
  col_numrange       NUMRANGE,
  col_tsrange        TSRANGE,
  col_tstzrange      TSTZRANGE,
  col_daterange      DATERANGE
);

-- Multirange types
CREATE TABLE type_demo_multiranges (
  col_int4multi      INT4MULTIRANGE,
  col_int8multi      INT8MULTIRANGE,
  col_nummulti       NUMMULTIRANGE,
  col_tsmulti        TSMULTIRANGE,
  col_tstzmulti      TSTZMULTIRANGE,
  col_datemulti      DATEMULTIRANGE
);

-- System / OID types
CREATE TABLE type_demo_system (
  col_oid            OID,
  col_regclass       REGCLASS,
  col_regcollation   REGCOLLATION,
  col_regconfig      REGCONFIG,
  col_regdictionary  REGDICTIONARY,
  col_regnamespace   REGNAMESPACE,
  col_regoper        REGOPER,
  col_regoperator    REGOPERATOR,
  col_regproc        REGPROC,
  col_regprocedure   REGPROCEDURE,
  col_regrole        REGROLE,
  col_regtype        REGTYPE,
  col_xid            XID,
  col_xid8           XID8,
  col_cid            CID,
  col_tid            TID,
  col_pg_lsn         PG_LSN,
  col_pg_snapshot    PG_SNAPSHOT
);

-- Casting between types
SELECT
  42::INTEGER,
  42::BIGINT,
  42::SMALLINT,
  42::NUMERIC(10,2),
  42::REAL,
  42::DOUBLE PRECISION,
  42::TEXT,
  'true'::BOOLEAN,
  '2024-01-15'::DATE,
  '2024-01-15 10:30:00'::TIMESTAMP,
  '2024-01-15 10:30:00+00'::TIMESTAMPTZ,
  '1 year 2 months 3 days'::INTERVAL,
  '192.168.1.0/24'::CIDR,
  '192.168.1.1'::INET,
  'a0:b1:c2:d3:e4:f5'::MACADDR,
  '{"key": "value"}'::JSONB,
  'a fat cat'::TSVECTOR,
  'fat & cat'::TSQUERY,
  'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'::UUID,
  '[2024-01-01, 2024-12-31]'::DATERANGE,
  ARRAY[1, 2, 3]::INTEGER[];

-- Pseudo-types in function signatures
CREATE FUNCTION identity_fn(val ANYELEMENT) RETURNS ANYELEMENT
  LANGUAGE sql AS $$ SELECT val; $$;

CREATE FUNCTION array_identity(val ANYARRAY) RETURNS ANYARRAY
  LANGUAGE sql AS $$ SELECT val; $$;

CREATE FUNCTION range_identity(val ANYRANGE) RETURNS ANYRANGE
  LANGUAGE sql AS $$ SELECT val; $$;

CREATE FUNCTION void_fn() RETURNS VOID
  LANGUAGE sql AS $$ SELECT; $$;

CREATE FUNCTION set_fn() RETURNS SETOF INTEGER
  LANGUAGE sql AS $$ SELECT generate_series(1, 10); $$;

CREATE FUNCTION record_fn() RETURNS RECORD
  LANGUAGE sql AS $$ SELECT 1, 'hello'::TEXT; $$;
