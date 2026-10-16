// Gera todos os arquivos do site público a partir dos dados crus do Firestore.

const { buildSiteModel } = require('./site-model');
const { renderSite, renderSitemap } = require('./render');
const { renderArticlePage } = require('./render-article');
const { renderProjectPage } = require('./render-project');
const { renderFeed } = require('./render-feed');

/** Pastas cujo conteúdo é 100% gerado (páginas apagadas no admin somem do Hosting). */
const GENERATED_PREFIXES = ['/artigos/', '/projetos/'];

function buildSiteFiles(raw, { now = new Date() } = {}) {
  const model = buildSiteModel(raw, { now });
  const files = {
    '/index.html': renderSite(model),
    '/sitemap.xml': renderSitemap(model),
    '/feed.xml': renderFeed(model),
  };
  for (const article of model.articles.pages) {
    files[`${article.pageUrl}index.html`] = renderArticlePage(model, article);
  }
  for (const project of model.projects.filter((p) => p.pageUrl)) {
    files[`${project.pageUrl}index.html`] = renderProjectPage(model, project);
  }
  return { model, files };
}

module.exports = { buildSiteFiles, GENERATED_PREFIXES };
