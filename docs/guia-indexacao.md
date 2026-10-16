# Guia de indexação — Search Console e artigos internalizados

Ordem recomendada: **1 → 2 → 3 → 4 → 5**. Os passos 1 e 2 dependem do seu acesso ao Google e ao registro.br; os demais usam o admin.

---

## 1. Publicar esta versão (artigos dentro do site)

```
cd functions
npm install
npm test
cd ..
firebase deploy --only functions
flutter build web --release --no-tree-shake-icons --base-href /admin/
node scripts/build-hosting.js
firebase deploy --only hosting
```

> No Git Bash, prefixe o `flutter build` com `MSYS_NO_PATHCONV=1`.
> Não use `--preview-imports` no build que vai para o ar: ele é só para pré-visualizar (as imagens ficariam apontando para o Medium/LinkedIn).

Depois, no admin:

1. **Artigos → Importar textos do Medium/LinkedIn.** Importa os 11 artigos, copia as ~80 imagens para o seu Storage e preenche slug, resumo, data e capa. Leva alguns minutos.
2. Confira um ou dois em **Texto no site** (editor com pré-visualização) e ajuste o que quiser.
3. O site é republicado sozinho. Confira em `https://www.marcosmhs.com.br/artigos/random-forest-101-utilizando-r/`.

Se a importação der erro de permissão:
- **Firestore:** as regras precisam permitir que usuário logado grave em `articleContent`.
- **Storage:** as regras precisam permitir que usuário logado grave em `images/articles/**` (usado pelo botão "Imagem" do editor).
- **Função:** a conta de serviço da função precisa do papel *Administrador de objetos do Storage* (normalmente já tem, como Editor do projeto).

---

## 2. Cadastrar o site no Google Search Console

Use uma propriedade do tipo **Domínio**: ela cobre `www`, sem `www`, `http` e `https` de uma vez.

1. Acesse https://search.google.com/search-console e clique em **Adicionar propriedade**.
2. Escolha **Domínio**, digite `marcosmhs.com.br` e clique em **Continuar**.
3. O Google mostra um registro **TXT** parecido com `google-site-verification=AbCdEf...`. Copie e **deixe a janela aberta**.
4. Em outra aba, entre em https://registro.br → **Domínios** → `marcosmhs.com.br` → **DNS** → **Editar zona**.
   (O domínio usa o DNS do próprio Registro.br, então é ali mesmo.)
5. **Nova entrada**:
   - Tipo: **TXT**
   - Nome: deixe **em branco** (é o próprio `marcosmhs.com.br`)
   - Dados: cole o `google-site-verification=...`
   Salve e confirme a alteração da zona.
6. Espere de 15 minutos a 1 hora e clique em **Verificar** no Search Console. Se falhar, espere mais um pouco; a propagação no Registro.br costuma levar até 1 hora.

**Não apague esse TXT depois**: o Google confere de tempos em tempos.

### Logo após verificar

1. **Sitemaps** (menu lateral) → digite `sitemap.xml` → **Enviar**. Deve aparecer "Sucesso" com 12 URLs (a home + 11 artigos).
2. **Inspeção de URL** → cole `https://www.marcosmhs.com.br/` → **Solicitar indexação**. Repita para os 3 ou 4 artigos mais importantes (o Google limita a cerca de 10 pedidos por dia; os demais ele acha pelo sitemap).
3. Em **Configurações → Associações**, se usar Google Analytics no futuro, associe por ali.

### Bônus: Bing (2 minutos)

https://www.bing.com/webmasters → **Importar do Google Search Console**. Também cobre o DuckDuckGo e o ChatGPT Search, que usam o índice do Bing.

---

## 3. Fazer `marcosmhs.com.br` (sem www) funcionar

Hoje o endereço sem `www` não responde. Para redirecionar para o `www`:

1. Console do Firebase → **Hosting** → **Adicionar domínio personalizado**.
2. Digite `marcosmhs.com.br` e marque **Redirecionar para um domínio existente** → `www.marcosmhs.com.br`.
3. O Firebase mostra os registros (normalmente um **TXT** de verificação e um ou dois registros **A**). Adicione-os no **Editar zona** do registro.br, com o campo Nome em branco.
4. O certificado HTTPS é emitido sozinho em algumas horas.

---

## 4. Dizer ao Medium que o original agora é o seu site (canonical)

Sem isso, o Google tende a considerar o Medium como o original, porque ele publicou primeiro e tem mais autoridade.

Para cada artigo no Medium: abra a história → **⋯** → **Story settings** (ou **Mais configurações**) → **Advanced Settings** → **Customize Canonical Link** → marque *This story was originally published elsewhere* → cole o endereço novo → **Save canonical link**.

| Artigo no Medium | Canonical a configurar |
|---|---|
| A new approach for creating multilevel models | https://www.marcosmhs.com.br/artigos/a-new-approach-for-creating-multilevel-models/ |
| Análise de risco na liberação de empréstimos | https://www.marcosmhs.com.br/artigos/analise-de-risco-na-liberacao-de-emprestimos/ |
| Avaliação de Fundos Imobiliários com Python | https://www.marcosmhs.com.br/artigos/avaliacao-de-fundos-imobiliarios-com-python/ |
| Como encontrar a melhor estratégia de investimento… | https://www.marcosmhs.com.br/artigos/como-encontrar-a-melhor-estrategia-de-investimento/ |
| Complete Hive Example on Flutter App | https://www.marcosmhs.com.br/artigos/complete-hive-example-on-flutter-app/ |
| Random Forests 101 com R | https://www.marcosmhs.com.br/artigos/random-forest-101-utilizando-r/ |
| Modelo de regressão multinível | https://www.marcosmhs.com.br/artigos/regressao-multinivel/ |
| Stock prediction LSTM Neural Network function | https://www.marcosmhs.com.br/artigos/stock-prediction-lstm-neural-network-function/ |
| Utilização de Keras para predição com dados estruturados | https://www.marcosmhs.com.br/artigos/utilizacao-de-keras-para-predicao-com-dados-estruturados/ |

> Se você mudar o slug de algum artigo no admin, o endereço muda: atualize o canonical no Medium também.

**LinkedIn** não tem canonical. Para os dois artigos de lá, edite o artigo e acrescente no final: *"Publicado originalmente em [marcosmhs.com.br](link do artigo)"*. Isso ajuda o Google a ligar as duas versões e leva leitores para o seu site.

- https://www.marcosmhs.com.br/artigos/como-reinventamos-estrategia-de-dados-na-rentcars/
- https://www.marcosmhs.com.br/artigos/voce-sabe-como-seu-time-realmente-te-ve/

**Artigos novos**: escreva primeiro no admin (botão **Texto no site**), publique e só então republique no Medium com o canonical apontando para o site.

---

## 5. Páginas de projeto, feed RSS e links nos seus apps

### Publicar

```
cd functions && npm test && cd ..
firebase deploy --only functions
flutter build web --release --no-tree-shake-icons --base-href /admin/
node scripts/build-hosting.js
firebase deploy --only hosting
```

### Páginas de projeto (`/projetos/<slug>/`)

Cada projeto da lista no admin tem o botão **Texto no site**. A página só é publicada quando o projeto tem texto, para não criar páginas rasas que o Google ignora.

- **Importar do README do GitHub** funciona quando o README tem conteúdo de verdade: *TEB Mesada* e *That Exotic Bug Package* já podem ser importados.
- **Janela de Johari:** preencha o link do GitHub no admin (`https://github.com/marcosmhs/teb_janelajohari`); o README dela também é bom.
- **Escala, Planning Poker, CashTrack e o próprio site:** os READMEs são o modelo padrão do Flutter, e a importação recusa. Escreva no editor; uma estrutura que funciona bem:
  - *O problema* — por que você criou o app.
  - *Como funciona* — 3 a 5 passos, com uma ou duas capturas de tela (botão **Imagem**).
  - *Tecnologias* — Flutter, Firebase etc. e alguma decisão interessante.
  - *O que aprendi* — é o que diferencia o seu texto de uma descrição genérica.
- Marque **Feito em família** no Mesada e no João e Bento.

### Feed RSS (`/feed.xml`)

Gerado sozinho, com o texto completo dos artigos. Use em:
- Feedly e outros leitores (o navegador já encontra o feed pela página).
- Ferramentas de agendamento de posts no LinkedIn que leem RSS, para divulgar cada artigo novo.

### Links para o seu site nos apps

O Google só conta links que existem como `<a href>` no HTML. Em app Flutter, texto clicável desenhado na tela **não conta**.

| App | O que fazer |
|---|---|
| Janela de Johari | **Feito.** O nome no rodapé da landing virou link e o autor está ligado ao site. Publique com `bash scripts/build-hosting.sh && firebase deploy --only hosting` na pasta `teb_janelajohari`. |
| Escala, Planning Poker, CashTrack, Mesada | 1) No `web/index.html` de cada um, dentro do `<head>`, acrescente o bloco abaixo. 2) No rodapé ou na tela "Sobre", use o widget novo do `teb_package`: `const TebAuthorCredit(projectPath: '/projetos/<slug>/')`. Ele gera um `<a href>` real na web. |
| João e Bento | Na Google Play Console, acrescente ao final da descrição: "Criado por Marcos H. Silva — https://www.marcosmhs.com.br". Preencha também o campo **Site** do desenvolvedor. |
| READMEs do GitHub | Uma linha no final de cada README: `Feito por [Marcos H. Silva](https://www.marcosmhs.com.br)`. Vale também para o README do seu perfil (repositório `marcosmhs/marcosmhs`). |

Bloco para o `<head>` dos apps Flutter (troque o nome e a URL do app):

```html
<meta name="author" content="Marcos H. Silva">
<link rel="author" href="https://www.marcosmhs.com.br/">
<script type="application/ld+json">
{"@context":"https://schema.org","@type":"WebApplication","name":"Planning Poker","url":"https://planningpoker-teb.web.app/","applicationCategory":"BusinessApplication","operatingSystem":"Web","author":{"@type":"Person","@id":"https://www.marcosmhs.com.br/#pessoa","name":"Marcos H. Silva","url":"https://www.marcosmhs.com.br/"}}
</script>
```

---

## 6. Acompanhar

- **Search Console → Páginas**: mostra o que foi indexado e por quê não foi ("Rastreada, mas não indexada", "Cópia sem canonical" etc.). Os primeiros resultados aparecem em alguns dias; o quadro completo leva de 2 a 4 semanas.
- **Search Console → Desempenho**: consultas que trouxeram visitas. Use para ajustar títulos e resumos no admin.
- **Teste de resultados avançados** (https://search.google.com/test/rich-results): cole a URL de um artigo para confirmar que o Google lê os dados estruturados `BlogPosting` e a home como `ProfilePage`.
