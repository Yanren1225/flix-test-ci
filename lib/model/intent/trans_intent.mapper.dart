// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'trans_intent.dart';

class TransActionMapper extends EnumMapper<TransAction> {
  TransActionMapper._();

  static TransActionMapper? _instance;
  static TransActionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TransActionMapper._());
    }
    return _instance!;
  }

  static TransAction fromValue(dynamic value) {
    ensureInitialized();
    return MapperContainer.globals.fromValue(value);
  }

  @override
  TransAction decode(dynamic value) {
    switch (value) {
      case 'confirmReceive':
        return TransAction.confirmReceive;
      case 'askBreakPoint':
        return TransAction.askBreakPoint;
      case 'confirmBreakPoint':
        return TransAction.confirmBreakPoint;
      case 'askPairDevice':
        return TransAction.askPairDevice;
      case 'confirmPairDevice':
        return TransAction.confirmPairDevice;
      case 'deletePairDevice':
        return TransAction.deletePairDevice;
      case 'confirmDeletePairDevice':
        return TransAction.confirmDeletePairDevice;
      case 'clipboard':
        return TransAction.clipboard;
      case 'cancel':
        return TransAction.cancel;
      default:
        throw MapperException.unknownEnumValue(value);
    }
  }

  @override
  dynamic encode(TransAction self) {
    switch (self) {
      case TransAction.confirmReceive:
        return 'confirmReceive';
      case TransAction.askBreakPoint:
        return 'askBreakPoint';
      case TransAction.confirmBreakPoint:
        return 'confirmBreakPoint';
      case TransAction.askPairDevice:
        return 'askPairDevice';
      case TransAction.confirmPairDevice:
        return 'confirmPairDevice';
      case TransAction.deletePairDevice:
        return 'deletePairDevice';
      case TransAction.confirmDeletePairDevice:
        return 'confirmDeletePairDevice';
      case TransAction.clipboard:
        return 'clipboard';
      case TransAction.cancel:
        return 'cancel';
    }
  }
}

extension TransActionMapperExtension on TransAction {
  String toValue() {
    TransActionMapper.ensureInitialized();
    return MapperContainer.globals.toValue<TransAction>(this) as String;
  }
}

class TransIntentMapper extends ClassMapperBase<TransIntent> {
  TransIntentMapper._();

  static TransIntentMapper? _instance;
  static TransIntentMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = TransIntentMapper._());
      TransActionMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'TransIntent';

  static String _$deviceId(TransIntent v) => v.deviceId;
  static const Field<TransIntent, String> _f$deviceId =
      Field('deviceId', _$deviceId);
  static String _$bubbleId(TransIntent v) => v.bubbleId;
  static const Field<TransIntent, String> _f$bubbleId =
      Field('bubbleId', _$bubbleId);
  static TransAction _$action(TransIntent v) => v.action;
  static const Field<TransIntent, TransAction> _f$action =
      Field('action', _$action);
  static Map<String, Object>? _$extra(TransIntent v) => v.extra;
  static const Field<TransIntent, Map<String, Object>> _f$extra =
      Field('extra', _$extra, opt: true);

  @override
  final Map<Symbol, Field<TransIntent, dynamic>> fields = const {
    #deviceId: _f$deviceId,
    #bubbleId: _f$bubbleId,
    #action: _f$action,
    #extra: _f$extra,
  };

  static TransIntent _instantiate(DecodingData data) {
    return TransIntent(
        deviceId: data.dec(_f$deviceId),
        bubbleId: data.dec(_f$bubbleId),
        action: data.dec(_f$action),
        extra: data.dec(_f$extra));
  }

  @override
  final Function instantiate = _instantiate;

  static TransIntent fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<TransIntent>(map);
  }

  static TransIntent fromJson(String json) {
    return ensureInitialized().decodeJson<TransIntent>(json);
  }
}

mixin TransIntentMappable {
  String toJson() {
    return TransIntentMapper.ensureInitialized()
        .encodeJson<TransIntent>(this as TransIntent);
  }

  Map<String, dynamic> toMap() {
    return TransIntentMapper.ensureInitialized()
        .encodeMap<TransIntent>(this as TransIntent);
  }

  TransIntentCopyWith<TransIntent, TransIntent, TransIntent> get copyWith =>
      _TransIntentCopyWithImpl(this as TransIntent, $identity, $identity);
  @override
  String toString() {
    return TransIntentMapper.ensureInitialized()
        .stringifyValue(this as TransIntent);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            TransIntentMapper.ensureInitialized()
                .isValueEqual(this as TransIntent, other));
  }

  @override
  int get hashCode {
    return TransIntentMapper.ensureInitialized().hashValue(this as TransIntent);
  }
}

extension TransIntentValueCopy<$R, $Out>
    on ObjectCopyWith<$R, TransIntent, $Out> {
  TransIntentCopyWith<$R, TransIntent, $Out> get $asTransIntent =>
      $base.as((v, t, t2) => _TransIntentCopyWithImpl(v, t, t2));
}

abstract class TransIntentCopyWith<$R, $In extends TransIntent, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  MapCopyWith<$R, String, Object, ObjectCopyWith<$R, Object, Object>>?
      get extra;
  $R call(
      {String? deviceId,
      String? bubbleId,
      TransAction? action,
      Map<String, Object>? extra});
  TransIntentCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _TransIntentCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, TransIntent, $Out>
    implements TransIntentCopyWith<$R, TransIntent, $Out> {
  _TransIntentCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<TransIntent> $mapper =
      TransIntentMapper.ensureInitialized();
  @override
  MapCopyWith<$R, String, Object, ObjectCopyWith<$R, Object, Object>>?
      get extra => $value.extra != null
          ? MapCopyWith($value.extra!,
              (v, t) => ObjectCopyWith(v, $identity, t), (v) => call(extra: v))
          : null;
  @override
  $R call(
          {String? deviceId,
          String? bubbleId,
          TransAction? action,
          Object? extra = $none}) =>
      $apply(FieldCopyWithData({
        if (deviceId != null) #deviceId: deviceId,
        if (bubbleId != null) #bubbleId: bubbleId,
        if (action != null) #action: action,
        if (extra != $none) #extra: extra
      }));
  @override
  TransIntent $make(CopyWithData data) => TransIntent(
      deviceId: data.get(#deviceId, or: $value.deviceId),
      bubbleId: data.get(#bubbleId, or: $value.bubbleId),
      action: data.get(#action, or: $value.action),
      extra: data.get(#extra, or: $value.extra));

  @override
  TransIntentCopyWith<$R2, TransIntent, $Out2> $chain<$R2, $Out2>(
          Then<$Out2, $R2> t) =>
      _TransIntentCopyWithImpl($value, $cast, t);
}
