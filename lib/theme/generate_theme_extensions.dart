import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('lib/theme/colors.json');
  final jsonString = file.readAsStringSync();
  final Map<String, dynamic> colors = json.decode(jsonString);

  final buffer = StringBuffer();
  buffer.writeln("import 'package:flutter/material.dart';");
  buffer.writeln();
  _writeNestedClasses(buffer, colors['light']);
  buffer.writeln();
  buffer.writeln('extension CustomTheme on ThemeData {');
  buffer.writeln('  CustomColors get flixColors {');
  buffer.writeln('    return brightness == Brightness.dark');
  buffer.writeln('        ? CustomColors.fromJson(_darkColors)');
  buffer.writeln('        : CustomColors.fromJson(_lightColors);');
  buffer.writeln('  }');
  buffer.writeln('}');
  buffer.writeln();

  buffer.writeln('CustomColors getLightColors()=> CustomColors.fromJson(_lightColors);');
  buffer.writeln('CustomColors getDarkColors()=> CustomColors.fromJson(_darkColors);');

  buffer.writeln('');
  buffer.writeln('const _lightColors = ${json.encode(colors['light'])};');
  buffer.writeln('const _darkColors = ${json.encode(colors['dark'])};');


  final outputFile = File('lib/theme/theme_extensions.dart');
  outputFile.writeAsStringSync(buffer.toString());
}

void _writeNestedClasses(StringBuffer buffer, Map<String, dynamic> map,
    [String className = 'CustomColors']) {
  buffer.writeln('class $className {');

  /// 类属性
  map.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      buffer.writeln('  final ${_capitalize(key)}FlixColor $key;');
    } else {
      buffer.writeln('  final Color $key;');
    }
  });

  /// 构造函数
  buffer.writeln();
  buffer.writeln('  const $className({');
  map.forEach((key, value) {
    buffer.writeln('    required this.$key,');
  });
  buffer.writeln('  });');

  /// fromJson 方法
  buffer.writeln();
  buffer.writeln('  factory $className.fromJson(Map<String, dynamic> json) {');
  buffer.writeln('    return $className(');
  map.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      final nestedClassName = '${_capitalize(key)}FlixColor';
      buffer.writeln('      $key: $nestedClassName.fromJson(json[\'$key\']),');
    } else {
      buffer.writeln('      $key: ${_parseColor('json[\'$key\']')},');
    }
  });
  buffer.writeln('    );');
  buffer.writeln('  }');

  buffer.writeln('}');

  /// 嵌套
  map.forEach((key, value) {
    if (value is Map<String, dynamic>) {
      _writeNestedClasses(buffer, value, '${_capitalize(key)}FlixColor');
    }
  });
}

String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

String _parseColor(String colorExpression) {
  return 'Color(int.parse($colorExpression.replaceFirst(\'#\', \'0xFF\')))';
}
