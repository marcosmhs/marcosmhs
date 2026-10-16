// Monta a pasta hosting/ que o Firebase CLI publica:
//   hosting/index.html, sitemap.xml  -> site estático gerado do Firestore (mesmo código da Cloud Function)
//   hosting/robots.txt, favicon.png  -> site/static/
//   hosting/admin/                   -> build do Flutter (flutter build web --base-href /admin/)
//
// Uso:  node scripts/build-hosting.js            (site + admin)
//       node scripts/build-hosting.js --site-only (só o HTML, para pré-visualizar)
//       node scripts/build-hosting.js --site-only --preview-imports
//            (importa em memória os artigos ainda sem texto, só para pré-visualizar; não grava nada)

const fs = require('fs');
const path = require('path');

const config = require('../functions/src/site-config');
const { buildSiteFiles } = require('../functions/src/site-files');
const { fetchArticle, fetchGithubReadme, htmlToMarkdown, firstParagraph } = require('../functions/src/article-import');

const ROOT = path.resolve(__dirname, '..');
const OUT = path.join(ROOT, 'hosting');
const PROJECT_ID = 'omarcosmhs';
// Chave pública do app web (a mesma de lib/firebase_options.dart); a leitura depende das regras do Firestore.
const API_KEY = process.env.FIREBASE_WEB_API_KEY || 'AIzaSyBr2JZb5sAjE5buF8wFHTyENHJxkV3xjMI';

function fromRest(value) {
  if (!value || typeof value !== 'object') return value;
  if ('stringValue' in value) return value.stringValue;
  if ('integerValue' in value) return Number(value.integerValue);
  if ('doubleValue' in value) return Number(value.doubleValue);
  if ('booleanValue' in value) return value.booleanValue;
  if ('timestampValue' in value) return value.timestampValue;
  if ('nullValue' in value) return null;
  if ('arrayValue' in value) return (value.arrayValue.values || []).map(fromRest);
  if ('mapValue' in value) return docFields(value.mapValue.fields);
  return null;
}

const docFields = (fields = {}) => Object.fromEntries(Object.entries(fields).map(([k, v]) => [k, fromRest(v)]));

async function fetchCollection(name) {
  const docs = [];
  let pageToken = '';
  do {
    const q = new URLSearchParams({ pageSize: '300', key: API_KEY });
    if (pageToken) q.set('pageToken', pageToken);
    const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${name}?${q}`;
    const res = await fetch(url);
    if (!res.ok) throw new Error(`Firestore ${name}: ${res.status} ${await res.text()}`);
    const body = await res.json();
    for (const d of body.documents || []) docs.push({ _id: d.name.split('/').pop(), ...docFields(d.fields) });
    pageToken = body.nextPageToken || '';
  } while (pageToken);
  return docs;
}

function copyDir(src, dest) {
  fs.mkdirSync(dest, { recursive: true });
  for (const entry of fs.readdirSync(src, { withFileTypes: true })) {
    const from = path.join(src, entry.name);
    const to = path.join(dest, entry.name);
    if (entry.isDirectory()) copyDir(from, to);
    else fs.copyFileSync(from, to);
  }
}

async function previewImports(raw) {
  const has = new Set((raw.articleContent || []).map((c) => c.articleId || c._id));
  for (const a of raw.article) {
    const id = a.id || a._id;
    if (has.has(id)) continue;
    try {
      const fetched = await fetchArticle(a.url);
      const content = htmlToMarkdown(fetched.html);
      raw.articleContent.push({ _id: id, articleId: id, content, updatedAt: new Date().toISOString() });
      if (!a.summary) a.summary = firstParagraph(content);
      if ((!a.date || a.date === 'null') && fetched.publishedAt) a.date = fetched.publishedAt;
      console.log(`  pré-visualização: ${a.title}`);
    } catch (e) {
      console.warn(`  não importado (${a.title}): ${e.message}`);
    }
  }
  const hasProject = new Set((raw.projectContent || []).map((c) => c.projectId || c._id));
  for (const p of raw.project) {
    const id = p.id || p._id;
    const repo = p.urlGithub || (/github\.com/i.test(p.url || '') ? p.url : '');
    if (hasProject.has(id) || !repo) continue;
    try {
      const { markdown } = await fetchGithubReadme(repo);
      raw.projectContent.push({ _id: id, projectId: id, content: markdown, updatedAt: new Date().toISOString() });
      console.log(`  pré-visualização (projeto): ${p.title}`);
    } catch (e) {
      console.warn(`  projeto sem página (${p.title}): ${e.message}`);
    }
  }
}

async function main() {
  const siteOnly = process.argv.includes('--site-only');
  const raw = {};
  for (const name of config.collections) {
    try {
      raw[name] = await fetchCollection(name);
    } catch (e) {
      if (!name.endsWith('Content')) throw e;
      // As regras do Firestore podem não liberar leitura pública desta coleção.
      console.warn(`Aviso: não consegui ler ${name}; essas páginas não serão geradas localmente.`);
      console.warn('       Depois do deploy, clique em "Publicar site agora" no admin para gerá-las.');
      raw[name] = [];
    }
  }

  if (process.argv.includes('--preview-imports')) await previewImports(raw);

  const { files, model } = buildSiteFiles(raw);
  fs.rmSync(OUT, { recursive: true, force: true });
  for (const [file, content] of Object.entries(files)) {
    const dest = path.join(OUT, file);
    fs.mkdirSync(path.dirname(dest), { recursive: true });
    fs.writeFileSync(dest, content);
  }
  copyDir(path.join(ROOT, 'site', 'static'), OUT);
  console.log(`Site gerado em ${path.relative(ROOT, OUT)}/ (${model.articles.pages.length} páginas de artigo)`);

  if (!siteOnly) {
    const adminBuild = path.join(ROOT, 'build', 'web');
    if (!fs.existsSync(path.join(adminBuild, 'index.html'))) {
      throw new Error('Build do admin não encontrado. Rode antes: flutter build web --release --no-tree-shake-icons --base-href /admin/');
    }
    const adminIndex = fs.readFileSync(path.join(adminBuild, 'index.html'), 'utf8');
    if (!adminIndex.includes('<base href="/admin/">')) {
      throw new Error('O build do admin não foi gerado com --base-href /admin/.');
    }
    copyDir(adminBuild, path.join(OUT, 'admin'));
    console.log('Admin copiado para hosting/admin/');
  }
}

main().catch((e) => {
  console.error(e.message || e);
  process.exit(1);
});
