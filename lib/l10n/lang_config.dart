/// LangConfig is a singleton class that holds the current language of the app.

import 'dart:async';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 支持的语言列表, 用以显示语言名称
final _supportLangNameMapping = {
  "zh_CN": "简体中文",
  "en": "English",
  "ja": "日本語",
};

class LangData {
  final bool ifFollowSystem;
  final Locale? lang;

  LangData(this.ifFollowSystem, this.lang);
}

/// LangConfig is a singleton class that holds the current language of the app.
/// 管理当前语言的单例类
class LangConfig extends ChangeNotifier {
  Locale? _lang;
  final _langStream = StreamController<LangData>.broadcast();
  bool _followSystem = true;

  static LangConfig? _instance;

  /// 设置当前语言
  void _setLang(Locale newLang) {
    talker.debug("LangConfig setLang, lang = $newLang");
    _followSystem = false;
    _lang = newLang;
    _save();
    _langStream.add(
      LangData(_followSystem, _lang),
    );
    notifyListeners();
  }

  /// 设置当前语言, shortcut for `instance.setLang(newLang)`
  static void set(Locale newLang) {
    instance._setLang(newLang);
  }

  /// 获取当前语言
  /// 建议使用 `LangConfig.lang` 获取当前语言
  Locale? get _current => _followSystem ? null : _lang;

  /// 获取当前语言, shortcut for `instance.current`
  static Locale? get lang => instance._current;

  /// 获取是否跟随系统语言
  static bool get ifFollowSystem => instance._followSystem;

  /// 设置是否跟随系统语言
  void _setFollowSystem() {
    _followSystem = true;
    _save();
    _langStream.add(
      LangData(_followSystem, _lang),
    );
    notifyListeners();
  }

  /// 设置是否跟随系统语言
  static void followSystem() => instance._setFollowSystem();

  void _linkSetState(VoidCallback fn) => addListener(fn);

  /// 关联 setState 实现自动刷新
  /// 用于在语言切换时自动刷新页面, 建议在页面的 initState 中调用
  static void link(VoidCallback fn) => instance._linkSetState(fn);

  void _unlinkSetState(VoidCallback fn) => removeListener(fn);

  /// 取消关联 setState
  static void unlink(VoidCallback fn) => instance._unlinkSetState(fn);

  /// 初始化
  static Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    final lang = sp.getString('lang');
    final followSystem = sp.getBool('lang_followSystem') ?? true;

    talker.debug("LangConfig init, lang = $lang, followSystem = $followSystem");

    if (!followSystem) {
      if (lang != null) {
        set(Locale(lang));
      }
    }
  }

  void _save() async {
    final sp = await SharedPreferences.getInstance();
    sp.setString('lang', _lang.toString());
    sp.setBool('lang_followSystem', _followSystem);
    talker
        .debug("LangConfig save, lang = $_lang, followSystem = $_followSystem");
  }

  static Stream<LangData> get langStream => instance._langStream.stream;

  static LangData get langData => LangData(ifFollowSystem, lang);

  /// 获取 LangConfig 实例
  static LangConfig get instance {
    _instance ??= LangConfig();
    return _instance!;
  }
}

extension LocaleExt on Locale {
  /// 是否支持语言名称映射(`zh_CN` -> `简体中文`)
  bool get nameable => _supportLangNameMapping.containsKey(toString());

  /// 获取语言名称, 如果支持则返回映射的名称(`简体中文`), 否则返回原始名称(`zh_CN`)
  String get name {
    if (_supportLangNameMapping.containsKey(toString())) {
      return _supportLangNameMapping[toString()]!;
    } else {
      return toString();
    }
  }
}
