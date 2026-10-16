// Configuração do site público que não vem do Firestore.
// Tudo o que é conteúdo editável fica no admin; aqui ficam só constantes de estrutura.

module.exports = {
  siteName: 'marcosmhs',
  siteUrl: 'https://www.marcosmhs.com.br',
  // Outras formas do nome usadas nos perfis (Medium usa o nome completo); ajudam o Google a ligar os perfis.
  alternateNames: ['Marcos Henrique da Silva', 'Marcos Silva'],
  city: 'Curitiba, Brasil',
  cityShort: 'Curitiba, BR',
  brand: 'That Exotic Bug',
  availability: 'Disponível para projetos',

  // Textos de apoio do leiaute (títulos de seção e frases curtas).
  copy: {
    headerTag: '/ dados',
    heroBadgeTitle: 'Dados & tecnologia',
    aboutHeadline: 'Excelência técnica de engenharia com liderança humanizada.',
    experienceTitle: 'Trajetória profissional',
    articlesTitle: 'Artigos publicados',
    projectsTitle: 'Projetos pessoais',
    projectsIntro:
      'Apps, pacotes e até um jogo, publicados sob o selo <strong>That Exotic Bug</strong>. Alguns nasceram dentro de casa.',
    contactTitle: 'Vamos conversar?',
    contactText:
      'Interessado em colaborar ou discutir oportunidades? Estou sempre aberto a conversas sobre dados, tecnologia e inovação.',
  },

  // Coleções do Firestore lidas para montar o site (ver lib/consts.dart).
  collections: [
    'headerText',
    'introText',
    'aboutMeData',
    'aboutMeText',
    'aboutMeTechnology',
    'experience',
    'article',
    'project',
    'articleContent',
    'projectContent',
  ],
};
