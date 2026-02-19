-- =============================================
-- DDL: CREATE, ALTER, DROP for all object types
-- =============================================

-- Schema
CREATE SCHEMA IF NOT EXISTS app;
ALTER SCHEMA app OWNER TO admin_user;
DROP SCHEMA IF EXISTS old_schema CASCADE;

-- Database
CREATE DATABASE analytics
  OWNER = admin_user
  ENCODING = 'UTF8'
  TABLESPACE = fast_storage;

-- Extension
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
DROP EXTENSION IF EXISTS hstore CASCADE;

-- Domain
CREATE DOMAIN email_address AS TEXT
  CHECK (VALUE ~* '^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$')
  NOT NULL;

CREATE DOMAIN positive_int AS INTEGER
  DEFAULT 0
  CONSTRAINT positive_check CHECK (VALUE >= 0);

ALTER DOMAIN email_address ADD CONSTRAINT max_len CHECK (length(VALUE) <= 255);
DROP DOMAIN IF EXISTS old_domain RESTRICT;

-- Type (composite)
CREATE TYPE address AS (
  street TEXT,
  city   TEXT,
  state  CHAR(2),
  zip    VARCHAR(10)
);

-- Type (enum)
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'shipped', 'delivered', 'cancelled');
ALTER TYPE order_status ADD VALUE IF NOT EXISTS 'refunded' AFTER 'cancelled';

-- Table with all column options
CREATE TABLE app.orders (
  id           BIGSERIAL PRIMARY KEY,
  user_id      BIGINT NOT NULL REFERENCES app.users(id),
  status       order_status DEFAULT 'pending',
  total        NUMERIC(12, 2) NOT NULL CHECK (total >= 0),
  currency     CHAR(3) DEFAULT 'USD',
  notes        TEXT,
  metadata     JSONB DEFAULT '{}'::JSONB,
  tags         TEXT[] DEFAULT '{}',
  ip_address   INET,
  session_id   UUID,
  created_at   TIMESTAMPTZ DEFAULT now() NOT NULL,
  updated_at   TIMESTAMPTZ,
  CONSTRAINT orders_total_positive CHECK (total > 0),
  UNIQUE (user_id, created_at),
  EXCLUDE USING gist (tstzrange(created_at, updated_at) WITH &&)
);

COMMENT ON TABLE app.orders IS 'Customer orders';
COMMENT ON COLUMN app.orders.metadata IS 'Arbitrary JSON metadata';

-- Unlogged table
CREATE UNLOGGED TABLE session_cache (
  token TEXT PRIMARY KEY,
  data  JSONB,
  expires_at TIMESTAMPTZ
);

-- Temporary table
CREATE TEMPORARY TABLE tmp_import (
  raw_data TEXT
);

CREATE TEMP TABLE tmp_staging (LIKE app.orders INCLUDING ALL);

-- Virtual generated columns (PG18)
CREATE TABLE app.products (
  id          BIGSERIAL PRIMARY KEY,
  price       NUMERIC(10,2) NOT NULL,
  tax_rate    NUMERIC(4,2) DEFAULT 0.08,
  total       NUMERIC(10,2) GENERATED ALWAYS AS (price * (1 + tax_rate)) VIRTUAL,
  label       TEXT GENERATED ALWAYS AS (price::TEXT || ' USD') STORED
);

-- NOT ENFORCED constraints (PG18)
CREATE TABLE app.imports (
  id          BIGSERIAL PRIMARY KEY,
  ref_id      BIGINT,
  amount      NUMERIC CHECK (amount > 0) NOT ENFORCED,
  FOREIGN KEY (ref_id) REFERENCES app.products(id) NOT ENFORCED
);

ALTER TABLE app.imports ALTER CONSTRAINT imports_amount_check ENFORCED;

-- Temporal constraints with WITHOUT OVERLAPS and PERIOD (PG18)
CREATE TABLE app.reservations (
  room_id     INTEGER,
  during      DATERANGE NOT NULL,
  guest       TEXT,
  PRIMARY KEY (room_id, during WITHOUT OVERLAPS)
);

CREATE TABLE app.bookings (
  room_id     INTEGER,
  during      DATERANGE NOT NULL,
  FOREIGN KEY (room_id, PERIOD during)
    REFERENCES app.reservations (room_id, PERIOD during)
);

-- Table with GENERATED columns and IDENTITY
CREATE TABLE app.invoices (
  id         BIGINT GENERATED ALWAYS AS IDENTITY,
  order_id   BIGINT REFERENCES app.orders(id),
  subtotal   NUMERIC(12, 2),
  tax_rate   NUMERIC(5, 4),
  tax_amount NUMERIC(12, 2) GENERATED ALWAYS AS (subtotal * tax_rate) STORED,
  total      NUMERIC(12, 2) GENERATED ALWAYS AS (subtotal + subtotal * tax_rate) STORED,
  PRIMARY KEY (id)
);

-- Table with inheritance
CREATE TABLE app.audit_log (
  id         BIGSERIAL PRIMARY KEY,
  action     TEXT NOT NULL,
  payload    JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE app.user_audit_log (
  user_id BIGINT NOT NULL REFERENCES app.users(id)
) INHERITS (app.audit_log);

-- Partitioned table
CREATE TABLE app.events (
  id         BIGSERIAL,
  event_type TEXT NOT NULL,
  payload    JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
) PARTITION BY RANGE (created_at);

CREATE TABLE app.events_2024q1 PARTITION OF app.events
  FOR VALUES FROM ('2024-01-01') TO ('2024-04-01');

ALTER TABLE app.events ATTACH PARTITION app.events_2024q2
  FOR VALUES FROM ('2024-04-01') TO ('2024-07-01');

ALTER TABLE app.events DETACH PARTITION app.events_2024q1;

-- SPLIT PARTITION (PG18)
ALTER TABLE app.events SPLIT PARTITION events_2024q1
  INTO (
    PARTITION events_2024m1 FOR VALUES FROM ('2024-01-01') TO ('2024-02-01'),
    PARTITION events_2024m2 FOR VALUES FROM ('2024-02-01') TO ('2024-03-01')
  );

-- ALTER TABLE operations
ALTER TABLE app.orders ADD COLUMN shipped_at TIMESTAMPTZ;
ALTER TABLE app.orders ALTER COLUMN notes SET DEFAULT '';
ALTER TABLE app.orders ALTER COLUMN currency SET NOT NULL;
ALTER TABLE app.orders RENAME COLUMN notes TO order_notes;
ALTER TABLE app.orders DROP COLUMN IF EXISTS old_column CASCADE;
ALTER TABLE app.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE app.orders DISABLE ROW LEVEL SECURITY;
ALTER TABLE app.orders SET LOGGED;
ALTER TABLE app.orders SET UNLOGGED;
ALTER TABLE app.orders OWNER TO app_admin;

-- Index types
CREATE INDEX idx_orders_user ON app.orders (user_id);
CREATE UNIQUE INDEX idx_orders_session ON app.orders (session_id) WHERE session_id IS NOT NULL;
CREATE INDEX CONCURRENTLY idx_orders_created ON app.orders (created_at DESC);
CREATE INDEX idx_orders_tags ON app.orders USING gin (tags);
CREATE INDEX idx_orders_metadata ON app.orders USING gin (metadata jsonb_path_ops);
CREATE INDEX idx_orders_ip ON app.orders USING gist (ip_address inet_ops);
CREATE INDEX idx_orders_covering ON app.orders (user_id) INCLUDE (total, status);
REINDEX INDEX CONCURRENTLY idx_orders_user;
DROP INDEX CONCURRENTLY IF EXISTS idx_orders_old;

-- View
CREATE OR REPLACE VIEW app.active_orders AS
  SELECT o.*, u.name AS user_name
  FROM app.orders o
  JOIN app.users u ON u.id = o.user_id
  WHERE o.status NOT IN ('cancelled', 'refunded');

-- Materialized view
CREATE MATERIALIZED VIEW app.order_stats AS
  SELECT
    date_trunc('month', created_at) AS month,
    count(*) AS order_count,
    sum(total) AS revenue
  FROM app.orders
  GROUP BY 1
WITH DATA;

REFRESH MATERIALIZED VIEW CONCURRENTLY app.order_stats;
DROP MATERIALIZED VIEW IF EXISTS app.old_stats;

-- Sequence
CREATE SEQUENCE app.custom_id_seq
  START WITH 1000
  INCREMENT BY 1
  NO MAXVALUE
  CACHE 20;

ALTER SEQUENCE app.custom_id_seq OWNED BY app.orders.id;

-- Function
CREATE OR REPLACE FUNCTION app.calculate_tax(amount NUMERIC, rate NUMERIC DEFAULT 0.08)
RETURNS NUMERIC
LANGUAGE sql
IMMUTABLE
PARALLEL SAFE
RETURNS NULL ON NULL INPUT
COST 10
AS $$
  SELECT round(amount * rate, 2);
$$;

-- Procedure
CREATE OR REPLACE PROCEDURE app.archive_old_orders(cutoff_date TIMESTAMPTZ)
LANGUAGE sql
AS $$
  DELETE FROM app.orders WHERE created_at < cutoff_date AND status = 'delivered';
$$;

-- Trigger + trigger function
CREATE OR REPLACE FUNCTION app.update_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_orders_updated
  BEFORE UPDATE ON app.orders
  FOR EACH ROW
  EXECUTE FUNCTION app.update_timestamp();

CREATE TRIGGER trg_orders_audit
  AFTER INSERT OR UPDATE OR DELETE ON app.orders
  FOR EACH STATEMENT
  EXECUTE PROCEDURE app.log_changes();

-- Event trigger
CREATE OR REPLACE FUNCTION log_ddl_events()
RETURNS EVENT_TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  RAISE NOTICE 'DDL event: %', tg_tag;
END;
$$;

-- Rule (legacy)
CREATE RULE protect_orders AS
  ON DELETE TO app.orders
  WHERE old.status = 'delivered'
  DO INSTEAD NOTHING;

-- Policy (RLS)
CREATE POLICY user_orders ON app.orders
  FOR ALL
  USING (user_id = current_setting('app.current_user_id')::BIGINT);

-- Aggregate
CREATE AGGREGATE array_concat_agg(anycompatiblearray) (
  SFUNC = array_cat,
  STYPE = anycompatiblearray,
  INITCOND = '{}'
);

-- Collation
CREATE COLLATION IF NOT EXISTS case_insensitive (
  provider = icu,
  locale = 'und-u-ks-level2'
);

-- Statistics
CREATE STATISTICS app.orders_stats (dependencies, mcv)
  ON user_id, status FROM app.orders;

-- Foreign data wrapper + server + mapping
CREATE SERVER remote_pg
  FOREIGN DATA WRAPPER postgres_fdw
  OPTIONS (host 'db.example.com', port '5432', dbname 'remote');

CREATE USER MAPPING FOR current_user
  SERVER remote_pg
  OPTIONS (user 'remote_user', password 'secret');

-- Tablespace
CREATE TABLESPACE fast_storage LOCATION '/ssd/pgdata';

-- Grant / Revoke / Privileges
GRANT SELECT, INSERT, UPDATE ON app.orders TO app_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA app TO app_admin;
REVOKE DELETE ON app.orders FROM app_user;
GRANT USAGE ON SCHEMA app TO app_readonly;

-- ALTER DEFAULT PRIVILEGES for LARGE OBJECTS (PG18)
ALTER DEFAULT PRIVILEGES
  GRANT SELECT ON LARGE OBJECTS TO analyst_role;

-- Reassign / Drop owned
REASSIGN OWNED BY old_user TO new_user;
DROP OWNED BY old_user CASCADE;

-- Role
CREATE ROLE app_readonly LOGIN;
ALTER ROLE app_readonly SET search_path = app, public;
DROP ROLE IF EXISTS temp_role;

-- GRANT advanced keywords
GRANT CONNECT ON DATABASE analytics TO app_readonly;
GRANT MAINTAIN ON TABLE app.orders TO app_admin;
GRANT EXECUTE ON ROUTINE app.calculate_tax TO app_user;
GRANT app_admin TO app_user WITH ADMIN OPTION;
GRANT app_admin TO app_user GRANTED BY admin_user;

-- Column COLLATE
CREATE TABLE app.i18n_content (
  id       BIGSERIAL PRIMARY KEY,
  title_en TEXT COLLATE "en_US",
  title_de TEXT COLLATE "de_DE"
);

-- MATCH SIMPLE / PARTIAL in foreign keys
CREATE TABLE app.fk_demo (
  a INTEGER,
  b INTEGER,
  FOREIGN KEY (a, b) REFERENCES app.parent(x, y) MATCH SIMPLE,
  FOREIGN KEY (a, b) REFERENCES app.parent(x, y) MATCH PARTIAL
);

-- Partition by HASH and LIST
CREATE TABLE app.sessions (
  id    BIGSERIAL,
  token TEXT NOT NULL
) PARTITION BY HASH (id);

CREATE TABLE app.sessions_0 PARTITION OF app.sessions
  FOR VALUES WITH (MODULUS 4, REMAINDER 0);
CREATE TABLE app.sessions_1 PARTITION OF app.sessions
  FOR VALUES WITH (MODULUS 4, REMAINDER 1);

CREATE TABLE app.logs (
  id       BIGSERIAL,
  severity TEXT NOT NULL
) PARTITION BY LIST (severity);

CREATE TABLE app.logs_info PARTITION OF app.logs
  FOR VALUES IN ('info', 'debug');

-- LIKE with EXCLUDING
CREATE TABLE app.orders_archive (LIKE app.orders EXCLUDING INDEXES);

-- ALTER TABLE: STORAGE types
ALTER TABLE app.orders ALTER COLUMN metadata SET STORAGE EXTENDED;
ALTER TABLE app.orders ALTER COLUMN notes SET STORAGE EXTERNAL;
ALTER TABLE app.orders ALTER COLUMN currency SET STORAGE PLAIN;
ALTER TABLE app.orders ALTER COLUMN status SET STORAGE MAIN;

-- ALTER TABLE: COMPRESSION
ALTER TABLE app.orders ALTER COLUMN metadata SET COMPRESSION lz4;

-- ALTER TABLE: VALIDATE CONSTRAINT
ALTER TABLE app.orders VALIDATE CONSTRAINT orders_total_positive;

-- ALTER TABLE: CLUSTER ON
ALTER TABLE app.orders CLUSTER ON idx_orders_user;

-- ALTER TABLE: REPLICA trigger
ALTER TABLE app.orders ENABLE REPLICA TRIGGER trg_orders_updated;

-- ALTER TABLE: EXPRESSION for generated columns
ALTER TABLE app.products ALTER COLUMN total SET EXPRESSION AS (price * (1 + tax_rate));

-- DETACH PARTITION with FINALIZE
ALTER TABLE app.events DETACH PARTITION app.events_2024q1 FINALIZE;

-- Schema with AUTHORIZATION
CREATE SCHEMA reporting AUTHORIZATION admin_user;

-- Extension with VERSION
CREATE EXTENSION hstore WITH VERSION '1.8';

-- View with CASCADED check option
CREATE VIEW app.active_users_strict AS
  SELECT * FROM app.users WHERE is_active
  WITH CASCADED CHECK OPTION;

-- Policy with PERMISSIVE / RESTRICTIVE
CREATE POLICY permissive_read ON app.orders AS PERMISSIVE
  FOR SELECT TO PUBLIC USING (true);

CREATE POLICY restrictive_dept ON app.orders AS RESTRICTIVE
  FOR ALL USING (department_id = current_setting('app.dept_id')::INT);

-- Sequence with OWNED BY NONE
ALTER SEQUENCE app.custom_id_seq OWNED BY NONE;

-- SECURITY LABEL
SECURITY LABEL ON TABLE app.orders IS 'classified';
SECURITY LABEL ON LARGE OBJECT 12345 IS 'restricted';

-- COMMENT ON PROCEDURAL LANGUAGE
COMMENT ON PROCEDURAL LANGUAGE plpgsql IS 'PL/pgSQL procedural language';

-- IMPORT FOREIGN SCHEMA
IMPORT FOREIGN SCHEMA public FROM SERVER remote_pg INTO app;

-- Foreign table
CREATE FOREIGN TABLE app.remote_users (
  id   BIGINT,
  name TEXT,
  email TEXT
) SERVER remote_pg OPTIONS (schema_name 'public', table_name 'users');

-- Publication and Subscription
CREATE PUBLICATION app_pub FOR ALL TABLES;
CREATE PUBLICATION orders_pub FOR TABLE app.orders;

CREATE SUBSCRIPTION app_sub
  CONNECTION 'host=replica dbname=analytics'
  PUBLICATION app_pub;

-- ACCESS METHOD
CREATE ACCESS METHOD myam TYPE TABLE HANDLER heap_tableam_handler;

-- TEXT SEARCH objects
CREATE TEXT SEARCH CONFIGURATION app.english_config (PARSER = default);
CREATE TEXT SEARCH DICTIONARY app.english_dict (TEMPLATE = simple, STOPWORDS = english);
CREATE TEXT SEARCH PARSER app.custom_parser (
  START = my_start, GETTOKEN = my_gettoken, END = my_end, LEXTYPES = my_lextypes
);
CREATE TEXT SEARCH TEMPLATE app.custom_template (INIT = my_init, LEXIZE = my_lexize);

-- OPERATOR FAMILY
CREATE OPERATOR FAMILY app.my_btree_ops USING btree;

-- CREATE TYPE (range) with params
CREATE TYPE app.float_range AS RANGE (
  SUBTYPE = float8,
  SUBTYPE_DIFF = float8mi,
  CANONICAL = my_canonical
);

-- CREATE AGGREGATE with params
CREATE AGGREGATE app.running_avg(float8) (
  SFUNC = float8_accum,
  STYPE = float8[],
  FINALFUNC = float8_avg,
  FINALFUNC_MODIFY = READ_ONLY,
  INITCOND = '{0,0,0}'
);

-- Function with TRANSFORM
CREATE FUNCTION app.json_handler()
RETURNS void LANGUAGE plpgsql TRANSFORM FOR TYPE jsonb AS $$
BEGIN
  NULL;
END;
$$;

-- Function with ATOMIC body (SQL-standard)
CREATE FUNCTION app.add_one(x int)
RETURNS int LANGUAGE sql BEGIN ATOMIC;
  RETURN x + 1;
END;
