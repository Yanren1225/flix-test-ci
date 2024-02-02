import 'package:androp/model/bubble/shared_file.dart';
import 'package:androp/presentation/widgets/share_bubble.dart';
import 'package:http/http.dart';

abstract class PrimitiveBubble<Content> {
  String get id;
  String get from;
  String get to;
  BubbleType get type;
  Content get content;

  static PrimitiveBubble<dynamic> fromJson(Map<String, dynamic> json) {
    final typeOrdinal = json['type'] as int;
    final type = BubbleType.values[typeOrdinal];

    switch (type) {
      case BubbleType.Text:
        return PrimitiveTextBubble.fromJson(json);
      case BubbleType.Image:
        return PrimitiveFileBubble.fromJson(json);
      case BubbleType.Video:
        return PrimitiveFileBubble.fromJson(json);
      case BubbleType.File:
        return PrimitiveFileBubble.fromJson(json);
    }
  }

  Map<String, dynamic> toJson();
}

class PrimitiveTextBubble extends PrimitiveBubble<String> {
  @override
  late String id;

  @override
  late String from;

  @override
  late String to;

  @override
  late BubbleType type;

  @override
  late String content;

  PrimitiveTextBubble.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    from = json['from'] as String;
    to = json['to'] as String;
    final typeOrdinal = json['type'] as int;
    final type = BubbleType.values[typeOrdinal];
    this.type = type;
    content = json['content'] as String;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'type': type.index,
      'content': content
    };
  }

  PrimitiveTextBubble({
    required this.id,
    required this.from,
    required this.to,
    required this.type,
    required this.content,
  });
}

class PrimitiveFileBubble extends PrimitiveBubble<FileTransfer> {
  @override
  late String id;

  @override
  late String from;

  @override
  late String to;

  @override
  late BubbleType type;

  @override
  late FileTransfer content;

  PrimitiveFileBubble.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    from = json['from'] as String;
    to = json['to'] as String;
    final typeOrdinal = json['type'] as int;
    final type = BubbleType.values[typeOrdinal];
    this.type = type;
    content = FileTransfer.fromJson(json['content'] as Map<String, dynamic>);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'type': type.index,
      'content': content.toJson()
    };
  }

  PrimitiveFileBubble copy(
      {String? id,
      String? from,
      String? to,
      BubbleType? type,
      FileTransfer? content}) {
    return PrimitiveFileBubble(
        id: id ?? this.id,
        from: from ?? this.from,
        to: to ?? this.to,
        type: type ?? this.type,
        content: content ?? this.content);
  }

  PrimitiveFileBubble({
    required this.id,
    required this.from,
    required this.to,
    required this.type,
    required this.content,
  });
}

class FileTransfer {
  late FileShareState state;
  late FileMeta meta;

  FileTransfer({this.state = FileShareState.unknown, required this.meta});

  FileTransfer.fromJson(Map<String, dynamic> json) {
    state = FileShareState.values[json['state'] as int];
    meta = FileMeta.fromJson(json['meta'] as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return {'state': state.index, 'meta': meta.toJson()};
  }

  FileTransfer copy({FileShareState? state, FileMeta? meta}) {
    return FileTransfer(state: state ?? this.state, meta: meta ?? this.meta);
  }
}

enum BubbleType { Text, Image, Video, File }
