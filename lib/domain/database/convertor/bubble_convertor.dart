import 'package:flix/domain/database/database.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:flix/model/ui_bubble/shared_file.dart';

PrimitiveBubble fromDBEntity(BubbleEntity bubbleEntity, dynamic content) {
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
          content: fromFileContent(content as FileContent));
    default:
      throw UnimplementedError();
  }
}

String fromTextContent(TextContent textContent) {
  return textContent.content;
}

FileTransfer fromFileContent(FileContent fileContent) {
  return FileTransfer(
      state: FileState.values[fileContent.state],
      progress: fileContent.progress,
      speed: fileContent.speed,
      meta: FileMeta(
          resourceId: fileContent.resourceId,
          name: fileContent.name,
          mimeType: fileContent.mimeType,
          nameWithSuffix: fileContent.nameWithSuffix,
          size: fileContent.size,
          path: fileContent.path,
          width: fileContent.width,
          height: fileContent.height));
}
