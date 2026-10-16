// Publica arquivos no Firebase Hosting pela API REST, sem o Firebase CLI.
// Cria uma versão nova com todos os arquivos da versão no ar, trocando só os informados
// (o admin em /admin/ e os demais arquivos continuam iguais), finaliza e libera.
// Docs: https://firebase.google.com/docs/hosting/api-deploy

const crypto = require('crypto');
const zlib = require('zlib');

const API = 'https://firebasehosting.googleapis.com/v1beta1';

async function api(token, method, path, body) {
  const res = await fetch(path.startsWith('http') ? path : `${API}/${path}`, {
    method,
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: body === undefined ? undefined : JSON.stringify(body),
  });
  const text = await res.text();
  if (!res.ok) throw new Error(`Hosting API ${method} ${path}: ${res.status} ${text}`);
  return text ? JSON.parse(text) : {};
}

async function listFiles(token, versionName) {
  const files = {};
  let pageToken = '';
  do {
    const q = new URLSearchParams({ pageSize: '1000', status: 'ACTIVE' });
    if (pageToken) q.set('pageToken', pageToken);
    const page = await api(token, 'GET', `${versionName}/files?${q}`);
    for (const f of page.files || []) files[f.path] = f.hash;
    pageToken = page.nextPageToken || '';
  } while (pageToken);
  return files;
}

/**
 * @param {object} opts
 * @param {string} opts.site      id do site no Hosting (ex.: "omarcosmhs")
 * @param {string} opts.token     access token OAuth com escopo cloud-platform/firebase.hosting
 * @param {Record<string,string|Buffer>} opts.files  caminho ("/index.html") -> conteúdo
 * @param {string} [opts.message] mensagem da release (aparece no console do Hosting)
 * @param {string[]} [opts.prune] prefixos ("/artigos/") cujos arquivos antigos são descartados
 *                                antes de incluir os novos
 */
async function publishFiles({ site, token, files, message, prune = [] }) {
  const live = await api(token, 'GET', `sites/${site}/channels/live`);
  const current = live.release && live.release.version;
  if (!current) throw new Error('O site ainda não tem versão no ar; faça o primeiro deploy com o Firebase CLI.');

  const manifest = await listFiles(token, current.name);
  for (const path of Object.keys(manifest)) {
    if (prune.some((prefix) => path.startsWith(prefix))) delete manifest[path];
  }
  const uploads = {};
  for (const [path, content] of Object.entries(files)) {
    const gz = zlib.gzipSync(Buffer.isBuffer(content) ? content : Buffer.from(content, 'utf8'), { level: 9 });
    const hash = crypto.createHash('sha256').update(gz).digest('hex');
    manifest[path] = hash;
    uploads[hash] = gz;
  }

  const version = await api(token, 'POST', `sites/${site}/versions`, { config: current.config || {} });
  const populated = await api(token, 'POST', `${version.name}:populateFiles`, { files: manifest });
  for (const hash of populated.uploadRequiredHashes || []) {
    const gz = uploads[hash];
    if (!gz) throw new Error(`O Hosting pediu um arquivo que não está na versão atual (hash ${hash}).`);
    const res = await fetch(`${populated.uploadUrl}/${hash}`, {
      method: 'POST',
      headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/octet-stream' },
      body: gz,
    });
    if (!res.ok) throw new Error(`Upload ${hash}: ${res.status} ${await res.text()}`);
  }

  await api(token, 'PATCH', `${version.name}?update_mask=status`, { status: 'FINALIZED' });
  const release = await api(
    token,
    'POST',
    `sites/${site}/releases?versionName=${encodeURIComponent(version.name)}`,
    message ? { message } : {},
  );
  return { version: version.name, release: release.name, files: Object.keys(manifest).length };
}

module.exports = { publishFiles };
