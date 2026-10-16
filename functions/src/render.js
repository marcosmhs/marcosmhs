// Gera o HTML estático do site a partir do modelo (site-model.js).
// Leiaute baseado no design "Marcos H. Silva — Criando valor através dos dados" (Claude Design).

const config = require('./site-config');

const esc = (v) =>
  String(v ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');

const INLINE_TAGS = { b: 'strong', strong: 'strong', i: 'em', em: 'em', u: 'u' };

/** Escapa o texto e libera apenas negrito/itálico/sublinhado sem atributos. */
function inlineHtml(text) {
  return esc(text)
    .replace(/&lt;(\/?)(b|strong|i|em|u)&gt;/gi, (_, close, tag) => `<${close}${INLINE_TAGS[tag.toLowerCase()]}>`)
    .replace(/&lt;br\s*\/?&gt;/gi, '<br>');
}

/** Texto do admin -> parágrafos e listas. Linhas iniciadas por "- " ou "• " viram itens de lista. */
function richBlocks(text) {
  const lines = String(text ?? '')
    .split(/<br\s*\/?>|\n/i)
    .map((l) => l.trim())
    .filter(Boolean);
  const out = [];
  let list = [];
  const flush = () => {
    if (!list.length) return;
    if (out.length && out[out.length - 1].startsWith('<p>')) {
      out[out.length - 1] = out[out.length - 1].replace('<p>', '<p class="lead-in">');
    }
    out.push(`<ul class="bullets">${list.map((li) => `<li><span>${inlineHtml(li)}</span></li>`).join('')}</ul>`);
    list = [];
  };
  for (const line of lines) {
    const m = line.match(/^[-•–]\s+(.*)$/);
    if (m) {
      list.push(m[1]);
    } else {
      flush();
      out.push(`<p>${inlineHtml(line)}</p>`);
    }
  }
  flush();
  return out.join('\n');
}

const plainText = (html) =>
  String(html ?? '')
    .replace(/<[^>]*>/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();

const truncate = (text, max) => (text.length <= max ? text : `${text.slice(0, max - 1).replace(/\s+\S*$/, '')}…`);

const ext = 'target="_blank" rel="noopener"';
const srOnly = (text) => `<span class="sr-only">${esc(text)}</span>`;

const NAV = [
  ['sobre', 'Sobre'],
  ['experiencia', 'Experiência'],
  ['artigos', 'Artigos'],
  ['projetos', 'Projetos'],
];

/** Dados estruturados da pessoa (reaproveitados como autor nas páginas de artigo). */
function personLd(m) {
  return {
    '@type': 'Person',
    '@id': `${config.siteUrl}/#pessoa`,
    name: m.name,
    ...(config.alternateNames.length ? { alternateName: config.alternateNames } : {}),
    url: `${config.siteUrl}/`,
    ...(m.jobTitle ? { jobTitle: m.jobTitle } : {}),
    ...(m.company ? { worksFor: { '@type': 'Organization', name: m.company } } : {}),
    ...(m.photoUrl ? { image: m.photoUrl } : {}),
    ...(m.email ? { email: `mailto:${m.email}` } : {}),
    address: { '@type': 'PostalAddress', addressLocality: config.city.split(',')[0], addressCountry: 'BR' },
    sameAs: m.socials.map((s) => s.href),
    knowsAbout: m.techGroups.flatMap((g) => g.items),
  };
}

/** <head> comum: SEO, Open Graph, fontes e CSS. */
function commonHead({ m, title, description, url, ogType, image, ld, extraHead = '', extraCss = '' }) {
  return `<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${esc(title)}</title>
<meta name="description" content="${esc(description)}">
<meta name="author" content="${esc(m.name)}">
<link rel="canonical" href="${esc(url)}">
<meta property="og:type" content="${ogType}">
<meta property="og:locale" content="pt_BR">
<meta property="og:site_name" content="${esc(m.name)}">
<meta property="og:title" content="${esc(title)}">
<meta property="og:description" content="${esc(description)}">
<meta property="og:url" content="${esc(url)}">
${image ? `<meta property="og:image" content="${esc(image)}">` : ''}
<meta name="twitter:card" content="${image ? 'summary_large_image' : 'summary'}">
<meta name="theme-color" content="#F4F4F8">
${extraHead}
<link rel="icon" type="image/png" href="/favicon.png">
<link rel="alternate" type="application/rss+xml" title="Artigos de ${esc(m.name)}" href="/feed.xml">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&family=IBM+Plex+Sans:wght@400;500;600&display=swap">
<script type="application/ld+json">${JSON.stringify(ld).replace(/</g, '\\u003c')}</script>
<style>${CSS}${extraCss}</style>`;
}

function renderHead(m) {
  const title = m.tagline ? `${m.name} — ${m.tagline}` : m.name;
  const roleText = [m.jobTitle, m.company].filter(Boolean).join(' na ');
  const description = truncate(
    [roleText ? `${m.name}, ${roleText}.` : m.name, plainText(m.introTexts[1] || m.introTexts[0] || '')]
      .filter(Boolean)
      .join(' '),
    160,
  );
  const url = `${config.siteUrl}/`;
  const ld = {
    '@context': 'https://schema.org',
    '@type': 'ProfilePage',
    url,
    name: title,
    inLanguage: 'pt-BR',
    dateModified: m.generatedAt.toISOString(),
    mainEntity: personLd(m),
  };
  return commonHead({ m, title, description, url, ogType: 'profile', image: m.photoUrl, ld });
}

/** `base` é '' na home e '/' nas outras páginas, para as âncoras apontarem para a home. */
function renderHeader(m, base = '') {
  const links = NAV.map(([id, label]) => `<a href="${base}#${id}" data-nav="${id}">${esc(label)}</a>`).join('');
  const mobileLinks = [...NAV, ['contato', 'Contato']]
    .map(([id, label]) => `<a href="${base}#${id}" data-nav="${id}">${esc(label)}</a>`)
    .join('');
  return `<header class="site-header">
  <div class="wrap header-bar">
    <a class="brand" href="${base}#topo"><span class="brand-name">${esc(m.name)}</span><span class="mono brand-tag">${esc(config.copy.headerTag)}</span></a>
    <nav class="nav-desktop" aria-label="Principal">
      ${links}
      <a class="btn-dark" href="${base}#contato" data-nav="contato">Contato</a>
      <a class="admin-icon" href="/admin/" title="Área administrativa" aria-label="Área administrativa"><span class="admin-head"></span><span class="admin-body"></span></a>
    </nav>
    <button class="menu-btn" type="button" aria-expanded="false" aria-controls="menu-mobile" aria-label="Abrir menu"><span></span><span></span><span></span></button>
  </div>
  <nav id="menu-mobile" class="nav-mobile wrap" aria-label="Principal" hidden>
    ${mobileLinks}
    <a class="mono admin-link" href="/admin/">Área administrativa</a>
  </nav>
</header>`;
}

function renderHero(m) {
  const initials = m.name
    .split(/\s+/)
    .filter((p) => /^[A-Za-zÀ-ú]/.test(p))
    .map((p) => p[0])
    .slice(0, 2)
    .join('');
  const photo = m.photoUrl
    ? `<img src="${esc(m.photoUrl)}" alt="Foto de ${esc(m.name)}" width="380" height="475" fetchpriority="high">`
    : `<span class="photo-fallback" aria-hidden="true">${esc(initials)}</span>`;
  return `<section class="hero" aria-label="Apresentação">
  <div class="wrap hero-grid">
    <div class="hero-text">
      ${m.roleLine.length ? `<p class="mono kicker hero-role">${m.roleLine.map((r) => `<span>${esc(r)}</span>`).join('<span class="dot">·</span>')}</p>` : ''}
      <div class="hero-title">
        <h1>${esc(m.name)}</h1>
        ${m.tagline ? `<p class="tagline">${esc(m.tagline)}${/[.!?]$/.test(m.tagline) ? '' : '.'}</p>` : ''}
      </div>
      <div class="prose hero-intro">${m.introTexts.map((t) => `<p>${inlineHtml(t)}</p>`).join('\n')}</div>
      <div class="hero-actions">
        <a class="btn-primary" href="#projetos">Ver projetos</a>
        <a class="btn-outline" href="#contato">Entrar em contato</a>
        <div class="hero-socials">${m.socials.map((s) => `<a class="mono" href="${esc(s.href)}" ${ext} aria-label="${esc(s.label)}">${esc(s.short)}</a>`).join('')}</div>
      </div>
    </div>
    <div class="hero-photo">
      <div class="photo-frame">${photo}</div>
      ${m.experience.sinceYear ? `<div class="photo-badge"><span class="mono">desde ${m.experience.sinceYear}</span><span>${esc(config.copy.heroBadgeTitle)}</span></div>` : ''}
    </div>
  </div>
</section>`;
}

const sectionHead = (num, label, title, extra = '') => `<div class="section-head">
  <div class="section-title"><p class="mono kicker">${num} — ${esc(label)}</p><h2>${esc(title)}</h2></div>
  ${extra}
</div>`;

function renderAbout(m) {
  const groups = m.techGroups
    .map(
      (g) => `<div class="tech-group">
  <h3 class="mono">${esc(g.title)}</h3>
  <ul class="chips">${g.items.map((t) => `<li class="mono">${esc(t)}</li>`).join('')}</ul>
</div>`,
    )
    .join('\n');
  return `<section id="sobre" class="band band-white">
  <div class="wrap stack-48">
    ${sectionHead('01', 'Sobre mim', config.copy.aboutHeadline)}
    <div class="about-grid">
      <div class="prose about-text">${m.aboutTexts.map(richBlocks).join('\n')}</div>
      <div class="tech-groups">${groups}</div>
    </div>
  </div>
</section>`;
}

function renderExperience(m) {
  const e = m.experience;
  if (!e.expGroups.length) return '';
  const strip = `<div class="strip" aria-hidden="true">
  <div class="strip-bars">${e.strip.map((s) => `<div style="flex:${s.flex} 1 0;background:${s.color}"></div>`).join('')}</div>
  <div class="strip-labels mono">${e.strip.map((s) => `<div style="flex:${s.flex} 1 0"${s.rtl ? ' class="rtl"' : ''}>${esc(s.label)}</div>`).join('')}</div>
</div>`;
  const groups = e.expGroups
    .map(
      (g) => `<li class="exp-card">
  <div class="exp-company">
    <h3>${esc(g.company)}</h3>
    <p class="mono muted">${esc(g.range)}</p>
    ${g.meta ? `<p class="mono">${esc(g.meta)}</p>` : ''}
  </div>
  <ol class="exp-roles">
    ${g.roles
      .map(
        (r) => `<li>
      <span class="exp-dot" style="border-color:${r.color};background:${r.current ? r.color : '#fff'}"></span>
      <div class="exp-meta"><p class="mono muted">${esc(r.period)}</p>${r.current ? '<span class="mono pill-current">ATUAL</span>' : ''}${r.step ? `<span class="mono pill-step">${esc(r.step)}</span>` : ''}</div>
      <h4>${esc(r.title)}</h4>
      ${r.desc ? `<p>${esc(r.desc)}</p>` : ''}
    </li>`,
      )
      .join('\n')}
  </ol>
</li>`,
    )
    .join('\n');
  return `<section id="experiencia" class="band band-grey">
  <div class="wrap stack-48">
    ${sectionHead('02', 'Experiência', config.copy.experienceTitle, e.careerSummary ? `<p class="mono muted">${esc(e.careerSummary)}</p>` : '')}
    ${strip}
    <ol class="exp-list">${groups}</ol>
  </div>
</section>`;
}

/** Página interna quando o texto já está no site; senão, o link original. */
const articleHref = (a) => a.pageUrl || a.url;

function articleCard(a) {
  return `<li data-cat="${a.category}">
  <a class="card article-card" href="${esc(articleHref(a))}"${a.pageUrl ? '' : ` ${ext}`}>
    <div class="article-head" style="background-color:${a.tint};color:${a.ink}">
      <span class="mono article-cat">${esc(a.catLabel)}</span>
      <span class="mono article-mark">${esc(a.mark)}</span>
    </div>
    <div class="article-body">
      <h4>${esc(a.title)}${a.en ? '<span class="mono pill-en" title="Artigo em inglês">EN</span>' : ''}</h4>
      <div class="tags">${a.tags.map((t) => `<span class="mono tag">${esc(t)}</span>`).join('')}</div>
      <span class="article-foot">${a.pageUrl ? `${esc(a.readingTime)}<span>ler artigo →</span>` : `${esc(a.src)}<span>abre em nova aba ↗</span>`}</span>
    </div>
  </a>
</li>`;
}

function renderArticles(m) {
  const { featured, rest, counts } = m.articles;
  if (!featured) return '';
  const filters =
    counts.todos > 1
      ? `<div class="filters" role="group" aria-label="Filtrar artigos">
  ${[
    ['todos', 'Todos', '#1C1D29'],
    ['lead', 'Liderança & estratégia', '#5B5BD6'],
    ['tech', 'Tutoriais técnicos', '#0E7C7B'],
  ]
    .filter(([id]) => id === 'todos' || counts[id] > 0)
    .map(
      ([id, label, sw]) =>
        `<button type="button" data-filter="${id}" aria-pressed="${id === 'todos'}"><span class="swatch" style="background:${sw}"></span>${esc(label)}<span class="mono muted">${counts[id]}</span></button>`,
    )
    .join('\n  ')}
</div>`
      : '';
  const cover = featured.image
    ? `<img src="${esc(featured.image)}" alt="" loading="lazy" onerror="this.remove()">`
    : '';
  return `<section id="artigos" class="band band-white">
  <div class="wrap stack-40">
    ${sectionHead('03', 'Artigos', config.copy.articlesTitle, filters)}
    <a class="featured" href="${esc(articleHref(featured))}"${featured.pageUrl ? '' : ` ${ext}`} data-cat="${featured.category}">
      <div class="featured-cover">${cover}</div>
      <div class="featured-body">
        <p class="mono featured-kicker">Destaque · mais recente · ${esc(featured.catLabel)}</p>
        <h3>${esc(featured.title)}${featured.en ? '<span class="mono pill-en">EN</span>' : ''}</h3>
        <div class="tags">${featured.tags.map((t) => `<span class="mono tag-outline">${esc(t)}</span>`).join('')}</div>
        <span class="featured-cta">${featured.pageUrl ? `Ler artigo <span aria-hidden="true">→</span>` : `Ler no ${esc(featured.src)} <span aria-hidden="true">↗</span>${srOnly('(abre em nova aba)')}`}</span>
      </div>
    </a>
    ${rest.length ? `<ul class="grid grid-280" id="lista-artigos">${rest.map(articleCard).join('\n')}</ul>` : ''}
  </div>
</section>`;
}

function renderProjects(m) {
  if (!m.projects.length) return '';
  const cards = m.projects
    .map(
      (p) => `<li>
  <article class="card project-card">
    ${p.image ? `<img src="${esc(p.image)}" alt="${esc(p.title)}" loading="lazy" onerror="this.remove()">` : ''}
    <div class="project-body">
      <div class="tags">${p.tags.map((t) => `<span class="mono tag">${esc(t)}</span>`).join('')}${p.family ? '<span class="mono tag tag-family">feito em família</span>' : ''}</div>
      <h3>${p.pageUrl ? `<a class="card-title-link" href="${p.pageUrl}">${esc(p.title)}</a>` : esc(p.title)}</h3>
      ${p.desc ? `<p>${esc(p.desc)}</p>` : ''}
      ${p.links.length || p.pageUrl ? `<div class="project-links">${p.pageUrl ? `<a class="btn-dark" href="${p.pageUrl}">Detalhes ${srOnly(`de ${p.title}`)}<span aria-hidden="true">→</span></a>` : ''}${p.links.map((l, i) => `<a class="${i === 0 && !p.pageUrl ? 'btn-dark' : 'btn-light'}" href="${esc(l.href)}" ${ext}>${esc(l.label)} <span aria-hidden="true">↗</span>${srOnly(`de ${p.title} (abre em nova aba)`)}</a>`).join('')}</div>` : ''}
    </div>
  </article>
</li>`,
    )
    .join('\n');
  return `<section id="projetos" class="band band-grey">
  <div class="wrap stack-40">
    ${sectionHead('04', 'Projetos', config.copy.projectsTitle, `<p class="section-intro">${config.copy.projectsIntro}</p>`)}
    <ul class="grid grid-300">${cards}</ul>
  </div>
</section>`;
}

function renderContact(m) {
  const cols = Math.max(Math.min(m.contacts.length, 4), 1);
  return `<section id="contato" class="band band-violet">
  <div class="wrap stack-48">
    <div class="section-head">
      <div class="section-title contact-title">
        <p class="mono kicker">05 — Contato</p>
        <h2>${esc(config.copy.contactTitle)}</h2>
        <p class="contact-text">${esc(config.copy.contactText)}</p>
      </div>
      <div class="mono contact-info"><span>${esc(config.city)}</span><span><span class="online"></span>${esc(config.availability)}</span></div>
    </div>
    <ul class="contacts" style="--cols:${cols}">
      ${m.contacts
        .map(
          (c) => `<li><a href="${esc(c.href)}"${c.external ? ` ${ext}` : ''}>
        <span class="mono contact-label">${esc(c.label)}<span aria-hidden="true">↗</span></span>
        <span class="contact-value">${esc(c.value)}</span>
      </a></li>`,
        )
        .join('\n      ')}
    </ul>
  </div>
</section>`;
}

function renderFooter(m) {
  const d = m.generatedAt;
  const updated = `${String(d.getDate()).padStart(2, '0')}/${String(d.getMonth() + 1).padStart(2, '0')}/${d.getFullYear()}`;
  const links = [
    ...m.socials.map((s) => `<a href="${esc(s.href)}" ${ext}>${esc(s.label)}</a>`),
    ...(m.email ? [`<a href="mailto:${esc(m.email)}">E-mail</a>`] : []),
    ...(m.articles.pages.length ? ['<a href="/feed.xml">RSS</a>'] : []),
  ].join('');
  return `<footer class="site-footer">
  <div class="wrap footer-bar">
    <div class="footer-id"><span class="footer-name">${esc(m.name)}</span><span class="mono">© ${d.getFullYear()} · um projeto ${esc(config.brand)} · atualizado em ${updated}</span></div>
    <nav aria-label="Redes" class="footer-links">${links}<a class="mono footer-admin" href="/admin/">admin</a></nav>
  </div>
</footer>`;
}

function renderSite(model) {
  return `<!DOCTYPE html>
<html lang="pt-BR">
<head>
${renderHead(model)}
</head>
<body>
<a class="skip-link" href="#topo">Pular para o conteúdo</a>
${renderHeader(model)}
<main id="topo">
${renderHero(model)}
${renderAbout(model)}
${renderExperience(model)}
${renderArticles(model)}
${renderProjects(model)}
${renderContact(model)}
</main>
${renderFooter(model)}
<script>${JS}</script>
</body>
</html>
`;
}

function renderSitemap(model) {
  const day = (d) => d.toISOString().slice(0, 10);
  const urls = [
    { loc: `${config.siteUrl}/`, lastmod: day(model.generatedAt) },
    ...model.articles.pages.map((a) => ({
      loc: `${config.siteUrl}${a.pageUrl}`,
      lastmod: day(a.updatedAt || a.publishedAt || model.generatedAt),
    })),
    ...model.projects
      .filter((p) => p.pageUrl)
      .map((p) => ({ loc: `${config.siteUrl}${p.pageUrl}`, lastmod: day(p.updatedAt || model.generatedAt) })),
  ];
  return `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
${urls.map((u) => `  <url>\n    <loc>${esc(u.loc)}</loc>\n    <lastmod>${u.lastmod}</lastmod>\n  </url>`).join('\n')}
</urlset>
`;
}

const CSS = `
:root{--ink:#1C1D29;--ink-2:#3F4152;--ink-3:#4F5263;--muted:#5E6075;--line:#E4E5EA;--line-2:#DCDDE3;--bg:#F6F6F8;--bg-hero:#F4F4F8;--violet:#5B5BD6;--violet-ink:#4B4BC4;--violet-deep:#3E3EB0;--violet-tint:#EEEEFB;--teal:#0E7C7B;--radius:12px;--sans:'IBM Plex Sans',system-ui,-apple-system,sans-serif;--mono:'IBM Plex Mono',ui-monospace,monospace;--gutter:clamp(20px,5vw,48px)}
*,*::before,*::after{box-sizing:border-box}
html{scroll-behavior:smooth}
body{margin:0;background:var(--bg);color:var(--ink);font-family:var(--sans);-webkit-font-smoothing:antialiased}
h1,h2,h3,h4,p{margin:0}
ul,ol{margin:0;padding:0;list-style:none}
img{max-width:100%}
a{color:var(--violet-ink)}
a:hover{color:#3434A8}
:focus-visible{outline:2px solid var(--violet);outline-offset:3px;border-radius:4px}
section,footer{scroll-margin-top:72px}
.mono{font-family:var(--mono)}
.muted{color:var(--muted)}
.sr-only{position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0 0 0 0);white-space:nowrap}
.skip-link{position:absolute;left:-9999px;top:8px;z-index:100;background:#fff;padding:10px 14px;border-radius:8px}
.skip-link:focus{left:8px}
.wrap{max-width:1280px;margin:0 auto;padding:0 var(--gutter)}
.stack-48{display:flex;flex-direction:column;gap:48px}
.stack-40{display:flex;flex-direction:column;gap:40px}
.kicker{font-size:13px;color:var(--violet-ink);letter-spacing:.02em}
.band{padding:clamp(72px,9vw,120px) 0}
.band-white{background:#fff}.band-grey{background:var(--bg)}.band-violet{background:var(--violet-tint)}
.section-head{display:flex;flex-wrap:wrap;justify-content:space-between;align-items:flex-end;gap:24px}
.section-title{display:flex;flex-direction:column;gap:12px}
.section-title h2{font-size:clamp(30px,4vw,44px);font-weight:600;letter-spacing:-.025em;line-height:1.1;max-width:760px;text-wrap:balance}
.section-intro{font-size:15px;line-height:1.6;color:var(--ink-3);max-width:440px;text-wrap:pretty}
.section-intro strong{color:var(--ink);font-weight:600}
.prose{display:flex;flex-direction:column;gap:14px;font-size:17px;line-height:1.65;color:var(--ink-2);text-wrap:pretty}
.prose strong{color:var(--ink);font-weight:600}
.btn-primary,.btn-outline,.btn-dark,.btn-light{text-decoration:none;font-weight:600;border-radius:8px;display:inline-flex;align-items:center;gap:6px;min-height:44px;padding:0 18px;font-size:15px}
.btn-primary{background:var(--violet);color:#fff;min-height:48px;padding:0 22px;font-size:16px}
.btn-primary:hover{background:var(--violet-ink);color:#fff}
.btn-outline{border:1px solid #C9CAD3;color:var(--ink);font-weight:500;min-height:48px;padding:0 22px;font-size:16px}
.btn-outline:hover{border-color:var(--ink);color:var(--ink)}
.btn-dark{background:var(--ink);color:#fff;border:1px solid var(--ink)}
.btn-dark:hover{background:#3A3C52;color:#fff}
.btn-light{background:#fff;color:var(--ink);border:1px solid var(--line-2)}
.btn-light:hover{filter:brightness(.94);color:var(--ink)}
/* header */
.site-header{position:fixed;inset:0 0 auto 0;z-index:50;background:rgba(255,255,255,.94);backdrop-filter:blur(10px);border-bottom:1px solid var(--line)}
.header-bar{height:64px;display:flex;align-items:center;justify-content:space-between;gap:24px}
.brand{display:flex;align-items:center;gap:10px;color:var(--ink);text-decoration:none;min-height:44px}
.brand:hover{color:var(--ink)}
.brand-name{font-weight:600;font-size:17px;letter-spacing:-.01em}
.brand-tag{font-size:12px;color:var(--muted)}
.nav-desktop{display:flex;align-items:center;gap:4px}
.nav-desktop a[data-nav]:not(.btn-dark){color:var(--ink-3);text-decoration:none;font-size:15px;font-weight:500;padding:0 14px;min-height:44px;display:flex;align-items:center}
.nav-desktop a[data-nav]:not(.btn-dark):hover,.nav-desktop a[aria-current]:not(.btn-dark){color:var(--ink)}
.nav-desktop a[aria-current]:not(.btn-dark){box-shadow:inset 0 -2px 0 var(--violet)}
.nav-desktop .btn-dark{margin-left:10px}
.admin-icon{width:44px;height:44px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;opacity:.45;margin-left:4px}
.admin-icon:hover{opacity:.9}
.admin-head{width:8px;height:8px;border:1.5px solid var(--ink);border-radius:50%}
.admin-body{width:14px;height:6px;border:1.5px solid var(--ink);border-bottom:none;border-radius:8px 8px 0 0}
.menu-btn{display:none;width:44px;height:44px;background:transparent;border:1px solid var(--line-2);border-radius:8px;flex-direction:column;align-items:center;justify-content:center;gap:5px;cursor:pointer}
.menu-btn span{width:18px;height:2px;background:var(--ink)}
.nav-mobile{border-top:1px solid var(--line);padding-top:8px;padding-bottom:20px;flex-direction:column}
.nav-mobile:not([hidden]){display:flex}
.nav-mobile a{color:var(--ink-3);text-decoration:none;font-size:17px;font-weight:500;min-height:48px;display:flex;align-items:center;border-bottom:1px solid #EEEEF2}
.nav-mobile a[aria-current]{color:var(--ink)}
.nav-mobile .admin-link{font-size:14px;color:var(--muted);border-bottom:none}
@media (max-width:767px){.nav-desktop{display:none}.menu-btn{display:flex}}
@media (min-width:768px){.nav-mobile{display:none !important}}
/* hero */
.hero{background:var(--bg-hero);padding:clamp(112px,14vw,168px) 0 clamp(64px,8vw,112px)}
.hero-grid{display:flex;flex-wrap:wrap-reverse;align-items:center;gap:clamp(40px,6vw,88px)}
.hero-text{flex:1 1 520px;min-width:0;display:flex;flex-direction:column;gap:28px}
.hero-role{display:flex;flex-wrap:wrap;gap:6px 14px}
.hero-role .dot{color:#B9BBCC}
.hero-title{display:flex;flex-direction:column;gap:14px}
.hero h1{font-size:clamp(44px,7vw,84px);line-height:1;font-weight:600;letter-spacing:-.035em}
.tagline{font-size:clamp(22px,2.6vw,30px);line-height:1.25;color:var(--ink-3);letter-spacing:-.01em}
.hero-intro{max-width:620px}
.hero-actions{display:flex;flex-wrap:wrap;gap:12px;align-items:center}
.hero-socials{display:flex;gap:4px;margin-left:6px}
.hero-socials a{font-size:13px;color:var(--ink-3);text-decoration:none;min-width:44px;min-height:44px;padding:0 8px;display:flex;align-items:center;justify-content:center}
.hero-socials a:hover{color:var(--ink)}
.hero-photo{flex:0 1 340px;min-width:220px;max-width:380px;margin:0 auto;position:relative}
.photo-frame{aspect-ratio:4/5;width:100%;border-radius:16px;overflow:hidden;background:#E9E9EF;border:1px solid var(--line);display:flex;align-items:center;justify-content:center}
.photo-frame img{width:100%;height:100%;object-fit:cover;display:block}
.photo-fallback{font-size:64px;font-weight:600;color:#B9BBCC}
.photo-badge{position:absolute;left:-14px;bottom:24px;background:#fff;color:#11121B;border-radius:10px;padding:10px 14px;display:flex;flex-direction:column;gap:2px;border:1px solid var(--line);box-shadow:0 12px 30px -14px rgba(20,21,40,.25)}
.photo-badge .mono{font-size:11px;color:var(--muted)}
.photo-badge span:last-child{font-size:14px;font-weight:600}
/* about */
.about-grid{display:flex;flex-wrap:wrap;gap:clamp(40px,6vw,80px)}
.about-text{flex:1 1 480px;min-width:0;gap:20px;line-height:1.7}
.about-text .lead-in{color:var(--ink);font-weight:500}
.bullets{display:flex;flex-direction:column;gap:14px}
.bullets li{display:flex;gap:14px}
.bullets li::before{content:"";flex:none;width:8px;height:8px;background:var(--violet);margin-top:10px}
.tech-groups{flex:1 1 340px;min-width:0;display:flex;flex-direction:column;gap:20px}
.tech-group{border:1px solid var(--line);border-radius:var(--radius);padding:24px;display:flex;flex-direction:column;gap:16px;background:#FAFAFB}
.tech-group h3{font-size:13px;font-weight:500;color:var(--muted);text-transform:uppercase;letter-spacing:.06em}
.chips{display:flex;flex-wrap:wrap;gap:8px}
.chips li{font-size:13px;color:var(--ink);background:#fff;border:1px solid var(--line-2);border-radius:6px;padding:7px 11px}
/* experience */
.strip{display:flex;flex-direction:column;gap:10px}
.strip-bars{display:flex;height:12px;border-radius:3px;overflow:hidden;gap:2px}
.strip-bars div,.strip-labels div{min-width:10px}
.strip-labels{display:flex;gap:2px;font-size:12px;color:var(--muted)}
.strip-labels div{white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.strip-labels .rtl{direction:rtl}
.exp-list{display:flex;flex-direction:column;gap:20px}
.exp-card{background:#fff;border:1px solid var(--line);border-radius:14px;padding:clamp(22px,3vw,36px);display:flex;flex-wrap:wrap;gap:24px clamp(32px,5vw,64px)}
.exp-company{flex:1 1 220px;max-width:300px;display:flex;flex-direction:column;gap:8px}
.exp-company h3{font-size:22px;font-weight:600;letter-spacing:-.015em}
.exp-company p{font-size:13px}
.exp-roles{flex:1 1 420px;min-width:0;padding-left:28px;display:flex;flex-direction:column;gap:28px;border-left:2px solid var(--line)}
.exp-roles li{position:relative;display:flex;flex-direction:column;gap:6px}
.exp-dot{position:absolute;left:-37px;top:4px;width:12px;height:12px;border-radius:50%;border:2px solid;box-shadow:0 0 0 4px #fff}
.exp-meta{display:flex;flex-wrap:wrap;align-items:center;gap:8px 12px}
.exp-meta p{font-size:13px}
.pill-current{font-size:11px;font-weight:500;color:#fff;background:var(--violet-ink);border-radius:4px;padding:2px 7px}
.pill-step{font-size:11px;color:#0E6E6D;background:#E3F2F1;border-radius:4px;padding:2px 7px}
.exp-roles h4{font-size:18px;font-weight:600}
.exp-roles p:not(.mono){font-size:15px;line-height:1.6;color:var(--ink-3);max-width:620px;text-wrap:pretty}
/* cards */
.grid{display:grid;gap:20px}
.grid-280{grid-template-columns:repeat(auto-fill,minmax(min(100%,280px),1fr))}
.grid-300{grid-template-columns:repeat(auto-fill,minmax(min(100%,300px),1fr))}
.grid>li{display:flex}
.grid>li[hidden]{display:none}
.card{flex:1;display:flex;flex-direction:column;background:#fff;border:1px solid var(--line);border-radius:var(--radius);overflow:hidden;color:var(--ink);text-decoration:none;transition:transform .2s ease,box-shadow .2s ease,border-color .2s}
.card:hover{transform:translateY(-3px);box-shadow:0 14px 30px -14px rgba(20,21,40,.28);border-color:#D2D3DB;color:var(--ink)}
.tags{display:flex;flex-wrap:wrap;gap:6px;align-items:center}
.tag{font-size:12px;color:var(--ink-3);background:#F3F3F6;border-radius:5px;padding:3px 8px}
.tag-family{color:#8A4B12;background:#FBEFE2}
.tag-outline{font-size:12px;color:var(--violet-deep);border:1px solid #C9C9F0;border-radius:5px;padding:4px 9px}
.pill-en{font-size:11px;font-weight:500;color:var(--muted);border:1px solid var(--line-2);border-radius:4px;padding:1px 5px;margin-left:8px;vertical-align:2px}
/* articles */
.filters{display:flex;flex-wrap:wrap;gap:6px;background:#F1F1F4;padding:4px;border-radius:10px}
.filters button{font-family:var(--sans);font-size:14px;font-weight:500;border:none;cursor:pointer;min-height:40px;padding:0 14px;border-radius:7px;background:transparent;color:var(--ink-3);display:flex;align-items:center;gap:8px}
.filters button[aria-pressed="true"]{background:#fff;color:var(--ink);box-shadow:0 1px 3px rgba(20,21,40,.14)}
.filters .muted{font-size:12px}
.swatch{width:8px;height:8px;border-radius:2px}
.featured{display:flex;flex-wrap:wrap;background:var(--violet-tint);color:var(--ink);border-radius:16px;overflow:hidden;text-decoration:none;transition:transform .2s ease,box-shadow .2s ease}
.featured[hidden]{display:none}
.featured:hover{transform:translateY(-3px);box-shadow:0 24px 48px -20px rgba(20,21,40,.25);color:var(--ink)}
.featured-cover{flex:1 1 420px;min-height:260px;position:relative;background-color:#E2E2F4;background-image:repeating-linear-gradient(135deg,transparent 0 9px,rgba(20,21,40,.05) 9px 10px)}
.featured-cover img{position:absolute;inset:0;width:100%;height:100%;object-fit:cover}
.featured-body{flex:1 1 420px;min-width:0;padding:clamp(28px,4vw,48px);display:flex;flex-direction:column;gap:20px;justify-content:center}
.featured-kicker{font-size:12px;color:var(--violet-deep);letter-spacing:.06em;text-transform:uppercase}
.featured h3{font-size:clamp(24px,2.8vw,34px);font-weight:600;line-height:1.2;letter-spacing:-.02em;text-wrap:balance}
.featured-cta{font-weight:600;font-size:15px;color:var(--violet-deep);display:flex;align-items:center;gap:8px}
.article-head{height:112px;background-image:repeating-linear-gradient(135deg,transparent 0 9px,rgba(20,21,40,.04) 9px 10px);padding:16px 18px;display:flex;flex-direction:column;justify-content:space-between}
.article-cat{font-size:11px;letter-spacing:.06em;text-transform:uppercase}
.article-mark{font-size:22px;font-weight:500;letter-spacing:-.01em;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.article-body{padding:18px 18px 16px;display:flex;flex-direction:column;gap:14px;flex:1}
.article-body h4{font-size:17px;font-weight:600;line-height:1.35;text-wrap:pretty}
.article-foot{margin-top:auto;padding-top:12px;border-top:1px solid #EEEEF2;font-size:13px;font-weight:500;color:var(--ink-3);display:flex;justify-content:space-between;gap:8px}
/* projects */
.project-card img{width:100%;aspect-ratio:16/9;object-fit:cover;display:block;background:#EEEEF2}
.project-body{padding:24px;display:flex;flex-direction:column;gap:14px;flex:1}
.project-body h3{font-size:19px;font-weight:600;letter-spacing:-.01em;line-height:1.3}
.project-body>p{font-size:15px;line-height:1.6;color:var(--ink-3);text-wrap:pretty}
.project-links{margin-top:auto;padding-top:8px;display:flex;flex-wrap:wrap;gap:8px}
.project-links a{font-size:14px;padding:0 16px}
.card-title-link{color:inherit;text-decoration:none}
.card-title-link:hover{color:var(--violet-ink);text-decoration:underline;text-underline-offset:3px}
/* contact */
.contact-title{gap:16px;max-width:640px}
.contact-title h2{font-size:clamp(36px,5.5vw,64px);letter-spacing:-.03em;line-height:1.05}
.contact-text{font-size:18px;line-height:1.6;color:var(--ink-2);text-wrap:pretty}
.contact-info{display:flex;flex-direction:column;gap:8px;font-size:13px;color:var(--ink-2)}
.contact-info>span{display:flex;align-items:center;gap:8px}
.online{width:8px;height:8px;border-radius:50%;background:#1F9D63}
.contacts{display:grid;grid-template-columns:repeat(var(--cols),minmax(0,1fr));gap:1px;background:#D9D9F2;border:1px solid #D9D9F2;border-radius:14px;overflow:hidden}
.contacts li{display:flex}
.contacts a{flex:1;background:#fff;color:var(--ink);text-decoration:none;padding:28px 24px;display:flex;flex-direction:column;gap:10px;transition:background .2s}
.contacts a:hover{background:#F7F7FD;color:var(--ink)}
.contact-label{font-size:12px;color:var(--muted);text-transform:uppercase;letter-spacing:.06em;display:flex;justify-content:space-between}
.contact-value{font-size:17px;font-weight:500;word-break:break-word}
@media (max-width:1023px){.contacts{grid-template-columns:repeat(2,minmax(0,1fr))}}
@media (max-width:639px){.contacts{grid-template-columns:1fr}}
/* footer */
.site-footer{background:#fff;color:var(--muted);border-top:1px solid var(--line);padding:40px 0}
.footer-bar{display:flex;flex-wrap:wrap;justify-content:space-between;align-items:center;gap:20px 40px}
.footer-id{display:flex;flex-direction:column;gap:6px}
.footer-id .mono{font-size:12px}
.footer-name{color:var(--ink);font-weight:600;font-size:16px}
.footer-links{display:flex;flex-wrap:wrap;gap:4px;align-items:center}
.footer-links a{color:var(--ink-3);text-decoration:none;font-size:14px;min-height:44px;padding:0 12px;display:flex;align-items:center}
.footer-links a:hover{color:var(--ink)}
.footer-links .footer-admin{color:#8A8CA3;font-size:12px}
@media (prefers-reduced-motion:reduce){html{scroll-behavior:auto}*{transition:none !important;animation:none !important}}
`;

const JS = `
(function(){
  var btn=document.querySelector('.menu-btn'),menu=document.getElementById('menu-mobile');
  if(btn&&menu){
    btn.addEventListener('click',function(){var open=btn.getAttribute('aria-expanded')==='true';btn.setAttribute('aria-expanded',String(!open));btn.setAttribute('aria-label',open?'Abrir menu':'Fechar menu');menu.hidden=open;});
    menu.addEventListener('click',function(e){if(e.target.closest('a')){btn.setAttribute('aria-expanded','false');btn.setAttribute('aria-label','Abrir menu');menu.hidden=true;}});
  }
  var ids=['sobre','experiencia','artigos','projetos','contato'],active='';
  function onScroll(){
    var a='';
    for(var i=0;i<ids.length;i++){var el=document.getElementById(ids[i]);if(el&&el.getBoundingClientRect().top<140)a=ids[i];}
    if(a===active)return;active=a;
    document.querySelectorAll('[data-nav]').forEach(function(l){if(l.getAttribute('data-nav')===a)l.setAttribute('aria-current','true');else l.removeAttribute('aria-current');});
  }
  window.addEventListener('scroll',onScroll,{passive:true});onScroll();
  var filters=document.querySelectorAll('[data-filter]');
  filters.forEach(function(b){b.addEventListener('click',function(){
    var f=b.getAttribute('data-filter');
    filters.forEach(function(o){o.setAttribute('aria-pressed',String(o===b));});
    document.querySelectorAll('#lista-artigos [data-cat]').forEach(function(li){li.hidden=f!=='todos'&&li.getAttribute('data-cat')!==f;});
    var feat=document.querySelector('.featured');
    if(feat)feat.hidden=f!=='todos'&&feat.getAttribute('data-cat')!==f;
  });});
})();
`;

module.exports = {
  renderSite,
  renderSitemap,
  richBlocks,
  inlineHtml,
  commonHead,
  personLd,
  renderHeader,
  renderFooter,
  esc,
  ext,
  srOnly,
  JS,
};
