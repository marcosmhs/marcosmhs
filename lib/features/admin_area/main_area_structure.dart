import 'package:flutter/material.dart';
import 'package:marcosmhs/features/admin_area/user/user.dart';
import 'package:marcosmhs/features/admin_area/vertical_menu.dart';
import 'package:teb_package/control_widgets/teb_text.dart';
import 'package:teb_package/screen_widgets/teb_scaffold.dart';

class MainAreaStructure extends StatefulWidget {
  final User user;
  final Widget? widget;
  final bool mobile;
  final String infoMessage;

  final Size size;
  const MainAreaStructure({
    super.key,
    required this.mobile,
    required this.user,
    required this.size,
    this.widget,
    this.infoMessage = '',
  });

  @override
  State<MainAreaStructure> createState() => _MainAreaStructureState();
}

class _MainAreaStructureState extends State<MainAreaStructure> {
  @override
  Widget build(BuildContext context) {
    return TebScaffold(
      title: const Text('That Exotic Bug'),
      responsive: false,
      showAppBar: widget.mobile,
      drawer: widget.mobile
          ? VerticalMenu(mobile: widget.mobile, user: widget.user, size: widget.size)
          : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // menu
          if (!widget.mobile)
            VerticalMenu(mobile: widget.mobile, user: widget.user, size: widget.size),
          // área principal
          Container(
            padding: const EdgeInsets.all(10),
            width: widget.mobile ? widget.size.width : widget.size.width * 0.78,
            child: widget.infoMessage.isNotEmpty
                ? Center(
                    child: TebText(
                    widget.infoMessage,
                    fontColor: Theme.of(context).colorScheme.primary,
                    fontSize: 50,
                  ))
                : SingleChildScrollView(child: widget.widget ?? const Text('')),
          )
        ],
      ),
    );
  }
}
