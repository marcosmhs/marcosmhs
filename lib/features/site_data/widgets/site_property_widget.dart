import 'package:flutter/material.dart';
//import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marcosmhs/features/main/theme_data.dart';
import 'package:teb_package/visual_elements/material_color_picker/teb_material_color_picker.dart';
import 'package:teb_package/visual_elements/teb_buttons_line.dart';
import 'package:teb_package/visual_elements/teb_checkbox.dart';
import 'package:teb_package/visual_elements/teb_dropdown_menu.dart';
import 'package:teb_package/visual_elements/teb_text.dart';
import 'package:teb_package/visual_elements/teb_text_form_field.dart';

enum SitePropertyType { text, color, numeric, fontWeigh, device }

class SiteProperty extends StatefulWidget {
  final BuildContext context;
  final Size size;
  final List<SitePropertyType> sitePropertyTypes;
  final String propertyTitle;
  final bool propertyMemoInput;
  final String? propertyValue;
  final double? propertyFontSize;
  final bool propertyMobile;
  final bool propertyDesktop;
  final FontWeight? propertyFontWeight;
  final Color? propertyColor;

  final Function(String? value)? onChangedProperty;
  final Function(Color? value)? onChangedPropertyColor;
  final Function(String? value)? onChangedPropertyFontSize;
  final Function(Object?)? onFontWeightSelected;
  final Function(bool?)? onDeviceMobileSelected;
  final Function(bool?)? onDeviceDesktopSelected;

  final String? Function(String? value)? onValidateProperty;
  final String? Function(String? value)? onValidatePropertyFontSize;

  final bool showActionButton;
  final String actionButtonLabel;
  final FaIcon? actionButtonIcon;
  final Function()? actionButtonPressed;

  const SiteProperty({
    super.key,
    required this.context,
    required this.size,
    required this.sitePropertyTypes,
    required this.propertyTitle,
    this.propertyValue,
    this.propertyColor,
    this.propertyMemoInput = false,
    this.propertyFontSize,
    this.propertyFontWeight,
    this.propertyMobile = true,
    this.propertyDesktop = true,
    this.onChangedProperty,
    this.onChangedPropertyColor,
    this.onChangedPropertyFontSize,
    this.onFontWeightSelected,
    this.onDeviceMobileSelected,
    this.onDeviceDesktopSelected,
    this.onValidateProperty,
    this.onValidatePropertyFontSize,
    this.showActionButton = false,
    this.actionButtonLabel = '',
    this.actionButtonIcon,
    this.actionButtonPressed,
  });

  @override
  State<SiteProperty> createState() => _SitePropertyState();
}

class _SitePropertyState extends State<SiteProperty> {
  final TextEditingController _textPropertyController = TextEditingController();
  final TextEditingController _textPropertyFontSizeController = TextEditingController();

  var _propertyColorButtonBackgroundColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _propertyColorButtonBackgroundColor = widget.propertyColor ?? Colors.transparent;
    _textPropertyController.text = widget.propertyValue ?? '';
    if (widget.propertyFontSize != null) {
      _textPropertyFontSizeController.text = widget.propertyFontSize.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    _textPropertyController.text = widget.propertyValue ?? '';
    if (widget.propertyFontSize != null) {
      _textPropertyFontSizeController.text = widget.propertyFontSize.toString();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showActionButton)
          TebButton(
            label: widget.actionButtonLabel,
            icon: widget.actionButtonIcon,
            onPressed: widget.actionButtonPressed,
            padding: const EdgeInsets.only(top: 10),
          ),
        if (widget.showActionButton) const Spacer(),
        SizedBox(
          width: widget.showActionButton ? widget.size.width * 0.68 : widget.size.width * 0.76,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // title
              if (widget.propertyTitle.isNotEmpty)
                Row(
                  children: [
                    TebText(
                      widget.propertyTitle,
                      textColor: Theme.of(context).primaryColorLight,
                      textSize: 20,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ],
                ),

              // propertie value
              if (widget.sitePropertyTypes.where((s) => s == SitePropertyType.text).isNotEmpty)
                TebTextEdit(
                  labelText: widget.propertyTitle,
                  controller: _textPropertyController,
                  onChanged: widget.onChangedProperty,
                  maxLines: widget.propertyMemoInput ? 4 : 1,
                  validator: widget.onValidateProperty,
                ),

              // Properties
              Padding(
                padding: const EdgeInsets.all(1),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // font size
                        if (widget.sitePropertyTypes.where((s) => s == SitePropertyType.numeric).isNotEmpty)
                          SizedBox(
                            width: 150,
                            child: TebTextEdit(
                              labelText: 'Tamanho',
                              controller: _textPropertyFontSizeController,
                              onChanged: widget.onChangedPropertyFontSize,
                              validator: widget.onValidatePropertyFontSize,
                            ),
                          ),
                        if (widget.sitePropertyTypes.where((s) => s == SitePropertyType.numeric).isNotEmpty) const Spacer(),

                        // font weigh
                        if (widget.sitePropertyTypes.where((s) => s == SitePropertyType.fontWeigh).isNotEmpty)
                          TebDropDownMenu(
                            selectedValue: widget.propertyFontWeight,
                            itens: FontWeight.values,
                            text: 'Selecione a fonte',
                            onSelected: (selectedValue) {
                              setState(() => widget.onFontWeightSelected!(selectedValue));
                            },
                          ),
                        if (widget.sitePropertyTypes.where((s) => s == SitePropertyType.fontWeigh).isNotEmpty) const Spacer(),

                        // color selection
                        if (widget.sitePropertyTypes.where((s) => s == SitePropertyType.color).isNotEmpty)
                          SizedBox(
                            width: 220,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: _propertyColorButtonBackgroundColor),
                              onPressed: () {
                                TebMaterialColorPicker.showColorPicker(
                                  context: context,
                                  pickedColor: widget.propertyColor ?? thatExoticBugTheme.colorScheme.primary,
                                ).then((selectecColor) {
                                  setState(() => _propertyColorButtonBackgroundColor = selectecColor);
                                  widget.onChangedPropertyColor!(selectecColor);
                                });
                              },
                              child: const Text('Selecione a cor'),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Mobile / desktop
              if (widget.sitePropertyTypes.where((s) => s == SitePropertyType.device).isNotEmpty)
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: TebCheckBox(
                        context: context,
                        value: widget.propertyDesktop,
                        title: 'Desktop',
                        onChanged: (checked) => setState(() => widget.onDeviceDesktopSelected!(checked)),
                      ),
                    ),
                    const SizedBox(width: 50),
                    SizedBox(
                      width: 150,
                      child: TebCheckBox(
                        context: context,
                        value: widget.propertyMobile,
                        title: 'Mobile',
                        onChanged: (checked) => setState(() => widget.onDeviceMobileSelected!(checked)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
