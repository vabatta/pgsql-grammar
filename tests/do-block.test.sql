-- BEGIN / END inside DO body are highlighted
DO $$ BEGIN NULL; END; $$;
--       ^^^^^ keyword
--                ^^^ keyword

-- IF / THEN / ELSE inside DO body
DO $$ BEGIN IF true THEN NULL; ELSE NULL; END IF; END; $$;
--          ^^ keyword
--                  ^^^^ keyword
--                             ^^^^ keyword

-- RAISE with severity inside DO body
DO $$ BEGIN RAISE NOTICE 'msg'; END; $$;
--          ^^^^^ keyword
--                ^^^^^^ keyword

-- PERFORM inside DO body
DO $$ BEGIN PERFORM pg_sleep(0); END; $$;
--          ^^^^^^^ keyword

-- WHILE loop inside DO body
DO $$ BEGIN WHILE true LOOP NULL; END LOOP; END; $$;
--          ^^^^^ keyword

-- EXECUTE with nested dollar-quote — inner $$ body is also highlighted as SQL
DO $$ BEGIN EXECUTE $q$ SELECT 1 $q$; END; $$;
--          ^^^^^^^ keyword
--                      ^^^^^^ keyword
