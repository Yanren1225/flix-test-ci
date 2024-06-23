import 'package:flix/model/ui_bubble/shareable.dart';
import 'package:flix/utils/drawin_file_security_extension.dart';

class SharedFile extends Shareable<FileMeta> {
  @override
  final String id;

  FileState state;

  // 发送或者接收的进度, 范围：0~1
  double progress;

  int speed;

  @override
  FileMeta content;

  String? groupId;

  SharedFile(
      {required this.id,
      required this.content,
      this.state = FileState.unknown,
      this.progress = 0,
      this.speed = 0,
      this.groupId});
}

class SharedDirectory extends Shareable<List<SharedFile>> {
  @override
  final String id;

  FileState state;

  // 发送或者接收的进度, 范围：0~1
  double progress;

  int speed;

  @override
  List<SharedFile> content;

  late DirectoryMeta meta;

  SharedDirectory({
    required this.id,
    required this.content,
    required this.meta,
    required this.state,
    this.progress = 0,
    this.speed = 0,
  });
}

class DirectoryMeta {
  final String name;
  final int size;
  String? path;
  String? groupId;
  // List<FileMeta>? metas;

  DirectoryMeta({required this.name, required this.size, this.path,/* this.metas,*/this.groupId});

  DirectoryMeta fromJson(Map<String, dynamic> json){
    return DirectoryMeta.fromJson(json);
  }

  factory DirectoryMeta.fromJson(Map<String, dynamic> json) {
    return DirectoryMeta(
        name: json['name'],
        size: json['size'],
        path: json['path'],
      /*  metas: (json['metas'] as List<dynamic>)
            .map((m) => FileMeta.fromJson(m))
            .toList()*/);
  }

  Map<String, dynamic> toJson({bool full = false}) {
    final map = {
      'name': name,
      'size': size,
      // 'metas': metas?.map((fileMeta) => fileMeta.toJson(full: full)).toList()
    };
    if (full) {
      if (path != null) {
        map['path'] = path!;
      }
    }
    return map;
  }

  DirectoryMeta copy(
      {
        String? resourceId,
        String? name,
        String? mimeType,
        String? nameWithSuffix,
        int? size,
        String? path,
        int? width,
        int? height,
        String? groupId,
        List<FileMeta>? metas}) {
    return DirectoryMeta(
        name: name ?? this.name,
        size: size ?? this.size,
        path: path ?? this.path,
        groupId: groupId ?? this.groupId,/*
        metas: metas ?? this.metas*/);
  }

  @override
  String toString() {
    return 'name: $name, size: $size, path: $path';
  }
}

class FileMeta with DrawinFileSecurityExtension {
  final String resourceId;
  final String name;
  final String mimeType;
  final String nameWithSuffix;
  final int size;
  String? path;

  // 图片和视频文件的款高度
  final int width;
  final int height;

  FileMeta(
      {required this.resourceId,
      required this.name,
      required this.mimeType,
      required this.nameWithSuffix,
      required this.size,
      this.path,
      this.width = 0,
      this.height = 0});

  FileMeta.fromJson(Map<String, dynamic> json)
      : resourceId = json['resourceId'] ?? '',
        name = json['name'],
        mimeType = json['mimeType'],
        nameWithSuffix = json['nameWithSuffix'],
        size = json['size'],
        path = json['path'],
        width = json['width'],
        height = json['height'];

  Map<String, dynamic> toJson({bool full = false}) {
    final map = {
      'name': name,
      'mimeType': mimeType,
      'nameWithSuffix': nameWithSuffix,
      'size': size,
      'width': width,
      'height': height,
    };
    if (full) {
      map['resourceId'] = resourceId;
      if (path != null) {
        map['path'] = path!;
      }
    }
    return map;
  }

  FileMeta copy(
      {String? resourceId,
      String? name,
      String? mimeType,
      String? nameWithSuffix,
      int? size,
      String? path,
      int? width,
      int? height}) {
    return FileMeta(
        resourceId: resourceId ?? this.resourceId,
        name: name ?? this.name,
        mimeType: mimeType ?? this.mimeType,
        nameWithSuffix: nameWithSuffix ?? this.nameWithSuffix,
        size: size ?? this.size,
        path: path ?? this.path,
        width: width ?? this.width,
        height: height ?? this.height);
  }

  @override
  String toString() {
    return 'resourceId: $resourceId, name: $name, mimeType: $mimeType, nameWithSuffix: $nameWithSuffix, size: $size, path: $path, width: $width, height: $height';
  }
}

enum FileState {
  /// unknown state.
  unknown,

  /// 文件被选择
  picked,

  /// The file is wait to accepted.
  waitToAccepted,

  /// The file is being shared.
  inTransit,

  /// The file sharing has been cancelled.
  cancelled,

  /// 完成文件发送
  sendCompleted,

  /// 完成文件接收
  receiveCompleted,

  /// The file sharing has been completed.
  completed,

  /// 文件发送失败
  sendFailed,

  /// 文件接收失败
  receiveFailed,

  /// The file sharing has failed.
  failed;
}
