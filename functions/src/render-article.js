// Página de artigo: /artigos/<slug>/index.html
// O conteúdo é Markdown (editor do admin / importação do Medium e LinkedIn).

const { Marked } = require('marked');
const hljs = require('highlight.js/lib/common');
hljs.registerLanguage('r', require('highlight.js/lib/languages/r'));
hljs.registerLanguage('dart', require('highlight.js/lib/languages/dart'));

const config = require('./site-config');
const { commonHead, personLd, renderHeader, renderFooter, esc, ext, JS } = require('./render');
const { slugify } = require('./article-import');

const AUTO_LANGS = ['r', 'python', 'dart', 'sql', 'bash', 'json', 'yaml', 'javascript', 'java', 'csharp', 'xml'];

function highlight(code, lang) {
  try {
    if (lang && hljs.getLanguage(lang)) return hljs.highlight(code, { language: lang }).value;
    return hljs.highlightAuto(code, AUTO_LANGS).value;
  } catch {
    return esc(code);
  }
}

/** Converte Markdown em HTML; devolve também os títulos (para o sumário) e o tamanho do texto. */
function markdownToHtml(markdown) {
  const headings = [];
  const usedIds = new Set();
  const marked = new Marked({ gfm: true, breaks: false });
  marked.use({
    renderer: {
      // HTML cru no Markdown é exibido como texto: só a sintaxe Markdown vira HTML.
      html: ({ text }) => esc(text),
      heading({ tokens, depth }) {
        const inner = this.parser.parseInline(tokens);
        const plain = inner.replace(/<[^>]+>/g, '');
        let id = slugify(plain) || `secao-${headings.length + 1}`;
        for (let n = 2; usedIds.has(id); n++) id = `${slugify(plain)}-${n}`;
        usedIds.add(id);
        const level = Math.min(Math.max(depth, 2), 6);
        if (level <= 3) headings.push({ id, text: plain, level });
        return `<h${level} id="${id}">${inner}</h${level}>\n`;
      },
      code({ text, lang }) {
        const language = (lang || '').trim().split(/\s+/)[0];
        return `<pre class="code"><code class="hljs${language ? ` language-${esc(language)}` : ''}">${highlight(text, language)}</code></pre>\n`;
      },
      image({ href, title, text }) {
        const img = `<img src="${esc(href)}" alt="${esc(text || title || '')}" loading="lazy" decoding="async">`;
        return title ? `<figure>${img}<figcaption>${esc(title)}</figcaption></figure>` : img;
      },
      link({ href, title, tokens }) {
        const inner = this.parser.parseInline(tokens);
        const external = /^https?:\/\//i.test(href) && !href.startsWith(config.siteUrl);
        return `<a href="${esc(href)}"${title ? ` title="${esc(title)}"` : ''}${external ? ` ${ext}` : ''}>${inner}</a>`;
      },
      // Imagem sozinha num parágrafo vira <figure> fora do <p>.
      paragraph({ tokens }) {
        const inner = this.parser.parseInline(tokens);
        if (/^<(figure|img)[^>]*>(.*<\/figure>)?$/s.test(inner.trim())) return `${inner}\n`;
        return `<p>${inner}</p>\n`;
      },
    },
  });
  const html = marked.parse(String(markdown ?? ''));
  return { html, headings };
}

const DATE_FMT = new Intl.DateTimeFormat('pt-BR', { day: 'numeric', month: 'long', year: 'numeric', timeZone: 'UTC' });

function renderArticlePage(model, article) {
  const { html, headings } = markdownToHtml(article.content);
  const url = `${config.siteUrl}${article.pageUrl}`;
  const description = article.summary || article.title;
  const cover = article.image;
  // No Medium a capa costuma ser também a primeira imagem do texto: não repete.
  const contentStartsWithImage = /^!\[/.test(String(article.content).trimStart());
  const showCover = cover && !contentStartsWithImage;
  const published = article.publishedAt;
  const modified = article.updatedAt || published || model.generatedAt;

  const ld = [
    {
      '@context': 'https://schema.org',
      '@type': 'BlogPosting',
      headline: article.title,
      description,
      url,
      mainEntityOfPage: url,
      inLanguage: article.en ? 'en' : 'pt-BR',
      ...(cover ? { image: [cover] } : {}),
      ...(published ? { datePublished: published.toISOString() } : {}),
      dateModified: modified.toISOString(),
      keywords: article.tags.join(', '),
      author: personLd(model),
      publisher: { '@id': `${config.siteUrl}/#pessoa` },
    },
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: model.name, item: `${config.siteUrl}/` },
        { '@type': 'ListItem', position: 2, name: 'Artigos', item: `${config.siteUrl}/#artigos` },
        { '@type': 'ListItem', position: 3, name: article.title, item: url },
      ],
    },
  ];

  const extraHead = [
    published ? `<meta property="article:published_time" content="${published.toISOString()}">` : '',
    `<meta property="article:modified_time" content="${modified.toISOString()}">`,
    ...article.tags.map((t) => `<meta property="article:tag" content="${esc(t)}">`),
  ].join('\n');

  const others = model.articles.pages.filter((a) => a.id !== article.id).slice(0, 3);
  const toc =
    headings.filter((h) => h.level === 2).length >= 3
      ? `<nav class="toc" aria-label="Neste artigo"><p class="mono">Neste artigo</p><ol>${headings
          .filter((h) => h.level === 2)
          .map((h) => `<li><a href="#${h.id}">${esc(h.text)}</a></li>`)
          .join('')}</ol></nav>`
      : '';

  return `<!DOCTYPE html>
<html lang="${article.en ? 'en' : 'pt-BR'}">
<head>
${commonHead({
  m: model,
  title: `${article.title} | ${model.name}`,
  description,
  url,
  ogType: 'article',
  image: cover || model.photoUrl,
  ld,
  extraHead,
  extraCss: ARTICLE_CSS,
})}
</head>
<body>
<a class="skip-link" href="#conteudo">Pular para o conteúdo</a>
${renderHeader(model, '/')}
<main id="conteudo" class="article-page">
  <article>
    <header class="wrap article-header">
      <nav class="mono crumbs" aria-label="Você está em"><a href="/">Início</a> / <a href="/#artigos">Artigos</a></nav>
      <p class="mono kicker">${esc(article.catLabel)}${article.en ? ' · em inglês' : ''}</p>
      <h1>${esc(article.title)}</h1>
      ${article.summary ? `<p class="article-summary">${esc(article.summary)}</p>` : ''}
      <p class="mono article-meta">
        <span>${esc(model.name)}</span>
        ${published ? `<span>·</span><time datetime="${published.toISOString()}">${DATE_FMT.format(published)}</time>` : ''}
        <span>·</span><span>${esc(article.readingTime)}</span>
      </p>
      <div class="tags">${article.tags.map((t) => `<span class="mono tag">${esc(t)}</span>`).join('')}</div>
    </header>
    ${showCover ? `<div class="wrap article-cover"><img src="${esc(cover)}" alt="" fetchpriority="high" onerror="this.parentNode.remove()"></div>` : ''}
    <div class="wrap article-layout">
      ${toc}
      <div class="article-content">
${html}
      </div>
    </div>
    <footer class="wrap article-end">
      ${article.url ? `<p class="mono original">Publicado originalmente no <a href="${esc(article.url)}" ${ext}>${esc(article.src)}</a>.</p>` : ''}
      <div class="author-card">
        ${model.photoUrl ? `<img src="${esc(model.photoUrl)}" alt="" width="64" height="64" loading="lazy">` : ''}
        <div>
          <p class="author-name">${esc(model.name)}</p>
          <p>${esc([model.jobTitle, model.company].filter(Boolean).join(' na '))}</p>
          <p class="author-links"><a href="/#contato">Entrar em contato</a>${model.socials.map((s) => ` · <a href="${esc(s.href)}" ${ext}>${esc(s.label)}</a>`).join('')}</p>
        </div>
      </div>
    </footer>
  </article>
  ${
    others.length
      ? `<section class="band band-grey more-articles" aria-labelledby="mais-artigos">
    <div class="wrap stack-40">
      <h2 id="mais-artigos">Outros artigos</h2>
      <ul class="grid grid-280">${others
        .map(
          (a) => `<li><a class="card more-card" href="${a.pageUrl}"><span class="mono kicker">${esc(a.catLabel)}</span><span class="more-title">${esc(a.title)}</span><span class="mono muted">${esc(a.readingTime)}</span></a></li>`,
        )
        .join('')}</ul>
      <a class="btn-outline" href="/#artigos">Ver todos os artigos</a>
    </div>
  </section>`
      : ''
  }
</main>
${renderFooter(model)}
<script>${JS}</script>
</body>
</html>
`;
}

const ARTICLE_CSS = `
.article-page{padding-top:64px;background:#fff}
.article-header{max-width:820px;padding-top:clamp(40px,7vw,80px);padding-bottom:28px;display:flex;flex-direction:column;gap:18px}
.crumbs{font-size:12px;color:var(--muted)}
.crumbs a{color:var(--muted)}
.article-header h1{font-size:clamp(32px,5vw,52px);line-height:1.1;font-weight:600;letter-spacing:-.03em;text-wrap:balance}
.article-summary{font-size:20px;line-height:1.5;color:var(--ink-3);text-wrap:pretty}
.article-meta{display:flex;flex-wrap:wrap;gap:6px 10px;font-size:13px;color:var(--muted)}
.article-cover{max-width:1100px;margin-bottom:32px}
.article-cover img{width:100%;max-height:520px;object-fit:cover;border-radius:16px;display:block;background:#EEEEF2}
.article-layout{max-width:1100px;display:flex;gap:56px;align-items:flex-start;padding-bottom:48px}
.toc{flex:0 0 220px;position:sticky;top:96px;font-size:14px;line-height:1.5}
.toc p{font-size:12px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em;margin-bottom:12px}
.toc ol{display:flex;flex-direction:column;gap:10px;border-left:2px solid var(--line);padding-left:14px}
.toc a{color:var(--ink-3);text-decoration:none}
.toc a:hover{color:var(--ink)}
@media (max-width:1023px){.toc{display:none}}
.article-content{flex:1;min-width:0;max-width:720px;margin:0 auto;font-size:18px;line-height:1.75;color:var(--ink-2)}
.article-content>*+*{margin-top:1.15em}
.article-content h2{font-size:28px;line-height:1.25;font-weight:600;color:var(--ink);letter-spacing:-.015em;margin-top:2em;scroll-margin-top:88px}
.article-content h3{font-size:22px;line-height:1.3;font-weight:600;color:var(--ink);margin-top:1.6em;scroll-margin-top:88px}
.article-content h4,.article-content h5,.article-content h6{font-size:18px;font-weight:600;color:var(--ink);margin-top:1.4em}
.article-content strong{color:var(--ink);font-weight:600}
.article-content a{color:var(--violet-ink);text-underline-offset:3px}
.article-content ul,.article-content ol{padding-left:1.4em}
.article-content ul{list-style:disc}
.article-content ol{list-style:decimal}
.article-content li+li{margin-top:.4em}
.article-content blockquote{margin-left:0;margin-right:0;border-left:3px solid var(--violet);padding:4px 0 4px 20px;color:var(--ink-3);font-style:italic}
.article-content hr{border:none;border-top:1px solid var(--line);margin:2.5em 0}
.article-content figure{margin:2em 0}
.article-content img{max-width:100%;height:auto;border-radius:10px;display:block;margin:0 auto}
.article-content figcaption{font-size:14px;color:var(--muted);text-align:center;margin-top:10px;line-height:1.5}
.article-content :not(pre)>code{font-family:var(--mono);font-size:.88em;background:#F3F3F6;border-radius:4px;padding:2px 6px;color:var(--ink)}
.article-content table{border-collapse:collapse;width:100%;font-size:15px;display:block;overflow-x:auto}
.article-content th,.article-content td{border:1px solid var(--line);padding:8px 12px;text-align:left}
.article-content th{background:#FAFAFB;color:var(--ink)}
pre.code{background:#1C1D29;color:#E6E6EF;border-radius:10px;padding:18px 20px;overflow-x:auto;font-size:14px;line-height:1.6}
pre.code code{font-family:var(--mono)}
.hljs-comment,.hljs-quote{color:#8B8FA8;font-style:italic}
.hljs-keyword,.hljs-selector-tag,.hljs-built_in,.hljs-type{color:#B4A7FF}
.hljs-string,.hljs-attr,.hljs-template-tag{color:#9BE3B5}
.hljs-number,.hljs-literal{color:#F6B97A}
.hljs-title,.hljs-function .hljs-title,.hljs-title.function_{color:#7FC8F8}
.hljs-variable,.hljs-params{color:#E6E6EF}
.hljs-meta{color:#F08DB0}
.article-end{max-width:720px;padding-bottom:72px;display:flex;flex-direction:column;gap:24px}
.original{font-size:13px;color:var(--muted);border-top:1px solid var(--line);padding-top:20px}
.author-card{display:flex;gap:18px;align-items:center;background:var(--violet-tint);border-radius:14px;padding:22px}
.author-card img{border-radius:50%;object-fit:cover;flex:none}
.author-card p{font-size:15px;color:var(--ink-3);line-height:1.5}
.author-card .author-name{font-weight:600;color:var(--ink);font-size:17px}
.author-links a{color:var(--violet-ink)}
.more-articles h2{font-size:28px;font-weight:600;letter-spacing:-.02em}
.more-articles .btn-outline{align-self:flex-start}
.more-card{padding:22px;gap:12px}
.more-card .kicker{font-size:11px;text-transform:uppercase;letter-spacing:.06em}
.more-title{font-size:17px;font-weight:600;line-height:1.35}
.more-card .muted{font-size:12px;margin-top:auto}
`;

module.exports = { renderArticlePage, markdownToHtml, ARTICLE_CSS };
