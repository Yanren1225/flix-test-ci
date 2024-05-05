// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'ship_command.dart';

class ShipCommandMapper extends ClassMapperBase<ShipCommand> {
  ShipCommandMapper._();

  static ShipCommandMapper? _instance;
  static ShipCommandMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ShipCommandMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ShipCommand';

  static String _$command(ShipCommand v) => v.command;
  static const Field<ShipCommand, String> _f$command =
      Field('command', _$command);
  static dynamic _$data(ShipCommand v) => v.data;
  static const Field<ShipCommand, dynamic> _f$data =
      Field('data', _$data, opt: true);

  @override
  final Map<Symbol, Field<ShipCommand, dynamic>> fields = const {
    #command: _f$command,
    #data: _f$data,
  };

  static ShipCommand _instantiate(DecodingData data) {
    return ShipCommand(data.dec(_f$command), data.dec(_f$data));
  }

  @override
  final Function instantiate = _instantiate;

  static ShipCommand fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ShipCommand>(map);
  }

  static ShipCommand fromJson(String json) {
    return ensureInitialized().decodeJson<ShipCommand>(json);
  }
}

mixin ShipCommandMappable {
  String toJson() {
    return ShipCommandMapper.ensureInitialized()
        .encodeJson<ShipCommand>(this as ShipCommand);
  }

  Map<String, dynamic> toMap() {
    return ShipCommandMapper.ensureInitialized()
        .encodeMap<ShipCommand>(this as ShipCommand);
  }

  ShipCommandCopyWith<ShipCommand, ShipCommand, ShipCommand> get copyWith =>
      _ShipCommandCopyWithImpl(this as ShipCommand, $identity, $identity);
  @override
  String toString() {
    return ShipCommandMapper.ensureInitialized()
        .stringifyValue(this as ShipCommand);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            ShipCommandMapper.ensureInitialized()
                .isValueEqual(this as ShipCommand, other));
  }

  @override
  int get hashCode {
    return ShipCommandMapper.ensureInitialized().hashValue(this as ShipCommand);
  }
}

extension ShipCommandValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ShipCommand, $Out> {
  ShipCommandCopyWith<$R, ShipCommand, $Out> get $asShipCommand =>
      $base.as((v, t, t2) => _ShipCommandCopyWithImpl(v, t, t2));
}

abstract class ShipCommandCopyWith<$R, $In extends ShipCommand, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? command, dynamic data});
  ShipCommandCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ShipCommandCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ShipCommand, $Out>
    implements ShipCommandCopyWith<$R, ShipCommand, $Out> {
  _ShipCommandCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ShipCommand> $mapper =
      ShipCommandMapper.ensureInitialized();
  @override
  $R call({String? command, Object? data = $none}) => $apply(FieldCopyWithData({
        if (command != null) #command: command,
        if (data != $none) #data: data
      }));
  @override
  ShipCommand $make(CopyWithData data) => ShipCommand(
      data.get(#command, or: $value.command), data.get(#data, or: $value.data));

  @override
  ShipCommandCopyWith<$R2, ShipCommand, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _ShipCommandCopyWithImpl($value, $cast, t);
}
