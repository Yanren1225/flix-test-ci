import 'dart:convert';
import 'dart:ffi';

import 'package:flix/domain/constants.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';
import 'package:flix/utils/file/file_helper.dart';

abstract class PrimitiveBubble<Content> {
  String get id;

  String get from;

  String get to;

  BubbleType get type;

  Content get content;

  int time = DateTime.now().millisecondsSinceEpoch;

  String? get groupId;

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
      case BubbleType.Directory:
        return PrimitiveDirectoryBubble.fromJson(json);
      default:
        throw UnimplementedError();
    }
  }

  Map<String, dynamic> toJson({required FilePathSaveType pathSaveType});
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
  
  @override
  late String? groupId;

  PrimitiveTextBubble.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    from = json['from'] as String;
    to = json['to'] as String;
    final typeOrdinal = json['type'] as int;
    final type = BubbleType.values[typeOrdinal];
    this.type = type;
    content = json['content'] as String;
    groupId = json['groupId'];
    time = json['time'] ?? 0x7FFFFFFFFFFFFFFF;
  }

  @override
  Map<String, dynamic> toJson({FilePathSaveType pathSaveType = FilePathSaveType.none}) {
    return {
      'id': id,
      'from': from,
      'to': to,
      'type': type.index,
      'content': content,
      'time': time,
      'groupId': groupId
    };
  }

  PrimitiveTextBubble(
      {required this.id,
      required this.from,
      required this.to,
      required this.type,
      required this.content,
      required this.time,
      this.groupId});

  @override
  String toString() {
    return 'PrimitiveTextBubble{id: $id, from: $from, to: $to, type: $type, content: $content, time: $time ,groupId: $groupId}';
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

  String? groupId;

  PrimitiveFileBubble.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    from = json['from'] as String;
    to = json['to'] as String;
    final typeOrdinal = json['type'] as int;
    final type = BubbleType.values[typeOrdinal];
    this.type = type;
    time = json['time'] ?? 0x7FFFFFFFFFFFFFFF;
    content = FileTransfer.fromJson(json['content'] as Map<String, dynamic>);
    groupId = json['groupId'];
  }

  @override
  Map<String, dynamic> toJson({required FilePathSaveType pathSaveType}) {
    return {
      'id': id,
      'from': from,
      'to': to,
      'type': type.index,
      'content': content.toJson(pathSaveType: pathSaveType),
      'time': time,
      'groupId': groupId
    };
  }

  PrimitiveFileBubble copy(
      {String? id,
      String? from,
      String? to,
      BubbleType? type,
      FileTransfer? content,
      int? time,
      String? groupId,}) {
    var fileBubble = PrimitiveFileBubble(
        id: id ?? this.id,
        from: from ?? this.from,
        to: to ?? this.to,
        type: type ?? this.type,
        content: content ?? this.content,
        time: time ?? this.time,
        groupId: groupId ?? this.groupId,
    );
    return fileBubble;
  }

  PrimitiveFileBubble(
      {required this.id,
      required this.from,
      required this.to,
      required this.type,
      required this.content,
      required this.time,
      required this.groupId});

  @override
  String toString() {
    return 'PrimitiveFileBubble{id: $id, from: $from, to: $to, type: $type, content: $content, time: $time, groupId: $groupId}';
  }
}

class PrimitiveDirectoryBubble extends PrimitiveBubble<DirectoryTransfer> {
  @override
  late String id;

  @override
  late String from;

  @override
  late String to;

  @override
  BubbleType type = BubbleType.Directory;

  @override
  late DirectoryTransfer content;

  @override
  late int time;

  @override
  late String? groupId;

  // DirectoryTransfer transfer() => DirectoryTransfer.get(content);

  PrimitiveDirectoryBubble.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    from = json['from'] as String;
    to = json['to'] as String;
    groupId = json['groupId'];
    final typeOrdinal = json['type'] as int;
    final type = BubbleType.values[typeOrdinal];
    this.type = type;
    time = json['time'] ?? 0x7FFFFFFFFFFFFFFF;
    content = DirectoryTransfer.fromJson(json['content']);
  }

  @override
  Map<String, dynamic> toJson({required FilePathSaveType pathSaveType}) {
    return {
      'id': id,
      'from': from,
      'to': to,
      'type': type.index,
      'content': content.toJson(pathSaveType: pathSaveType),
      'time': time,
      'groupId': groupId
    };
  }

  PrimitiveDirectoryBubble copy(
      {String? id,
      String? from,
      String? to,
      BubbleType? type,
      DirectoryTransfer? content,
      int? time,
      String? groupId}) {
    var fileBubble = PrimitiveDirectoryBubble(
        id: id ?? this.id,
        from: from ?? this.from,
        to: to ?? this.to,
        type: type ?? this.type,
        content: content ?? this.content,
        time: time ?? this.time,
        groupId: groupId ?? this.groupId);
    return fileBubble;
  }

  PrimitiveDirectoryBubble(
      {required this.id,
      required this.from,
      required this.to,
      required this.type,
      required this.content,
      required this.time,
      this.groupId});

  @override
  String toString() {
    return 'PrimitiveDirectoryBubble{id: $id, from: $from, to: $to, type: $type, content: $content, time: $time}';
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
    state = FileState.values[json['state'] ?? FileState.unknown.index];
    progress = json['progress'] ?? 0.0;
    speed = json['speed'] as int? ?? 0;
    receiveBytes = json[Constants.receiveBytes] as int? ?? 0;
    meta = FileMeta.fromJson(json['meta'] as Map<String, dynamic>);
    waitingForAccept = json['waitingForAccept'] ?? true;
  }

  Map<String, dynamic> toJson({required FilePathSaveType pathSaveType}) {
    final map = {
      'state': state.index,
      'progress': progress,
      'speed': speed,
      'receiveBytes': receiveBytes,
      'meta': meta.toJson(pathSaveType: pathSaveType)
    };
    if (pathSaveType != FilePathSaveType.none) {
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

class DirectoryTransfer {
  late final DirectoryMeta meta;
  late final List<PrimitiveFileBubble> _fileBubbles;
  late bool waitingForAccept = true;
  late FileState _state;

  DirectoryTransfer({
    required this.meta,
    required List<PrimitiveFileBubble> fileBubbles,
    this.waitingForAccept = true,
    FileState state = FileState.unknown,
  }) {
    _state = state;
    _fileBubbles = fileBubbles;
  }

  DirectoryTransfer._internal(this.meta,
      this._fileBubbles,
      this._state,
      this.waitingForAccept);

  Future<List<PrimitiveFileBubble>> copyContentList(
      PrimitiveFileBubble Function(PrimitiveFileBubble) fileBubble) async {
    return _fileBubbles.map((e) => fileBubble(e)).toList();
  }

  factory DirectoryTransfer.fromJson(Map<String, dynamic> json) {
    final meta = DirectoryMeta.fromJson(json['meta'] as Map<String, dynamic>);
    return DirectoryTransfer(
        state: FileState.values[json['state'] ?? FileState.unknown.index],
        meta: meta,
        waitingForAccept: json['waitingForAccept'] ?? true,
        fileBubbles: (json['fileBubbles'] as List<dynamic>).map((m) {
          final fileBubble = PrimitiveFileBubble.fromJson(m);
          return fileBubble.copy(
              content: fileBubble.content
                  .copy(meta: fileBubble.content.meta.copy(parent: meta)));
        }).toList());
  }

  Map<String, dynamic> toJson({required FilePathSaveType pathSaveType}) {
    final map = {
      'state': state.index,
      'meta': meta.toJson(pathSaveType: pathSaveType),
      'fileBubbles': _fileBubbles
          .map((fileBubble) => fileBubble.toJson(pathSaveType: pathSaveType))
          .toList(),
    };
    if (pathSaveType != FilePathSaveType.none) {
      map['waitingForAccept'] = waitingForAccept;
    }
    return map;
  }

  DirectoryTransfer copy(
      {DirectoryMeta? meta, bool? waitingForAccept, FileState? state}) {
    if (waitingForAccept != null || state != null) {
      copyContentList((p0) {
        if (waitingForAccept != null) {
          p0.content.waitingForAccept = waitingForAccept;
        }
        if (state != null) {
          p0.content.state = state;
        }
        return p0;
      });
    }
    return DirectoryTransfer._internal(
        meta ?? this.meta,
        _fileBubbles,
        state ?? _state,
        waitingForAccept ?? this.waitingForAccept);
  }

  @override
  String toString() {
    return 'DirectoryTransfer = progress=$progress, speed=$speed, state=$state, '
        'receiveBytes=$receiveBytes, sendSize=$sendSize, '
        'receiveSize=$receiveSize, fileBubbles=${fileBubbles.length}';
  }

  double get progress=> ((fileBubbles.fold(0.0,
          (previousValue, element) => previousValue + element.content.progress)) /sendSize);

  int get speed {
    int inTransitSize = 0;
    int s = 0;
    for (var element in fileBubbles) {
      if (s != 0 || element.content.state == FileState.inTransit) {
        inTransitSize++;
        s += s;
      }
    }
    return inTransitSize == 0 ? 0 : s ~/ inTransitSize;
  }

  FileState get state {
    FileState state = _state;
    FileState? lastState;
    bool stateSingle = true;
    // 当发送被取消或者已经传输完成时，不再通过子气泡更新状态
    bool nonCheckState = (state == FileState.cancelled ||
        state == FileState.completed || state == FileState.picked);

    for (var bubble in fileBubbles) {
      if (!nonCheckState) {
        // 只保存批量状态
        if (bubble.content.state == FileState.picked ||
            bubble.content.state == FileState.waitToAccepted ||
            bubble.content.state == FileState.inTransit) {
          state = bubble.content.state;
        }
        if (lastState == null) {
          lastState = bubble.content.state;
        } else if (lastState != bubble.content.state) {
          stateSingle = false;
        }
        lastState = bubble.content.state;
      }
    }
    if (stateSingle && lastState != null) {
      state = lastState;
    }
    return state;
  }

  int get receiveBytes => fileBubbles.fold(0,
      (previousValue, element) => previousValue + element.content.receiveBytes);

  int get sendSize => fileBubbles.length;

  int get receiveSize => fileBubbles.fold(
      0, (previousValue, element) => previousValue +
      ((element.content.state == FileState.completed ||
          element.content.state == FileState.receiveCompleted ||
          element.content.state == FileState.sendCompleted) ? 1 : 0));

  List<PrimitiveFileBubble> get fileBubbles => _fileBubbles;
}

enum BubbleType { Text, Image, Video, File, App, Time, Directory }

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

  @override
  late String? groupId;

  UpdateFileStateBubble.fromJson(Map<String, dynamic> json) {
    id = json['id'] as String;
    from = json['from'] as String;
    to = json['to'] as String;
    groupId = json['groupId'];
    final typeOrdinal = json['type'] as int;
    final type = BubbleType.values[typeOrdinal];
    this.type = type;
    content = FileState.values[json['content'] as int];
    time = json['time'] ?? 0x7FFFFFFFFFFFFFFF;
  }

  @override
  Map<String, dynamic> toJson({required FilePathSaveType pathSaveType}) {
    return {
      'id': id,
      'from': from,
      'to': to,
      'type': type.index,
      'content': content.index,
      'time': time,
      'groupId': groupId
    };
  }

  UpdateFileStateBubble(
      {required this.id,
      required this.from,
      required this.to,
      required this.type,
      required this.content,
      required this.time,
      this.groupId});

  @override
  String toString() {
    return 'UpdateFileStateBubble{id: $id, from: $from, to: $to, type: $type, time: $time, content: $content, groupId=$groupId}';
  }
}
