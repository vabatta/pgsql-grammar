import { createHighlighter, bundledThemes } from 'shiki';
import { createServer } from 'http';
import { readFileSync, readdirSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const PORT = 3117;

const ALL_THEMES = Object.keys(bundledThemes).sort();
const DEFAULT_THEME = 'github-dark';

// Curated list of popular themes shown first in the dropdown
const POPULAR = [
  'github-dark', 'github-light', 'github-dark-dimmed',
  'dracula', 'one-dark-pro', 'one-light',
  'monokai', 'nord', 'solarized-dark', 'solarized-light',
  'catppuccin-mocha', 'catppuccin-latte',
  'tokyo-night', 'vitesse-dark', 'vitesse-light',
  'material-theme-ocean', 'rose-pine', 'rose-pine-dawn',
  'min-dark', 'min-light',
];

function loadGrammar() {
  return JSON.parse(readFileSync(resolve(ROOT, 'pgsql.tmLanguage.json'), 'utf8'));
}

function loadSamples() {
  const dir = resolve(ROOT, 'samples');
  return readdirSync(dir)
    .filter(f => f.endsWith('.sql'))
    .sort()
    .map(f => ({
      name: f,
      content: readFileSync(resolve(dir, f), 'utf8'),
    }));
}

let highlighter = null;
let loadedThemes = new Set();

async function getHighlighter(theme) {
  if (!highlighter) {
    const grammar = loadGrammar();
    highlighter = await createHighlighter({
      langs: [{ ...grammar, name: 'pgsql' }],
      themes: [theme],
    });
    loadedThemes.add(theme);
  } else {
    // Reload grammar on every request
    const grammar = loadGrammar();
    highlighter.dispose();
    loadedThemes.clear();
    highlighter = await createHighlighter({
      langs: [{ ...grammar, name: 'pgsql' }],
      themes: [theme],
    });
    loadedThemes.add(theme);
  }
  return highlighter;
}

function isDark(theme) {
  const light = ['github-light', 'github-light-default', 'github-light-high-contrast',
    'one-light', 'catppuccin-latte', 'solarized-light', 'vitesse-light',
    'min-light', 'light-plus', 'ayu-light', 'rose-pine-dawn', 'slack-ochin',
    'snazzy-light', 'material-theme-lighter', 'everforest-light', 'night-owl-light',
    'gruvbox-light-hard', 'gruvbox-light-medium', 'gruvbox-light-soft',
    'kanagawa-lotus'];
  return !light.includes(theme);
}

function buildThemeOptions(currentTheme) {
  const popularSet = new Set(POPULAR);
  const rest = ALL_THEMES.filter(t => !popularSet.has(t));

  let html = '<optgroup label="Popular">';
  for (const t of POPULAR) {
    const sel = t === currentTheme ? ' selected' : '';
    html += `<option value="${t}"${sel}>${t}</option>`;
  }
  html += '</optgroup><optgroup label="All themes">';
  for (const t of rest) {
    const sel = t === currentTheme ? ' selected' : '';
    html += `<option value="${t}"${sel}>${t}</option>`;
  }
  html += '</optgroup>';
  return html;
}

async function renderPage(theme) {
  const hl = await getHighlighter(theme);
  const samples = loadSamples();
  const dark = isDark(theme);

  const blocks = samples.map(s => {
    const html = hl.codeToHtml(s.content, { lang: 'pgsql', theme });
    return `
      <section class="sample">
        <h2>${s.name}</h2>
        <div class="code-block">${html}</div>
      </section>`;
  }).join('\n');

  const bg = dark ? '#0d1117' : '#ffffff';
  const fg = dark ? '#c9d1d9' : '#24292f';
  const surface = dark ? '#161b22' : '#f6f8fa';
  const border = dark ? '#30363d' : '#d0d7de';
  const accent = dark ? '#58a6ff' : '#0969da';

  return `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>pgsql-grammar preview — ${theme}</title>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Helvetica, Arial, sans-serif;
      background: ${bg};
      color: ${fg};
      padding: 2rem;
      max-width: 960px;
      margin: 0 auto;
    }

    header {
      position: sticky;
      top: 0;
      z-index: 10;
      background: ${bg};
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin: -2rem -2rem 2rem;
      padding: 1rem 2rem;
      border-bottom: 1px solid ${border};
    }

    header h1 { font-size: 1.4rem; font-weight: 600; }

    .controls {
      display: flex;
      gap: 0.75rem;
      align-items: center;
    }

    select, button {
      background: ${surface};
      color: ${fg};
      border: 1px solid ${border};
      padding: 0.35rem 0.75rem;
      border-radius: 6px;
      cursor: pointer;
      font-size: 0.85rem;
    }
    select:hover, button:hover { border-color: ${accent}; }

    .sample { margin-bottom: 2rem; }
    .sample h2 {
      font-size: 0.95rem;
      font-weight: 500;
      margin-bottom: 0.5rem;
      color: ${accent};
    }

    .code-block {
      border: 1px solid ${border};
      border-radius: 8px;
      overflow: auto;
    }
    .code-block pre {
      padding: 1rem;
      font-size: 13px;
      line-height: 1.5;
      tab-size: 4;
    }

    .meta {
      font-size: 0.8rem;
      color: ${border};
      margin-top: 1rem;
      text-align: center;
    }
  </style>
</head>
<body>
  <header>
    <h1>pgsql-grammar preview</h1>
    <div class="controls">
      <select id="theme-select" onchange="sessionStorage.setItem('scrollY',window.scrollY);location.href='/?theme='+this.value">
        ${buildThemeOptions(theme)}
      </select>
      <button onclick="sessionStorage.setItem('scrollY',window.scrollY);location.reload()">Reload</button>
    </div>
  </header>
  ${blocks}
  <p class="meta">Edit pgsql.tmLanguage.json or samples/*.sql, then reload.</p>
  <script>
    {const y=sessionStorage.getItem('scrollY');if(y){sessionStorage.removeItem('scrollY');requestAnimationFrame(()=>window.scrollTo(0,+y))}}
  </script>
</body>
</html>`;
}

const server = createServer(async (req, res) => {
  try {
    const url = new URL(req.url, `http://localhost:${PORT}`);
    const theme = ALL_THEMES.includes(url.searchParams.get('theme'))
      ? url.searchParams.get('theme')
      : DEFAULT_THEME;
    const html = await renderPage(theme);
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    res.end(html);
  } catch (err) {
    res.writeHead(500, { 'Content-Type': 'text/plain' });
    res.end(err.stack);
  }
});

server.listen(PORT, () => {
  console.log(`Preview running at http://localhost:${PORT}`);
  console.log('Edit grammar/samples and refresh the page.');
});
