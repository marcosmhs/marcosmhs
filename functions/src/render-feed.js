// Feed RSS 2.0 dos artigos: /feed.xml (texto completo em content:encoded).

const config = require('./site-config');
const { markdownToHtml } = require('./render-article');

const xml = (v) =>
  String(v ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
const cdata = (v) => `<![CDATA[${String(v ?? '').replace(/]]>/g, ']]]]><![CDATA[>')}]]>`;

/** Torna absolutos os links internos ("/artigos/...") para leitores de feed. */
const absolutize = (html) => html.replace(/(href|src)="\/(?!\/)/g, `$1="${config.siteUrl}/`);

function renderFeed(model) {
  const items = [...model.articles.pages]
    .sort((a, b) => (b.publishedAt || b.updatedAt || 0) - (a.publishedAt || a.updatedAt || 0))
    .slice(0, 50);
  const feedUrl = `${config.siteUrl}/feed.xml`;
  const lastBuild = (items[0] && (items[0].updatedAt || items[0].publishedAt)) || model.generatedAt;

  return `<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:dc="http://purl.org/dc/elements/1.1/">
<channel>
  <title>${xml(`Artigos de ${model.name}`)}</title>
  <link>${config.siteUrl}/</link>
  <atom:link href="${feedUrl}" rel="self" type="application/rss+xml"/>
  <description>${xml(`Artigos sobre dados, data science, tecnologia e liderança, por ${model.name}.`)}</description>
  <language>pt-BR</language>
  <lastBuildDate>${lastBuild.toUTCString()}</lastBuildDate>
${items
  .map((a) => {
    const url = `${config.siteUrl}${a.pageUrl}`;
    const date = a.publishedAt || a.updatedAt || model.generatedAt;
    const { html } = markdownToHtml(a.content);
    return `  <item>
    <title>${xml(a.title)}</title>
    <link>${url}</link>
    <guid isPermaLink="true">${url}</guid>
    <pubDate>${date.toUTCString()}</pubDate>
    <dc:creator>${xml(model.name)}</dc:creator>
${a.tags.map((t) => `    <category>${xml(t)}</category>`).join('\n')}
    <description>${xml(a.summary || a.title)}</description>
    <content:encoded>${cdata(absolutize(html))}</content:encoded>
  </item>`;
  })
  .join('\n')}
</channel>
</rss>
`;
}

module.exports = { renderFeed };
