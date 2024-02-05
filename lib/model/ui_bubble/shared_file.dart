import 'package:androp/model/shareable.dart';
import 'package:file_selector/file_selector.dart';

class SharedFile extends Shareable<XFile?> {
  @override
  final String id;

  FileShareState shareState;

  FileMeta meta;

  @override
  final XFile? content;

  SharedFile(
      {required this.id,
      required this.meta,
      this.content,
      this.shareState = FileShareState.unknown});
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

enum FileShareState {
  /// unknown state.
  unknown,

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
