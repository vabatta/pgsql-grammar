import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { createHighlighter } from 'shiki';
import { readFileSync, readdirSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const grammar = JSON.parse(readFileSync(resolve(ROOT, 'pgsql.tmLanguage.json'), 'utf8'));

const highlighter = await createHighlighter({
  langs: [{ ...grammar, name: 'pgsql' }],
  themes: ['github-dark'],
});

const testsDir = resolve(ROOT, 'tests');
const testFiles = readdirSync(testsDir).filter(f => f.endsWith('.test.sql')).sort();

const ASSERTION_RE = /^--\s*\^/;

function parseAssertion(line) {
  const caretStart = line.indexOf('^');
  const caretEnd = line.lastIndexOf('^') + 1;
  const scopeText = line.slice(caretEnd).trim();
  const negated = scopeText.startsWith('!');
  const scope = negated ? scopeText.slice(1) : scopeText;
  return { colStart: caretStart, colEnd: caretEnd, scope, negated };
}

function scopeMatches(actual, expected) {
  return actual === expected || actual.startsWith(expected + '.');
}

function getScopesInRange(tokenLine, lineOffset, colStart, colEnd) {
  const scopes = new Set();
  const absStart = lineOffset + colStart;
  const absEnd = lineOffset + colEnd;
  for (const token of tokenLine) {
    const tStart = token.offset;
    const tEnd = token.offset + token.content.length;
    if (tStart < absEnd && tEnd > absStart) {
      if (token.explanation) {
        for (const exp of token.explanation) {
          for (const s of exp.scopes) {
            scopes.add(s.scopeName);
          }
        }
      }
    }
  }
  return scopes;
}

for (const file of testFiles) {
  const content = readFileSync(resolve(testsDir, file), 'utf8');
  const allLines = content.split('\n');

  const codeLines = [];
  const assertions = [];
  let lastCodeLineIndex = -1;

  for (let i = 0; i < allLines.length; i++) {
    const line = allLines[i];
    if (ASSERTION_RE.test(line)) {
      if (lastCodeLineIndex >= 0) {
        assertions.push({
          fileLine: i + 1,
          codeLineIndex: lastCodeLineIndex,
          ...parseAssertion(line),
        });
      }
    } else {
      lastCodeLineIndex = codeLines.length;
      codeLines.push(line);
    }
  }

  const code = codeLines.join('\n');
  const { tokens } = highlighter.codeToTokens(code, {
    lang: 'pgsql',
    theme: 'github-dark',
    includeExplanation: true,
  });

  // Compute absolute offset for the start of each code line
  const lineOffsets = [];
  let offset = 0;
  for (const line of codeLines) {
    lineOffsets.push(offset);
    offset += line.length + 1; // +1 for newline
  }

  describe(file, () => {
    for (const a of assertions) {
      const prefix = a.negated ? '!' : '';
      const label = `line ${a.fileLine} col ${a.colStart}-${a.colEnd}: ${prefix}${a.scope}`;
      it(label, () => {
        const tokenLine = tokens[a.codeLineIndex];
        assert.ok(tokenLine, `No tokens for code line ${a.codeLineIndex + 1}`);
        const scopes = getScopesInRange(tokenLine, lineOffsets[a.codeLineIndex], a.colStart, a.colEnd);
        const hasScope = [...scopes].some(s => scopeMatches(s, a.scope));
        if (a.negated) {
          assert.ok(!hasScope,
            `Expected scope "${a.scope}" to NOT be present at columns ${a.colStart}-${a.colEnd}.\n` +
            `Found scopes: ${[...scopes].join(', ')}`
          );
        } else {
          assert.ok(hasScope,
            `Expected scope "${a.scope}" at columns ${a.colStart}-${a.colEnd}.\n` +
            `Found scopes: ${[...scopes].join(', ')}`
          );
        }
      });
    }
  });
}

highlighter.dispose();
