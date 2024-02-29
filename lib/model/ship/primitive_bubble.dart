import 'package:anydrop/model/ui_bubble/shared_file.dart';
import 'package:anydrop/presentation/widgets/bubbles/share_bubble.dart';
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
      case BubbleType.Video:
      case BubbleType.App:
      case BubbleType.File:
        return PrimitiveFileBubble.fromJson(json);
      default:
        throw UnimplementedError();
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
      'content': content,
    };
  }

  PrimitiveTextBubble({
    required this.id,
    required this.from,
    required this.to,
    required this.type,
    required this.content,
  });

  @override
  String toString() {
    return 'id: $id, from: $from, to: $to, type: $type, content: $content';
  }
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

  @override
  String toString() {
    return 'id: $id, from: $from, to: $to, type: $type, content: $content';
  }
}

class FileTransfer {
  late double progress;
  late FileState state;
  late FileMeta meta;

  FileTransfer({this.state = FileState.unknown, this.progress = 0.0, required this.meta });

  FileTransfer.fromJson(Map<String, dynamic> json) {
    state = FileState.values[json['state'] as int];
    progress = json['progress'] as double;
    meta = FileMeta.fromJson(json['meta'] as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return {'state': state.index, 'progress': progress, 'meta': meta.toJson()};
  }

  FileTransfer copy({FileState? state, double? progress, FileMeta? meta}) {
    return FileTransfer(state: state ?? this.state, progress : progress ?? this.progress, meta: meta ?? this.meta);
  }

  @override
  String toString() {
    return 'progress: $progress, state: $state, meta: $meta';
  }
}

enum BubbleType { Text, Image, Video, File, App }

abstract class InVisibleBubble<Content> extends PrimitiveBubble<Content> {}

class UpdateFileStateBubble extends InVisibleBubble<FileState> {
  @override
  late String id;

  @override
  late String from;

  @override
  late String to;

  @override
  late BubbleType type;

  @override
  late FileState content;

  UpdateFileStateBubble.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    from = json['from'] as String;
    to = json['to'] as String;
    final typeOrdinal = json['type'] as int;
    final type = BubbleType.values[typeOrdinal];
    this.type = type;
    content = FileState.values[json['content'] as int];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'type': type.index,
      'content': content.index,
    };
  }

  UpdateFileStateBubble({
    required this.id,
    required this.from,
    required this.to,
    required this.type,
    required this.content,
  });

}
