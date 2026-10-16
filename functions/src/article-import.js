// Importa artigos publicados no Medium ou no LinkedIn e converte para Markdown,
// preservando títulos, negrito/itálico, links, listas, citações, blocos de código e imagens com legenda.
//
// Medium:   o texto completo vem do feed RSS do autor (https://medium.com/feed/@usuario).
// LinkedIn: o texto vem da página pública do artigo.

const { parse } = require('node-html-parser');
const TurndownService = require('turndown');

const BROWSER_UA =
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0 Safari/537.36';

const ENTITIES = { amp: '&', lt: '<', gt: '>', quot: '"', apos: "'", nbsp: ' ', '#39': "'" };
const decodeEntities = (s) =>
  String(s)
    .replace(/&#x([0-9a-f]+);/gi, (_, h) => String.fromCodePoint(parseInt(h, 16)))
    .replace(/&#(\d+);/g, (_, d) => String.fromCodePoint(Number(d)))
    .replace(/&([a-z]+|#39);/gi, (m, n) => ENTITIES[n.toLowerCase()] ?? m);

function slugify(text) {
  return String(text ?? '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/\(em ingles\)/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 80)
    .replace(/-+$/, '');
}

function sourceOf(url) {
  const u = String(url ?? '').toLowerCase();
  if (u.includes('medium.com')) return 'medium';
  if (u.includes('linkedin.com/pulse')) return 'linkedin';
  return '';
}

/** Id do post no Medium: o sufixo hexadecimal do slug ou o /p/<id> do guid. */
function mediumPostId(url) {
  const clean = String(url ?? '').split(/[?#]/)[0].replace(/\/$/, '');
  const p = clean.match(/\/p\/([0-9a-f]{8,})$/i);
  if (p) return p[1].toLowerCase();
  const tail = clean.match(/-([0-9a-f]{8,})$/i);
  return tail ? tail[1].toLowerCase() : '';
}

const cdata = (block, tag) => {
  const m = block.match(new RegExp(`<${tag}>(?:<!\\[CDATA\\[)?([\\s\\S]*?)(?:\\]\\]>)?</${tag}>`));
  return m ? m[1].trim() : '';
};

async function getText(url, fetchImpl, headers = {}) {
  const res = await fetchImpl(url, { headers: { 'User-Agent': BROWSER_UA, ...headers } });
  if (!res.ok) throw new Error(`Não consegui ler ${url} (HTTP ${res.status}).`);
  return res.text();
}

async function fetchMediumArticle(url, fetchImpl = fetch) {
  const user = String(url).match(/medium\.com\/(@[^/?#]+)/i);
  if (!user) throw new Error('URL do Medium sem o @usuario; use o link completo do artigo.');
  const id = mediumPostId(url);
  const xml = await getText(`https://medium.com/feed/${user[1]}`, fetchImpl);
  const items = xml.split('<item>').slice(1);
  const item = items.find((it) => mediumPostId(cdata(it, 'guid')) === id || mediumPostId(cdata(it, 'link')) === id);
  if (!item) {
    throw new Error(
      'O artigo não está no feed do Medium (o feed só traz os 10 mais recentes). ' +
        'Copie o texto manualmente para o editor.',
    );
  }
  const tags = [...item.matchAll(/<category><!\[CDATA\[([^\]]*)\]\]><\/category>/g)].map((m) => m[1]);
  return {
    source: 'medium',
    title: decodeEntities(cdata(item, 'title')),
    html: cdata(item, 'content:encoded'),
    publishedAt: new Date(cdata(item, 'pubDate')).toISOString(),
    tags,
    cover: '',
  };
}

async function fetchLinkedInArticle(url, fetchImpl = fetch) {
  const html = await getText(url, fetchImpl, { 'Accept-Language': 'pt-BR,pt;q=0.9' });
  const root = parse(html);
  // Blocos do corpo, na ordem: texto, imagem etc. (exclui a capa e os "artigos relacionados").
  const blocks = root.querySelectorAll('[data-test-id^="publishing-"]');
  if (!blocks.length) throw new Error('O LinkedIn não devolveu o texto do artigo (talvez exija login).');
  for (const img of root.querySelectorAll('img[data-delayed-url]')) {
    img.setAttribute('src', img.getAttribute('data-delayed-url'));
  }
  for (const span of root.querySelectorAll('span')) {
    const cls = span.getAttribute('class') || '';
    if (/font-\[(700|bold)\]|font-bold/.test(cls)) span.replaceWith(`<strong>${span.innerHTML}</strong>`);
    else if (/italic/.test(cls)) span.replaceWith(`<em>${span.innerHTML}</em>`);
  }
  const title =
    root.querySelector('h1')?.text?.trim() ||
    decodeEntities((html.match(/<title>([^<]*)/) || [])[1] || '').replace(/\s*\|\s*LinkedIn\s*$/, '');
  const published = (html.match(/"datePublished"\s*:\s*"([^"]+)"/) || [])[1];
  const cover = decodeEntities((html.match(/<meta property="og:image" content="([^"]*)"/) || [])[1] || '');
  return {
    source: 'linkedin',
    title: title.replace(/\s+/g, ' ').trim(),
    html: blocks
      .map((b) => {
        for (const img of b.querySelectorAll('img')) {
          if (/^(article content|conteúdo do artigo)$/i.test(img.getAttribute('alt') || '')) img.setAttribute('alt', '');
        }
        return b.innerHTML;
      })
      .join('\n'),
    publishedAt: published ? new Date(published).toISOString() : '',
    tags: [],
    cover,
  };
}

function createTurndown() {
  const td = new TurndownService({
    headingStyle: 'atx',
    codeBlockStyle: 'fenced',
    bulletListMarker: '-',
    emDelimiter: '*',
    strongDelimiter: '**',
    hr: '---',
  });

  // Pixel de estatística do Medium e imagens sem src.
  // (regra própria: o turndown aplica a regra padrão de imagem antes de td.remove)
  td.addRule('trackingPixel', {
    filter: (node) => node.nodeName === 'IMG' && /medium\.com\/_\/stat|^$/.test(node.getAttribute('src') || ''),
    replacement: () => '',
  });
  td.remove(['script', 'style', 'iframe', 'noscript']);

  // Blocos de código do Medium usam <br> e <em> dentro do <pre>.
  td.addRule('pre', {
    filter: 'pre',
    replacement: (_, node) => {
      const code = decodeEntities(
        node.innerHTML
          .replace(/<br\s*\/?>/gi, '\n')
          .replace(/<[^>]+>/g, ''),
      ).replace(/\n+$/, '');
      const fence = code.includes('```') ? '~~~~' : '```';
      return `\n\n${fence}\n${code}\n${fence}\n\n`;
    },
  });

  // <figure><img><figcaption> -> ![legenda](url "legenda"); o site renderiza o título como legenda.
  td.addRule('figure', {
    filter: 'figure',
    replacement: (_, node) => {
      const img = node.querySelector('img');
      if (!img) return '';
      const src = img.getAttribute('src') || '';
      if (!src) return '';
      const caption = (node.querySelector('figcaption')?.textContent || '').replace(/\s+/g, ' ').trim();
      const alt = (caption || img.getAttribute('alt') || '').replace(/[[\]]/g, '');
      const title = caption ? ` "${caption.replace(/"/g, "'")}"` : '';
      return `\n\n![${alt}](${src}${title})\n\n`;
    },
  });
  return td;
}

/** Ajusta os níveis de título para começar em h2 (o h1 da página é o título do artigo). */
function normalizeHeadings(html) {
  const levels = [...html.matchAll(/<h([1-6])[\s>]/gi)].map((m) => Number(m[1]));
  if (!levels.length) return html;
  const shift = Math.min(...levels) - 2;
  if (!shift) return html;
  return html.replace(/<(\/?)h([1-6])(\s|>)/gi, (_, close, n, rest) => {
    const level = Math.min(Math.max(Number(n) - shift, 2), 6);
    return `<${close}h${level}${rest}`;
  });
}

function htmlToMarkdown(html) {
  const md = createTurndown().turndown(normalizeHeadings(String(html ?? '')));
  return md.replace(/\n{3,}/g, '\n\n').trim() + '\n';
}

/** Primeiro parágrafo de texto do Markdown, para resumo/meta description. */
function firstParagraph(markdown, max = 160) {
  const para =
    String(markdown ?? '')
      .split(/\n{2,}/)
      .map((p) => p.trim())
      .find((p) => p.length >= 40 && !/^(#|!\[|```|~~~|>|-\s|\d+\.\s|---)/.test(p)) || '';
  const text = para
    .replace(/!\[[^\]]*\]\([^)]*\)/g, '')
    .replace(/\[([^\]]*)\]\([^)]*\)/g, '$1')
    .replace(/[*_`]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
  return text.length <= max ? text : `${text.slice(0, max - 1).replace(/\s+\S*$/, '')}…`;
}

/** Lista as URLs das imagens do Markdown (sintaxe ![alt](url "título")). */
function imageUrls(markdown) {
  return [...String(markdown).matchAll(/!\[[^\]]*\]\((\S+?)(?:\s+"[^"]*")?\)/g)].map((m) => m[1]);
}

/** Troca cada URL de imagem pelo resultado de `upload(url)` (cópia no Storage). */
async function rehostImages(markdown, upload) {
  const map = {};
  for (const url of [...new Set(imageUrls(markdown))]) {
    if (/firebasestorage\.googleapis\.com/.test(url)) continue;
    map[url] = await upload(url);
  }
  let out = markdown;
  for (const [from, to] of Object.entries(map)) out = out.split(`(${from}`).join(`(${to}`);
  return { markdown: out, count: Object.keys(map).length };
}

/** "https://github.com/dono/repo/..." -> { owner, repo } */
function githubRepo(url) {
  const m = String(url ?? '').match(/github\.com\/([^/?#]+)\/([^/?#]+)/i);
  return m ? { owner: m[1], repo: m[2].replace(/\.git$/, '') } : null;
}

/**
 * Lê o README.md do repositório (branch main ou master) e torna absolutos
 * os links e imagens relativos. Recusa o README padrão gerado pelo `flutter create`.
 */
async function fetchGithubReadme(url, fetchImpl = fetch) {
  const gh = githubRepo(url);
  if (!gh) throw new Error('O projeto não tem link do GitHub.');
  let text = '';
  let branch = '';
  for (const b of ['main', 'master']) {
    const res = await fetchImpl(`https://raw.githubusercontent.com/${gh.owner}/${gh.repo}/${b}/README.md`, {
      headers: { 'User-Agent': BROWSER_UA },
    });
    if (res.ok) {
      text = await res.text();
      branch = b;
      break;
    }
  }
  if (!text) throw new Error('O repositório não tem README.md.');
  if (/A new Flutter project\./i.test(text) && text.length < 1200) {
    throw new Error('O README é o modelo padrão do Flutter; escreva o texto do projeto no editor.');
  }
  const raw = `https://raw.githubusercontent.com/${gh.owner}/${gh.repo}/${branch}/`;
  const blob = `https://github.com/${gh.owner}/${gh.repo}/blob/${branch}/`;
  const absolute = (base, href) => (/^([a-z]+:|#|\/\/)/i.test(href) ? href : base + href.replace(/^\.?\//, ''));
  let markdown = text
    // imagens Markdown e <img> HTML relativas -> raw
    .replace(/(!\[[^\]]*\]\()([^)\s]+)/g, (_, pre, href) => pre + absolute(raw, href))
    .replace(/<img[^>]*src="([^"]+)"[^>]*>/gi, (_, src) => `![](${absolute(raw, src)})`)
    // links relativos -> página do arquivo no GitHub
    .replace(/(^|[^!])(\[[^\]]*\]\()([^)\s]+)/g, (_, lead, pre, href) => lead + pre + absolute(blob, href));
  // o título do README (# Nome) repete o h1 da página
  markdown = markdown.replace(/^\s*#\s+[^\n]+\n+/, '');
  // a página já usa h1; desce um nível se o README começar em h1 nas seções
  if (/^#\s/m.test(markdown)) markdown = markdown.replace(/^(#{1,5})\s/gm, '#$1 ');
  return { source: 'github', title: gh.repo, markdown: `${markdown.trim()}\n`, publishedAt: '', cover: '' };
}

async function fetchArticle(url, fetchImpl = fetch) {
  const source = sourceOf(url);
  if (source === 'medium') return fetchMediumArticle(url, fetchImpl);
  if (source === 'linkedin') return fetchLinkedInArticle(url, fetchImpl);
  throw new Error('Importação automática só funciona com links do Medium ou do LinkedIn.');
}

module.exports = {
  fetchArticle,
  fetchGithubReadme,
  githubRepo,
  htmlToMarkdown,
  rehostImages,
  imageUrls,
  firstParagraph,
  slugify,
  mediumPostId,
  sourceOf,
  BROWSER_UA,
};
