import 'dart:ffi';

import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/presentation/widgets/bubbles/bubble_widget.dart';
import 'package:http/http.dart';

abstract class PrimitiveBubble<Content> {
  String get id;

  String get from;

  String get to;

  BubbleType get type;

  Content get content;

  int time = DateTime.now().millisecondsSinceEpoch;

  static PrimitiveBubble<dynamic> fromJson(Map<String, dynamic> json) {
    final typeOrdinal = json['type'] as int;
    final type = BubbleType.values[typeOrdinal];
    switch (type) {
      case BubbleType.Text:
        PrimitiveTextBubble textBubble = PrimitiveTextBubble.fromJson(json);
        return textBubble;
      case BubbleType.Image:
      case BubbleType.Video:
      case BubbleType.App:
      case BubbleType.File:
        PrimitiveFileBubble fileBubble = PrimitiveFileBubble.fromJson(json);
        return fileBubble;
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

  @override
  late int time;

  PrimitiveTextBubble.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    from = json['from'] as String;
    to = json['to'] as String;
    final typeOrdinal = json['type'] as int;
    final type = BubbleType.values[typeOrdinal];
    this.type = type;
    content = json['content'] as String;
    time = json['time'] ?? 0x7FFFFFFFFFFFFFFF;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'type': type.index,
      'content': content,
      'time': time
    };
  }

  PrimitiveTextBubble(
      {required this.id,
      required this.from,
      required this.to,
      required this.type,
      required this.content,
      required this.time});

  @override
  String toString() {
    return 'PrimitiveTextBubble{id: $id, from: $from, to: $to, type: $type, content: $content, time: $time}';
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

  @override
  late int time;

  PrimitiveFileBubble.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    from = json['from'] as String;
    to = json['to'] as String;
    final typeOrdinal = json['type'] as int;
    final type = BubbleType.values[typeOrdinal];
    this.type = type;
    time = json['time'] ?? 0x7FFFFFFFFFFFFFFF;
    content = FileTransfer.fromJson(json['content'] as Map<String, dynamic>);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'type': type.index,
      'content': content.toJson(),
      'time': time
    };
  }

  PrimitiveFileBubble copy(
      {String? id,
      String? from,
      String? to,
      BubbleType? type,
      FileTransfer? content,
      int? time}) {
    var fileBubble = PrimitiveFileBubble(
        id: id ?? this.id,
        from: from ?? this.from,
        to: to ?? this.to,
        type: type ?? this.type,
        content: content ?? this.content,
        time: time ?? this.time);
    return fileBubble;
  }

  PrimitiveFileBubble(
      {required this.id,
      required this.from,
      required this.to,
      required this.type,
      required this.content,
      required this.time});

  @override
  String toString() {
    return 'PrimitiveFileBubble{id: $id, from: $from, to: $to, type: $type, content: $content, time: $time}';
  }
}

class PrimitiveTimeBubble extends PrimitiveTextBubble {
  PrimitiveTimeBubble(
      {required super.id,
      required super.from,
      required super.to,
      required super.type,
      required super.content,
      required super.time});
}

class FileTransfer {
  late double progress;
  late FileState state;
  late FileMeta meta;
  bool waitingForAccept = true;

  FileTransfer(
      {this.state = FileState.unknown,
      this.progress = 0.0,
      required this.meta,
      this.waitingForAccept = true});

  FileTransfer.fromJson(Map<String, dynamic> json) {
    state = FileState.values[json['state'] as int];
    progress = json['progress'] as double;
    meta = FileMeta.fromJson(json['meta'] as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return {'state': state.index, 'progress': progress, 'meta': meta.toJson()};
  }

  FileTransfer copy(
      {FileState? state,
      double? progress,
      FileMeta? meta,
      bool? waitingForAccept}) {
    return FileTransfer(
        state: state ?? this.state,
        progress: progress ?? this.progress,
        meta: meta ?? this.meta,
        waitingForAccept: waitingForAccept ?? this.waitingForAccept);
  }

  @override
  String toString() {
    return 'progress: $progress, state: $state, meta: $meta';
  }
}

enum BubbleType { Text, Image, Video, File, App, Time }

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
  late int time;

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
    time = json['time'] ?? 0x7FFFFFFFFFFFFFFF;
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'from': from,
      'to': to,
      'type': type.index,
      'content': content.index,
      'time': time
    };
  }

  UpdateFileStateBubble(
      {required this.id,
      required this.from,
      required this.to,
      required this.type,
      required this.content,
      required this.time});

  @override
  String toString() {
    return 'UpdateFileStateBubble{id: $id, from: $from, to: $to, type: $type, time: $time, content: $content}';
  }
}
