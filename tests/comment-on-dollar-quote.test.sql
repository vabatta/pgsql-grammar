-- COMMENT ON with single-quoted string
COMMENT ON TABLE app.orders IS 'Customer orders';
-- ^^^^^^^ keyword.ddl
--         ^^ keyword.ddl
--            ^^^^^ keyword.ddl
--                           ^^ keyword.other
--                              ^^^^^^^^^^^^^^^^ string.quoted.single

-- COMMENT ON with $$ dollar-quoted string literal
COMMENT ON TYPE wf.reuse_policy IS $$
-- ^^^^^^^ keyword.ddl
--         ^^ keyword.ddl
--            ^^^^ keyword.ddl
--                               ^^ keyword.other
--                                  ^^ string.unquoted.dollar
Governs resubmission when prior closed runs exist.
-- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ string.unquoted.dollar
$$;

-- COMMENT ON with labelled dollar-quote $body$ ... $body$
COMMENT ON COLUMN app.orders.notes IS $body$
-- ^^^^^^^ keyword.ddl
--         ^^ keyword.ddl
--            ^^^^^^ keyword.ddl
--                                  ^^ keyword.other
--                                     ^^^^^^ string.unquoted.dollar
Free-form text annotation.
-- ^^^^^^^^^^^^^^^^^^^^^^^^ string.unquoted.dollar
$body$;
--^^^^^^ string.unquoted.dollar

-- Content inside COMMENT ON $$ should NOT be highlighted as SQL keywords
COMMENT ON TABLE t IS $$
SELECT is just text here, not a keyword.
-- ^^^^ !keyword
$$;

-- COMMENT ON FUNCTION with type list in signature
COMMENT ON FUNCTION wf.register_activity(TEXT, TEXT, INTERVAL, INT) IS 'test';
--                                        ^^^^ entity.name.tag
--                                              ^^^^ entity.name.tag
--                                                    ^^^^^^^^ entity.name.tag
--                                                              ^^^ entity.name.tag

-- Types inside IS '...' should NOT be highlighted (consumed as string)
COMMENT ON TABLE t IS 'TEXT and INT are not types here';
--                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ string.quoted.single
