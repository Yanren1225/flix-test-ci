import 'package:flutter/cupertino.dart';

import 'l10n.dart';

class LangConfig {
  Locale? lang;
  Null Function(Locale)? onLangChange;

  static LangConfig? _instance;

  LangConfig();

  void setLang(Locale newLang) {
    onLangChange?.call(newLang);
    lang = newLang;
  }

  Locale? get current => lang;

  static LangConfig get instance {
    _instance ??= LangConfig();
    return _instance!;
  }
}
