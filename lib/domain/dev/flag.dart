import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Flag<T> extends ChangeNotifier {
  final String _key;
  late final String _spKey;
  final String _name;
  String? _desp;
  final T _defaultValue;
  T? _value;

  Flag(this._key, this._name, this._defaultValue, [this._desp]) {
    _spKey = 'flag_$_key';
    _value = _defaultValue;
    _syncFromSP();
  }

  Flag describe(String desp) {
    _desp = desp;
    return this;
  }

  void _syncFromSP() async {
    final sp = await SharedPreferences.getInstance();
    _value = sp.get(_spKey) as T? ?? _defaultValue;
    notifyListeners();
  }

  T get value => _value!;

  set value(T newValue) {
    _value = newValue;
    notifyListeners();
    _syncToSP();
  }

  String get name => _name;

  String get key => _key;

  String? get desp => _desp;

  void _syncToSP();
}

class BoolFlag extends Flag<bool> {
  BoolFlag(String key, String name, bool defaultValue, [String? desp])
      : super(key, name, defaultValue, desp);

  void toggle() {
    _value = !_value!;
    notifyListeners();
    _syncToSP();
  }

  @override
  void _syncToSP() async {
    final sp = await SharedPreferences.getInstance();
    sp.setBool(_spKey, _value!);
  }
}

class IntFlag extends Flag<int> {
  IntFlag(String key, String name, int defaultValue, [String? desp])
      : super(key, name, defaultValue, desp);

  void increment() {
    _value = _value! + 1;
    notifyListeners();
    _syncToSP();
  }

  void decrement() {
    _value = _value! - 1;
    notifyListeners();
    _syncToSP();
  }

  @override
  void _syncToSP() async {
    final sp = await SharedPreferences.getInstance();
    sp.setInt(_spKey, _value!);
  }
}

class StringFlag extends Flag<String> {
  StringFlag(String key, String name, String defaultValue, [String? desp])
      : super(key, name, defaultValue, desp);

  void update(String newValue) {
    _value = newValue;
    notifyListeners();
    _syncToSP();
  }

  @override
  void _syncToSP() async {
    final sp = await SharedPreferences.getInstance();
    sp.setString(_spKey, _value!);
  }
}
