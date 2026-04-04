-- GRANT with function type signature
GRANT EXECUTE ON FUNCTION wf.register_activity(TEXT, TEXT, INTERVAL, INT) TO app_role;
--                                              ^^^^ entity.name.tag
--                                                    ^^^^ entity.name.tag
--                                                          ^^^^^^^^ entity.name.tag
--                                                                    ^^^ entity.name.tag

-- REVOKE with function type signature
REVOKE EXECUTE ON FUNCTION wf.register_activity(TEXT, INT) FROM app_role;
--                                               ^^^^ entity.name.tag
--                                                     ^^^ entity.name.tag

-- ALTER FUNCTION with type signature
ALTER FUNCTION wf.register_activity(TEXT, INT) OWNER TO app_role;
--                                   ^^^^ entity.name.tag
--                                         ^^^ entity.name.tag

-- DROP FUNCTION with type signature
DROP FUNCTION wf.register_activity(TEXT, INT);
--                                  ^^^^ entity.name.tag
--                                        ^^^ entity.name.tag
