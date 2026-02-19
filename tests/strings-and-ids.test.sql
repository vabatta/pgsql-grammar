-- Single-quoted strings
SELECT 'hello' FROM t;
--     ^^^^^^^ string.quoted.single

-- Escape strings
SELECT E'\n' FROM t;
--     ^^^^^ string.quoted.single

-- Double-quoted identifiers
SELECT "my_col" FROM t;
--     ^^^^^^^^ variable.other

-- Line comments
-- this is a comment
-- ^^^^^^^^^^^^^^^^^ comment.line.double-dash

-- Block comments
SELECT /* inline */ 1;
--     ^^^^^^^^^^^^ comment.block
