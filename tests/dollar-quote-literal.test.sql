-- SELECT with $$ dollar-quoted string literal — opening delimiter is string.unquoted.dollar
SELECT $$ hello world $$;
--     ^^ string.unquoted.dollar

-- INSERT with $$ dollar-quoted string literal
INSERT INTO t (x) VALUES ($$some text$$);
--                        ^^ string.unquoted.dollar

-- Body text inside $$ in SELECT is part of the string
SELECT $$ hello world $$;
--        ^^^^^^^^^^^ string.unquoted.dollar

-- Keyword inside $$ in SELECT does NOT get keyword scope
SELECT $$ SELECT is just text $$;
--        ^^^^^^ !keyword
