import 'dart:ffi';

import 'package:flix/domain/constants.dart';
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

  Map<String, dynamic> toJson({bool full = false});
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
  Map<String, dynamic> toJson({bool full = false}) {
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
  Map<String, dynamic> toJson({bool full = false}) {
    return {
      'id': id,
      'from': from,
      'to': to,
      'type': type.index,
      'content': content.toJson(full: full),
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
  late int speed;
  late FileState state;
  late FileMeta meta;
  bool waitingForAccept = true;
  late int receiveBytes;

  FileTransfer(
      {this.state = FileState.unknown,
      this.progress = 0.0,
      this.speed = 0,
      this.receiveBytes = 0,
      required this.meta,
      this.waitingForAccept = true});

  FileTransfer.fromJson(Map<String, dynamic> json) {
    state = FileState.values[json['state'] as int];
    progress = json['progress'] as double;
    speed = json['speed'] as int? ?? 0;
    receiveBytes = json[Constants.receiveBytes] as int? ?? 0;
    meta = FileMeta.fromJson(json['meta'] as Map<String, dynamic>);
    waitingForAccept = json['waitingForAccept'] ?? true;
  }

  Map<String, dynamic> toJson({bool full = false}) {
    final map = {
      'state': state.index,
      'progress': progress,
      'speed': speed,
      'receiveBytes': receiveBytes,
      'meta': meta.toJson(full: full)
    };
    if (full) {
      map['waitingForAccept'] = waitingForAccept;
    }
    return map;
  }

  FileTransfer copy(
      {FileState? state,
      double? progress,
      int? speed,
      int? receiveBytes,
      FileMeta? meta,
      bool? waitingForAccept}) {
    return FileTransfer(
        state: state ?? this.state,
        progress: progress ?? this.progress,
        speed: speed ?? this.speed,
        meta: meta ?? this.meta,
        receiveBytes: receiveBytes ?? this.receiveBytes ,
        waitingForAccept: waitingForAccept ?? this.waitingForAccept);
  }

  @override
  String toString() {
    return 'FileTransfer{progress: $progress, speed: $speed, state: $state, meta: $meta, waitingForAccept: $waitingForAccept, receiveBytes: $receiveBytes}';
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
  Map<String, dynamic> toJson({bool full = false}) {
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
