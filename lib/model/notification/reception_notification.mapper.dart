// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'reception_notification.dart';

class ReceptionNotificationMapper
    extends ClassMapperBase<ReceptionNotification> {
  ReceptionNotificationMapper._();

  static ReceptionNotificationMapper? _instance;
  static ReceptionNotificationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ReceptionNotificationMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'ReceptionNotification';

  static String _$from(ReceptionNotification v) => v.from;
  static const Field<ReceptionNotification, String> _f$from =
      Field('from', _$from);
  static String _$bubbleId(ReceptionNotification v) => v.bubbleId;
  static const Field<ReceptionNotification, String> _f$bubbleId =
      Field('bubbleId', _$bubbleId);

  @override
  final Map<Symbol, Field<ReceptionNotification, dynamic>> fields = const {
    #from: _f$from,
    #bubbleId: _f$bubbleId,
  };

  static ReceptionNotification _instantiate(DecodingData data) {
    return ReceptionNotification(
        from: data.dec(_f$from), bubbleId: data.dec(_f$bubbleId));
  }

  @override
  final Function instantiate = _instantiate;

  static ReceptionNotification fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ReceptionNotification>(map);
  }

  static ReceptionNotification fromJson(String json) {
    return ensureInitialized().decodeJson<ReceptionNotification>(json);
  }
}

mixin ReceptionNotificationMappable {
  String toJson() {
    return ReceptionNotificationMapper.ensureInitialized()
        .encodeJson<ReceptionNotification>(this as ReceptionNotification);
  }

  Map<String, dynamic> toMap() {
    return ReceptionNotificationMapper.ensureInitialized()
        .encodeMap<ReceptionNotification>(this as ReceptionNotification);
  }

  ReceptionNotificationCopyWith<ReceptionNotification, ReceptionNotification,
          ReceptionNotification>
      get copyWith => _ReceptionNotificationCopyWithImpl(
          this as ReceptionNotification, $identity, $identity);
  @override
  String toString() {
    return ReceptionNotificationMapper.ensureInitialized()
        .stringifyValue(this as ReceptionNotification);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            ReceptionNotificationMapper.ensureInitialized()
                .isValueEqual(this as ReceptionNotification, other));
  }

  @override
  int get hashCode {
    return ReceptionNotificationMapper.ensureInitialized()
        .hashValue(this as ReceptionNotification);
  }
}

extension ReceptionNotificationValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ReceptionNotification, $Out> {
  ReceptionNotificationCopyWith<$R, ReceptionNotification, $Out>
      get $asReceptionNotification =>
          $base.as((v, t, t2) => _ReceptionNotificationCopyWithImpl(v, t, t2));
}

abstract class ReceptionNotificationCopyWith<
    $R,
    $In extends ReceptionNotification,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? from, String? bubbleId});
  ReceptionNotificationCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _ReceptionNotificationCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ReceptionNotification, $Out>
    implements ReceptionNotificationCopyWith<$R, ReceptionNotification, $Out> {
  _ReceptionNotificationCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ReceptionNotification> $mapper =
      ReceptionNotificationMapper.ensureInitialized();
  @override
  $R call({String? from, String? bubbleId}) => $apply(FieldCopyWithData({
        if (from != null) #from: from,
        if (bubbleId != null) #bubbleId: bubbleId
      }));
  @override
  ReceptionNotification $make(CopyWithData data) => ReceptionNotification(
      from: data.get(#from, or: $value.from),
      bubbleId: data.get(#bubbleId, or: $value.bubbleId));

  @override
  ReceptionNotificationCopyWith<$R2, ReceptionNotification, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _ReceptionNotificationCopyWithImpl($value, $cast, t);
}
