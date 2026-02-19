import { createHighlighter } from 'shiki';
import { readFileSync, writeFileSync, unlinkSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const grammar = JSON.parse(readFileSync(resolve(ROOT, 'pgsql.tmLanguage.json'), 'utf8'));
const sample = readFileSync(resolve(ROOT, 'samples', '00-showcase.sql'), 'utf8');

const theme = 'github-dark';
const hl = await createHighlighter({
  langs: [{ ...grammar, name: 'pgsql' }],
  themes: [theme],
});

const code = hl.codeToHtml(sample, { lang: 'pgsql', theme });
hl.dispose();

const html = `<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { background: #0d1117; padding: 24px; display: inline-block; }
  pre.shiki { padding: 20px 24px; border-radius: 8px; font-size: 13px; line-height: 1.55; font-family: 'SF Mono', 'Fira Code', 'JetBrains Mono', Menlo, monospace; border: 1px solid #30363d; }
</style></head>
<body>${code}</body></html>`;

const tmpHtml = resolve(ROOT, '.tmp-screenshot.html');
const outPng = resolve(ROOT, 'screenshot.png');
writeFileSync(tmpHtml, html);

// Install playwright as a local dep temporarily
execSync('npm install --no-save playwright 2>&1', { cwd: ROOT, stdio: 'inherit' });

const { chromium } = await import('playwright');
const browser = await chromium.launch();
const page = await browser.newPage({ deviceScaleFactor: 2 });
await page.goto(`file://${tmpHtml}`);
const body = await page.$('body');
await body.screenshot({ path: outPng });
await browser.close();

unlinkSync(tmpHtml);
console.log(`Saved: ${outPng}`);
