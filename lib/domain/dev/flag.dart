import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Flag<T> extends ChangeNotifier {
  final String _key;
  late final String _spKey;
  final String _name;
  String? _desp;
  final bool _saveToSp;
  final T _defaultValue;
  T? _value;

  Flag(this._key, this._name, this._defaultValue, this._saveToSp,
      [this._desp]) {
    _spKey = 'flag_$_key';
    _value = _defaultValue;
    if (_saveToSp) _syncFromSP();
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
    if (_saveToSp) _syncToSP();
  }

  String get name => _name;

  String get key => _key;

  String? get description => _desp;

  T get defaultValue => _defaultValue;

  bool get saveToSp => _saveToSp;

  bool get isDefault => _value == _defaultValue;

  void _syncToSP();
}

class BoolFlag extends Flag<bool> {
  BoolFlag({
    required String key,
    required String name,
    required bool defaultValue,
    bool saveToSp = true,
    String? description,
  }) : super(key, name, defaultValue, saveToSp, description);

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
  IntFlag({
    required String key,
    required String name,
    required int defaultValue,
    String? description,
  }) : super(key, name, defaultValue, true, description);

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
  StringFlag({
    required String key,
    required String name,
    required String defaultValue,
    String? description,
  }) : super(key, name, defaultValue, true, description);

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
