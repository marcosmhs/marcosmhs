const test = require('node:test');
const assert = require('node:assert');
const zlib = require('zlib');
const crypto = require('crypto');

const { buildSiteModel, parsePeriod } = require('../src/site-model');
const { renderSite, richBlocks, inlineHtml } = require('../src/render');
const { publishFiles } = require('../src/hosting');

test('parsePeriod entende nomes completos, abreviações e "Até o momento"', () => {
  assert.deepStrictEqual(parsePeriod('Setembro/2017'), { year: 2017, month: 9 });
  assert.deepStrictEqual(parsePeriod('Fev/2024'), { year: 2024, month: 2 });
  assert.deepStrictEqual(parsePeriod('Março/2022'), { year: 2022, month: 3 });
  assert.deepStrictEqual(parsePeriod('03/2026'), { year: 2026, month: 3 });
  assert.strictEqual(parsePeriod('Até o momento'), null);
  assert.strictEqual(parsePeriod(''), null);
});

test('texto rico: escapa HTML, mantém negrito e vira lista', () => {
  assert.strictEqual(inlineHtml('<b>ok</b> <script>x</script>'), '<strong>ok</strong> &lt;script&gt;x&lt;/script&gt;');
  const html = richBlocks('Conquistas: <br> - A <b>um</b> <br> - B');
  assert.match(html, /<p class="lead-in">Conquistas:<\/p>/);
  assert.match(html, /<ul class="bullets"><li><span>A <strong>um<\/strong><\/span><\/li><li><span>B<\/span><\/li><\/ul>/);
});

const raw = {
  headerText: [{ siteName: 'marcosmhs', name: 'Fulano', nameComplement: 'Dados', email: 'a@b.com', urlLinkedin: 'https://www.linkedin.com/in/fulano/' }],
  introText: [{ siteName: 'marcosmhs', introText: 'Intro <b>forte</b>' }],
  aboutMeData: [{ siteName: 'marcosmhs', profilePhotoUrl: '' }],
  aboutMeText: [],
  aboutMeTechnology: [{ siteName: 'marcosmhs', technologyName: 'Dart', type: 'AboutMeTechnologyType.development', desktop: true }],
  experience: [
    { siteName: 'marcosmhs', order: 3, title: 'Manager', company: 'B', durationStart: 'Mar/2026', durationEnd: 'Até o momento' },
    { siteName: 'marcosmhs', order: 2, title: 'Coord', company: 'A', durationStart: 'Fev/2024', durationEnd: 'Fev/2026' },
    { siteName: 'marcosmhs', order: 1, title: 'Analista', company: 'A', durationStart: 'Janeiro/2020', durationEnd: 'Janeiro/2024' },
    { siteName: 'outro', order: 9, title: 'Ignorar', company: 'X', durationStart: '2010', durationEnd: '' },
  ],
  article: [
    { siteName: 'marcosmhs', order: 1, title: 'Tutorial (em inglês)', url: 'https://medium.com/@x/a', tag1: 'Python' },
    { siteName: 'marcosmhs', order: 0, title: 'Liderança', url: 'https://www.linkedin.com/pulse/x', tag1: 'AI' },
  ],
  project: [
    { siteName: 'marcosmhs', order: 1, title: 'Pacote', url: 'https://github.com/x/pkg', urlGithub: '' },
    { siteName: 'marcosmhs', order: 2, title: 'Jogo', url: 'https://play.google.com/store/apps/details?id=x', family: true },
  ],
};

test('modelo: agrupa experiência por empresa, deduz categorias e links', () => {
  const m = buildSiteModel(raw, { now: new Date(2026, 9, 16) });
  assert.deepStrictEqual(m.experience.expGroups.map((g) => g.company), ['B', 'A']);
  assert.strictEqual(m.experience.expGroups[1].roles.length, 2);
  assert.strictEqual(m.experience.expGroups[0].roles[0].current, true);
  assert.strictEqual(m.experience.sinceYear, 2020);
  assert.deepStrictEqual(m.roleLine, ['Manager', 'B', 'Curitiba, BR']);
  assert.strictEqual(m.articles.featured.title, 'Liderança');
  assert.strictEqual(m.articles.featured.category, 'lead');
  assert.strictEqual(m.articles.rest[0].en, true);
  assert.strictEqual(m.articles.rest[0].title, 'Tutorial');
  assert.deepStrictEqual(m.projects[0].links.map((l) => l.label), ['Google Play']);
  assert.strictEqual(m.projects[0].family, true);
  assert.deepStrictEqual(m.projects[1].links.map((l) => l.label), ['GitHub']);
});

test('render: HTML com um h1, seções com id e dados estruturados', () => {
  const html = renderSite(buildSiteModel(raw, { now: new Date(2026, 9, 16) }));
  assert.strictEqual((html.match(/<h1/g) || []).length, 1);
  for (const id of ['sobre', 'experiencia', 'artigos', 'projetos', 'contato']) assert.match(html, new RegExp(`id="${id}"`));
  assert.match(html, /application\/ld\+json/);
  assert.match(html, /Intro <strong>forte<\/strong>/);
  assert.doesNotMatch(html, /Ignorar/);
});

test('publishFiles: copia a versão no ar trocando só os arquivos informados', async () => {
  const calls = [];
  const oldGz = zlib.gzipSync(Buffer.from('antigo'));
  const oldHash = crypto.createHash('sha256').update(oldGz).digest('hex');
  global.fetch = async (url, init = {}) => {
    calls.push({ url, method: init.method, body: init.body });
    const json = (o) => ({ ok: true, status: 200, text: async () => JSON.stringify(o) });
    if (url.endsWith('/channels/live')) {
      return json({ release: { version: { name: 'sites/s/versions/v1', config: { rewrites: [{ glob: '/admin/**' }] } } } });
    }
    if (url.includes('/versions/v1/files')) {
      return json({ files: [{ path: '/index.html', hash: oldHash }, { path: '/admin/main.dart.js', hash: 'abc' }] });
    }
    if (url.endsWith('/sites/s/versions')) return json({ name: 'sites/s/versions/v2' });
    if (url.endsWith(':populateFiles')) {
      const files = JSON.parse(init.body).files;
      return json({ uploadUrl: 'https://upload/v2', uploadRequiredHashes: [files['/index.html']] });
    }
    if (url.startsWith('https://upload/')) return { ok: true, status: 200, text: async () => '' };
    if (url.includes('update_mask=status')) return json({});
    if (url.includes('/releases?')) return json({ name: 'sites/s/releases/r1' });
    throw new Error(`chamada inesperada ${url}`);
  };

  const result = await publishFiles({ site: 's', token: 't', files: { '/index.html': 'novo' } });
  assert.strictEqual(result.version, 'sites/s/versions/v2');
  assert.strictEqual(result.files, 2);

  const created = calls.find((c) => c.url.endsWith('/sites/s/versions'));
  assert.deepStrictEqual(JSON.parse(created.body).config, { rewrites: [{ glob: '/admin/**' }] });
  const populate = JSON.parse(calls.find((c) => c.url.endsWith(':populateFiles')).body).files;
  assert.strictEqual(populate['/admin/main.dart.js'], 'abc');
  assert.notStrictEqual(populate['/index.html'], oldHash);
  assert.strictEqual(calls.filter((c) => c.url.startsWith('https://upload/')).length, 1);
  assert.ok(calls.at(-1).url.includes('releases?versionName=sites%2Fs%2Fversions%2Fv2'));
});
