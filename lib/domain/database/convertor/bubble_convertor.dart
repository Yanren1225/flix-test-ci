import 'package:androp/domain/database/database.dart';
import 'package:androp/model/ship/primitive_bubble.dart';
import 'package:androp/model/ui_bubble/shared_file.dart';

PrimitiveBubble fromDBEntity(BubbleEntity bubbleEntity, dynamic content) {
  switch (BubbleType.values[bubbleEntity.type]) {
    case BubbleType.Text:
      return PrimitiveTextBubble(
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
      meta: FileMeta(
          name: fileContent.name,
          mimeType: fileContent.mimeType,
          nameWithSuffix: fileContent.nameWithSuffix,
          size: fileContent.size,
          path: fileContent.path));
}
