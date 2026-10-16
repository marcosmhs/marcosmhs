// Converte os documentos crus do Firestore no modelo usado pelo template.
// Recebe { colecao: [doc, ...] } com docs como objetos simples (Admin SDK ou REST convertido).

const config = require('./site-config');
const { slugify } = require('./article-import');

const PALETTE = {
  violet: { color: '#5B5BD6', tint: '#EEEEFB', ink: '#3E3EB0' },
  teal: { color: '#0E7C7B', tint: '#E3F2F1', ink: '#0B5E5D' },
};
const COMPANY_COLORS = ['#5B5BD6', '#0E7C7B', '#8A8CA3'];
const MONTHS = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
const MONTH_KEYS = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];

const str = (v) => (v === undefined || v === null ? '' : String(v).trim());
const num = (v) => (Number.isFinite(Number(v)) ? Number(v) : 0);
const ofSite = (docs) => (docs || []).filter((d) => !d.siteName || d.siteName === config.siteName);

/** "Setembro/2017", "Fev/2024", "03/2026" -> { year, month }; vazio ou "Até o momento" -> null. */
function parsePeriod(text) {
  const t = str(text)
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '');
  const year = t.match(/(19|20)\d{2}/);
  if (!year) return null;
  let month = 1;
  const numeric = t.match(/^(\d{1,2})\s*[/.-]/);
  if (numeric) {
    month = Math.min(Math.max(Number(numeric[1]), 1), 12);
  } else {
    const idx = MONTH_KEYS.findIndex((k) => t.startsWith(k));
    if (idx >= 0) month = idx + 1;
  }
  return { year: Number(year[0]), month };
}

const fmtPeriod = (d) => (d ? `${MONTHS[d.month - 1]}/${d.year}` : 'Até o momento');
const monthIndex = (d, now) => {
  const v = d || now;
  return v.year * 12 + v.month;
};
const fmtDuration = (months) => {
  if (months < 12) return `${months} ${months === 1 ? 'mês' : 'meses'}`;
  const y = Math.round(months / 12);
  return `${y} ${y === 1 ? 'ano' : 'anos'}`;
};

function articleSource(url) {
  const u = str(url).toLowerCase();
  if (u.includes('linkedin.com')) return 'LinkedIn';
  if (u.includes('medium.com')) return 'Medium';
  try {
    return new URL(url).hostname.replace(/^www\./, '');
  } catch {
    return 'site externo';
  }
}

function buildExperience(docs, now) {
  const roles = ofSite(docs)
    .map((d) => ({
      order: num(d.order),
      title: str(d.title),
      company: str(d.company),
      desc: str(d.description).replace(/"+$/, ''),
      start: parsePeriod(d.durationStart),
      end: parsePeriod(d.durationEnd),
      startText: str(d.durationStart),
      endText: str(d.durationEnd),
    }))
    .filter((r) => r.title || r.company)
    .sort((a, b) => b.order - a.order);

  const groups = [];
  for (const r of roles) {
    let g = groups[groups.length - 1];
    if (!g || g.company !== r.company) {
      g = { company: r.company, roles: [] };
      groups.push(g);
    }
    g.roles.push(r);
  }

  const expGroups = groups.map((g, gi) => {
    const first = g.roles[g.roles.length - 1];
    const last = g.roles[0];
    const color = COMPANY_COLORS[Math.min(gi, COMPANY_COLORS.length - 1)];
    const months = first.start ? monthIndex(last.end, now) - monthIndex(first.start, now) + 1 : 0;
    const n = g.roles.length;
    const durationText = months > 0 ? fmtDuration(months) : '';
    return {
      company: g.company,
      color,
      months: Math.max(months, 1),
      range: `${first.start ? fmtPeriod(first.start) : first.startText} – ${
        last.end || !last.endText ? fmtPeriod(last.end) : last.endText
      }`,
      meta: [n > 1 ? `${n} cargos` : '', durationText].filter(Boolean).join(' · '),
      roles: g.roles.map((r, i) => ({
        title: r.title,
        desc: r.desc,
        period: `${r.start ? fmtPeriod(r.start) : r.startText} – ${
          r.end || !r.endText ? fmtPeriod(r.end) : r.endText
        }`,
        current: !r.end,
        color,
        step: n > 1 ? `${String(n - i).padStart(2, '0')} / ${String(n).padStart(2, '0')}` : '',
      })),
    };
  });

  const starts = roles.filter((r) => r.start);
  const earliest = starts.length ? starts[starts.length - 1].start : null;
  const totalMonths = earliest && roles[0] ? monthIndex(roles[0].end, now) - monthIndex(earliest, now) + 1 : 0;
  const strip = [...expGroups].reverse().map((g, i, arr) => ({
    flex: g.months,
    color: g.color,
    label: g.company,
    rtl: i === arr.length - 1 && arr.length > 1,
  }));

  return {
    current: roles.find((r) => !r.end) || roles[0] || null,
    sinceYear: earliest ? earliest.year : null,
    expGroups,
    strip,
    careerSummary: totalMonths
      ? `${fmtDuration(totalMonths)} de carreira · ${groups.length} ${groups.length === 1 ? 'empresa' : 'empresas'}`
      : '',
  };
}

const toDate = (v) => {
  if (!v || v === 'null') return null;
  const d = v instanceof Date ? v : typeof v.toDate === 'function' ? v.toDate() : new Date(v);
  return Number.isNaN(d.getTime()) ? null : d;
};

function readingTime(markdown) {
  const words = String(markdown)
    .replace(/```[\s\S]*?```/g, ' ')
    .split(/\s+/)
    .filter(Boolean).length;
  return `${Math.max(1, Math.round(words / 200))} min de leitura`;
}

function buildArticles(docs, contentDocs = []) {
  const contentById = contentIndex(contentDocs, 'articleId');
  const usedSlugs = new Set();
  const all = ofSite(docs)
    .map((d) => {
      const id = str(d.id) || str(d._id);
      const contentDoc = contentById[id];
      let title = str(d.title);
      const en = str(d.language) === 'en' || /\(em ingl[eê]s\)/i.test(title);
      title = title.replace(/\s*\(em ingl[eê]s\)\s*/i, ' ').trim();
      const tags = [str(d.tag1), str(d.tag2)].filter(Boolean);
      // remove parâmetros de rastreamento (?trackingId=..., ?source=...) do link original
      const url = str(d.url).replace(/\?(trackingId|source)=[^#]*$/, '');
      const category = ['lead', 'tech'].includes(str(d.category))
        ? str(d.category)
        : url.toLowerCase().includes('linkedin.com')
          ? 'lead'
          : 'tech';
      const c = category === 'lead' ? PALETTE.violet : PALETTE.teal;
      let slug = '';
      if (contentDoc) slug = uniqueSlug(slugify(str(d.slug) || title) || id.toLowerCase(), usedSlugs);
      return {
        id,
        slug,
        pageUrl: slug ? `/artigos/${slug}/` : '',
        content: contentDoc ? str(contentDoc.content) : '',
        summary: str(d.summary),
        publishedAt: toDate(d.date),
        updatedAt: contentDoc ? toDate(contentDoc.updatedAt) : null,
        readingTime: contentDoc ? readingTime(contentDoc.content) : '',
        order: num(d.order),
        title,
        en,
        tags,
        url,
        src: articleSource(url),
        image: str(d.externalImageUrl) || str(d.firestorageImageUrl),
        category,
        catLabel: category === 'lead' ? 'Liderança & estratégia' : 'Tutorial técnico',
        mark: tags[0] || (category === 'lead' ? 'Liderança' : 'Técnico'),
        tint: c.tint,
        ink: c.ink,
      };
    })
    .filter((a) => a.title && a.url)
    .sort((a, b) => a.order - b.order);

  const counts = {
    todos: all.length,
    lead: all.filter((a) => a.category === 'lead').length,
    tech: all.filter((a) => a.category === 'tech').length,
  };
  return { featured: all[0] || null, rest: all.slice(1), counts, all, pages: all.filter((a) => a.pageUrl) };
}

/** Indexa os textos (articleContent / projectContent) pelo id do item. */
function contentIndex(contentDocs, idField) {
  const byId = {};
  for (const c of contentDocs || []) {
    const id = str(c[idField]) || str(c._id);
    if (id && str(c.content)) byId[id] = c;
  }
  return byId;
}

function uniqueSlug(base, used) {
  let slug = base;
  for (let n = 2; used.has(slug); n++) slug = `${base}-${n}`;
  used.add(slug);
  return slug;
}

function buildProjects(docs, contentDocs = []) {
  const contentById = contentIndex(contentDocs, 'projectId');
  const usedSlugs = new Set();
  return ofSite(docs)
    .map((d) => {
      const id = str(d.id) || str(d._id);
      const contentDoc = contentById[id];
      const slug = contentDoc ? uniqueSlug(slugify(str(d.slug) || str(d.title)) || id.toLowerCase(), usedSlugs) : '';
      const url = str(d.url);
      let github = str(d.urlGithub);
      let live = url;
      // Projeto cujo único link é o próprio GitHub: mostra como botão GitHub.
      if (!github && /github\.com/i.test(url)) {
        github = url;
        live = '';
      }
      const links = [];
      if (live) {
        links.push({ label: /play\.google\.com/i.test(live) ? 'Google Play' : 'Acessar', href: live });
      }
      if (github) links.push({ label: 'GitHub', href: github });
      return {
        id,
        slug,
        pageUrl: slug ? `/projetos/${slug}/` : '',
        content: contentDoc ? str(contentDoc.content) : '',
        summary: str(d.summary) || str(d.description),
        updatedAt: contentDoc ? toDate(contentDoc.updatedAt) : null,
        isGame: /play\.google\.com/i.test(live),
        github,
        live,
        order: num(d.order),
        title: str(d.title),
        desc: str(d.description),
        tags: [str(d.tag1), str(d.tag2), str(d.tag3)].filter(Boolean),
        image: str(d.externalImageUrl) || str(d.firestorageImageUrl),
        family: d.family === true,
        links,
      };
    })
    .filter((p) => p.title)
    .sort((a, b) => b.order - a.order);
}

function buildTechGroups(docs) {
  const techs = ofSite(docs).filter((t) => t.desktop !== false && str(t.technologyName));
  const of = (type) => techs.filter((t) => str(t.type).endsWith(type)).map((t) => str(t.technologyName));
  return [
    { title: 'Desenvolvimento', items: of('development') },
    { title: 'Data Science', items: of('dataScience') },
  ].filter((g) => g.items.length);
}

function buildSiteModel(raw, { now = new Date() } = {}) {
  const nowYm = { year: now.getFullYear(), month: now.getMonth() + 1 };
  const header = ofSite(raw.headerText)[0] || {};
  const aboutData = ofSite(raw.aboutMeData)[0] || {};

  const name = str(header.name) || 'Marcos H. Silva';
  const email = str(header.email);
  const socials = [
    { label: 'LinkedIn', short: 'in', href: str(header.urlLinkedin) },
    { label: 'GitHub', short: 'gh', href: str(header.urlGitGub) },
    { label: 'Medium', short: 'md', href: str(header.urlMedium) },
  ]
    .filter((s) => s.href)
    .map((s) => ({ ...s, value: prettyUrl(s.href) }));

  const contacts = [
    ...(email ? [{ label: 'E-mail', value: email, href: `mailto:${email}`, external: false }] : []),
    ...socials.map((s) => ({ label: s.label, value: s.value, href: s.href, external: true })),
  ];

  const experience = buildExperience(raw.experience, nowYm);
  const current = experience.current;

  return {
    name,
    tagline: str(header.nameComplement),
    email,
    photoUrl: str(aboutData.profilePhotoUrl),
    roleLine: [current && current.title, current && current.company, config.cityShort].filter(Boolean),
    jobTitle: current ? current.title : '',
    company: current ? current.company : '',
    introTexts: ofSite(raw.introText).map((t) => str(t.introText)).filter(Boolean),
    aboutTexts: ofSite(raw.aboutMeText).map((t) => str(t.aboutMeText)).filter(Boolean),
    techGroups: buildTechGroups(raw.aboutMeTechnology),
    experience,
    articles: buildArticles(raw.article, raw.articleContent),
    projects: buildProjects(raw.project, raw.projectContent),
    socials,
    contacts,
    generatedAt: now,
  };
}

function prettyUrl(href) {
  try {
    const u = new URL(href);
    const path = u.pathname.replace(/\/$/, '');
    if (u.hostname.includes('medium.com')) return path.replace(/^\//, '');
    if (u.hostname.includes('linkedin.com')) return path.replace(/^\//, '');
    return u.hostname.replace(/^www\./, '') + path;
  } catch {
    return href;
  }
}

module.exports = { buildSiteModel, parsePeriod };
