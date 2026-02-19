-- CREATE PUBLICATION
CREATE PUBLICATION mypub FOR ALL TABLES;
--     ^^^^^^^^^^^ keyword.ddl

-- CREATE SUBSCRIPTION
CREATE SUBSCRIPTION mysub CONNECTION 'host=h' PUBLICATION mypub;
--     ^^^^^^^^^^^^ keyword.ddl

-- CREATE POLICY
CREATE POLICY mypol ON t FOR ALL USING (true);
--     ^^^^^^ keyword.ddl

-- CREATE ROLE
CREATE ROLE myrole WITH LOGIN;
--     ^^^^ keyword.ddl

-- CREATE SERVER
CREATE SERVER myserver FOREIGN DATA WRAPPER postgres_fdw;
--     ^^^^^^ keyword.ddl

-- CREATE STATISTICS
CREATE STATISTICS mystats ON a, b FROM t;
--     ^^^^^^^^^^ keyword.ddl

-- CREATE TRANSFORM
CREATE TRANSFORM FOR int LANGUAGE plpgsql (FROM SQL WITH FUNCTION f(), TO SQL WITH FUNCTION g());
--     ^^^^^^^^^ keyword.ddl

-- CREATE CAST (unique syntax: no object name, CAST( matches as function)
CREATE CAST (bigint AS int4) WITH FUNCTION int4(bigint);
--     ^^^^ support.function

-- CREATE FOREIGN TABLE (uses create_table rule, so column names are captured)
CREATE FOREIGN TABLE ft (id int, name text) SERVER myserver;
--     ^^^^^^^^^^^^^ keyword.ddl
--                               ^^^^ !entity.name.tag

-- CREATE FOREIGN DATA WRAPPER
CREATE FOREIGN DATA WRAPPER myfdw;
--     ^^^^^^^^^^^^^^^^^^^^ keyword.ddl

-- CREATE OPERATOR FAMILY
CREATE OPERATOR FAMILY myfam USING btree;
--     ^^^^^^^^^^^^^^^ keyword.ddl

-- CREATE OPERATOR CLASS
CREATE OPERATOR CLASS myclass FOR TYPE int4 USING btree AS OPERATOR 1 <;
--     ^^^^^^^^^^^^^^ keyword.ddl

-- CREATE ACCESS METHOD
CREATE ACCESS METHOD myam TYPE TABLE HANDLER myhandler;
--     ^^^^^^^^^^^^^ keyword.ddl

-- CREATE TEXT SEARCH CONFIGURATION
CREATE TEXT SEARCH CONFIGURATION myconfig (PARSER = default);
--     ^^^^^^^^^^^^^^^^^^^^^^^^^^ keyword.ddl

-- CREATE TEXT SEARCH DICTIONARY
CREATE TEXT SEARCH DICTIONARY mydict (TEMPLATE = simple);
--     ^^^^^^^^^^^^^^^^^^^^^^ keyword.ddl

-- CREATE TEXT SEARCH PARSER
CREATE TEXT SEARCH PARSER myparser (START = mystart, GETTOKEN = mygettoken, END = myend, LEXTYPES = mylextypes);
--     ^^^^^^^^^^^^^^^^^^ keyword.ddl

-- CREATE TEXT SEARCH TEMPLATE
CREATE TEXT SEARCH TEMPLATE mytempl (INIT = myinit, LEXIZE = mylexize);
--     ^^^^^^^^^^^^^^^^^^^^ keyword.ddl

-- CREATE USER MAPPING
CREATE USER MAPPING FOR myuser SERVER myserver;
--     ^^^^^^^^^^^^ keyword.ddl

-- CREATE OR REPLACE handles new types
CREATE OR REPLACE TRANSFORM FOR int LANGUAGE plpgsql (FROM SQL WITH FUNCTION f(), TO SQL WITH FUNCTION g());
--                ^^^^^^^^^ keyword.ddl
