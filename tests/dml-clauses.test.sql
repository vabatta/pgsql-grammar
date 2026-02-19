-- DISTINCT ON
SELECT DISTINCT ON (dept_id) name FROM users;
--     ^^^^^^^^ keyword

-- NULLS FIRST / NULLS LAST
SELECT * FROM t ORDER BY name ASC NULLS FIRST;
--                                ^^^^^^^^^^^ keyword
SELECT * FROM t ORDER BY name DESC NULLS LAST;
--                                 ^^^^^^^^^^ keyword

-- FETCH FIRST / ROWS ONLY
SELECT * FROM t FETCH FIRST 5 ROWS ONLY;
--              ^^^^^^^^^^^ keyword
--                                 ^^^^ keyword

-- TABLESAMPLE
SELECT * FROM large_table TABLESAMPLE BERNOULLI(10);
--                        ^^^^^^^^^^^ keyword

-- FILTER clause
SELECT count(*) FILTER (WHERE x > 0) FROM t;
--              ^^^^^^ keyword

-- WITHIN GROUP
SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY salary) FROM t;
--                          ^^^^^^^^^^^^ keyword

-- GROUPING SETS / CUBE / ROLLUP
SELECT dept, count(*) FROM t GROUP BY GROUPING SETS ((dept), ());
--                                    ^^^^^^^^^^^^^ keyword
SELECT dept, count(*) FROM t GROUP BY CUBE (dept);
--                                    ^^^^ keyword
SELECT dept, count(*) FROM t GROUP BY ROLLUP (dept);
--                                    ^^^^^^ keyword

-- WINDOW clause
SELECT row_number() OVER w FROM t WINDOW w AS (ORDER BY id);
--                                ^^^^^^ keyword

-- LATERAL
SELECT * FROM t CROSS JOIN LATERAL (SELECT 1) sub;
--                         ^^^^^^^ keyword

-- ON CONFLICT / DO UPDATE / DO NOTHING
INSERT INTO t (id) VALUES (1) ON CONFLICT (id) DO UPDATE SET id = 1;
--                             ^^^^^^^^^^^ keyword
--                                              ^^^^^^^^^ keyword
INSERT INTO t (id) VALUES (1) ON CONFLICT DO NOTHING;
--                                        ^^^^^^^^^^ keyword

-- EXCLUDED
INSERT INTO t (id, v) VALUES (1, 2) ON CONFLICT (id) DO UPDATE SET v = EXCLUDED.v;
--                                                                      ^^^^^^^^ keyword

-- RETURNING
INSERT INTO t (id) VALUES (1) RETURNING id;
--                             ^^^^^^^^^ keyword

-- ISNULL / NOTNULL
SELECT * FROM t WHERE x ISNULL;
--                      ^^^^^^ keyword
SELECT * FROM t WHERE x NOTNULL;
--                      ^^^^^^^ keyword

-- OVERLAPS
SELECT (DATE '2024-01-01', DATE '2024-06-30') OVERLAPS (DATE '2024-03-01', INTERVAL '1 day');
--                                            ^^^^^^^^ keyword

-- ESCAPE
SELECT 'a' LIKE 'a%' ESCAPE '\';
--                    ^^^^^^ keyword

-- RECURSIVE in CTE
WITH RECURSIVE cte AS (SELECT 1) SELECT * FROM cte;
--   ^^^^^^^^^ keyword

-- SEARCH / CYCLE in CTE
WITH RECURSIVE cte AS (SELECT 1 UNION ALL SELECT 1) SEARCH DEPTH FIRST BY id SET ord CYCLE id SET cyc USING path SELECT 1;
--                                                   ^^^^^^ keyword
--                                                          ^^^^^ keyword
--                                                                          ^^^ keyword
--                                                                                   ^^^^^ keyword

-- SIMILAR TO
SELECT 'hello' SIMILAR TO 'h%';
--              ^^^^^^^^^^ keyword

-- LIKE / ILIKE
SELECT 'hello' LIKE 'h%';
--             ^^^^ keyword
SELECT 'hello' ILIKE 'H%';
--             ^^^^^ keyword

-- FREEZE
SELECT * FROM t FOR UPDATE;
--              ^^^^^^^^^^ keyword
