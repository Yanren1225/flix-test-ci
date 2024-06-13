// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'wifi_or_ap_name.dart';

class WifiOrApNameMapper extends ClassMapperBase<WifiOrApName> {
  WifiOrApNameMapper._();

  static WifiOrApNameMapper? _instance;
  static WifiOrApNameMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = WifiOrApNameMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'WifiOrApName';

  static bool _$isAp(WifiOrApName v) => v.isAp;
  static const Field<WifiOrApName, bool> _f$isAp = Field('isAp', _$isAp);
  static String _$name(WifiOrApName v) => v.name;
  static const Field<WifiOrApName, String> _f$name = Field('name', _$name);

  @override
  final Map<Symbol, Field<WifiOrApName, dynamic>> fields = const {
    #isAp: _f$isAp,
    #name: _f$name,
  };

  static WifiOrApName _instantiate(DecodingData data) {
    return WifiOrApName(isAp: data.dec(_f$isAp), name: data.dec(_f$name));
  }

  @override
  final Function instantiate = _instantiate;

  static WifiOrApName fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<WifiOrApName>(map);
  }

  static WifiOrApName fromJson(String json) {
    return ensureInitialized().decodeJson<WifiOrApName>(json);
  }
}

mixin WifiOrApNameMappable {
  String toJson() {
    return WifiOrApNameMapper.ensureInitialized()
        .encodeJson<WifiOrApName>(this as WifiOrApName);
  }

  Map<String, dynamic> toMap() {
    return WifiOrApNameMapper.ensureInitialized()
        .encodeMap<WifiOrApName>(this as WifiOrApName);
  }

  WifiOrApNameCopyWith<WifiOrApName, WifiOrApName, WifiOrApName> get copyWith =>
      _WifiOrApNameCopyWithImpl(this as WifiOrApName, $identity, $identity);
  @override
  String toString() {
    return WifiOrApNameMapper.ensureInitialized()
        .stringifyValue(this as WifiOrApName);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            WifiOrApNameMapper.ensureInitialized()
                .isValueEqual(this as WifiOrApName, other));
  }

  @override
  int get hashCode {
    return WifiOrApNameMapper.ensureInitialized()
        .hashValue(this as WifiOrApName);
  }
}

extension WifiOrApNameValueCopy<$R, $Out>
    on ObjectCopyWith<$R, WifiOrApName, $Out> {
  WifiOrApNameCopyWith<$R, WifiOrApName, $Out> get $asWifiOrApName =>
      $base.as((v, t, t2) => _WifiOrApNameCopyWithImpl(v, t, t2));
}

abstract class WifiOrApNameCopyWith<$R, $In extends WifiOrApName, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({bool? isAp, String? name});
  WifiOrApNameCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _WifiOrApNameCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, WifiOrApName, $Out>
    implements WifiOrApNameCopyWith<$R, WifiOrApName, $Out> {
  _WifiOrApNameCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<WifiOrApName> $mapper =
      WifiOrApNameMapper.ensureInitialized();
  @override
  $R call({bool? isAp, String? name}) => $apply(FieldCopyWithData(
      {if (isAp != null) #isAp: isAp, if (name != null) #name: name}));
  @override
  WifiOrApName $make(CopyWithData data) => WifiOrApName(
      isAp: data.get(#isAp, or: $value.isAp),
      name: data.get(#name, or: $value.name));

  @override
  WifiOrApNameCopyWith<$R2, WifiOrApName, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _WifiOrApNameCopyWithImpl($value, $cast, t);
}
