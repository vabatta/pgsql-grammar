-- Volatility
CREATE FUNCTION f() RETURNS void LANGUAGE sql VOLATILE AS $$ SELECT; $$;
--                                             ^^^^^^^^ keyword
CREATE FUNCTION f() RETURNS void LANGUAGE sql STABLE AS $$ SELECT; $$;
--                                             ^^^^^^ keyword
CREATE FUNCTION f() RETURNS void LANGUAGE sql IMMUTABLE AS $$ SELECT; $$;
--                                             ^^^^^^^^^ keyword

-- Security
CREATE FUNCTION f() RETURNS void LANGUAGE sql SECURITY DEFINER AS $$ SELECT; $$;
--                                             ^^^^^^^^ keyword
--                                                      ^^^^^^^ keyword
CREATE FUNCTION f() RETURNS void LANGUAGE sql SECURITY INVOKER AS $$ SELECT; $$;
--                                                     ^^^^^^^ keyword

-- COST
CREATE FUNCTION f() RETURNS void LANGUAGE sql COST 100 AS $$ SELECT; $$;
--                                             ^^^^ keyword

-- Parallel safety
CREATE FUNCTION f() RETURNS void LANGUAGE sql PARALLEL SAFE AS $$ SELECT; $$;
--                                             ^^^^^^^^ keyword
CREATE FUNCTION f() RETURNS void LANGUAGE sql PARALLEL RESTRICTED AS $$ SELECT; $$;
--                                             ^^^^^^^^ keyword
--                                                      ^^^^^^^^^^ keyword
CREATE FUNCTION f() RETURNS void LANGUAGE sql PARALLEL UNSAFE AS $$ SELECT; $$;
--                                                     ^^^^^^ keyword

-- Null handling
CREATE FUNCTION f() RETURNS void LANGUAGE sql RETURNS NULL ON NULL INPUT AS $$ SELECT; $$;
--                                             ^^^^^^^ keyword
CREATE FUNCTION f() RETURNS void LANGUAGE sql CALLED ON NULL INPUT AS $$ SELECT; $$;
--                                             ^^^^^^ keyword
CREATE FUNCTION f() RETURNS void LANGUAGE sql STRICT AS $$ SELECT; $$;
--                                             ^^^^^^ keyword
CREATE FUNCTION f() RETURNS void LANGUAGE sql LEAKPROOF AS $$ SELECT; $$;
--                                             ^^^^^^^^^ keyword

-- VARIADIC / INOUT / OUT params
CREATE FUNCTION f(VARIADIC args int[]) RETURNS void LANGUAGE sql AS $$ SELECT; $$;
--                ^^^^^^^^ keyword
CREATE PROCEDURE p(INOUT x int) LANGUAGE sql AS $$ SELECT; $$;
--                 ^^^^^ keyword
CREATE FUNCTION f(OUT result int) RETURNS int LANGUAGE sql AS $$ SELECT 1; $$;
--                ^^^ keyword

-- RETURNS TABLE / RETURNS SETOF
CREATE FUNCTION f() RETURNS TABLE (id int, name text) LANGUAGE sql AS $$ SELECT 1, 'a'; $$;
--                  ^^^^^^^ keyword
CREATE FUNCTION f() RETURNS SETOF int LANGUAGE sql AS $$ SELECT 1; $$;
--                  ^^^^^^^ keyword

-- FOR EACH ROW / FOR EACH STATEMENT
CREATE TRIGGER t BEFORE UPDATE ON tbl FOR EACH ROW EXECUTE FUNCTION f();
--               ^^^^^^ keyword
--                                     ^^^^^^^^^^^^ keyword
--                                                  ^^^^^^^^^^^^^^^ keyword
CREATE TRIGGER t AFTER INSERT ON tbl FOR EACH STATEMENT EXECUTE PROCEDURE f();
--              ^^^^^ keyword
--                                   ^^^^^^^^^^^^^^^^^^ keyword
--                                                      ^^^^^^^^^^^^^^^^^ keyword
