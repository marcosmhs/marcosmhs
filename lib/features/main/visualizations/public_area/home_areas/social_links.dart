import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/features/main/visualizations/widgets/url_manager.dart';
import 'package:marcosmhs/features/site_data/header/site_header_data.dart';
import 'package:marcosmhs/features/site_data/main_data/site_main_data.dart';

class SocialLinks extends StatefulWidget {
  final BuildContext context;
  final Size size;
  final bool mobile;
  final SiteMainData siteMainData;
  final SiteHeaderText siteHeader;

  const SocialLinks({
    super.key,
    required this.context,
    required this.siteMainData,
    required this.siteHeader,
    required this.size,
    this.mobile = false,
  });

  @override
  State<SocialLinks> createState() => _SocialLinksState();
}

class _SocialLinksState extends State<SocialLinks> {
  @override
  Widget build(BuildContext context) {
    var links = [
      if (widget.siteHeader.urlGitGub.isNotEmpty)
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.github),
          color: widget.siteMainData.specialFontColor,
          iconSize: 26.0,
          onPressed: () => UrlManager().launchUrl(url: widget.siteHeader.urlGitGub),
        ),
      if (widget.siteHeader.urlLinkedin.isNotEmpty)
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.linkedin),
          color: widget.siteMainData.specialFontColor,
          iconSize: 26.0,
          onPressed: () => UrlManager().launchUrl(url: widget.siteHeader.urlLinkedin),
        ),
      if (widget.siteHeader.urlMedium.isNotEmpty)
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.medium),
          color: widget.siteMainData.specialFontColor,
          iconSize: 26.0,
          onPressed: () => UrlManager().launchUrl(url: widget.siteHeader.urlMedium),
        ),
      if (!widget.mobile)
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Container(
            height: widget.size.height * 0.20,
            width: 2,
            color: widget.siteMainData.specialFontColor.withOpacity(0.4),
          ),
        ),
    ];

    return SizedBox(
      width: widget.mobile ? null : widget.size.width * 0.09,
      height: widget.mobile ? null : widget.size.height - 82,
      child: widget.mobile
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: links,
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: links,
            ),
    );
  }
}
