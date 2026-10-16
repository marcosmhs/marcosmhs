# Plano — site público estático gerado pelo admin

## Objetivo

- O site público (`www.marcosmhs.com.br/`) passa a ser **HTML estático**, indexável pelo Google e leve (~50 KB contra alguns MB do Flutter).
- O conteúdo continua sendo editado **100% pelo admin** em Flutter, que agora fica em `/admin/`.
- **Cada alteração salva no admin regera e republica o HTML** direto no Firebase, sem precisar do computador nem do Firebase CLI.

## Arquitetura

```
 Admin (Flutter, /admin/)                       Firebase
 ┌───────────────────────┐   salva    ┌──────────────────────┐
 │ formulário → Salvar   │──────────▶ │ Firestore            │
 │                       │            └──────────┬───────────┘
 │ SitePublisher         │  chama               │ lê
 │  (agrupa 3 s)         │──────────▶ ┌──────────▼───────────┐
 └───────────────────────┘            │ Cloud Function       │
                                      │ publishSite          │
                                      │  1. confere admin    │
                                      │  2. lê o Firestore   │
                                      │  3. gera index.html  │
                                      │     e sitemap.xml    │
                                      │  4. nova versão do   │
                                      │     Hosting (API)    │
                                      └──────────┬───────────┘
                                                 ▼
                                      ┌──────────────────────┐
                                      │ Firebase Hosting     │
                                      │  /        → HTML     │
                                      │  /admin/  → Flutter  │
                                      └──────────────────────┘
```

- A função cria uma versão nova do Hosting copiando **todos** os arquivos da versão no ar e trocando só `index.html` e `sitemap.xml`. O admin em `/admin/` não é afetado. A troca é atômica: o visitante vê a versão antiga ou a nova, nunca uma página quebrada.
- O mesmo código de geração (`functions/src/`) é usado pelo script local `scripts/build-hosting.js`, então um deploy feito pelo CLI publica exatamente o mesmo HTML.
- O status da última publicação fica em `siteMeta/publish` no Firestore e aparece no menu do admin ("Publicar site agora").

## O que foi implementado

| Parte | Arquivos |
|---|---|
| Geração do HTML (leiaute do Claude Design) | `functions/src/render.js`, `site-model.js`, `site-config.js` |
| Publicação no Hosting via API | `functions/src/hosting.js` |
| Cloud Function chamável `publishSite` | `functions/index.js` |
| Testes (datas, texto rico, modelo, API do Hosting simulada) | `functions/test/site.test.js` (`npm test`) |
| Build local (site + admin) | `scripts/build-hosting.js`, `site/static/` |
| Hosting: `/` estático, `/admin/` Flutter | `firebase.json` |
| Admin publica após salvar + botão manual | `lib/features/admin_area/site_publisher.dart`, os 8 formulários, `vertical_menu.dart` |
| Admin separado do site | `main.dart` (abre no login), `internal_landing_screen.dart`, `web/index.html` (`noindex`) |
| Campos novos editáveis no admin | Artigo: **Categoria** (Liderança/Técnico/Automática). Projeto: **Feito em família** |

Textos fixos do leiaute (títulos de seção, "Disponível para projetos", cidade) ficam em `functions/src/site-config.js`. Todo o resto vem do Firestore.

## Custos

Cloud Functions exige o plano **Blaze** (pago por uso). Para este uso, a conta deve ficar em zero ou em centavos:

| Item | Uso esperado | Franquia gratuita do Blaze |
|---|---|---|
| Cloud Functions | algumas publicações por mês, ~5 s cada | 2 milhões de chamadas/mês |
| Cloud Build (deploy da função) | ~1 min por deploy | 2.500 min/mês |
| Artifact Registry (imagem da função) | ~100–200 MB | 0,5 GB |
| Hosting | ~10 MB por versão | 10 GB armazenados, 360 MB/dia de tráfego |
| Firestore | ~10 leituras de coleção por publicação | 50 mil leituras/dia |

**O Blaze também resolve um problema atual:** o Cloud Storage deixou de funcionar em projetos Spark. Hoje a sua foto e as imagens enviadas pelo admin respondem `402`, tanto no site atual quanto no novo.

Recomendações:
- Criar um **alerta de orçamento** (ex.: R$ 10) em Google Cloud Console → Faturamento → Orçamentos e alertas.
- Em Hosting → Configurações, limitar o **histórico de versões** (ex.: 20), já que cada publicação cria uma versão.

## Passo a passo da primeira implantação

1. **Plano Blaze:** Console do Firebase → Uso e faturamento → Modificar plano. Em seguida, crie o alerta de orçamento.
2. **Instalar as dependências da função:**
   ```
   cd functions
   npm install
   npm test
   ```
3. **Build do admin** (no PowerShell; no Git Bash, prefixe com `MSYS_NO_PATHCONV=1`):
   ```
   flutter build web --release --no-tree-shake-icons --base-href /admin/
   ```
4. **Montar a pasta do Hosting:**
   ```
   node scripts/build-hosting.js
   ```
   Para pré-visualizar: `firebase emulators:start --only hosting` e abra http://127.0.0.1:5000.
5. **Primeiro deploy** (o Hosting precisa ter uma versão no ar antes de a função poder publicar):
   ```
   firebase deploy --only hosting,functions
   ```
6. **Permissão da função no Hosting:** no Google Cloud Console → IAM, dê o papel **Administrador do Firebase Hosting** (`roles/firebasehosting.admin`) à conta de serviço da função. Por padrão é `NÚMERO_DO_PROJETO-compute@developer.gserviceaccount.com`; o nome exato aparece em Cloud Run → `publishsite` → Segurança.
7. **Testar:** entre em `/admin/`, altere um texto, salve. O menu mostra "Publicando o site..." e depois "Publicado às HH:MM". Recarregue `/` (pode levar até 5 minutos por causa do cache do navegador; aba anônima mostra na hora).
8. **Google:** cadastre o domínio no Google Search Console e envie `https://www.marcosmhs.com.br/sitemap.xml`.

## Rotina depois da implantação

- **Alterar conteúdo:** só pelo admin. A publicação é automática.
- **Alterar o leiaute ou textos fixos:** edite `functions/src/render.js` ou `site-config.js`, rode `npm test` e `firebase deploy --only functions`, depois clique em "Publicar site agora" no admin.
- **Alterar o admin (Flutter):** passos 3, 4 e `firebase deploy --only hosting`.

## Ajustes de conteúdo pendentes (fazer pelo admin)

- Erros de digitação: "atráves", "Gerente de de", "Data Analist", "oferaçam", "pelos estratégia", "Randon Forest".
- O cargo aparece como "Gerente de Engenharia de Dados" na introdução e "Data & Analytics Manager" na experiência.
- Capas de artigos do LinkedIn expiram (a de "Você sabe como seu time realmente te vê?" já expirou). Envie a imagem pelo admin depois do Blaze.
- Marcar **Feito em família** em "Web App de mesada" e "João e Bento".

## Riscos e limites

- **Sessão expirada:** se o login do Firebase expirar e o admin ainda mostrar o usuário salvo localmente, a publicação falha com "Faça login no admin". Basta sair e entrar de novo.
- **Publicações simultâneas:** duas publicações seguidas são seguras; vence a última, e ambas leem os dados mais recentes.
- **Deploy pelo CLI:** sobrescreve o `index.html` com o gerado localmente. Como o script lê o mesmo Firestore, o resultado é igual; rode sempre `node scripts/build-hosting.js` antes.
- **Cabeçalhos HTTP:** `Cache-Control` e `X-Robots-Tag` do `firebase.json` não são aplicados pelo emulador local, então só dá para confirmá-los depois do deploy. O admin já está protegido contra indexação pela meta `noindex` e pelo `robots.txt`.
