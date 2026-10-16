const test = require('node:test');
const assert = require('node:assert');

const { buildSiteFiles } = require('../src/site-files');
const { fetchGithubReadme } = require('../src/article-import');

const raw = {
  headerText: [{ name: 'Fulano' }],
  article: [
    { _id: 'a1', id: 'a1', order: 0, title: 'Antigo', url: 'https://medium.com/@x/a-1111aaaa', date: '2022-01-10T00:00:00Z', tag1: 'R' },
    { _id: 'a2', id: 'a2', order: 1, title: 'Novo', url: 'https://medium.com/@x/b-2222bbbb', date: '2025-05-01T00:00:00Z' },
  ],
  articleContent: [
    { _id: 'a1', articleId: 'a1', content: 'Texto [interno](/artigos/novo/) ![i](/img.png)' },
    { _id: 'a2', articleId: 'a2', content: 'Texto novo' },
  ],
  project: [
    { _id: 'p1', id: 'p1', order: 2, title: 'Jogo', url: 'https://play.google.com/store/apps/details?id=x', family: true },
    { _id: 'p2', id: 'p2', order: 1, title: 'App Web', url: 'https://app.web.app', urlGithub: 'https://github.com/x/app' },
  ],
  projectContent: [{ _id: 'p1', projectId: 'p1', content: '## Como funciona\n\nTexto do jogo.' }],
};

test('projetos: página só para quem tem texto, com SoftwareApplication e link "Detalhes" na home', () => {
  const { files } = buildSiteFiles(raw, { now: new Date('2026-10-16T12:00:00Z') });
  const page = files['/projetos/jogo/index.html'];
  assert.ok(page);
  assert.ok(!files['/projetos/app-web/index.html']);
  assert.match(page, /"@type":"SoftwareApplication"/);
  assert.match(page, /"applicationCategory":"GameApplication"/);
  assert.match(page, /<h2 id="como-funciona">/);
  assert.match(page, /feito em família/);
  assert.match(files['/index.html'], /href="\/projetos\/jogo\/">Detalhes/);
  assert.match(files['/sitemap.xml'], /\/projetos\/jogo\//);
});

test('feed: RSS com artigos do mais novo para o mais antigo e links absolutos', () => {
  const { files } = buildSiteFiles(raw, { now: new Date('2026-10-16T12:00:00Z') });
  const feed = files['/feed.xml'];
  assert.ok(feed.indexOf('<title>Novo</title>') < feed.indexOf('<title>Antigo</title>'));
  assert.match(feed, /<pubDate>Thu, 01 May 2025 00:00:00 GMT<\/pubDate>/);
  assert.match(feed, /href="https:\/\/www\.marcosmhs\.com\.br\/artigos\/novo\/"/);
  assert.match(feed, /src="https:\/\/www\.marcosmhs\.com\.br\/img\.png"/);
  assert.match(feed, /<category>R<\/category>/);
  assert.match(files['/index.html'], /type="application\/rss\+xml"/);
});

test('README: links relativos viram absolutos e o modelo do Flutter é recusado', async () => {
  const ok = async (text) => ({ ok: true, text: async () => text });
  const readme = '# Meu App\n\nTexto ![tela](docs/tela.png) e [licença](LICENSE).\n\n# Funções\n\n- a';
  const r = await fetchGithubReadme('https://github.com/x/app', async (url) =>
    url.includes('/main/') ? ok(readme) : { ok: false },
  );
  assert.match(r.markdown, /!\[tela\]\(https:\/\/raw\.githubusercontent\.com\/x\/app\/main\/docs\/tela\.png\)/);
  assert.match(r.markdown, /\[licença\]\(https:\/\/github\.com\/x\/app\/blob\/main\/LICENSE\)/);
  assert.match(r.markdown, /^## Funções/m);
  assert.doesNotMatch(r.markdown, /Meu App/);

  await assert.rejects(
    fetchGithubReadme('https://github.com/x/app', async () => ok('# app\n\nA new Flutter project.\n')),
    /modelo padrão do Flutter/,
  );
});
