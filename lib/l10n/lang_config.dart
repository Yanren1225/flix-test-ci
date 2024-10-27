import 'package:flutter/cupertino.dart';

class LangConfig {

  Locale? lang;

  static LangConfig? _instance;

  LangConfig();

  void setLang(Locale newLang){
    lang = newLang;
  }

  Locale? get current => lang;

  static LangConfig get instance {
    _instance ??= LangConfig();
    return _instance!;
  }

}