# Briefing — Nova interface do site pessoal de Marcos H. Silva

## 1. Contexto

Site pessoal e portfólio profissional de **Marcos H. Silva**, gestor da área de dados (Data & Analytics Manager na Rentcars, Curitiba/BR). O site está em **www.marcosmhs.com.br**.

Hoje é uma página única (one-page) com rolagem por seções. Todo o conteúdo é cadastrado num painel administrativo e guardado num banco (Firestore). Por isso **a quantidade de itens em cada lista varia**: o layout precisa funcionar com 1 item ou com 15.

O site leva também a marca **"That Exotic Bug"**, o selo dos projetos pessoais de software de Marcos (apps, pacotes, um jogo). O nome da pessoa vem primeiro; "That Exotic Bug" é uma assinatura secundária.

## 2. Objetivo da nova interface

1. Passar credibilidade para **recrutadores, líderes de tecnologia e pares da área de dados**: alguém que lidera times de engenharia de dados e data science e ainda escreve código.
2. Deixar claros, em poucos segundos: quem é, o que faz hoje e como entrar em contato.
3. Mostrar a produção própria (artigos e projetos) como prova de competência técnica.
4. **Ser indexável pelo Google.** A nova interface será feita em **HTML semântico estático** (não em canvas), com um `h1` só e seções com `h2`, textos reais no HTML e links `<a href>` de verdade.

## 3. Público e tom

- Público: recrutadores, gestores de dados/tecnologia, comunidade de dados e desenvolvimento no Brasil.
- Idioma: **português do Brasil** (alguns artigos estão em inglês e são marcados assim).
- Tom: profissional, direto, humano. Nada de "rockstar"/"ninja". A ideia central do site é **"Criando valor através dos dados"**.

## 4. Estrutura da página (ordem atual, pode ser melhorada)

Navegação fixa no topo com âncoras para: **Sobre · Experiência · Artigos · Projetos · Contato**. Há ainda um acesso discreto à **área administrativa** (hoje é um ícone de usuário). Ele precisa existir, mas sem chamar atenção.

### 4.1 Hero (abertura)
- Nome: **Marcos H. Silva**
- Frase de posicionamento: **"Criando valor através dos dados"**
- 1 a 3 parágrafos curtos de introdução (conteúdo dinâmico, aceita **negrito** e quebra de linha). Conteúdo atual:
  - "Gerente de Engenharia de Dados na Rentcars, onde desafio meus conhecimentos e habilidades constantemente para impulsionar o sucesso da empresa."
  - "Acredito que a gestão orientada por dados é a chave para envolver e persuadir as pessoas. Como resultado, tenho me dedicado cada vez mais à geração de insights por meio de técnicas de Data Science, incluindo o uso de redes neurais e random forests para criar modelos preditivos que impactam positivamente o processo de tomada de decisões."
- Sugestão: incluir no hero chamadas para ação ("Ver projetos", "Entrar em contato") e os ícones das redes.

### 4.2 Sobre mim
- Foto de perfil (vem de URL; prever um placeholder caso não haja foto).
- Parágrafos de texto (dinâmico, aceita **negrito**, quebras de linha e listas simples). Conteúdo atual:
  - "Lidero equipes de alta performance na missão de transformar dados brutos em produtos de dados estratégicos que impulsionam o negócio. Com mais de 7 anos de experiência no Grupo Boticário e uma carreira dedicada à tecnologia, desenvolvi uma paixão por unir a excelência técnica da engenharia com a liderança humanizada para construir soluções inovadoras."
  - "Minhas principais conquistas incluem:
    - A **estruturação e liderança** de times de engenheiros e donos de produtos de dados, cobrindo o ciclo de vida completo da informação, desde a captura até a visualização final.
    - A liderança na implantação de **soluções omnichannel**, impactando a experiência de compra e comunicação em mais de 4.000 lojas e 500 franqueados.
    - A **prospecção e implementação de novas tecnologias** e fornecedores de TI para agregar inovação e dinamismo ao core business."
- Tecnologias, em **dois grupos** de etiquetas (chips):
  - **Desenvolvimento:** SQL Server, Dart, Flutter, C# (com foco em Unity 3D), Unity
  - **Data Science:** Redes Neurais LSTM, Modelos de Regressão Multinível, Google BigQuery, Data Wrangling

### 4.3 Experiência profissional
Linha do tempo, da mais recente para a mais antiga. Cada item tem: **cargo, empresa, período (início – fim ou "Até o momento"), descrição curta (1 frase), ícone e cor do ícone** (cadastrados no admin). Hoje são 7 itens, 6 deles na mesma empresa. A linha do tempo deve deixar visível a **progressão de carreira dentro do Grupo Boticário**.

| Período | Cargo | Empresa | Descrição |
|---|---|---|---|
| Mar/2026 – Até o momento | Data & Analytics Manager | Rentcars | Gestão do time de engenharia de dados e data science responsável pela estratégia de dados da empresa |
| Fev/2024 – Fev/2026 | Coordenador de Engenharia de Dados | Grupo Boticário | Gestão do time de engenharia de dados responsável pelos dados utilizados para otimização do portfólio |
| Abr/2023 – Jan/2024 | Data Product Specialist | Grupo Boticário | Ajudando na governança e utilização de dados do Grupo Boticário |
| Abr/2022 – Abr/2023 | Data Analyst Specialist | Grupo Boticário | Utilizando dados para medir a performance de processos e entregas dos times de tecnologia |
| Fev/2019 – Mar/2022 | Trade Marketing Specialist | Grupo Boticário | Criando meios para que as lojas de O Boticário ofereçam uma experiência incrível para seus clientes |
| Set/2017 – Jan/2019 | Business Relationship Management | Grupo Boticário | Ajudando os times de negócio a entregar o melhor de si através da tecnologia |
| Jul/2013 – Ago/2017 | Analista de Projetos e Dados | Grupo Marista | Ajudando as 23 escolas do Grupo Marista a oferecer um melhor serviço para seus alunos e pais |

### 4.4 Artigos publicados
Grade de cards. Cada artigo tem: **título, até 2 tags, imagem de capa (opcional, pode falhar ao carregar), link externo** (LinkedIn ou Medium) e indicação "(em inglês)" quando for o caso. Hoje são 11. O artigo mais recente é o destaque:

- **De 1 ano para 3 dias: como reinventamos a estratégia de Data na Rentcars** — AI, DataViz (LinkedIn) ← *destaque*
- Você sabe como seu time realmente te vê? — Liderança, Desenvolvimento (LinkedIn)
- Complete Hive Example on Flutter App (em inglês) — Flutter, Hive
- A new approach for creating multilevel models (em inglês) — RStudio, Modelagem Multinível
- Como encontrar a melhor estratégia de investimento — Python, Investimentos
- Avaliação de Fundos Imobiliários com Python — Python, Fundos Imobiliários
- Stock prediction LSTM Neural Network function (em inglês) — RStudio, Redes Neurais
- Análise de risco na liberação de empréstimos — RStudio, Random Forest
- Utilização de Keras para predição com dados estruturados — Python, Keras
- Regressão Multinível — RStudio, Modelos GLM
- Random Forest 101 utilizando R — RStudio, Random Forest

Pedidos para esta seção:
- Os artigos se dividem em dois grupos: **liderança/estratégia de dados** (os recentes) e **tutoriais técnicos** (Python/R/Flutter). Vale separar visualmente ou permitir filtro por tag.
- Card com **estado sem imagem** bonito (muitas capas estão faltando ou expiram). A capa não pode ser obrigatória.
- Indicar que o link abre em site externo.

### 4.5 Projetos
Grade de cards. Cada projeto tem: **título, descrição (1 a 3 frases), até 3 tags, imagem (opcional), link "Acessar" (opcional) e link "GitHub" (opcional)**. Hoje são 8:

- **CashTrack** — Web app simples e direto para acompanhar seus gastos no celular. Flutter, Firebase. Acessar + GitHub
- **Web App de atividades e mesada dos filhos** — Organiza as tarefas de casa do filho e o valor da mesada do mês. Flutter, Firebase. Acessar + GitHub
- **Janela de Johari** — Site para aplicar a dinâmica da Janela de Johari no seu time. Dinâmica, Pessoas. Acessar
- **That Exotic Bug Package** — Pacote de componentes Flutter para simplificar e agilizar o desenvolvimento. Flutter, Dart. GitHub
- **www.marcosmhs.com.br** — Este site. Flutter, Dart, Firebase. Acessar + GitHub
- **Planning Poker Web App** — Apoio às plannings de times ágeis que usam Scrum. Flutter, Dart. Acessar + GitHub
- **Escala Web App** — Criar, gerenciar e compartilhar escalas de trabalho (hospitais, laboratórios). Flutter, Dart. Acessar + GitHub
- **João e Bento** — Jogo para celulares e tablets em que um menino salva o irmão de vilões; feito como presente de aniversário para o filho. Unity, C#. Google Play

Pedidos: os botões aparecem só quando o link existe. O card não pode ficar desalinhado quando falta um deles. Projetos pessoais e de família (mesada, jogo) humanizam o perfil, então vale manter esse tom.

### 4.6 Contato
- Título atual: "Vamos conversar?"
- Canais: **E-mail** (marcosmhs@live.com) · **LinkedIn** (linkedin.com/in/marcosmhs) · **GitHub** (github.com/marcosmhs) · **Medium** (@marcosmhs)
- Texto: "Interessado em colaborar ou discutir oportunidades? Estou sempre aberto a conversas sobre dados, tecnologia e inovação."
- Informações: Curitiba, Brasil · Disponível para projetos

### 4.7 Rodapé (não existe hoje, sugerido)
Nome, redes, "© ano", assinatura "That Exotic Bug" e número de versão do site em tamanho pequeno (hoje a versão aparece no topo, abaixo do título).

## 5. Identidade visual atual (ponto de partida, pode evoluir)

- Fonte: **Poppins** (Google Fonts).
- Cores: primária `#667EEA` (azul-violeta), secundária `#764BA2` (roxo), fundo `#F9FAFB`, texto `#1F2937`, texto secundário `#4B5563`, cards brancos com sombra suave.
- Hero com gradiente diagonal primária → secundária e texto branco.
- Cards sobem levemente com sombra maior ao passar o mouse (hover).

Pode propor uma identidade nova. Ela deve continuar sóbria e tecnológica, com cara de "dados". O roxo/violeta pode ficar ou sair.

## 6. Problemas da interface atual que a nova deve resolver

1. A abertura (hero) é só texto sobre gradiente: falta foto, chamada para ação e hierarquia. A foto só aparece na seção seguinte.
2. A barra do topo mostra "That Exotic Bug" como título principal, o que confunde de quem é o site.
3. A cor dos cards de artigos e projetos é sorteada, sem significado. A cor deveria comunicar algo (categoria/tag) ou ser neutra.
4. Os contatos são 4 cards numa grade de 3 colunas, e o último fica sozinho na linha.
5. A experiência é uma lista de cards iguais, sem sensação de linha do tempo ou progressão.
6. Não há rodapé nem um caminho claro para o "próximo passo" (contato) ao longo da página.
7. As seções têm todas o mesmo peso visual; falta ritmo (alternância de fundos, densidade).

## 7. Requisitos técnicos e de comportamento

- **Responsivo**, mobile-first. Pontos de quebra usados hoje: ~768px (tablet) e ~1024px (desktop). Largura máxima do conteúdo: ~1280px.
- No mobile, a navegação vira menu (hambúrguer), que inclui o item de acesso ao admin.
- Navegação por âncoras com rolagem suave; indicar a seção ativa no menu.
- **SEO e semântica:** `header`, `nav`, `main`, `section` com `id` (`#sobre`, `#experiencia`, `#artigos`, `#projetos`, `#contato`), `footer`; um `h1` (o nome); imagens com `alt`; links externos com `rel="noopener"`.
- **Acessibilidade:** contraste AA, foco visível no teclado, área de toque ≥ 44px, respeitar `prefers-reduced-motion`.
- **Desempenho:** página leve, sem dependência de framework pesado no carregamento; imagens com `loading="lazy"`.
- Modo escuro: opcional, desejável.
- Todo conteúdo das seções 4.1 a 4.5 é **dinâmico**. Use os textos acima como conteúdo real, mas trate cada lista como repetível.

## 8. Entregáveis esperados

1. Página completa em desktop e mobile, com todas as seções preenchidas com o conteúdo real acima.
2. Estados: card sem imagem, projeto sem GitHub / sem link, lista com 1 item, hover e foco.
3. Tokens de design (cores, tipografia, espaçamentos, raios, sombras) para implementação.
