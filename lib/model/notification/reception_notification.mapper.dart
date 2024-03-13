// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'reception_notification.dart';

class MessageNotificationMapper extends ClassMapperBase<MessageNotification> {
  MessageNotificationMapper._();

  static MessageNotificationMapper? _instance;
  static MessageNotificationMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = MessageNotificationMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'MessageNotification';

  static String _$from(MessageNotification v) => v.from;
  static const Field<MessageNotification, String> _f$from =
      Field('from', _$from);
  static String _$bubbleId(MessageNotification v) => v.bubbleId;
  static const Field<MessageNotification, String> _f$bubbleId =
      Field('bubbleId', _$bubbleId);

  @override
  final Map<Symbol, Field<MessageNotification, dynamic>> fields = const {
    #from: _f$from,
    #bubbleId: _f$bubbleId,
  };

  static MessageNotification _instantiate(DecodingData data) {
    return MessageNotification(
        from: data.dec(_f$from), bubbleId: data.dec(_f$bubbleId));
  }

  @override
  final Function instantiate = _instantiate;

  static MessageNotification fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<MessageNotification>(map);
  }

  static MessageNotification fromJson(String json) {
    return ensureInitialized().decodeJson<MessageNotification>(json);
  }
}

mixin MessageNotificationMappable {
  String toJson() {
    return MessageNotificationMapper.ensureInitialized()
        .encodeJson<MessageNotification>(this as MessageNotification);
  }

  Map<String, dynamic> toMap() {
    return MessageNotificationMapper.ensureInitialized()
        .encodeMap<MessageNotification>(this as MessageNotification);
  }

  MessageNotificationCopyWith<MessageNotification, MessageNotification,
          MessageNotification>
      get copyWith => _MessageNotificationCopyWithImpl(
          this as MessageNotification, $identity, $identity);
  @override
  String toString() {
    return MessageNotificationMapper.ensureInitialized()
        .stringifyValue(this as MessageNotification);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            MessageNotificationMapper.ensureInitialized()
                .isValueEqual(this as MessageNotification, other));
  }

  @override
  int get hashCode {
    return MessageNotificationMapper.ensureInitialized()
        .hashValue(this as MessageNotification);
  }
}

extension MessageNotificationValueCopy<$R, $Out>
    on ObjectCopyWith<$R, MessageNotification, $Out> {
  MessageNotificationCopyWith<$R, MessageNotification, $Out>
      get $asMessageNotification =>
          $base.as((v, t, t2) => _MessageNotificationCopyWithImpl(v, t, t2));
}

abstract class MessageNotificationCopyWith<$R, $In extends MessageNotification,
    $Out> implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? from, String? bubbleId});
  MessageNotificationCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(
      Then<$Out2, $R2> t);
}

class _MessageNotificationCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, MessageNotification, $Out>
    implements MessageNotificationCopyWith<$R, MessageNotification, $Out> {
  _MessageNotificationCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<MessageNotification> $mapper =
      MessageNotificationMapper.ensureInitialized();
  @override
  $R call({String? from, String? bubbleId}) => $apply(FieldCopyWithData({
        if (from != null) #from: from,
        if (bubbleId != null) #bubbleId: bubbleId
      }));
  @override
  MessageNotification $make(CopyWithData data) => MessageNotification(
      from: data.get(#from, or: $value.from),
      bubbleId: data.get(#bubbleId, or: $value.bubbleId));

  @override
  MessageNotificationCopyWith<$R2, MessageNotification, $Out2>
      $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
          _MessageNotificationCopyWithImpl($value, $cast, t);
}
