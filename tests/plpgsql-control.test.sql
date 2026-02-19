-- PERFORM
DO $$ BEGIN PERFORM pg_sleep(0); END; $$;
--          ^^^^^^^ keyword

-- RETURN NEXT
DO $$ BEGIN RETURN NEXT; END; $$;
--          ^^^^^^^^^^^ keyword

-- RETURN QUERY
DO $$ BEGIN RETURN QUERY SELECT 1; END; $$;
--          ^^^^^^^^^^^^ keyword

-- INTO STRICT
DO $$ DECLARE v int; BEGIN SELECT 1 INTO STRICT v; END; $$;
--                                  ^^^^^^^^^^^ keyword

-- EXECUTE (dynamic SQL)
DO $$ BEGIN EXECUTE 'SELECT 1'; END; $$;
--          ^^^^^^^ keyword

-- FOUND
DO $$ BEGIN IF FOUND THEN NULL; END IF; END; $$;
--            ^^^^^ keyword

-- ELSIF / ELSEIF
DO $$ BEGIN IF false THEN NULL; ELSIF true THEN NULL; END IF; END; $$;
--                              ^^^^^ keyword
DO $$ BEGIN IF false THEN NULL; ELSEIF true THEN NULL; END IF; END; $$;
--                              ^^^^^^ keyword

-- CONTINUE / EXIT
DO $$ BEGIN LOOP CONTINUE WHEN true; EXIT; END LOOP; END; $$;
--               ^^^^^^^^ keyword
--                                   ^^^^ keyword

-- WHILE
DO $$ BEGIN WHILE true LOOP NULL; END LOOP; END; $$;
--          ^^^^^ keyword

-- FOREACH (without SLICE)
DO $$ DECLARE x int; BEGIN FOREACH x IN ARRAY ARRAY[1,2] LOOP NULL; END LOOP; END; $$;
--                         ^^^^^^^ keyword

-- OPEN / CLOSE for cursors
DO $$ DECLARE c REFCURSOR; BEGIN OPEN c FOR SELECT 1; CLOSE c; END; $$;
--                               ^^^^ keyword
--                                                     ^^^^^ keyword

-- RAISE severity levels
DO $$ BEGIN RAISE NOTICE 'msg'; END; $$;
--          ^^^^^ keyword
--                ^^^^^^ keyword
DO $$ BEGIN RAISE WARNING 'msg'; END; $$;
--                ^^^^^^^ keyword
DO $$ BEGIN RAISE INFO 'msg'; END; $$;
--                ^^^^ keyword
DO $$ BEGIN RAISE DEBUG 'msg'; END; $$;
--                ^^^^^ keyword
DO $$ BEGIN RAISE LOG 'msg'; END; $$;
--                ^^^ keyword

-- ASSERT
DO $$ BEGIN ASSERT true, 'ok'; END; $$;
--          ^^^^^^ keyword

-- SAVEPOINT / RELEASE in PL
DO $$ BEGIN SAVEPOINT sp; RELEASE SAVEPOINT sp; END; $$;
--          ^^^^^^^^^ keyword
--                        ^^^^^^^ keyword

-- CALL
CALL my_procedure(1, 2);
--^^ keyword
