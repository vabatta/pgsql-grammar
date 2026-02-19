-- =============================================
-- PL/pgSQL: all control flow keywords
-- Dollar quoting, nested functions
-- =============================================

-- Complete PL/pgSQL function with all control flow
CREATE OR REPLACE FUNCTION process_batch(
  p_batch_id   BIGINT,
  p_dry_run    BOOLEAN DEFAULT FALSE,
  VARIADIC p_tags TEXT[] DEFAULT '{}'
)
RETURNS TABLE (processed_id BIGINT, status TEXT)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
COST 1000
AS $fn$
DECLARE
  v_count      INTEGER := 0;
  v_total      NUMERIC;
  v_item       RECORD;
  v_status     TEXT;
  v_cursor     REFCURSOR;
  v_row_count  INTEGER;
  v_found      BOOLEAN;
BEGIN
  -- IF / ELSIF / ELSEIF / ELSE / THEN
  IF p_batch_id IS NULL THEN
    RAISE EXCEPTION 'batch_id cannot be null';
  ELSIF p_batch_id < 0 THEN
    RAISE WARNING 'Negative batch_id: %', p_batch_id;
    RETURN;
  ELSEIF p_dry_run THEN
    RAISE INFO 'Dry run mode for batch %', p_batch_id;
  ELSE
    RAISE DEBUG 'Processing batch %', p_batch_id;
  END IF;

  -- CASE expression
  v_status := CASE
    WHEN p_dry_run THEN 'dry_run'
    WHEN array_length(p_tags, 1) > 0 THEN 'tagged'
    ELSE 'standard'
  END;

  RAISE LOG 'Batch % mode: %', p_batch_id, v_status;

  -- FOR loop with query
  FOR v_item IN
    SELECT id, name, quantity
    FROM batch_items
    WHERE batch_id = p_batch_id
    ORDER BY id
  LOOP
    v_count := v_count + 1;

    -- CONTINUE / EXIT
    IF v_item.quantity = 0 THEN
      CONTINUE;
    END IF;

    IF v_count > 10000 THEN
      RAISE NOTICE 'Reached processing limit at item %', v_item.id;
      EXIT;
    END IF;

    -- PERFORM (discard result)
    PERFORM pg_notify('batch_progress', json_build_object(
      'batch_id', p_batch_id,
      'item_id', v_item.id,
      'count', v_count
    )::TEXT);

    -- RETURN NEXT (for RETURNS TABLE)
    processed_id := v_item.id;
    status := 'ok';
    RETURN NEXT;
  END LOOP;

  -- WHILE loop
  WHILE v_count < 5 LOOP
    v_count := v_count + 1;
  END LOOP;

  -- FOREACH over array
  FOREACH v_status IN ARRAY p_tags LOOP
    RAISE NOTICE 'Tag: %', v_status;
  END LOOP;

  -- GET DIAGNOSTICS
  UPDATE batch_items SET processed = TRUE WHERE batch_id = p_batch_id;
  GET DIAGNOSTICS v_row_count = ROW_COUNT;
  RAISE NOTICE 'Updated % rows', v_row_count;

  -- FOUND
  SELECT count(*) INTO STRICT v_total
  FROM batch_items
  WHERE batch_id = p_batch_id AND NOT processed;

  IF NOT FOUND THEN
    RAISE NOTICE 'All items processed';
  END IF;

  -- EXECUTE dynamic SQL
  EXECUTE format(
    'UPDATE batches SET status = %L, completed_at = now() WHERE id = %L',
    v_status, p_batch_id
  );

  -- Cursor operations
  OPEN v_cursor FOR SELECT * FROM batch_items WHERE batch_id = p_batch_id;
  FETCH v_cursor INTO v_item;
  MOVE FORWARD 5 IN v_cursor;
  CLOSE v_cursor;

  RETURN;

EXCEPTION
  WHEN unique_violation THEN
    RAISE WARNING 'Duplicate entry in batch %', p_batch_id;
  WHEN foreign_key_violation THEN
    RAISE WARNING 'FK violation in batch %', p_batch_id;
  WHEN others THEN
    RAISE WARNING 'Error in batch %: % %', p_batch_id, SQLSTATE, SQLERRM;
    RETURN;
END;
$fn$;

-- Function using RETURN QUERY
CREATE OR REPLACE FUNCTION get_active_users(p_limit INTEGER DEFAULT 100)
RETURNS SETOF users
LANGUAGE plpgsql
STABLE
SECURITY INVOKER
PARALLEL SAFE
CALLED ON NULL INPUT
AS $$
BEGIN
  RETURN QUERY
    SELECT *
    FROM users
    WHERE is_active = TRUE
    ORDER BY last_login DESC
    LIMIT p_limit;
END;
$$;

-- Procedure with transaction control
CREATE OR REPLACE PROCEDURE transfer_funds(
  p_from_id  BIGINT,
  p_to_id    BIGINT,
  p_amount   NUMERIC,
  INOUT p_success BOOLEAN DEFAULT FALSE
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_balance NUMERIC;
BEGIN
  SAVEPOINT before_transfer;

  SELECT balance INTO v_balance
  FROM accounts
  WHERE id = p_from_id
  FOR UPDATE;

  IF v_balance < p_amount THEN
    ROLLBACK TO SAVEPOINT before_transfer;
    p_success := FALSE;
    RETURN;
  END IF;

  UPDATE accounts SET balance = balance - p_amount WHERE id = p_from_id;
  UPDATE accounts SET balance = balance + p_amount WHERE id = p_to_id;

  RELEASE SAVEPOINT before_transfer;
  COMMIT;
  p_success := TRUE;
END;
$$;

-- CALL a procedure
CALL transfer_funds(1, 2, 100.00);

-- Nested dollar quotes
CREATE OR REPLACE FUNCTION run_dynamic(p_table TEXT)
RETURNS VOID
LANGUAGE plpgsql
AS $outer$
BEGIN
  EXECUTE $inner$
    SELECT count(*) FROM $inner$ || quote_ident(p_table);

  -- Another level of nesting
  EXECUTE $sql$
    DO $do$
    BEGIN
      RAISE NOTICE 'Inside nested block';
    END;
    $do$
  $sql$;
END;
$outer$;

-- ALIAS for function parameters
CREATE OR REPLACE FUNCTION get_user_name(p_id BIGINT)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
  user_id ALIAS FOR p_id;
  v_name  TEXT;
BEGIN
  SELECT name INTO v_name FROM users WHERE id = user_id;
  RETURN v_name;
END;
$$;

-- CONSTANT declaration
DO $$
DECLARE
  MAX_RETRIES CONSTANT int := 5;
  PI          CONSTANT numeric := 3.14159;
BEGIN
  RAISE NOTICE 'Max retries: %, PI: %', MAX_RETRIES, PI;
END;
$$;

-- FOR loop with REVERSE
DO $$
BEGIN
  FOR i IN REVERSE 10..1 LOOP
    RAISE NOTICE 'Countdown: %', i;
  END LOOP;
END;
$$;

-- FOREACH with SLICE
DO $$
DECLARE
  matrix int[][] := ARRAY[[1,2],[3,4],[5,6]];
  row_slice int[];
BEGIN
  FOREACH row_slice SLICE 1 IN ARRAY matrix LOOP
    RAISE NOTICE 'Row: %', row_slice;
  END LOOP;
END;
$$;

-- COMMIT / ROLLBACK AND CHAIN
CREATE OR REPLACE PROCEDURE batch_insert(n int)
LANGUAGE plpgsql
AS $$
BEGIN
  FOR i IN 1..n LOOP
    INSERT INTO batch_log (step) VALUES (i);
    IF i % 100 = 0 THEN
      COMMIT AND CHAIN;
    END IF;
  END LOOP;
  COMMIT;
END;
$$;

-- RAISE with USING options (MESSAGE, DETAIL, HINT, ERRCODE)
DO $$
BEGIN
  RAISE EXCEPTION 'Import failed'
    USING MESSAGE = 'Could not import row 42',
          DETAIL  = 'Column "email" violates NOT NULL constraint',
          HINT    = 'Ensure all required columns are present in the CSV',
          ERRCODE = 'P0001';
EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE 'Caught: %', SQLERRM;
END;
$$;

-- GET STACKED DIAGNOSTICS
DO $$
DECLARE
  v_state   TEXT;
  v_msg     TEXT;
  v_detail  TEXT;
  v_context TEXT;
BEGIN
  BEGIN
    EXECUTE 'SELECT 1/0';
  EXCEPTION WHEN OTHERS THEN
    GET STACKED DIAGNOSTICS
      v_state   = RETURNED_SQLSTATE,
      v_msg     = MESSAGE_TEXT,
      v_detail  = PG_EXCEPTION_DETAIL,
      v_context = PG_EXCEPTION_CONTEXT;
    RAISE NOTICE 'State: %, Message: %, Detail: %, Context: %',
      v_state, v_msg, v_detail, v_context;
  END;
END;
$$;

-- GET DIAGNOSTICS with PG_ROUTINE_OID
CREATE OR REPLACE FUNCTION self_aware()
RETURNS void LANGUAGE plpgsql AS $$
DECLARE
  v_oid OID;
BEGIN
  GET DIAGNOSTICS v_oid = PG_ROUTINE_OID;
  RAISE NOTICE 'My OID is %', v_oid;
END;
$$;

-- DO block (anonymous code block)
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
    EXECUTE 'ANALYZE ' || quote_ident(r.tablename);
  END LOOP;
END;
$$;

-- Trigger function with NEW/OLD references
CREATE OR REPLACE FUNCTION audit_trigger()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_log (table_name, action, new_data)
    VALUES (TG_TABLE_NAME, 'INSERT', to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_log (table_name, action, old_data, new_data)
    VALUES (TG_TABLE_NAME, 'UPDATE', to_jsonb(OLD), to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_log (table_name, action, old_data)
    VALUES (TG_TABLE_NAME, 'DELETE', to_jsonb(OLD));
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;
