/// LangConfig is a singleton class that holds the current language of the app.

import 'package:flix/domain/log/flix_log.dart';
import 'package:flutter/cupertino.dart';

/// LangConfig is a singleton class that holds the current language of the app.
class LangConfig {
  Locale? _lang;

  final List<Function(VoidCallback fn)> _linkedSetState = [];

  static LangConfig? _instance;

  /// 设置当前语言
  void setLang(Locale newLang) {
    _lang = newLang;
    for (var fn in _linkedSetState) {
      try {
        fn(() {});
      } catch (e) {
        talker.error('LangConfig.setLang', e);
      }
    }
  }

  /// 获取当前语言
  Locale? get current => _lang;

  /// 设置当前语言, shortcut for `setLang(newLang!)`
  set current(Locale? newLang) {
    setLang(newLang!);
  }

  /// 关联 setState 实现自动刷新
  void linkSetState(Function(VoidCallback fn) fn) {
    _linkedSetState.add(fn);
  }

  /// 取消关联 setState
  void unlinkSetState(Function(VoidCallback fn) fn) {
    _linkedSetState.remove(fn);
  }

  /// 获取 LangConfig 实例
  static LangConfig get instance {
    _instance ??= LangConfig();
    return _instance!;
  }

  /// 获取当前语言, shortcut for `instance.current`
  static Locale? get lang => instance.current;

  /// 设置当前语言, shortcut for `instance.current = newLang`
  static set lang(Locale? newLang) => instance.current = newLang;
}
