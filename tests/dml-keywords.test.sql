-- DEFAULT VALUES in INSERT
INSERT INTO t DEFAULT VALUES;
--            ^^^^^^^^^^^^^^ keyword

-- COLLATE in expressions (DML context)
SELECT name FROM t ORDER BY name COLLATE "C";
--                               ^^^^^^^ keyword

-- OVERRIDING SYSTEM VALUE
INSERT INTO t OVERRIDING SYSTEM VALUE VALUES (1);
--            ^^^^^^^^^^ keyword
--                       ^^^^^^ keyword

-- OVERRIDING USER VALUE
INSERT INTO t OVERRIDING USER VALUE VALUES (1);
--            ^^^^^^^^^^ keyword

-- MERGE SOURCE and TARGET
MERGE INTO t USING s ON t.id = s.id WHEN NOT MATCHED BY SOURCE THEN DELETE;
--                                                      ^^^^^^ keyword
MERGE INTO t USING s ON t.id = s.id WHEN NOT MATCHED BY TARGET THEN INSERT DEFAULT VALUES;
--                                                      ^^^^^^ keyword

-- CURRENT OF in WHERE clause
UPDATE t SET x = 1 WHERE CURRENT OF my_cursor;
--                        ^^^^^^^ keyword
--                                ^^ keyword

-- NOT MATERIALIZED in CTE
WITH cte AS NOT MATERIALIZED (SELECT 1) SELECT * FROM cte;
--          ^^^^^^^^^^^^^^^^ keyword

-- MATERIALIZED in CTE (DML context)
WITH cte AS MATERIALIZED (SELECT 1) SELECT * FROM cte;
--          ^^^^^^^^^^^^ keyword

-- NOT BETWEEN SYMMETRIC
SELECT x FROM t WHERE x NOT BETWEEN SYMMETRIC 1 AND 10;
--                       ^^^^^^^^^^^^^^^^^^^^^^ keyword

-- FOR UPDATE / FOR SHARE as compound keywords
SELECT x FROM t FOR UPDATE;
--              ^^^^^^^^^^ keyword
SELECT x FROM t FOR SHARE;
--              ^^^^^^^^^ keyword

-- COPY keywords
COPY t FROM STDIN;
--         ^^^^^ keyword
COPY t TO STDOUT;
--        ^^^^^^ keyword
COPY t FROM PROGRAM 'cmd';
--          ^^^^^^^ keyword
COPY t FROM STDIN WITH (FORCE_NOT_NULL (col1), FORCE_NULL (col2), FORCE_QUOTE (col3));
--                       ^^^^^^^^^^^^^^ keyword
--                                              ^^^^^^^^^^ keyword
--                                                                 ^^^^^^^^^^^ keyword
COPY t FROM STDIN WITH (ON_ERROR stop, LOG_VERBOSITY verbose);
--                       ^^^^^^^^ keyword
--                                     ^^^^^^^^^^^^^ keyword

-- BINARY option
COPY t TO STDOUT WITH (FORMAT BINARY);
--                             ^^^^^^ keyword
