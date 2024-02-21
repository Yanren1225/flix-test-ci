// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'ping_pong.dart';

class PingMapper extends ClassMapperBase<Ping> {
  PingMapper._();

  static PingMapper? _instance;
  static PingMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PingMapper._());
      DeviceModalMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Ping';

  static DeviceModal _$deviceModal(Ping v) => v.deviceModal;
  static const Field<Ping, DeviceModal> _f$deviceModal =
      Field('deviceModal', _$deviceModal);

  @override
  final Map<Symbol, Field<Ping, dynamic>> fields = const {
    #deviceModal: _f$deviceModal,
  };

  static Ping _instantiate(DecodingData data) {
    return Ping(data.dec(_f$deviceModal));
  }

  @override
  final Function instantiate = _instantiate;

  static Ping fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Ping>(map);
  }

  static Ping fromJson(String json) {
    return ensureInitialized().decodeJson<Ping>(json);
  }
}

mixin PingMappable {
  String toJson() {
    return PingMapper.ensureInitialized().encodeJson<Ping>(this as Ping);
  }

  Map<String, dynamic> toMap() {
    return PingMapper.ensureInitialized().encodeMap<Ping>(this as Ping);
  }

  PingCopyWith<Ping, Ping, Ping> get copyWith =>
      _PingCopyWithImpl(this as Ping, $identity, $identity);
  @override
  String toString() {
    return PingMapper.ensureInitialized().stringifyValue(this as Ping);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            PingMapper.ensureInitialized().isValueEqual(this as Ping, other));
  }

  @override
  int get hashCode {
    return PingMapper.ensureInitialized().hashValue(this as Ping);
  }
}

extension PingValueCopy<$R, $Out> on ObjectCopyWith<$R, Ping, $Out> {
  PingCopyWith<$R, Ping, $Out> get $asPing =>
      $base.as((v, t, t2) => _PingCopyWithImpl(v, t, t2));
}

abstract class PingCopyWith<$R, $In extends Ping, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  DeviceModalCopyWith<$R, DeviceModal, DeviceModal> get deviceModal;
  $R call({DeviceModal? deviceModal});
  PingCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PingCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Ping, $Out>
    implements PingCopyWith<$R, Ping, $Out> {
  _PingCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Ping> $mapper = PingMapper.ensureInitialized();
  @override
  DeviceModalCopyWith<$R, DeviceModal, DeviceModal> get deviceModal =>
      $value.deviceModal.copyWith.$chain((v) => call(deviceModal: v));
  @override
  $R call({DeviceModal? deviceModal}) => $apply(
      FieldCopyWithData({if (deviceModal != null) #deviceModal: deviceModal}));
  @override
  Ping $make(CopyWithData data) =>
      Ping(data.get(#deviceModal, or: $value.deviceModal));

  @override
  PingCopyWith<$R2, Ping, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _PingCopyWithImpl($value, $cast, t);
}

class PongMapper extends ClassMapperBase<Pong> {
  PongMapper._();

  static PongMapper? _instance;
  static PongMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = PongMapper._());
      DeviceModalMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Pong';

  static DeviceModal _$from(Pong v) => v.from;
  static const Field<Pong, DeviceModal> _f$from = Field('from', _$from);
  static DeviceModal _$to(Pong v) => v.to;
  static const Field<Pong, DeviceModal> _f$to = Field('to', _$to);

  @override
  final Map<Symbol, Field<Pong, dynamic>> fields = const {
    #from: _f$from,
    #to: _f$to,
  };

  static Pong _instantiate(DecodingData data) {
    return Pong(data.dec(_f$from), data.dec(_f$to));
  }

  @override
  final Function instantiate = _instantiate;

  static Pong fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Pong>(map);
  }

  static Pong fromJson(String json) {
    return ensureInitialized().decodeJson<Pong>(json);
  }
}

mixin PongMappable {
  String toJson() {
    return PongMapper.ensureInitialized().encodeJson<Pong>(this as Pong);
  }

  Map<String, dynamic> toMap() {
    return PongMapper.ensureInitialized().encodeMap<Pong>(this as Pong);
  }

  PongCopyWith<Pong, Pong, Pong> get copyWith =>
      _PongCopyWithImpl(this as Pong, $identity, $identity);
  @override
  String toString() {
    return PongMapper.ensureInitialized().stringifyValue(this as Pong);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            PongMapper.ensureInitialized().isValueEqual(this as Pong, other));
  }

  @override
  int get hashCode {
    return PongMapper.ensureInitialized().hashValue(this as Pong);
  }
}

extension PongValueCopy<$R, $Out> on ObjectCopyWith<$R, Pong, $Out> {
  PongCopyWith<$R, Pong, $Out> get $asPong =>
      $base.as((v, t, t2) => _PongCopyWithImpl(v, t, t2));
}

abstract class PongCopyWith<$R, $In extends Pong, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  DeviceModalCopyWith<$R, DeviceModal, DeviceModal> get from;
  DeviceModalCopyWith<$R, DeviceModal, DeviceModal> get to;
  $R call({DeviceModal? from, DeviceModal? to});
  PongCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _PongCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Pong, $Out>
    implements PongCopyWith<$R, Pong, $Out> {
  _PongCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Pong> $mapper = PongMapper.ensureInitialized();
  @override
  DeviceModalCopyWith<$R, DeviceModal, DeviceModal> get from =>
      $value.from.copyWith.$chain((v) => call(from: v));
  @override
  DeviceModalCopyWith<$R, DeviceModal, DeviceModal> get to =>
      $value.to.copyWith.$chain((v) => call(to: v));
  @override
  $R call({DeviceModal? from, DeviceModal? to}) => $apply(FieldCopyWithData(
      {if (from != null) #from: from, if (to != null) #to: to}));
  @override
  Pong $make(CopyWithData data) =>
      Pong(data.get(#from, or: $value.from), data.get(#to, or: $value.to));

  @override
  PongCopyWith<$R2, Pong, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _PongCopyWithImpl($value, $cast, t);
}
