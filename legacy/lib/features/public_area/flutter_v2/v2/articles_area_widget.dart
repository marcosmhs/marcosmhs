import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/features/admin_area/articles/article_data.dart';
import 'package:marcosmhs/features/public_area/v2/widgets/card_hover_widget.dart';
import 'package:marcosmhs/features/public_area/v2/widgets/card_image_widget.dart';
import 'package:marcosmhs/features/public_area/url_manager.dart';
import 'package:teb_package/control_widgets/teb_text.dart';

class ArticlesAreaWidget extends StatelessWidget {
  final List<Article> articleList;
  const ArticlesAreaWidget({super.key, required this.articleList});

  Widget _articleCardWidget({required BuildContext context, required Article article}) {
    List<String> tagsList = [];
    if (article.tag1.isNotEmpty) tagsList.add(article.tag1);
    if (article.tag2.isNotEmpty) tagsList.add(article.tag2);

    final Color colorSeed = cardColorSeed(article.title);

    return HoverCardWidget(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorSeed.withAlpha(50), colorSeed.withAlpha(150)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Center(
                child: CardImageWidget(
                  url: article.externalImageUrl.isNotEmpty
                      ? article.externalImageUrl
                      : article.firestorageImageUrl,
                  fit: BoxFit.cover,
                  color: colorSeed,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TebText(
                    article.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: tagsList.map((tag) {
                      return Chip(
                        label: TebText(tag),
                        backgroundColor: colorSeed.withAlpha(40),
                        labelStyle: TextStyle(
                          color: colorSeed,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => UrlManager.launchUrl(url: article.url),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TebText('Ler artigo', fontColor: colorSeed, fontWeight: FontWeight.bold),
                        SizedBox(width: 8),
                        Icon(FontAwesomeIcons.readme, size: 16, color: colorSeed),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TebText('Artigos Publicados', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 64),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;
                  if (constraints.maxWidth >= 1024) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth >= 768) {
                    crossAxisCount = 2;
                  } else {
                    crossAxisCount = 1;
                  }

                  const double gap = 32.0;

                  // Calcula a largura de cada item para preencher o grid corretamente
                  final double itemWidth =
                      (constraints.maxWidth - (gap * (crossAxisCount - 1))) / crossAxisCount;

                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: articleList.map((article) {
                      return SizedBox(
                        width: itemWidth,
                        child: _articleCardWidget(context: context, article: article),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
