import 'package:flutter/material.dart';
import 'package:marcosmhs/features/main/visualizations/public_area/home_areas/social_links.dart';
import 'package:marcosmhs/features/main/visualizations/widgets/url_manager.dart';
import 'package:marcosmhs/features/site_data/header/site_header_data.dart';
import 'package:marcosmhs/features/site_data/main_data/site_main_data.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class ContactArea extends StatelessWidget {
  final bool mobile;
  final SiteMainData siteMainData;
  final SiteHeaderText siteHeader;
  const ContactArea({super.key, this.mobile = false, required this.siteMainData, required this.siteHeader});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
          height: mobile ? null : size.height * 0.3,
          width: mobile ? null : size.width - 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16.0),
              TebText(
                "Vamos conversar",
                textSize: mobile ? 20 : 42,
                textColor: siteMainData.regularFontColor,
                letterSpacing: 3.0,
                textWeight: FontWeight.w700,
              ),
              const SizedBox(height: 16.0),
              Wrap(
                children: [
                  Text(
                    "Se quiser falar sobre desenvolvimento Flutter, data science ou só mandar um oi, minha caixa de e-mail está sempre aberta e farei o possível para respondê-lo",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: siteMainData.regularFontColor,
                      letterSpacing: 0.75,
                      fontSize: 17.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
              InkWell(
                onTap: () => UrlManager().launchEmail(),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
                  color: siteMainData.specialColor,
                  child: Container(
                    margin: const EdgeInsets.all(0.85),
                    height: size.height * 0.08,
                    width: size.width * (mobile ? 0.45 : 0.15),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: siteMainData.backgroundColor,
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: TebText(
                      "Enviar um e-mail",
                      textColor: siteMainData.specialColor,
                      textAlign: TextAlign.center,
                      letterSpacing: 3,
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        if (mobile)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            child: SocialLinks(
              context: context,
              siteMainData: siteMainData,
              siteHeader: siteHeader,
              size: size,
              mobile: true,
            ),
          ),

        //Footer
        Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height / 6,
          width: MediaQuery.of(context).size.width - 100,
          child: TebText(
            "Desenvolvido utilizando Flutter\n${DateTime.now().year}",
            textSize: 15.0,
            textColor: siteMainData.regularFontColor,
            letterSpacing: 3.0,
            textWeight: FontWeight.w200,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
