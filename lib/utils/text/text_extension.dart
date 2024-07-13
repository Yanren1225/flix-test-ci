import 'dart:io';

import 'package:chinese_font_library/chinese_font_library.dart';
import 'package:flutter/painting.dart';

extension TextStyleExtension on TextStyle {
  /// Add fontFamilyFallback & fontVariation to original font style
  TextStyle fix() {
    if (Platform.isWindows) {
      return useSystemChineseFont();
    } else if (Platform.isLinux){
      return copyWith(fontFamily: 'custom-sans');
    } else {
      return this;
    }
  }
}

// TextStyle fixWindows(TextStyle style) {
//   return style.fix();
// }