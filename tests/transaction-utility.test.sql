-- Isolation levels
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
--                                ^^^^^^^^^^^^ keyword
BEGIN ISOLATION LEVEL REPEATABLE READ;
--                    ^^^^^^^^^^ keyword
BEGIN ISOLATION LEVEL READ COMMITTED;
--                         ^^^^^^^^^ keyword
BEGIN ISOLATION LEVEL READ UNCOMMITTED;
--                         ^^^^^^^^^^^ keyword

-- DEFERRABLE / READ ONLY
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE READ ONLY DEFERRABLE;
--                                                       ^^^^^^^^^^ keyword

-- SAVEPOINT / ROLLBACK TO / RELEASE
SAVEPOINT sp1;
--^^^^^^^ keyword
ROLLBACK TO SAVEPOINT sp1;
--^^^^^^^ keyword
RELEASE SAVEPOINT sp1;
--^^^^^ keyword

-- ABORT
ABORT;
--^^^ keyword

-- SCROLL / CURSOR / WITH HOLD
BEGIN;
DECLARE c SCROLL CURSOR WITH HOLD FOR SELECT 1;
--        ^^^^^^ keyword
--               ^^^^^^ keyword
--                       ^^^^^^^^^ keyword

-- FETCH directions
FETCH NEXT FROM c;
--    ^^^^ keyword
FETCH FORWARD 5 FROM c;
--    ^^^^^^^ keyword
FETCH BACKWARD 5 FROM c;
--    ^^^^^^^^ keyword
FETCH ABSOLUTE 5 FROM c;
--    ^^^^^^^^ keyword
FETCH RELATIVE 2 FROM c;
--    ^^^^^^^^ keyword
FETCH PRIOR FROM c;
--    ^^^^^ keyword
CLOSE c;
COMMIT;

-- LOCK TABLE
BEGIN;
LOCK TABLE t IN ACCESS EXCLUSIVE MODE NOWAIT;
--^^ keyword
--                                    ^^^^^^ keyword
COMMIT;

-- LISTEN / NOTIFY / UNLISTEN
LISTEN my_channel;
--^^^^ keyword
NOTIFY my_channel, 'payload';
--^^^^ keyword
UNLISTEN my_channel;
--^^^^^^ keyword

-- PREPARE / DEALLOCATE
PREPARE stmt (int) AS SELECT $1;
--^^^^^ keyword
DEALLOCATE stmt;
--^^^^^^^^ keyword

-- SHOW / RESET
SHOW work_mem;
--^^ keyword
RESET work_mem;
--^^^ keyword

-- DISCARD
DISCARD ALL;
--^^^^^ keyword

-- CHECKPOINT
CHECKPOINT;
--^^^^^^^^ keyword

-- FREEZE in VACUUM
VACUUM (FREEZE) t;
--      ^^^^^^ keyword

-- VERBOSE in VACUUM
VACUUM (VERBOSE) t;
--      ^^^^^^^ keyword
