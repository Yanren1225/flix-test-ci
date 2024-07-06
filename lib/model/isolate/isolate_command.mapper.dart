// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'isolate_command.dart';

class IsolateCommandMapper extends ClassMapperBase<IsolateCommand> {
  IsolateCommandMapper._();

  static IsolateCommandMapper? _instance;
  static IsolateCommandMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = IsolateCommandMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'IsolateCommand';

  static String _$command(IsolateCommand v) => v.command;
  static const Field<IsolateCommand, String> _f$command =
      Field('command', _$command);
  static dynamic _$data(IsolateCommand v) => v.data;
  static const Field<IsolateCommand, dynamic> _f$data =
      Field('data', _$data, opt: true);

  @override
  final Map<Symbol, Field<IsolateCommand, dynamic>> fields = const {
    #command: _f$command,
    #data: _f$data,
  };

  static IsolateCommand _instantiate(DecodingData data) {
    return IsolateCommand(data.dec(_f$command), data.dec(_f$data));
  }

  @override
  final Function instantiate = _instantiate;

  static IsolateCommand fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<IsolateCommand>(map);
  }

  static IsolateCommand fromJson(String json) {
    return ensureInitialized().decodeJson<IsolateCommand>(json);
  }
}

mixin IsolateCommandMappable {
  String toJson() {
    return IsolateCommandMapper.ensureInitialized()
        .encodeJson<IsolateCommand>(this as IsolateCommand);
  }

  Map<String, dynamic> toMap() {
    return IsolateCommandMapper.ensureInitialized()
        .encodeMap<IsolateCommand>(this as IsolateCommand);
  }

  IsolateCommandCopyWith<IsolateCommand, IsolateCommand, IsolateCommand>
      get copyWith => _IsolateCommandCopyWithImpl(
          this as IsolateCommand, $identity, $identity);
  @override
  String toString() {
    return IsolateCommandMapper.ensureInitialized()
        .stringifyValue(this as IsolateCommand);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            IsolateCommandMapper.ensureInitialized()
                .isValueEqual(this as IsolateCommand, other));
  }

  @override
  int get hashCode {
    return IsolateCommandMapper.ensureInitialized()
        .hashValue(this as IsolateCommand);
  }
}

extension IsolateCommandValueCopy<$R, $Out>
    on ObjectCopyWith<$R, IsolateCommand, $Out> {
  IsolateCommandCopyWith<$R, IsolateCommand, $Out> get $asIsolateCommand =>
      $base.as((v, t, t2) => _IsolateCommandCopyWithImpl(v, t, t2));
}

abstract class IsolateCommandCopyWith<$R, $In extends IsolateCommand, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? command, dynamic data});
  IsolateCommandCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _IsolateCommandCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, IsolateCommand, $Out>
    implements IsolateCommandCopyWith<$R, IsolateCommand, $Out> {
  _IsolateCommandCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<IsolateCommand> $mapper =
      IsolateCommandMapper.ensureInitialized();
  @override
  $R call({String? command, Object? data = $none}) => $apply(FieldCopyWithData({
        if (command != null) #command: command,
        if (data != $none) #data: data
      }));
  @override
  IsolateCommand $make(CopyWithData data) => IsolateCommand(
      data.get(#command, or: $value.command), data.get(#data, or: $value.data));

  @override
  IsolateCommandCopyWith<$R2, IsolateCommand, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _IsolateCommandCopyWithImpl($value, $cast, t);
}
