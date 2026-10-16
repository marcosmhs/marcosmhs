// Página de projeto: /projetos/<slug>/index.html

const config = require('./site-config');
const { commonHead, personLd, renderHeader, renderFooter, esc, ext, JS } = require('./render');
const { markdownToHtml, ARTICLE_CSS } = require('./render-article');

function renderProjectPage(model, project) {
  const { html } = markdownToHtml(project.content);
  const url = `${config.siteUrl}${project.pageUrl}`;
  const description = project.summary || project.desc || project.title;
  const modified = project.updatedAt || model.generatedAt;

  const ld = [
    {
      '@context': 'https://schema.org',
      '@type': 'SoftwareApplication',
      name: project.title,
      description,
      url,
      applicationCategory: project.isGame ? 'GameApplication' : 'WebApplication',
      operatingSystem: project.isGame ? 'Android' : 'Web',
      ...(project.image ? { image: project.image } : {}),
      ...(project.live ? { installUrl: project.live } : {}),
      ...(project.github ? { sameAs: [project.github] } : {}),
      keywords: project.tags.join(', '),
      dateModified: modified.toISOString(),
      author: personLd(model),
    },
    {
      '@context': 'https://schema.org',
      '@type': 'BreadcrumbList',
      itemListElement: [
        { '@type': 'ListItem', position: 1, name: model.name, item: `${config.siteUrl}/` },
        { '@type': 'ListItem', position: 2, name: 'Projetos', item: `${config.siteUrl}/#projetos` },
        { '@type': 'ListItem', position: 3, name: project.title, item: url },
      ],
    },
  ];

  const others = model.projects.filter((p) => p.id !== project.id).slice(0, 3);
  const links = project.links
    .map(
      (l, i) =>
        `<a class="${i === 0 ? 'btn-primary' : 'btn-outline'}" href="${esc(l.href)}" ${ext}>${esc(l.label)} <span aria-hidden="true">↗</span></a>`,
    )
    .join('');

  return `<!DOCTYPE html>
<html lang="pt-BR">
<head>
${commonHead({
  m: model,
  title: `${project.title} — projeto de ${model.name}`,
  description,
  url,
  ogType: 'website',
  image: project.image || model.photoUrl,
  ld,
  extraCss: ARTICLE_CSS + PROJECT_CSS,
})}
</head>
<body>
<a class="skip-link" href="#conteudo">Pular para o conteúdo</a>
${renderHeader(model, '/')}
<main id="conteudo" class="article-page">
  <article>
    <header class="wrap article-header">
      <nav class="mono crumbs" aria-label="Você está em"><a href="/">Início</a> / <a href="/#projetos">Projetos</a></nav>
      <p class="mono kicker">Projeto ${esc(config.brand)}</p>
      <h1>${esc(project.title)}</h1>
      ${description ? `<p class="article-summary">${esc(description)}</p>` : ''}
      <div class="tags">${project.tags.map((t) => `<span class="mono tag">${esc(t)}</span>`).join('')}${project.family ? '<span class="mono tag tag-family">feito em família</span>' : ''}</div>
      ${links ? `<div class="project-actions">${links}</div>` : ''}
    </header>
    ${project.image ? `<div class="wrap project-shot"><img src="${esc(project.image)}" alt="Tela do ${esc(project.title)}" fetchpriority="high" onerror="this.parentNode.remove()"></div>` : ''}
    <div class="wrap article-layout">
      <div class="article-content">
${html}
      </div>
    </div>
    <footer class="wrap article-end">
      <div class="author-card">
        ${model.photoUrl ? `<img src="${esc(model.photoUrl)}" alt="" width="64" height="64" loading="lazy">` : ''}
        <div>
          <p class="author-name">Feito por ${esc(model.name)}</p>
          <p>${esc([model.jobTitle, model.company].filter(Boolean).join(' na '))}</p>
          <p class="author-links"><a href="/#contato">Entrar em contato</a>${model.socials.map((s) => ` · <a href="${esc(s.href)}" ${ext}>${esc(s.label)}</a>`).join('')}</p>
        </div>
      </div>
    </footer>
  </article>
  ${
    others.length
      ? `<section class="band band-grey more-articles" aria-labelledby="mais-projetos">
    <div class="wrap stack-40">
      <h2 id="mais-projetos">Outros projetos</h2>
      <ul class="grid grid-280">${others
        .map(
          (p) =>
            `<li><a class="card more-card" href="${p.pageUrl || p.links[0]?.href || '/#projetos'}"${p.pageUrl ? '' : ` ${ext}`}><span class="mono kicker">${esc(p.tags.join(' · '))}</span><span class="more-title">${esc(p.title)}</span><span class="muted more-desc">${esc(p.desc)}</span></a></li>`,
        )
        .join('')}</ul>
      <a class="btn-outline" href="/#projetos">Ver todos os projetos</a>
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

const PROJECT_CSS = `
.project-actions{display:flex;flex-wrap:wrap;gap:12px;margin-top:6px}
.project-shot{max-width:1100px;margin-bottom:32px}
.project-shot img{width:100%;max-height:480px;object-fit:contain;border-radius:16px;display:block;background:#F4F4F8;border:1px solid var(--line)}
.more-desc{font-size:14px;line-height:1.5;color:var(--ink-3)}
`;

module.exports = { renderProjectPage };
