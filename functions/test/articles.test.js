const test = require('node:test');
const assert = require('node:assert');

const { htmlToMarkdown, firstParagraph, slugify, mediumPostId, rehostImages } = require('../src/article-import');
const { markdownToHtml } = require('../src/render-article');
const { buildSiteFiles } = require('../src/site-files');
const { publishFiles } = require('../src/hosting');

test('Medium: <pre> com <br> e <em> vira bloco de código; figura mantém a legenda', () => {
  const html =
    '<h3>Passo 1</h3><p>Texto <strong>forte</strong> e <em>leve</em>.</p>' +
    '<pre>x &lt;- c(1, 2)<br><em># comentário</em><br>print(x)</pre>' +
    '<figure><img src="https://cdn/a.png" alt=""><figcaption>Legenda "boa"</figcaption></figure>' +
    '<img src="https://medium.com/_/stat?event=x" width="1" height="1">';
  const md = htmlToMarkdown(html);
  assert.match(md, /^## Passo 1/m);
  assert.match(md, /\*\*forte\*\* e \*leve\*/);
  assert.match(md, /```\nx <- c\(1, 2\)\n# comentário\nprint\(x\)\n```/);
  assert.match(md, /!\[Legenda "boa"\]\(https:\/\/cdn\/a\.png "Legenda 'boa'"\)/);
  assert.doesNotMatch(md, /_\/stat/);
});

test('utilitários: slug, id do Medium e resumo', () => {
  assert.strictEqual(slugify('Avaliação de Fundos (em inglês)!'), 'avaliacao-de-fundos');
  assert.strictEqual(mediumPostId('https://medium.com/@x/titulo-ef9894ce69fe?source=rss'), 'ef9894ce69fe');
  assert.strictEqual(mediumPostId('https://medium.com/p/ef9894ce69fe'), 'ef9894ce69fe');
  assert.strictEqual(firstParagraph('Olá,\n\nUm parágrafo de verdade com **mais** de quarenta caracteres.'), 'Um parágrafo de verdade com mais de quarenta caracteres.');
});

test('rehostImages troca só imagens externas', async () => {
  const md = '![a](https://x/1.png "t")\n\n![b](https://firebasestorage.googleapis.com/v0/b/k/o/2.png)';
  const { markdown, count } = await rehostImages(md, async (u) => `https://novo/${u.split('/').pop()}`);
  assert.strictEqual(count, 1);
  assert.match(markdown, /\(https:\/\/novo\/1\.png "t"\)/);
  assert.match(markdown, /firebasestorage/);
});

test('Markdown -> HTML: código destacado, figura com legenda, títulos com âncora, HTML cru escapado', () => {
  const { html, headings } = markdownToHtml(
    '## Intro\n\n![alt](https://i/x.png "Legenda")\n\n```r\nx <- 1\n```\n\n<script>alert(1)</script>\n\n[ext](https://exemplo.com)',
  );
  assert.match(html, /<h2 id="intro">Intro<\/h2>/);
  assert.match(html, /<figure><img src="https:\/\/i\/x\.png" alt="alt"[^>]*><figcaption>Legenda<\/figcaption><\/figure>/);
  assert.match(html, /<pre class="code"><code class="hljs language-r">/);
  assert.doesNotMatch(html, /<script>/);
  assert.match(html, /target="_blank" rel="noopener"/);
  assert.deepStrictEqual(headings, [{ id: 'intro', text: 'Intro', level: 2 }]);
});

test('site: gera página só para artigos com texto, com slug único e no sitemap', () => {
  const raw = {
    headerText: [{ name: 'Fulano' }],
    article: [
      { _id: 'a1', id: 'a1', order: 0, title: 'Mesmo título', url: 'https://medium.com/@x/a-1111aaaa' },
      { _id: 'a2', id: 'a2', order: 1, title: 'Mesmo título', url: 'https://medium.com/@x/b-2222bbbb' },
      { _id: 'a3', id: 'a3', order: 2, title: 'Sem texto', url: 'https://medium.com/@x/c-3333cccc' },
    ],
    articleContent: [
      { _id: 'a1', articleId: 'a1', content: 'Texto um', updatedAt: '2026-01-02T00:00:00Z' },
      { _id: 'a2', articleId: 'a2', content: 'Texto dois' },
    ],
  };
  const { files } = buildSiteFiles(raw, { now: new Date('2026-10-16T12:00:00Z') });
  assert.ok(files['/artigos/mesmo-titulo/index.html']);
  assert.ok(files['/artigos/mesmo-titulo-2/index.html']);
  assert.strictEqual(Object.keys(files).filter((f) => f.startsWith('/artigos/')).length, 2);
  assert.match(files['/sitemap.xml'], /artigos\/mesmo-titulo\/<\/loc>\s*<lastmod>2026-01-02/);
  assert.match(files['/index.html'], /href="\/artigos\/mesmo-titulo\/"/);
  assert.match(files['/index.html'], /href="https:\/\/medium\.com\/@x\/c-3333cccc" target="_blank"/);
  assert.match(files['/artigos/mesmo-titulo/index.html'], /"@type":"BlogPosting"/);
});

test('publishFiles com prune remove páginas de artigo que não existem mais', async () => {
  let populated;
  global.fetch = async (url, init = {}) => {
    const json = (o) => ({ ok: true, status: 200, text: async () => JSON.stringify(o) });
    if (url.endsWith('/channels/live')) return json({ release: { version: { name: 'sites/s/versions/v1', config: {} } } });
    if (url.includes('/files?')) {
      return json({ files: [{ path: '/artigos/velho/index.html', hash: 'h1' }, { path: '/admin/index.html', hash: 'h2' }] });
    }
    if (url.endsWith('/versions')) return json({ name: 'sites/s/versions/v2' });
    if (url.endsWith(':populateFiles')) {
      populated = JSON.parse(init.body).files;
      return json({ uploadUrl: 'https://upload', uploadRequiredHashes: [] });
    }
    return json({ name: 'sites/s/releases/r' });
  };
  await publishFiles({ site: 's', token: 't', files: { '/artigos/novo/index.html': 'x' }, prune: ['/artigos/'] });
  assert.deepStrictEqual(Object.keys(populated).sort(), ['/admin/index.html', '/artigos/novo/index.html']);
});
