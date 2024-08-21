import 'package:flutter/material.dart';

class CustomColors {
  final TextFlixColor text;
  final BackgroundFlixColor background;
  final SwitchableFlixColor switchable;

  const CustomColors({
    required this.text,
    required this.background,
    required this.switchable,
  });

  factory CustomColors.fromJson(Map<String, dynamic> json) {
    return CustomColors(
      text: TextFlixColor.fromJson(json['text']),
      background: BackgroundFlixColor.fromJson(json['background']),
      switchable: SwitchableFlixColor.fromJson(json['switchable']),
    );
  }
}
class TextFlixColor {
  final Color primary;
  final Color secondary;
  final Color tertiary;
  final Color quaternary;

  const TextFlixColor({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.quaternary,
  });

  factory TextFlixColor.fromJson(Map<String, dynamic> json) {
    return TextFlixColor(
      primary: Color(int.parse(json['primary'].replaceFirst('#', '0xFF'))),
      secondary: Color(int.parse(json['secondary'].replaceFirst('#', '0xFF'))),
      tertiary: Color(int.parse(json['tertiary'].replaceFirst('#', '0xFF'))),
      quaternary: Color(int.parse(json['quaternary'].replaceFirst('#', '0xFF'))),
    );
  }
}
class BackgroundFlixColor {
  final Color primary;
  final Color secondary;
  final Color tertiary;

  const BackgroundFlixColor({
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });

  factory BackgroundFlixColor.fromJson(Map<String, dynamic> json) {
    return BackgroundFlixColor(
      primary: Color(int.parse(json['primary'].replaceFirst('#', '0xFF'))),
      secondary: Color(int.parse(json['secondary'].replaceFirst('#', '0xFF'))),
      tertiary: Color(int.parse(json['tertiary'].replaceFirst('#', '0xFF'))),
    );
  }
}
class SwitchableFlixColor {
  final InactiveFlixColor inactive;
  final ActiveFlixColor active;

  const SwitchableFlixColor({
    required this.inactive,
    required this.active,
  });

  factory SwitchableFlixColor.fromJson(Map<String, dynamic> json) {
    return SwitchableFlixColor(
      inactive: InactiveFlixColor.fromJson(json['inactive']),
      active: ActiveFlixColor.fromJson(json['active']),
    );
  }
}
class InactiveFlixColor {
  final Color thumb;
  final Color track;

  const InactiveFlixColor({
    required this.thumb,
    required this.track,
  });

  factory InactiveFlixColor.fromJson(Map<String, dynamic> json) {
    return InactiveFlixColor(
      thumb: Color(int.parse(json['thumb'].replaceFirst('#', '0xFF'))),
      track: Color(int.parse(json['track'].replaceFirst('#', '0xFF'))),
    );
  }
}
class ActiveFlixColor {
  final Color thumb;
  final Color track;

  const ActiveFlixColor({
    required this.thumb,
    required this.track,
  });

  factory ActiveFlixColor.fromJson(Map<String, dynamic> json) {
    return ActiveFlixColor(
      thumb: Color(int.parse(json['thumb'].replaceFirst('#', '0xFF'))),
      track: Color(int.parse(json['track'].replaceFirst('#', '0xFF'))),
    );
  }
}

extension CustomTheme on ThemeData {
  CustomColors get flixColors {
    return brightness == Brightness.dark
        ? CustomColors.fromJson(_darkColors)
        : CustomColors.fromJson(_lightColors);
  }
}

CustomColors getLightColors()=> CustomColors.fromJson(_lightColors);
CustomColors getDarkColors()=> CustomColors.fromJson(_darkColors);

const _lightColors = {"text":{"primary":"#FF000000","secondary":"#993C3C43","tertiary":"#4C3C3C43","quaternary":"#2D3C3C43"},"background":{"primary":"#FFFFFFFF","secondary":"#FFF2F2F2","tertiary":"#CCF2F2F2"},"switchable":{"inactive":{"thumb":"#3F000000","track":"#19000000"},"active":{"thumb":"#FFFFFFFF","track":"#FF007AFF"}}};
const _darkColors = {"text":{"primary":"#FFFFFFFF","secondary":"#99EBEBF5","tertiary":"#4CEBEBF5","quaternary":"#2DEBEBF5"},"background":{"primary":"#FF1C1C1E","secondary":"#FF2C2C2E","tertiary":"#FF3A3A3C"},"switchable":{"inactive":{"thumb":"#3FFFFFFF","track":"#19FFFFFF"},"active":{"thumb":"#FFFFFFFF","track":"#FF007AFF"}}};
