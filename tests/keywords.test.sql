-- Basic DML keywords
SELECT name FROM users WHERE id = 1;
--^^^^ keyword
--          ^^^^ keyword
--                     ^^^^^ keyword

-- DDL keywords
CREATE TABLE t (id INT CHECK (id > 0) NOT ENFORCED);
--^^^^ keyword
--     ^^^^^ keyword
--                     ^^^^^ keyword
--                                    ^^^^^^^^^^^^ keyword

-- VIRTUAL keyword in DDL context
CREATE TABLE t (x INT GENERATED ALWAYS AS (1) VIRTUAL);
--                    ^^^^^^^^^ keyword
--                              ^^^^^^ keyword
--                                            ^^^^^^^ keyword

-- WAIT FOR
WAIT FOR ALL;
--^^ keyword
--   ^^^ keyword

-- PERIOD
PERIOD FOR p (s, e)
--^^^^ keyword

-- IGNORE NULLS in expression context
SELECT x IGNORE NULLS FROM t;
--       ^^^^^^^^^^^^ keyword
