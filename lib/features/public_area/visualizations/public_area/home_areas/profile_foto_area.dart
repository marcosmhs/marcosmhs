import 'package:flutter/material.dart';
import 'package:marcosmhs/features/admin_area/about_me/site_about_me_data.dart';
import 'package:marcosmhs/features/admin_area/main_data/site_main_data.dart';

class ProfileFotoArea extends StatefulWidget {
  final Size size;
  final BuildContext context;
  final bool mobile;
  final AboutMeData aboutMeData;
  final SiteMainData siteMainData;

  const ProfileFotoArea({
    super.key,
    required this.size,
    required this.context,
    required this.aboutMeData,
    required this.siteMainData,
    this.mobile = false,
  });

  @override
  State<ProfileFotoArea> createState() => _ProfileFotoAreaState();
}

class _ProfileFotoAreaState extends State<ProfileFotoArea> {
  @override
  Widget build(BuildContext context) {
    var imageArea = SizedBox(
      height: widget.mobile ? widget.size.height * 0.5 : widget.size.height / 1.5,
      width: widget.mobile ? widget.size.width * 0.6 : widget.size.width / 2 - 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: widget.mobile ? 50 : widget.size.height * 0.12,
            left: widget.mobile ? 50 : widget.size.width * 0.12,
            child: Card(
              color: widget.siteMainData.specialColor,
              child: Container(
                height: widget.mobile ? widget.size.height * 0.4 : widget.size.height / 2,
                width: widget.mobile ? widget.size.width * 0.45 : widget.size.width / 5,
                margin: const EdgeInsets.all(2.75),
                color: widget.siteMainData.backgroundColor,
              ),
            ),
          ),
          if (widget.aboutMeData.profilePhotoUrl.isNotEmpty)
            Stack(
              children: [
                Container(
                    width: widget.mobile ? widget.size.width * 0.5 : widget.size.width / 5,
                    color: widget.siteMainData.backgroundColor,
                    child: Image.network(
                      widget.aboutMeData.profilePhotoUrl,
                      fit: BoxFit.cover,
                    ),),
              ],
            )
        ],
      ),
    );
    if (widget.mobile) {
      return Center(child: imageArea);
    } else {
      return Expanded(child: imageArea);
    }
  }
}
