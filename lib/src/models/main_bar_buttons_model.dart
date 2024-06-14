import 'package:flutter/material.dart';

class MainBarButtonModel {
  Widget? leading;
  String? title;
  String? subTitle;
  Widget? trailing;
  IconData? icon;
  IconData? alternateIcon;
  Function? onTap = () {
    print("Valor por defecto");
  };
  Color? colors;
  Widget? launchWidget;

  MainBarButtonModel(
      {this.leading,
      this.title,
      this.subTitle,
      this.colors,
      this.icon,
      this.alternateIcon,
      this.trailing,
      this.onTap,
      this.launchWidget});
}
