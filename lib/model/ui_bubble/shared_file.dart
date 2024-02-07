import 'package:androp/model/ui_bubble/shareable.dart';
import 'package:file_selector/file_selector.dart';

class SharedFile extends Shareable<FileMeta> {
  @override
  final String id;

  FileState state;

  // 发送或者接收的进度, 范围：0~1
  double progress;

  @override
  FileMeta content;

  SharedFile(
      {required this.id,
      required this.content,
      this.state = FileState.unknown,
      this.progress = 0});
}

class FileMeta {
  final String name;
  final String mimeType;
  final String nameWithSuffix;
  final int size;
  final String? path;

  FileMeta(
      {required this.name,
      required this.mimeType,
      required this.nameWithSuffix,
      required this.size,
      this.path});

  FileMeta.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        mimeType = json['mimeType'],
        nameWithSuffix = json['nameWithSuffix'],
        size = json['size'],
        path = null;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mimeType': mimeType,
      'nameWithSuffix': nameWithSuffix,
      'size': size,
    };
  }

  FileMeta copy(
      {String? name,
      String? mimeType,
      String? nameWithSuffix,
      int? size,
      String? path}) {
    return FileMeta(
        name: name ?? this.name,
        mimeType: mimeType ?? this.mimeType,
        nameWithSuffix: nameWithSuffix ?? this.nameWithSuffix,
        size: size ?? this.size,
        path: path ?? this.path);
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
