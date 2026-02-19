import { createHighlighter } from 'shiki';
import { readFileSync, readdirSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const grammar = JSON.parse(readFileSync(resolve(ROOT, 'pgsql.tmLanguage.json'), 'utf8'));

const samplesDir = resolve(ROOT, 'samples');
const files = readdirSync(samplesDir).filter(f => f.endsWith('.sql')).sort();

const highlighter = await createHighlighter({
  langs: [{ ...grammar, name: 'pgsql' }],
  themes: ['github-dark'],
});

let totalUnscoped = 0;

for (const file of files) {
  const content = readFileSync(resolve(samplesDir, file), 'utf8');
  const { tokens } = highlighter.codeToTokens(content, { lang: 'pgsql', theme: 'github-dark' });

  let fileUnscoped = 0;
  for (const line of tokens) {
    for (const t of line) {
      const text = t.content.trim();
      if (!text) continue;
      if (t.explanation) {
        const hasScope = t.explanation.some(e =>
          e.scopes.some(s => s.scopeName !== 'source.pgsql' && !s.scopeName.startsWith('meta.'))
        );
        if (!hasScope) {
          if (fileUnscoped === 0) console.log(`\n--- ${file} ---`);
          console.log('  UNSCOPED:', JSON.stringify(text));
          fileUnscoped++;
        }
      }
    }
  }

  if (fileUnscoped === 0) {
    console.log(`${file}: all scoped`);
  } else {
    console.log(`  ${fileUnscoped} unscoped token(s)`);
  }
  totalUnscoped += fileUnscoped;
}

highlighter.dispose();
console.log(`\nTotal: ${totalUnscoped} unscoped token(s) across ${files.length} files`);
