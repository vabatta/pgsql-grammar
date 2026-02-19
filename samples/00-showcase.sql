-- Contextual highlighting: same words, different colors
SELECT
  u.name,                                      -- identifier (unstyled)
  u.created_at::DATE,                          -- type after :: (green)
  DATE '2024-01-01' AS since,                  -- type before literal (green)
  EXTRACT(EPOCH FROM u.created_at) AS ts,      -- extract field (purple)
  count(*) FILTER (WHERE u.is_active) AS total,
  CASE WHEN u.role IS NOT NULL THEN TRUE
       ELSE FALSE END AS has_role,             -- constants (purple)
  coalesce(u.score, 0) AS score,
  app.get_label(u.id) AS label                 -- user-defined function (blue)
FROM "public"."users" u                        -- quoted identifiers
LEFT JOIN orders o ON o.user_id = u.id
WHERE u.status IN ('active', 'pending')        -- strings
  AND u.score > 42                             -- number (blue)
  AND u.email IS NOT NULL
  AND u.metadata @> '{"verified": true}'::JSONB
GROUP BY u.name, u.created_at, u.role, u.status,
         u.score, u.is_active, u.id, u.email, u.metadata
ORDER BY total DESC NULLS LAST
LIMIT 100;

-- INSERT with ON CONFLICT and EXCLUDED
INSERT INTO users (name, email, role)
VALUES ('Alice', 'alice@example.com', 'admin')
ON CONFLICT (email) DO UPDATE
SET name = EXCLUDED.name,
    role = EXCLUDED.role
RETURNING id, name;

-- DDL: types in columns, VIRTUAL generated, NOT ENFORCED (PG18)
CREATE TABLE orders (
  id          BIGSERIAL PRIMARY KEY,
  user_id     BIGINT NOT NULL REFERENCES users(id),
  subtotal    NUMERIC(10,2) DEFAULT 0,
  tax         NUMERIC(10,2) GENERATED ALWAYS AS (subtotal * 0.08) VIRTUAL,
  status      TEXT CHECK (status IN ('pending', 'shipped')) NOT ENFORCED,
  metadata    JSONB,
  created_at  TIMESTAMPTZ DEFAULT now()
);

-- PL/pgSQL: types in DECLARE, not in DML
CREATE OR REPLACE FUNCTION get_user_summary(p_id BIGINT)
RETURNS TABLE (user_name TEXT, order_count INTEGER)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  v_found  BOOLEAN;
  v_total  NUMERIC;
BEGIN
  RETURN QUERY
    SELECT u.name, count(o.id)::INTEGER
    FROM users u
    LEFT JOIN orders o ON o.user_id = u.id
    WHERE u.id = p_id
    GROUP BY u.name;

  GET DIAGNOSTICS v_found = ROW_COUNT;
  IF NOT v_found THEN
    RAISE NOTICE 'User % not found', p_id;
  END IF;
END;
$$;

-- RETURNING with OLD/NEW (PG18)
UPDATE orders SET subtotal = 29.99 WHERE id = 1
RETURNING OLD.subtotal AS was, NEW.subtotal AS now;

-- COPY with option keywords
COPY users (name, email) TO '/tmp/users.csv'
  WITH (FORMAT csv, HEADER true, DELIMITER ',');
