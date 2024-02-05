import '../model/ui_bubble/shared_file.dart';
import '../model/ui_bubble/ui_bubble.dart';
import '../model/shareable.dart';
import '../model/ship/primitive_bubble.dart';

PrimitiveBubble fromBubbleEntity(UIBubble bubbleEntity) {
  if (bubbleEntity.shareable is SharedText) {
    final sharedText = bubbleEntity.shareable as SharedText;
    return PrimitiveTextBubble(
        id: sharedText.id,
        from: bubbleEntity.from,
        to: bubbleEntity.to,
        type: BubbleType.Text,
        content: sharedText.content);
  } else if (bubbleEntity.shareable is SharedFile) {
    final sharedFile = bubbleEntity.shareable as SharedFile;
    return PrimitiveFileBubble(
        id: sharedFile.id,
        from: bubbleEntity.from,
        to: bubbleEntity.to,
        type: BubbleType.File,
        content: FileTransfer(
            meta: sharedFile.meta, state: sharedFile.shareState));
  } else if (bubbleEntity.shareable is SharedImage) {
    final sharedFile = bubbleEntity.shareable as SharedImage;
    return PrimitiveFileBubble(
        id: sharedFile.id,
        from: bubbleEntity.from,
        to: bubbleEntity.to,
        type: BubbleType.Image,
        content: FileTransfer(
            meta: sharedFile.content, state: FileShareState.inTransit));
  } else {
    throw UnimplementedError();
  }
}

UIBubble toBubbleEntity(PrimitiveBubble bubble) {
  switch (bubble.type) {
    case BubbleType.Text:
      return UIBubble(
          from: bubble.from,
          to: bubble.to,
          shareable: SharedText(
              id: bubble.id,
              content: (bubble as PrimitiveTextBubble).content));
    case BubbleType.Image:
      final primitive = (bubble as PrimitiveFileBubble);
      return UIBubble(
          from: bubble.from,
          to: bubble.to,
          shareable:
          SharedImage(id: bubble.id, content: primitive.content.meta));
    case BubbleType.Video:
      throw UnimplementedError();
    case BubbleType.File:
      final primitive = (bubble as PrimitiveFileBubble);
      return UIBubble(
          from: bubble.from,
          to: bubble.to,
          shareable: SharedFile(
              id: bubble.id,
              shareState: primitive.content.state,
              meta: primitive.content.meta));
  }
}