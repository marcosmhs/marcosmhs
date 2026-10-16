const crypto = require('crypto');
const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineString } = require('firebase-functions/params');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');

const config = require('./src/site-config');
const { buildSiteFiles, GENERATED_PREFIXES } = require('./src/site-files');
const { publishFiles } = require('./src/hosting');
const {
  fetchArticle,
  fetchGithubReadme,
  htmlToMarkdown,
  rehostImages,
  firstParagraph,
  slugify,
  BROWSER_UA,
} = require('./src/article-import');

admin.initializeApp();
const db = admin.firestore();

// Id do site no Firebase Hosting; o padrão é o próprio id do projeto.
const HOSTING_SITE = defineString('HOSTING_SITE', { default: 'omarcosmhs' });

async function assertAdmin(auth) {
  if (!auth) throw new HttpsError('unauthenticated', 'Faça login no admin novamente.');
  const byUid = await db.collection('user').doc(auth.uid).get();
  if (byUid.exists) return;
  const email = auth.token.email;
  if (email) {
    const byEmail = await db.collection('user').where('email', '==', email).limit(1).get();
    if (!byEmail.empty) return;
  }
  throw new HttpsError('permission-denied', 'Usuário sem permissão de administrador.');
}

async function loadRawData() {
  const raw = {};
  await Promise.all(
    config.collections.map(async (name) => {
      const snap = await db.collection(name).get();
      raw[name] = snap.docs.map((d) => ({ _id: d.id, ...d.data() }));
    }),
  );
  return raw;
}

exports.publishSite = onCall(
  { region: 'us-central1', timeoutSeconds: 120, memory: '512MiB', maxInstances: 2 },
  async (request) => {
    await assertAdmin(request.auth);
    const statusRef = db.collection('siteMeta').doc('publish');
    const startedAt = new Date();
    const by = request.auth.token.email || request.auth.uid;
    await statusRef.set({ status: 'publishing', startedAt, by }, { merge: true });

    try {
      const { files, model } = buildSiteFiles(await loadRawData(), { now: startedAt });
      const { access_token: token } = await admin.credential.applicationDefault().getAccessToken();
      const result = await publishFiles({
        site: HOSTING_SITE.value(),
        token,
        files,
        prune: GENERATED_PREFIXES,
        message: `Publicado pelo admin (${by})`,
      });
      const summary = { ...result, articlePages: model.articles.pages.length };
      await statusRef.set({ status: 'done', finishedAt: new Date(), error: '', ...summary }, { merge: true });
      logger.info('Site publicado', summary);
      return { ok: true, publishedAt: startedAt.toISOString(), ...summary };
    } catch (e) {
      logger.error('Falha ao publicar o site', e);
      await statusRef.set({ status: 'error', finishedAt: new Date(), error: String(e.message || e) }, { merge: true });
      throw new HttpsError('internal', `Falha ao publicar o site: ${e.message || e}`);
    }
  },
);

const IMAGE_EXT = { 'image/jpeg': 'jpg', 'image/png': 'png', 'image/gif': 'gif', 'image/webp': 'webp', 'image/svg+xml': 'svg' };

/** Baixa a imagem e grava no Storage com token de download (mesmo formato de URL que o admin usa). */
async function copyImageToStorage(url, folder) {
  const res = await fetch(url, { headers: { 'User-Agent': BROWSER_UA } });
  if (!res.ok) throw new Error(`Não consegui baixar a imagem ${url} (HTTP ${res.status}).`);
  const contentType = (res.headers.get('content-type') || 'image/jpeg').split(';')[0].trim();
  const bytes = Buffer.from(await res.arrayBuffer());
  const name = crypto.createHash('sha1').update(url).digest('hex').slice(0, 16);
  const path = `${folder}/${name}.${IMAGE_EXT[contentType] || 'jpg'}`;
  const bucket = admin.storage().bucket();
  const token = crypto.randomUUID();
  await bucket.file(path).save(bytes, {
    resumable: false,
    metadata: { contentType, cacheControl: 'public, max-age=31536000', metadata: { firebaseStorageDownloadTokens: token } },
  });
  return `https://firebasestorage.googleapis.com/v0/b/${bucket.name}/o/${encodeURIComponent(path)}?alt=media&token=${token}`;
}

const isEmptyDate = (v) => !v || v === 'null';

const KINDS = {
  article: { collection: 'article', contentCollection: 'articleContent', idField: 'articleId', label: 'Artigo' },
  project: { collection: 'project', contentCollection: 'projectContent', idField: 'projectId', label: 'Projeto' },
};

/** Busca o texto na origem: Medium/LinkedIn para artigos, README do GitHub para projetos. */
async function fetchFromOrigin(kind, item) {
  if (kind === 'article') {
    const fetched = await fetchArticle(item.url);
    return { ...fetched, markdown: htmlToMarkdown(fetched.html) };
  }
  const repoUrl = item.urlGithub || (/github\.com/i.test(item.url || '') ? item.url : '');
  return fetchGithubReadme(repoUrl);
}

async function importContent({ kind, id, overwrite }) {
  const cfg = KINDS[kind];
  if (!cfg) throw new HttpsError('invalid-argument', 'Tipo de conteúdo inválido.');
  if (!id) throw new HttpsError('invalid-argument', 'Informe o item.');

  const itemRef = db.collection(cfg.collection).doc(id);
  const contentRef = db.collection(cfg.contentCollection).doc(id);
  const [itemSnap, contentSnap] = await Promise.all([itemRef.get(), contentRef.get()]);
  if (!itemSnap.exists) throw new HttpsError('not-found', `${cfg.label} não encontrado. Salve a lista antes.`);
  const item = itemSnap.data();
  if (contentSnap.exists && contentSnap.data().content && !overwrite) {
    throw new HttpsError('already-exists', 'Já existe texto no site. Confirme para substituir.');
  }

  let fetched;
  try {
    fetched = await fetchFromOrigin(kind, item);
  } catch (e) {
    throw new HttpsError('failed-precondition', e.message);
  }

  const folder = `images/${cfg.collection}s/${id}/content`;
  const warnings = [];
  // Uma imagem que não baixa não deve derrubar a importação: mantém o link original e avisa.
  const { markdown, count } = await rehostImages(fetched.markdown, async (url) => {
    try {
      return await copyImageToStorage(url, folder);
    } catch (e) {
      warnings.push(e.message);
      return url;
    }
  });

  const update = {};
  if (!item.slug) update.slug = slugify(item.title || fetched.title);
  if (kind === 'article') {
    if (!item.summary) update.summary = firstParagraph(markdown);
    if (isEmptyDate(item.date) && fetched.publishedAt) update.date = fetched.publishedAt;
    // Capas do LinkedIn expiram: guarda uma cópia no Storage. A URL lida agora na página
    // (fetched.cover) é a mais nova; a gravada no admin pode já ter expirado.
    const needsCover = /licdn\.com/.test(item.externalImageUrl || '') || (!item.externalImageUrl && !item.firestorageImageUrl);
    const candidates = [...new Set([fetched.cover, item.externalImageUrl].filter((u) => u && /licdn\.com/.test(u)))];
    if (needsCover && candidates.length) {
      for (const coverUrl of candidates) {
        try {
          update.firestorageImageUrl = await copyImageToStorage(coverUrl, `images/articles/${id}`);
          update.externalImageUrl = '';
          break;
        } catch (e) {
          warnings.push(`Capa: ${e.message}`);
        }
      }
    }
  }

  const now = new Date().toISOString();
  await contentRef.set({
    [cfg.idField]: id,
    siteName: config.siteName,
    content: markdown,
    source: fetched.source,
    importedFrom: kind === 'article' ? item.url : item.urlGithub || item.url,
    importedAt: now,
    updatedAt: now,
  });
  if (Object.keys(update).length) await itemRef.update(update);

  logger.info('Conteúdo importado', { kind, id, source: fetched.source, images: count, chars: markdown.length, warnings });
  return { ok: true, title: fetched.title, images: count - warnings.filter((w) => !w.startsWith('Capa')).length, chars: markdown.length, warnings, ...update };
}

const IMPORT_OPTIONS = { region: 'us-central1', timeoutSeconds: 300, memory: '512MiB', maxInstances: 2 };

/** Importa o texto de um artigo (Medium/LinkedIn) ou projeto (README do GitHub) e copia as imagens. */
exports.importContent = onCall(IMPORT_OPTIONS, async (request) => {
  await assertAdmin(request.auth);
  const { kind, id, overwrite = false } = request.data || {};
  return importContent({ kind, id, overwrite });
});

/** Compatibilidade: mesma coisa que importContent({ kind: 'article' }). */
exports.importArticle = onCall(IMPORT_OPTIONS, async (request) => {
  await assertAdmin(request.auth);
  const { articleId, overwrite = false } = request.data || {};
  return importContent({ kind: 'article', id: articleId, overwrite });
});
