import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';

Future<PrimitiveBubble?> fromDBEntity(BubbleEntity bubbleEntity, dynamic content) async {
  switch (BubbleType.values[bubbleEntity.type]) {
    case BubbleType.Text:
      return PrimitiveTextBubble(
          time: bubbleEntity.time,
          id: bubbleEntity.id,
          from: bubbleEntity.fromDevice,
          to: bubbleEntity.toDevice,
          type: BubbleType.values[bubbleEntity.type],
          content: fromTextContent(content as TextContent));
    case BubbleType.File:
    case BubbleType.Image:
    case BubbleType.Video:
    case BubbleType.App:
      return PrimitiveFileBubble(
          time: bubbleEntity.time,
          id: bubbleEntity.id,
          from: bubbleEntity.fromDevice,
          to: bubbleEntity.toDevice,
          type: BubbleType.values[bubbleEntity.type],
          content: fromFileContent(content as FileContent, null),
          groupId: bubbleEntity.groupId);
    case BubbleType.Directory:
      final fileList = await appDatabase.bubblesDao.getContentsByGroupId(
          content.id, BubbleType.File.index) as List<FileContent>;
      return PrimitiveDirectoryBubble(
          time: bubbleEntity.time,
          id: bubbleEntity.id,
          from: bubbleEntity.fromDevice,
          to: bubbleEntity.toDevice,
          type: BubbleType.values[bubbleEntity.type],
          content: fromDirectoryContent(content, fileList, bubbleEntity));
    default:
      throw UnimplementedError();
  }
}

String fromTextContent(TextContent textContent) {
  return textContent.content;
}

FileTransfer fromFileContent(FileContent fileContent, DirectoryMeta? directoryMeta) {
  return FileTransfer(
      state: FileState.values[fileContent.state],
      progress: fileContent.progress,
      speed: fileContent.speed,
      waitingForAccept: fileContent.waitingForAccept,
      receiveBytes: fileContent.size,
      meta: FileMeta(
          resourceId: fileContent.resourceId,
          name: fileContent.name,
          mimeType: fileContent.mimeType,
          nameWithSuffix: fileContent.nameWithSuffix,
          size: fileContent.size,
          path: fileContent.path,
          width: fileContent.width,
          height: fileContent.height,
          parent: directoryMeta));
}

DirectoryTransfer fromDirectoryContent(DirectoryContent content,
    List<FileContent> fileList, BubbleEntity bubbleEntity) {
  final meta =
      DirectoryMeta(name: content.name, size: content.size, path: content.path);
  return DirectoryTransfer(
      waitingForAccept: content.waitingForAccept,
      state: FileState.values[content.state],
      meta: meta,
      fileBubbles: fileList
          .map((e) => PrimitiveFileBubble(
              time: bubbleEntity.time,
              id: e.id,
              from: bubbleEntity.fromDevice,
              to: bubbleEntity.toDevice,
              groupId: bubbleEntity.id,
              type: BubbleType.File,
              content: fromFileContent(e, meta)))
          .toList());
}
