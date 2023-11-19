import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HeaderText {
  final String text;
  final bool mobile;
  final bool desktop;

  HeaderText({required this.text, this.mobile = true, this.desktop = true});
}

class TechnologiesText {
  final String text;
  final bool mobile;
  final bool desktop;

  TechnologiesText({required this.text, this.mobile = true, this.desktop = true});
}

class Article {
  final String title;
  final String tag1;
  final String tag2;
  final String date;
  final String url;
  final String imagePath;

  Article({
    required this.title,
    required this.tag1,
    required this.tag2,
    required this.date,
    required this.url,
    required this.imagePath,
  });
}

class Experience {
  final String title;
  final String company;
  final String description;
  final String duration;
  final int icon;
  final Color color;

  Experience({
    this.title = '',
    this.company = '',
    this.description = '',
    this.duration = '',
    this.icon = 0,
    this.color = Colors.red,
  });
}

class Project {
  final String imagePath;
  final String githubUrl;
  final String accessUrl;
  final String title;
  final String description;
  final String tech1;
  final String tech2;
  final String tech3;

  Project({
    required this.imagePath,
    required this.githubUrl,
    required this.accessUrl,
    required this.title,
    required this.description,
    required this.tech1,
    required this.tech2,
    required this.tech3,
  });
}

class Data {
  late List<HeaderText> headerText;
  late List<String> about;

  late String technologiesDevelopmentTitle;
  late List<TechnologiesText> technologiesDevelopment;
  late String technologiesDataScienceTitle;
  late List<TechnologiesText> technologiesDataScience;

  late List<Experience> experiences;
  late List<Article> articles;
  late List<Project> projects;

  Data() {
    _header();

    _about();

    _experience();

    _articles();

    _projects();
  }

  void _header() {
    headerText = [];

    headerText.add(
      HeaderText(
        desktop: true,
        mobile: false,
        text: "Acredito que a gestão orientada por dados é a chave para envolver e persuadir as pessoas."
            "Como resultado, tenho me dedicado cada vez mais à geração de insights por meio de técnicas"
            "de Data Science, incluindo o uso de redes neurais e random forests para criar modelos"
            "preditivos que impactam positivamente o processo de tomada de decisões.",
      ),
    );

    headerText.add(
      HeaderText(
        desktop: true,
        mobile: true,
        text: "Atualmente sou Data PO no Grupo Boticário, onde desafio constantemente meus"
            "conhecimentos e habilidades para impulsionar o sucesso da empresa.",
      ),
    );
  }

  void _about() {
    about = [];

    about.add("Entusiasta da tecnologia, apaixonado pela inovação especialmente pela gestão de requisitos e "
        "curadoria de produtos (também conhecido como Product Owner - PO).");

    about.add("Acredito que a gestão orientada por dados é a chave para envolver e persuadir as pessoas. "
        "Como resultado, tenho me dedicado cada vez mais à geração de insights por meio de técnicas "
        "de Data Science, incluindo o uso de redes neurais e random forests para criar modelos"
        " preditivos que impactam positivamente o processo de tomada de decisões.");

    about.add("Aqui estão algumas das tecnologias e áreas onde já trabalhei:\n\n");

    technologiesDevelopmentTitle = "Desenvolvimento";
    technologiesDevelopment = [];
    technologiesDevelopment.add(TechnologiesText(text: "Dart"));
    technologiesDevelopment.add(TechnologiesText(text: "Flutter"));
    technologiesDevelopment.add(TechnologiesText(text: "C#, com foco em Unity 3D", mobile: false));
    technologiesDevelopment.add(TechnologiesText(text: "C#", desktop: false));
    technologiesDevelopment.add(TechnologiesText(text: "Unity", desktop: false));
    technologiesDevelopment.add(TechnologiesText(text: "SQL Server"));
    technologiesDevelopment.add(TechnologiesText(text: "Google Big Query"));

    technologiesDataScienceTitle = "Data Science";
    technologiesDataScience = [];
    technologiesDataScience.add(TechnologiesText(text: "Data Science"));
    technologiesDataScience.add(TechnologiesText(text: "Data Wrangling"));
    technologiesDataScience.add(TechnologiesText(text: "Modelos de Regressão\nSimples e multinível", mobile: false));
    technologiesDataScience.add(TechnologiesText(text: "Modelos GLM", desktop: false));
    technologiesDataScience.add(TechnologiesText(text: "Redes Neurais LSTM"));
  }

  void _experience() {
    experiences = [];

    experiences.add(Experience(
      title: "Data Product Specialist",
      company: "Grupo Boticário",
      description: "Ajudando na governança e utilização de dados do Grupo Boticário",
      duration: "Desde abril/2023",
      icon: FontAwesomeIcons.database.codePoint,
      color: Colors.pink,
    ));

    experiences.add(Experience(
      title: "Data Analist Specialist",
      company: "Grupo Boticário",
      description: "Utilizando dados para criar medir a performance de processos e entregas dos times de tecnologia",
      duration: "Abril/2022 à abril/2023",
      icon: FontAwesomeIcons.database.codePoint,
      color: Colors.red,
    ));
    experiences.add(Experience(
      title: "Trade Marketing Specialist",
      company: "Grupo Boticário",
      description: "Criando meios para que as lojas de O Boticário oferaçam uma experiência incrível para seus clientes",
      duration: "Fevereiro/2019 à Março/2022",
      icon: FontAwesomeIcons.store.codePoint,
      color: Colors.brown,
    ));

    experiences.add(Experience(
      title: "Business Relationship Management",
      company: "Grupo Boticário",
      description: "Ajudando os times de negócio à entregar o melhor de si através da tecnologia",
      duration: "Setembro/2017 à Janeiro/2019",
      icon: FontAwesomeIcons.laptopCode.codePoint,
      color: Colors.deepOrange,
    ));

    experiences.add(Experience(
      title: "Analista de Projetos e dados",
      company: "Grupo Marista",
      description: "Ajudando as 23 escolas do Grupo Marista oferecer um melhor serviço para seus alunos e pais",
      duration: "Julho/2013 à Agosto/2017",
      icon: FontAwesomeIcons.school.codePoint,
      color: Colors.deepPurple,
    ));
  }

  void _articles() {
    articles = [];

    articles.add(Article(
      imagePath: "assets/images/articles/complete-hive-example-on-flutter-app-with-full-code.png",
      title: "Complete Hive Example on Flutter App (em inglês)",
      url: "https://medium.com/@marcosmhs/complete-hive-example-on-flutter-app-with-full-code-b22115114da9",
      tag1: "Flutter",
      tag2: "Hive",
      date: "01/01/2023",
    ));
    articles.add(Article(
      imagePath: "assets/images/articles/a-new-approach-for-creating-multilevel-models.png",
      title: "A new approach for creating multilevel models (em inglês)",
      url: "https://medium.com/@marcosmhs/a-new-approach-for-creating-multilevel-models-865690bcccd7",
      tag1: "RStudio",
      tag2: "Modelagem Multinível",
      date: "01/01/2023",
    ));
    articles.add(Article(
      imagePath:
          "assets/images/articles/como-encontrar-a-melhor-estrategia-de-investimento-de-uma-carteira-utilizando-python.png",
      title: "Como encontrar a melhor estratégia de investimento\nde uma carteira utilizando Python",
      url:
          "https://medium.com/@marcosmhs/como-encontrar-a-melhor-estrat%C3%A9gia-de-investimento-de-uma-carteira-utilizando-python-ef9894ce69fe",
      tag1: "Python",
      tag2: "Investimentos",
      date: "01/01/2023",
    ));
    articles.add(Article(
      imagePath: "assets/images/articles/avaliacao-de-fundos-imobiliarios-com-python.png",
      title: "Avaliação de Fundos Imobiliários com Python",
      url: "https://medium.com/@marcosmhs/avalia%C3%A7%C3%A3o-de-fundos-imobili%C3%A1rios-com-python-c74944fe7b98",
      tag1: "Python",
      tag2: "Fundos Imobiliários",
      date: "01/01/2023",
    ));
    articles.add(Article(
      imagePath: "assets/images/articles/stock-prediction-lstm-neural-network-function.png",
      title: "Stock prediction LSTM Neural Network function (em inglês)",
      url: "https://medium.com/@marcosmhs/stock-prediction-lstm-neural-network-function-d76bd504713e",
      tag1: "RStudio",
      tag2: "Redes Neurais",
      date: "01/01/2023",
    ));
    articles.add(Article(
      imagePath: "assets/images/articles/analise-de-risco-na-liberacao-de-emprestimos.png",
      title: "Análise de risco na liberação de empréstimos",
      url: "https://medium.com/@marcosmhs/an%C3%A1lise-de-risco-na-libera%C3%A7%C3%A3o-de-empr%C3%A9stimos-61ad2437ffd9",
      tag1: "RStudio",
      tag2: "Randon Forest",
      date: "01/01/2023",
    ));
    articles.add(Article(
      imagePath: "assets/images/articles/utilizacao-de-keras-para-predicao-com-dados-estruturados.png",
      title: "Utilização de Keras para predição com dados estruturados",
      url:
          "https://medium.com/@marcosmhs/utiliza%C3%A7%C3%A3o-de-keras-para-predi%C3%A7%C3%A3o-com-dados-estruturados-4a76977df7ea",
      tag1: "Python",
      tag2: "Keras",
      date: "01/01/2023",
    ));
    articles.add(Article(
      imagePath: "assets/images/articles/modelo-de-regressao-multinivel.png",
      title: "Regressão Multinível",
      url: "https://medium.com/@marcosmhs/modelo-de-regress%C3%A3o-multin%C3%ADvel-1dd11ea369e2",
      tag1: "RStudio",
      tag2: "Modelos GLM",
      date: "01/01/2023",
    ));
    articles.add(Article(
      imagePath: "assets/images/articles/random-forests-101-com-r.png",
      title: "Random Forest 101",
      url: "https://medium.com/@marcosmhs/random-forests-101-com-r-d5c1821dc445",
      tag1: "RStudio",
      tag2: "Randon Forest",
      date: "01/01/2023",
    ));
  }

  void _projects() {
    projects = [];

    projects.add(Project(
      imagePath: "assets/images/projects/planning_poker.png",
      githubUrl: "https://github.com/marcosmhs/planningpoker",
      accessUrl: "https://planningpoker-teb.web.app/",
      title: "Planning Poker Web App",
      description: "Um Web App para ajudar nas plannings de times ágeis que utilizam Scrum",
      tech1: "Flutter",
      tech2: "Dart",
      tech3: "Flutter UI",
    ));

    projects.add(Project(
      imagePath: "assets/images/projects/escala.png",
      githubUrl: "https://github.com/marcosmhs/escala",
      accessUrl: "https://escala-teb.web.app/",
      title: "Escala Web App",
      description: "Um Web App para criar, gerenciar e compartilhar a escala de trabalho, como em hospitais e laboratórios",
      tech1: "Flutter",
      tech2: "Dart",
      tech3: "Flutter UI",
    ));

    projects.add(Project(
        imagePath: "assets/images/projects/joao_e_bento.png",
        githubUrl: "",
        accessUrl: "https://play.google.com/store/apps/details?id=com.ThatExoticBug.JoaeBento",
        title: "João e Bento",
        description:
            "Um jogo para celulares e tablets em que um menino precisa salvar seu irmão de malvados vilões. Criei este jogo como presente de aniversário para meu filho.",
        tech1: "Unity",
        tech2: "C#",
        tech3: ""));
  }
}
