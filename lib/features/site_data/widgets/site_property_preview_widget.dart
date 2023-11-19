import 'package:flutter/material.dart';
import 'package:teb_package/visual_elements/teb_text.dart';

class SitePropertyPreview extends StatefulWidget {
  final Size size;
  final Color backgroundColor;
  final String text1;
  final Color text1Color;
  final double text1Size;
  final FontWeight? text1FontWeight;

  final String? text2;
  final Color? text2Color;
  final double? text2Size;
  final FontWeight? text2FontWeight;

  final String? text3;
  final Color? text3Color;
  final double? text3Size;
  final FontWeight? text3FontWeight;

  final String? text4;
  final Color? text4Color;
  final double? text4Size;
  final FontWeight? text4FontWeight;

  final BuildContext context;
  final bool showWhiteBorder;

  const SitePropertyPreview({
    super.key,
    required this.context,
    required this.size,
    required this.backgroundColor,
    required this.text1,
    required this.text1Color,
    required this.text1Size,
    this.text1FontWeight,
    this.text2,
    this.text2Color,
    this.text2Size,
    this.text2FontWeight,
    this.text3,
    this.text3Color,
    this.text3Size,
    this.text3FontWeight,
    this.text4,
    this.text4Color,
    this.text4Size,
    this.text4FontWeight,
    this.showWhiteBorder = true,
  });

  @override
  State<SitePropertyPreview> createState() => _SitePropertyPreviewState();
}

class _SitePropertyPreviewState extends State<SitePropertyPreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.showWhiteBorder ? Colors.white : null,
      child: Card(
        color: widget.backgroundColor,
        margin: const EdgeInsets.all(10),
        elevation: 0,
        child: Center(
          child: Column(
            children: [
              TebText(
                widget.text1,
                textColor: widget.text1Color,
                textSize: widget.text1Size,
                textWeight: widget.text1FontWeight,
                padding: const EdgeInsets.all(10),
              ),
              if (widget.text2 != null)
                TebText(
                  widget.text2!,
                  textColor: widget.text2Color,
                  textSize: widget.text2Size,
                  textWeight: widget.text2FontWeight,
                  padding: const EdgeInsets.all(10),
                ),
              if (widget.text3 != null)
                TebText(
                  widget.text3!,
                  textColor: widget.text3Color,
                  textSize: widget.text3Size,
                  textWeight: widget.text3FontWeight,
                  padding: const EdgeInsets.all(10),
                ),
              if (widget.text4 != null)
                TebText(
                  widget.text4!,
                  textColor: widget.text4Color,
                  textSize: widget.text4Size,
                  textWeight: widget.text4FontWeight,
                  padding: const EdgeInsets.all(10),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
