// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'hotspot_info.dart';

class HotspotInfoMapper extends ClassMapperBase<HotspotInfo> {
  HotspotInfoMapper._();

  static HotspotInfoMapper? _instance;
  static HotspotInfoMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = HotspotInfoMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'HotspotInfo';

  static String _$ssid(HotspotInfo v) => v.ssid;
  static const Field<HotspotInfo, String> _f$ssid = Field('ssid', _$ssid);
  static String _$key(HotspotInfo v) => v.key;
  static const Field<HotspotInfo, String> _f$key = Field('key', _$key);

  @override
  final Map<Symbol, Field<HotspotInfo, dynamic>> fields = const {
    #ssid: _f$ssid,
    #key: _f$key,
  };

  static HotspotInfo _instantiate(DecodingData data) {
    return HotspotInfo(ssid: data.dec(_f$ssid), key: data.dec(_f$key));
  }

  @override
  final Function instantiate = _instantiate;

  static HotspotInfo fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<HotspotInfo>(map);
  }

  static HotspotInfo fromJson(String json) {
    return ensureInitialized().decodeJson<HotspotInfo>(json);
  }
}

mixin HotspotInfoMappable {
  String toJson() {
    return HotspotInfoMapper.ensureInitialized()
        .encodeJson<HotspotInfo>(this as HotspotInfo);
  }

  Map<String, dynamic> toMap() {
    return HotspotInfoMapper.ensureInitialized()
        .encodeMap<HotspotInfo>(this as HotspotInfo);
  }

  HotspotInfoCopyWith<HotspotInfo, HotspotInfo, HotspotInfo> get copyWith =>
      _HotspotInfoCopyWithImpl(this as HotspotInfo, $identity, $identity);
  @override
  String toString() {
    return HotspotInfoMapper.ensureInitialized()
        .stringifyValue(this as HotspotInfo);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            HotspotInfoMapper.ensureInitialized()
                .isValueEqual(this as HotspotInfo, other));
  }

  @override
  int get hashCode {
    return HotspotInfoMapper.ensureInitialized().hashValue(this as HotspotInfo);
  }
}

extension HotspotInfoValueCopy<$R, $Out>
    on ObjectCopyWith<$R, HotspotInfo, $Out> {
  HotspotInfoCopyWith<$R, HotspotInfo, $Out> get $asHotspotInfo =>
      $base.as((v, t, t2) => _HotspotInfoCopyWithImpl(v, t, t2));
}

abstract class HotspotInfoCopyWith<$R, $In extends HotspotInfo, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? ssid, String? key});
  HotspotInfoCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _HotspotInfoCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, HotspotInfo, $Out>
    implements HotspotInfoCopyWith<$R, HotspotInfo, $Out> {
  _HotspotInfoCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<HotspotInfo> $mapper =
      HotspotInfoMapper.ensureInitialized();
  @override
  $R call({String? ssid, String? key}) => $apply(FieldCopyWithData(
      {if (ssid != null) #ssid: ssid, if (key != null) #key: key}));
  @override
  HotspotInfo $make(CopyWithData data) => HotspotInfo(
      ssid: data.get(#ssid, or: $value.ssid),
      key: data.get(#key, or: $value.key));

  @override
  HotspotInfoCopyWith<$R2, HotspotInfo, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _HotspotInfoCopyWithImpl($value, $cast, t);
}
