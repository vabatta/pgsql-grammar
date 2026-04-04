-- Built-in functions
SELECT now(), count(*);
--     ^^^ support.function
--            ^^^^^ support.function

-- Schema-qualified function
SELECT app.my_func();
--         ^^^^^^^ support.function

-- Table names after COPY should NOT be functions
COPY users (name) FROM stdin;
--   ^^^^^ !support.function

-- Table names after INSERT INTO should NOT be functions
INSERT INTO users (name) VALUES (1);
--          ^^^^^ !support.function

-- Table names after REFERENCES should NOT be functions
REFERENCES users(id);
--         ^^^^^ !support.function

-- 'is' as SQL keyword (not followed by '(') should remain a keyword
SELECT x FROM t WHERE x IS NULL;
--                      ^^ keyword

-- column named 'output' in INSERT inside dollar-quote should NOT be keyword.ddl
DO $$ BEGIN INSERT INTO t (id, output) VALUES (1, 'x'); END; $$;
--                             ^^^^^^ !keyword.ddl
