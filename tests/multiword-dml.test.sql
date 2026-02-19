-- AT TIME ZONE (all three words should be keyword in DML)
SELECT ts AT TIME ZONE 'UTC' FROM t;
--        ^^^^^^^^^^^^ keyword

-- FOR UPDATE / FOR SHARE locking clauses
SELECT x FROM t FOR UPDATE;
--              ^^^ keyword
--                  ^^^^^^ keyword
SELECT x FROM t FOR SHARE;
--              ^^^ keyword
--                  ^^^^^ keyword

-- FOR NO KEY UPDATE (4-word keyword in DML context)
SELECT x FROM t FOR NO KEY UPDATE;
--              ^^^^^^^^^^^^^^^^^ keyword

-- FOR KEY SHARE (3-word keyword in DML context)
SELECT x FROM t FOR KEY SHARE;
--              ^^^^^^^^^^^^^ keyword

-- SKIP LOCKED
SELECT x FROM t FOR UPDATE SKIP LOCKED;
--                         ^^^^^^^^^^^ keyword

-- BETWEEN SYMMETRIC
SELECT x FROM t WHERE x BETWEEN SYMMETRIC 1 AND 10;
--                       ^^^^^^^^^^^^^^^^^ keyword

-- EXCLUDE in window frame (DML context, not just DDL)
SELECT x, sum(x) OVER (ORDER BY x ROWS UNBOUNDED PRECEDING EXCLUDE CURRENT ROW) FROM t;
--                                                          ^^^^^^^ keyword
--                                                                  ^^^^^^^ keyword
--                                                                          ^^^ keyword
