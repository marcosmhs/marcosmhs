import 'package:flutter/material.dart';
import 'package:marcosmhs/features/main/visualizations/widgets/article_image.dart';
import 'package:marcosmhs/features/main/visualizations/widgets/area_title.dart';
import 'package:marcosmhs/features/main/visualizations/widgets/url_manager.dart';
import 'package:marcosmhs/features/site_data/articles/site_article_data.dart';
import 'package:marcosmhs/features/site_data/main_data/site_main_data.dart';
import 'package:teb_package/teb_package.dart';

class ArticlesArea extends StatelessWidget {
  final bool mobile;
  final SiteMainData siteMainData;
  final List<Article> articleList;
  const ArticlesArea({super.key, this.mobile = false, required this.siteMainData, required this.articleList});

  Widget _article({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String url,
    required String date,
    required Size size,
    String tag1 = "",
    String tag2 = "",
  }) {
    return Column(
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => UrlManager().launchUrl(url: url),
              child: ArticleImage(imagePath: imagePath),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: InkWell(
                    onTap: () => UrlManager().launchUrl(url: url),
                    child: SizedBox(
                      width: mobile ? size.width * 0.67 : null,
                      child: TebText(
                        title,
                        textSize: mobile ? 14 : 22.0,
                        textColor: siteMainData.regularFontColor,
                        textWeight: FontWeight.w700,
                        letterSpacing: 1.75,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ),

                // tags
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TebText(
                      tag1,
                      textSize: 12,
                      textColor: siteMainData.regularFontColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 10),
                    TebText(
                      tag2,
                      textSize: 10,
                      textColor: siteMainData.regularFontColor.withOpacity(0.7),
                    )
                  ],
                ),
                // date
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: TebText(
                    date,
                    textSize: 10,
                    textColor: siteMainData.regularFontColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: mobile ? 10 : 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    articleList.sort((a, b) => a.order.compareTo(b.order));
    return Column(
      children: [
        AreaTitle(size: size, title: 'Artigos', siteMainData: siteMainData),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: articleList.length,
              itemBuilder: (context, index) {
                return _article(
                    context: context,
                    imagePath: articleList[index].externalImageUrl.isNotEmpty
                        ? articleList[index].externalImageUrl
                        : articleList[index].firestorageImageUrl,
                    title: articleList[index].title,
                    url: articleList[index].url,
                    tag1: articleList[index].tag1,
                    tag2: articleList[index].tag2,
                    date: articleList[index].date == null ? '' : TebUtil.dateTimeFormat(date: articleList[index].date!),
                    size: size);
              },
            ),
          ],
        ),
      ],
    );
  }
}
