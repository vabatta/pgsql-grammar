/**
 * Validate that every SQL statement in samples/*.sql is syntactically valid
 * using the actual PostgreSQL parser (libpg-query, PG17).
 */

import { readFileSync, readdirSync } from "fs";
import { join } from "path";
import pg from "libpg-query";

await pg.loadModule();

const samplesDir = join(import.meta.dirname, "..", "samples");
const files = readdirSync(samplesDir)
  .filter((f) => f.endsWith(".sql"))
  .sort();

let totalErrors = 0;

for (const file of files) {
  const raw = readFileSync(join(samplesDir, file), "utf-8");

  // Strip psql meta-commands (lines starting with \)
  const sql = raw
    .split("\n")
    .filter((line) => !line.match(/^\s*\\[a-z]/))
    .join("\n");

  try {
    const result = pg.parseSync(sql);
    const n = result.stmts.length;
    console.log(`  ${file}: ${n} statements — ok`);
  } catch (err) {
    totalErrors++;
    console.error(`  ${file}: PARSE ERROR`);

    // Try to narrow down which statement failed by splitting on semicolons
    // and parsing individually
    const stmts = sql.split(";");
    let cumLen = 0;
    for (const chunk of stmts) {
      const stmt = chunk.trim();
      cumLen += chunk.length + 1; // +1 for the semicolon

      if (!stmt || /^--[\s\S]*$/.test(stmt.replace(/--[^\n]*/g, "").trim()))
        continue;

      // Skip empty-after-stripping-comments
      const stripped = stmt.replace(/--[^\n]*/g, "").trim();
      if (!stripped) continue;

      try {
        pg.parseSync(stmt);
      } catch (inner) {
        // Find approximate line number
        const lineNum = raw.substring(0, cumLen).split("\n").length;
        const preview =
          stmt.length > 120 ? stmt.substring(0, 120) + "..." : stmt;
        console.error(`    line ~${lineNum}: ${inner.message}`);
        console.error(
          `      → ${preview.replace(/\n/g, "\\n").replace(/\s+/g, " ")}`
        );
      }
    }
  }
}

console.log(
  `\n  ${files.length} files, ${totalErrors} with errors`
);
if (totalErrors > 0) process.exit(1);
