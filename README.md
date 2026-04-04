# pgsql-grammar

[![CI](https://github.com/vabatta/pgsql-grammar/actions/workflows/ci.yml/badge.svg)](https://github.com/vabatta/pgsql-grammar/actions/workflows/ci.yml)

Just a complete and colorful PG18 TextMate grammar.

Standalone `pgsql.tmLanguage.json` targeting Shiki, VS Code, GitHub Linguist, and anything that supports TextMate grammars.

![screenshot](screenshot.png)

## Highlighting

Actual colors depend on your theme. The table below documents the TextMate scope assigned to each token class — themes map scopes to colors.

| Token | Context | Scope | Example |
|-------|---------|-------|---------|
| Keywords | everywhere | `keyword` | `SELECT`, `FROM`, `WHERE`, `AND`, `JOIN`, `CREATE TABLE`, `BEGIN`, `END` |
| Operators | everywhere | `keyword.operator` | `::`, `=`, `<>`, `\|\|`, `@>`, `->>` |
| Built-in functions | before `(` | `support.function` | `now()`, `count(*)`, `coalesce(a, b)` |
| User-defined functions | before `(` | `entity.name.function` | `get_active_users(100)`, `app.my_func()` |
| Numbers | everywhere | `constant.numeric` | `42`, `3.14` |
| Built-in types | after `::`, inside `CAST`, before literal, DDL/signatures/`DECLARE` | `entity.name.tag` | `x::DATE`, `CAST(y AS NUMERIC)`, `INTERVAL '1 day'`, `id SERIAL` |
| Built-in types | DML (bare word) | unstyled | `SELECT date, name, text FROM t` |
| Constants | everywhere | `constant.language` | `NULL`, `TRUE`, `FALSE` |
| `EXTRACT` fields | inside `EXTRACT()` | `constant.language` | `EXTRACT(EPOCH FROM now())` |
| Single-quoted strings | everywhere | `string.quoted.single` | `'hello'`, `E'\n'` |
| Dollar-quoted literal | `COMMENT ON … IS`, `SELECT`, `INSERT … VALUES`, `CALL` | `string.unquoted` | `$$ plain text $$`, `$body$ text $body$` |
| Dollar-quoted body | `CREATE FUNCTION/PROCEDURE … AS`, `DO` | `meta.dollar-quote` (full SQL/PL inside) | `$$ BEGIN … END; $$` |
| Dollar-quoted nested | inside any dollar-quoted body (e.g. `EXECUTE $$…$$`) | `meta.dollar-quote` (recursive) | `EXECUTE $q$ SELECT 1 $q$;` |
| Double-quoted identifiers | everywhere | `variable.other` | `"my_table"."column"` |
| Comments | everywhere | `comment` | `-- line`, `/* block */` |
| Identifiers | DML | unstyled | `u.name`, `created_at`, `users` |
| Table after `INTO`/`COPY` | before `(columns)` | unstyled | `INSERT INTO users (name)`, `COPY t (col)` |
| Table after `ON`/`REFERENCES` | before `(columns)` | unstyled | `ON orders (user_id)`, `REFERENCES t(id)` |

## Coverage

- 300+ keywords (DML, DDL, PL/pgSQL, utility)
- 100+ PostgreSQL type names with multi-word support
- 200+ built-in functions and support constants
- Standalone keyword fallbacks for multiline resilience
- 415 test assertions across 20 test files

## Usage

```bash
npm test               # run 415 grammar tests
npm run validate       # 0 unscoped tokens across all samples
npm run validate-sql   # all statements parse via libpg-query
npm run preview        # http://localhost:3117 — live preview with theme picker
```

## Nix

```nix
# As a flake input
inputs.pgsql-grammar.url = "github:vabatta/pgsql-grammar";

# Get the grammar file
pgsql-grammar.packages.${system}.default
# → $out/pgsql.tmLanguage.json
```

## Versioning

Major version tracks PostgreSQL (`18.x.y` → PG18). Minor and patch are grammar improvements. PG minor releases (18.1, 18.2) never change SQL syntax, so the version space is entirely ours.

## License

MIT
