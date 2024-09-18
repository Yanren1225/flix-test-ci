// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'device_modal.dart';

class DeviceTypeMapper extends EnumMapper<DeviceType> {
  DeviceTypeMapper._();

  static DeviceTypeMapper? _instance;
  static DeviceTypeMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DeviceTypeMapper._());
    }
    return _instance!;
  }

  static DeviceType fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  DeviceType decode(dynamic value) {
    switch (value) {
      case 'mobile':
        return DeviceType.mobile;
      case 'desktop':
        return DeviceType.desktop;
      case 'web':
        return DeviceType.web;
      case 'headless':
        return DeviceType.headless;
      case 'server':
        return DeviceType.server;
      default:
        return DeviceType.values[1];
    }
  }

  @override
  dynamic encode(DeviceType self) {
    switch (self) {
      case DeviceType.mobile:
        return 'mobile';
      case DeviceType.desktop:
        return 'desktop';
      case DeviceType.web:
        return 'web';
      case DeviceType.headless:
        return 'headless';
      case DeviceType.server:
        return 'server';
    }
  }
}

extension DeviceTypeMapperExtension on DeviceType {
  String toValue() {
    DeviceTypeMapper.ensureInitialized();
    return MapperContainer.globals.toValue<DeviceType>(this) as String;
  }
}

class DeviceModalMapper extends ClassMapperBase<DeviceModal> {
  DeviceModalMapper._();

  static DeviceModalMapper? _instance;
  static DeviceModalMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = DeviceModalMapper._());
      DeviceTypeMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'DeviceModal';

  static String _$alias(DeviceModal v) => v.alias;
  static const Field<DeviceModal, String> _f$alias = Field('alias', _$alias);
  static String? _$deviceModel(DeviceModal v) => v.deviceModel;
  static const Field<DeviceModal, String> _f$deviceModel =
      Field('deviceModel', _$deviceModel);
  static DeviceType? _$deviceType(DeviceModal v) => v.deviceType;
  static const Field<DeviceModal, DeviceType> _f$deviceType =
      Field('deviceType', _$deviceType);
  static String _$fingerprint(DeviceModal v) => v.fingerprint;
  static const Field<DeviceModal, String> _f$fingerprint =
      Field('fingerprint', _$fingerprint);
  static int? _$port(DeviceModal v) => v.port;
  static const Field<DeviceModal, int> _f$port = Field('port', _$port);
  static int? _$version(DeviceModal v) => v.version;
  static const Field<DeviceModal, int> _f$version = Field('version', _$version);
  static String _$ip(DeviceModal v) => v.ip;
  static const Field<DeviceModal, String> _f$ip =
      Field('ip', _$ip, opt: true, def: '');
  static String _$host(DeviceModal v) => v.host;
  static const Field<DeviceModal, String> _f$host =
      Field('host', _$host, opt: true, def: '');
  static String _$from(DeviceModal v) => v.from;
  static const Field<DeviceModal, String> _f$from =
      Field('from', _$from, opt: true, def: '');

  @override
  final Map<Symbol, Field<DeviceModal, dynamic>> fields = const {
    #alias: _f$alias,
    #deviceModel: _f$deviceModel,
    #deviceType: _f$deviceType,
    #fingerprint: _f$fingerprint,
    #port: _f$port,
    #version: _f$version,
    #ip: _f$ip,
    #host: _f$host,
    #from: _f$from,
  };

  static DeviceModal _instantiate(DecodingData data) {
    return DeviceModal(
        alias: data.dec(_f$alias),
        deviceModel: data.dec(_f$deviceModel),
        deviceType: data.dec(_f$deviceType),
        fingerprint: data.dec(_f$fingerprint),
        port: data.dec(_f$port),
        version: data.dec(_f$version),
        ip: data.dec(_f$ip),
        host: data.dec(_f$host),
        from: data.dec(_f$from));
  }

  @override
  final Function instantiate = _instantiate;

  static DeviceModal fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<DeviceModal>(map);
  }

  static DeviceModal fromJson(String json) {
    return ensureInitialized().decodeJson<DeviceModal>(json);
  }
}

mixin DeviceModalMappable {
  String toJson() {
    return DeviceModalMapper.ensureInitialized()
        .encodeJson<DeviceModal>(this as DeviceModal);
  }

  Map<String, dynamic> toMap() {
    return DeviceModalMapper.ensureInitialized()
        .encodeMap<DeviceModal>(this as DeviceModal);
  }

  DeviceModalCopyWith<DeviceModal, DeviceModal, DeviceModal> get copyWith =>
      _DeviceModalCopyWithImpl(this as DeviceModal, $identity, $identity);
  @override
  String toString() {
    return DeviceModalMapper.ensureInitialized()
        .stringifyValue(this as DeviceModal);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            DeviceModalMapper.ensureInitialized()
                .isValueEqual(this as DeviceModal, other));
  }

  @override
  int get hashCode {
    return DeviceModalMapper.ensureInitialized().hashValue(this as DeviceModal);
  }
}

extension DeviceModalValueCopy<$R, $Out>
    on ObjectCopyWith<$R, DeviceModal, $Out> {
  DeviceModalCopyWith<$R, DeviceModal, $Out> get $asDeviceModal =>
      $base.as((v, t, t2) => _DeviceModalCopyWithImpl(v, t, t2));
}

abstract class DeviceModalCopyWith<$R, $In extends DeviceModal, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call(
      {String? alias,
      String? deviceModel,
      DeviceType? deviceType,
      String? fingerprint,
      int? port,
      int? version,
      String? ip,
      String? host,
      String? from});
  DeviceModalCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _DeviceModalCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, DeviceModal, $Out>
    implements DeviceModalCopyWith<$R, DeviceModal, $Out> {
  _DeviceModalCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<DeviceModal> $mapper =
      DeviceModalMapper.ensureInitialized();
  @override
  $R call(
          {String? alias,
          Object? deviceModel = $none,
          Object? deviceType = $none,
          String? fingerprint,
          Object? port = $none,
          Object? version = $none,
          String? ip,
          String? host,
          String? from}) =>
      $apply(FieldCopyWithData({
        if (alias != null) #alias: alias,
        if (deviceModel != $none) #deviceModel: deviceModel,
        if (deviceType != $none) #deviceType: deviceType,
        if (fingerprint != null) #fingerprint: fingerprint,
        if (port != $none) #port: port,
        if (version != $none) #version: version,
        if (ip != null) #ip: ip,
        if (host != null) #host: host,
        if (from != null) #from: from
      }));
  @override
  DeviceModal $make(CopyWithData data) => DeviceModal(
      alias: data.get(#alias, or: $value.alias),
      deviceModel: data.get(#deviceModel, or: $value.deviceModel),
      deviceType: data.get(#deviceType, or: $value.deviceType),
      fingerprint: data.get(#fingerprint, or: $value.fingerprint),
      port: data.get(#port, or: $value.port),
      version: data.get(#version, or: $value.version),
      ip: data.get(#ip, or: $value.ip),
      host: data.get(#host, or: $value.host),
      from: data.get(#from, or: $value.from));

  @override
  DeviceModalCopyWith<$R2, DeviceModal, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _DeviceModalCopyWithImpl($value, $cast, t);
}
