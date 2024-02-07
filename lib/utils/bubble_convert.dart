import '../model/ui_bubble/shared_file.dart';
import '../model/ui_bubble/ui_bubble.dart';
import '../model/ui_bubble/shareable.dart';
import '../model/ship/primitive_bubble.dart';

PrimitiveBubble fromUIBubble(UIBubble bubbleEntity) {
  switch (bubbleEntity.type) {
    case BubbleType.Text:
      final sharedText = bubbleEntity.shareable as SharedText;
      return PrimitiveTextBubble(
          id: sharedText.id,
          from: bubbleEntity.from,
          to: bubbleEntity.to,
          type: BubbleType.Text,
          content: sharedText.content);
      case BubbleType.Image:
    case BubbleType.Video:
    case BubbleType.File:
    final sharedFile = bubbleEntity.shareable as SharedFile;
    return PrimitiveFileBubble(
        id: sharedFile.id,
        from: bubbleEntity.from,
        to: bubbleEntity.to,
        type: BubbleType.File,
        content: FileTransfer(
            meta: sharedFile.content, state: sharedFile.state));
    case BubbleType.App:
      throw UnimplementedError();
  }
}

UIBubble toUIBubble(PrimitiveBubble bubble) {
  switch (bubble.type) {
    case BubbleType.Text:
      return UIBubble(
          from: bubble.from,
          to: bubble.to,
          type: bubble.type,
          shareable: SharedText(
              id: bubble.id,
              content: (bubble as PrimitiveTextBubble).content));
    case BubbleType.Image:
    case BubbleType.Video:
    case BubbleType.File:
      final primitive = (bubble as PrimitiveFileBubble);
      return UIBubble(
          from: bubble.from,
          to: bubble.to,
          type: bubble.type,
          shareable: SharedFile(
              id: bubble.id,
              state: primitive.content.state,
              content: primitive.content.meta));
    case BubbleType.App:
      throw UnimplementedError();
  }
}