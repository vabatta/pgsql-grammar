-- =============================================
-- DML: SELECT, INSERT, UPDATE, DELETE, MERGE
-- Query clauses and join types
-- =============================================

-- Basic SELECT with all clause keywords
SELECT DISTINCT ON (u.department_id)
  u.id, u.name, u.email, u.salary
FROM users u
WHERE u.is_active = TRUE
  AND u.salary BETWEEN 50000 AND 150000
  AND u.name LIKE 'A%'
  AND u.email ILIKE '%@example.com'
  AND u.name SIMILAR TO '(Alice|Bob)%'
  AND u.salary IS NOT NULL
  AND u.id IN (1, 2, 3, 4, 5)
  AND u.role IS DISTINCT FROM 'admin'
  AND u.department_id IS NOT DISTINCT FROM 10
  AND EXISTS (SELECT 1 FROM orders WHERE orders.user_id = u.id)
  AND u.salary > ANY (SELECT avg(salary) FROM users GROUP BY department_id)
  AND u.salary < ALL (SELECT max(salary) FROM users GROUP BY department_id)
  AND NOT u.is_deleted
GROUP BY u.id, u.name, u.email, u.salary, u.department_id
HAVING count(*) > 0
ORDER BY u.salary DESC NULLS LAST, u.name ASC NULLS FIRST
LIMIT 10 OFFSET 5;

-- FETCH FIRST / ROWS ONLY (SQL standard paging)
SELECT * FROM products
ORDER BY created_at DESC
FETCH FIRST 5 ROWS ONLY;

SELECT * FROM products
FETCH NEXT 10 ROWS ONLY;

-- All join types
SELECT o.id, u.name, p.title, c.name AS category
FROM orders o
INNER JOIN users u ON u.id = o.user_id
LEFT JOIN order_items oi ON oi.order_id = o.id
RIGHT JOIN products p ON p.id = oi.product_id
FULL JOIN categories c ON c.id = p.category_id
CROSS JOIN currencies curr
NATURAL JOIN shipping_zones sz
LEFT OUTER JOIN discounts d ON d.order_id = o.id
RIGHT OUTER JOIN warehouses w ON w.id = p.warehouse_id
FULL OUTER JOIN suppliers s ON s.id = p.supplier_id;

-- UNION / INTERSECT / EXCEPT
SELECT id, name, 'active' AS status FROM users WHERE is_active
UNION ALL
SELECT id, name, 'inactive' FROM users WHERE NOT is_active
INTERSECT
SELECT id, name, status FROM users WHERE created_at > '2024-01-01'
EXCEPT
SELECT id, name, status FROM users WHERE is_deleted;

-- TABLESAMPLE
SELECT * FROM large_table TABLESAMPLE BERNOULLI(10);

-- INSERT with ON CONFLICT
INSERT INTO users (name, email, role)
VALUES ('Alice', 'alice@example.com', 'admin'),
       ('Bob', 'bob@example.com', 'user')
ON CONFLICT (email) DO UPDATE
SET name = EXCLUDED.name,
    role = EXCLUDED.role
RETURNING id, name, email;

INSERT INTO audit_log (action) VALUES ('test')
ON CONFLICT DO NOTHING;

-- UPDATE with FROM and RETURNING
UPDATE products p
SET price = p.price * 1.10,
    updated_at = now()
FROM categories c
WHERE c.id = p.category_id
  AND c.name = 'Electronics'
RETURNING p.id, p.name, p.price;

-- DELETE with USING
DELETE FROM order_items oi
USING orders o
WHERE o.id = oi.order_id
  AND o.status = 'cancelled'
RETURNING oi.id;

-- MERGE (PG15+)
MERGE INTO inventory AS target
USING new_stock AS source
ON target.sku = source.sku
WHEN MATCHED AND source.quantity = 0 THEN
  DELETE
WHEN MATCHED THEN
  UPDATE SET quantity = target.quantity + source.quantity,
             updated_at = now()
WHEN NOT MATCHED THEN
  INSERT (sku, name, quantity, price)
  VALUES (source.sku, source.name, source.quantity, source.price);

-- INSERT with DEFAULT VALUES
INSERT INTO audit_log DEFAULT VALUES;

-- OVERRIDING SYSTEM / USER VALUE (identity columns)
INSERT INTO invoices (id, amount) OVERRIDING SYSTEM VALUE VALUES (999, 49.99);
INSERT INTO invoices (id, amount) OVERRIDING USER VALUE VALUES (1, 49.99);

-- COLLATE in expressions
SELECT name FROM users ORDER BY name COLLATE "C";
SELECT * FROM users WHERE name COLLATE "en_US" = 'Straße';

-- NOT MATERIALIZED / MATERIALIZED CTE hints
WITH cached AS MATERIALIZED (
  SELECT id, expensive_func(data) AS result FROM big_table
)
SELECT * FROM cached;

WITH uncached AS NOT MATERIALIZED (
  SELECT id, name FROM users WHERE is_active
)
SELECT * FROM uncached WHERE id < 100;

-- NOT BETWEEN SYMMETRIC
SELECT * FROM products WHERE price NOT BETWEEN SYMMETRIC 100 AND 10;

-- CURRENT OF (cursor-based update/delete)
UPDATE accounts SET balance = balance - 100 WHERE CURRENT OF acct_cursor;
DELETE FROM temp_results WHERE CURRENT OF batch_cursor;

-- MERGE with BY SOURCE / BY TARGET (PG17+)
MERGE INTO inventory AS t
USING new_shipment AS s ON t.sku = s.sku
WHEN MATCHED THEN
  UPDATE SET quantity = t.quantity + s.quantity
WHEN NOT MATCHED BY TARGET THEN
  INSERT (sku, quantity) VALUES (s.sku, s.quantity)
WHEN NOT MATCHED BY SOURCE THEN
  DELETE;

-- TRUNCATE with RESTART IDENTITY
TRUNCATE TABLE old_logs, archived_sessions;
TRUNCATE TABLE counters RESTART IDENTITY CASCADE;

-- COPY variants
COPY users (name, email) TO '/tmp/users.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', QUOTE '"', ESCAPE '\');
COPY users FROM '/tmp/import.csv' WITH (FORMAT csv, HEADER);
COPY imports FROM '/tmp/data.csv'
  WITH (FORMAT csv, HEADER true, ON_ERROR ignore, REJECT_LIMIT 100);

-- COPY from/to STDIN, STDOUT, PROGRAM
COPY users TO STDOUT WITH (FORMAT csv, HEADER);
COPY users FROM STDIN WITH (FORMAT csv);
COPY users FROM PROGRAM 'curl -s https://example.com/data.csv' WITH (FORMAT csv);

-- COPY BINARY format
COPY users TO '/tmp/users.bin' WITH (FORMAT BINARY);

-- COPY column-level options
COPY users FROM STDIN WITH (FORMAT csv, FORCE_NOT_NULL (email), FORCE_NULL (bio), FORCE_QUOTE (name));

-- COPY diagnostic options
COPY imports FROM '/tmp/data.csv'
  WITH (FORMAT csv, ON_ERROR stop, LOG_VERBOSITY verbose);

-- OLD/NEW in RETURNING (PG18)
INSERT INTO products (price, tax_rate)
VALUES (19.99, 0.10)
RETURNING NEW.*;

UPDATE products
SET price = 24.99
WHERE id = 1
RETURNING OLD.price AS old_price, NEW.price AS new_price;

DELETE FROM imports
WHERE id = 1
RETURNING OLD.*;

-- RESPECT/IGNORE NULLS in window functions (PG18)
SELECT
  product_id,
  value,
  first_value(value) IGNORE NULLS OVER (ORDER BY created_at) AS first_nn,
  last_value(value) RESPECT NULLS OVER (ORDER BY created_at) AS last_val
FROM measurements;

-- CTE with RECURSIVE, CYCLE, SEARCH
WITH RECURSIVE org_tree AS (
  SELECT id, name, manager_id, 1 AS depth
  FROM employees
  WHERE manager_id IS NULL
  UNION ALL
  SELECT e.id, e.name, e.manager_id, t.depth + 1
  FROM employees e
  JOIN org_tree t ON e.manager_id = t.id
)
SEARCH DEPTH FIRST BY name SET order_col
CYCLE id SET is_cycle USING path
SELECT * FROM org_tree WHERE NOT is_cycle;

-- LATERAL
SELECT u.name, recent.*
FROM users u
CROSS JOIN LATERAL (
  SELECT o.id, o.total, o.created_at
  FROM orders o
  WHERE o.user_id = u.id
  ORDER BY o.created_at DESC
  LIMIT 3
) recent;

-- GROUPING SETS, CUBE, ROLLUP
SELECT
  department_id,
  EXTRACT(YEAR FROM hire_date) AS hire_year,
  count(*) AS cnt,
  grouping(department_id) AS grp_dept,
  grouping(EXTRACT(YEAR FROM hire_date)) AS grp_year
FROM employees
GROUP BY GROUPING SETS (
  (department_id, EXTRACT(YEAR FROM hire_date)),
  (department_id),
  ()
);

SELECT region, product, sum(sales)
FROM sales_data
GROUP BY CUBE (region, product);

SELECT region, product, sum(sales)
FROM sales_data
GROUP BY ROLLUP (region, product);

-- Window functions in queries
SELECT
  name, department_id, salary,
  row_number() OVER w AS rn,
  rank() OVER w AS rnk,
  dense_rank() OVER w AS drnk,
  percent_rank() OVER w AS prnk,
  cume_dist() OVER w AS cd,
  ntile(4) OVER w AS quartile,
  lag(salary, 1) OVER w AS prev_salary,
  lead(salary, 1) OVER w AS next_salary,
  first_value(name) OVER w AS top_earner,
  last_value(name) OVER (w RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS bottom_earner,
  nth_value(name, 2) OVER w AS second_earner,
  avg(salary) OVER (w ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM employees
WINDOW w AS (PARTITION BY department_id ORDER BY salary DESC)
ORDER BY department_id, salary DESC;

-- FILTER clause with aggregates
SELECT
  department_id,
  count(*) AS total,
  count(*) FILTER (WHERE salary > 100000) AS high_earners,
  avg(salary) FILTER (WHERE hire_date > '2023-01-01') AS recent_avg,
  string_agg(name, ', ' ORDER BY name) FILTER (WHERE is_active) AS active_names
FROM employees
GROUP BY department_id;

-- WITHIN GROUP (ordered-set aggregates)
SELECT
  department_id,
  percentile_cont(0.5) WITHIN GROUP (ORDER BY salary) AS median_salary,
  percentile_disc(0.5) WITHIN GROUP (ORDER BY salary) AS median_salary_disc,
  mode() WITHIN GROUP (ORDER BY role) AS most_common_role
FROM employees
GROUP BY department_id;

-- Subqueries with ALL / ANY / SOME
SELECT * FROM products
WHERE price > ALL (SELECT price FROM products WHERE category_id = 1);

SELECT * FROM products
WHERE price > ANY (SELECT avg(price) FROM products GROUP BY category_id);

SELECT * FROM products
WHERE category_id = SOME (SELECT id FROM categories WHERE is_featured);

-- FOR UPDATE / SHARE / NOWAIT
SELECT * FROM accounts WHERE id = 1 FOR UPDATE NOWAIT;
SELECT * FROM accounts WHERE id = 1 FOR SHARE;
SELECT * FROM accounts WHERE id = 1 FOR UPDATE OF accounts;

-- ISNULL / NOTNULL operators
SELECT * FROM users WHERE email ISNULL;
SELECT * FROM users WHERE email NOTNULL;

-- Quoted identifiers
SELECT "user"."first_name", "user"."last_name"
FROM "public"."user"
WHERE "user"."is_active" = TRUE;

INSERT INTO "MySchema"."MyTable" ("Column1", "Column2")
VALUES ('value1', 'value2');

UPDATE "public"."order"
SET "status" = 'shipped', "updated_at" = now()
WHERE "order"."id" = 42;
