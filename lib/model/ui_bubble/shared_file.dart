import 'dart:io';

import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ui_bubble/shareable.dart';
import 'package:flix/utils/drawin_file_security_extension.dart';
import 'package:flix/utils/file/file_helper.dart';
import 'package:flix/utils/string_util.dart';
import 'package:path/path.dart' as path_utils;

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

  DirectoryMeta(
      {required this.name,
      required this.size,
      this.path,
      this.groupId});

  DirectoryMeta fromJson(Map<String, dynamic> json){
    return DirectoryMeta.fromJson(json);
  }

  factory DirectoryMeta.fromJson(Map<String, dynamic> json) {
    return DirectoryMeta(
        name: json['name'],
        size: json['size'],
        path: json['path'],
    );
  }

  Map<String, dynamic> toJson({required FilePathSaveType pathSaveType}) {
    final map = {
      'name': name,
      'size': size,
    };
    if (pathSaveType == FilePathSaveType.full) {
      if (path != null) {
        map['path'] = path!;
      }
    } else if (pathSaveType == FilePathSaveType.relative) {
      map['path'] = '${Platform.pathSeparator}$name';
    }
    return map;
  }

  String get rootPath => (path ?? '').removeSubstring(name);

  DirectoryMeta copy(
      {
        String? name,
        int? size,
        String? path,
        String? groupId}) {
    return DirectoryMeta(
        name: name ?? this.name,
        size: size ?? this.size,
        path: path ?? this.path,
        groupId: groupId ?? this.groupId);
  }

  @override
  String toString() {
    return 'name: $name, size: $size, path: $path, root path=$rootPath';
  }
}

class FileMeta with DrawinFileSecurityExtension {
  final String resourceId;
  final String name;
  final String mimeType;
  final String nameWithSuffix;
  final int size;
  String? path;
  DirectoryMeta? parent;

  // 图片和视频文件的款高度
  final int width;
  final int height;

  FileMeta(
      {required this.resourceId,
      required this.name,
      required this.mimeType,
      required this.nameWithSuffix,
      required this.size,
      this.path, this.parent,
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

  Map<String, dynamic> toJson({required FilePathSaveType pathSaveType}) {
    final map = {
      'name': name,
      'mimeType': mimeType,
      'nameWithSuffix': nameWithSuffix,
      'size': size,
      'width': width,
      'height': height,
    };
    if (pathSaveType == FilePathSaveType.full) {
      map['resourceId'] = resourceId;
      if (path != null) {
        map['path'] = path!;
      }
    } else if (pathSaveType == FilePathSaveType.relative) {
      map['resourceId'] = resourceId;
      if (parent != null && path != null) {
        map['path'] = getRelativePath(path!, parent!.rootPath);
      }
    }
    talker.debug("path 111 pathSaveType=$pathSaveType mp=${map['path']} , path=$path rootPath=${parent?.rootPath} , map=${map}");
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
      int? height,
      DirectoryMeta? parent}) {
    return FileMeta(
        resourceId: resourceId ?? this.resourceId,
        name: name ?? this.name,
        mimeType: mimeType ?? this.mimeType,
        nameWithSuffix: nameWithSuffix ?? this.nameWithSuffix,
        size: size ?? this.size,
        path: path ?? this.path,
        width: width ?? this.width,
        height: height ?? this.height,
        parent: parent ?? this.parent,
    );
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
