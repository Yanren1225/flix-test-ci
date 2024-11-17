/// LangConfig is a singleton class that holds the current language of the app.

import 'package:flix/domain/log/flix_log.dart';
import 'package:flutter/cupertino.dart';

/// LangConfig is a singleton class that holds the current language of the app.
/// 管理当前语言的单例类
class LangConfig {
  Locale? _lang;

  final List<Function(VoidCallback fn)> _linkedSetState = [];

  static LangConfig? _instance;

  /// 设置当前语言
  void setLang(Locale newLang) {
    _lang = newLang;
    // 通知所有关联的 setState 刷新页面
    for (var fn in _linkedSetState) {
      try {
        fn(() {});
      } catch (e) {
        talker.error('LangConfig.setLang', e);
      }
    }
  }

  /// 设置当前语言, shortcut for `instance.setLang(newLang)`
  static void set(Locale newLang) {
    instance.setLang(newLang);
  }

  /// 获取当前语言
  /// 建议使用 `LangConfig.lang` 获取当前语言
  Locale? get current => _lang;

  /// 获取当前语言, shortcut for `instance.current`
  static Locale? get lang => instance.current;

  /// 关联 setState 实现自动刷新
  /// 用于在语言切换时自动刷新页面, 建议在页面的 initState 中调用
  /// 建议使用 `LangConfig.link(fn)` 关联 setState
  void linkSetState(Function(VoidCallback fn) fn) {
    _linkedSetState.add(fn);
  }

  /// 关联 setState 实现自动刷新, shortcut for `instance.linkSetState(fn)`
  /// 用于在语言切换时自动刷新页面, 建议在页面的 initState 中调用
  static void link(Function(VoidCallback fn) fn) => instance.linkSetState(fn);

  /// 取消关联 setState
  /// 用于在 dispose 时取消关联
  /// 建议使用 `LangConfig.unlink(fn)` 取消关联
  void unlinkSetState(Function(VoidCallback fn) fn) =>
      _linkedSetState.remove(fn);

  /// 取消关联 setState, shortcut for `instance.unlinkSetState(fn)`
  static void unlink(Function(VoidCallback fn) fn) =>
      instance.unlinkSetState(fn);

  /// 获取 LangConfig 实例
  static LangConfig get instance {
    _instance ??= LangConfig();
    return _instance!;
  }
}
