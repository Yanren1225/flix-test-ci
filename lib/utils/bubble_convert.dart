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
          content: sharedText.content,
          time: bubbleEntity.time!);
    case BubbleType.Image:
    case BubbleType.Video:
    case BubbleType.File:
    case BubbleType.App:
      final sharedFile = bubbleEntity.shareable as SharedFile;
      return PrimitiveFileBubble(
          id: sharedFile.id,
          from: bubbleEntity.from,
          to: bubbleEntity.to,
          type: bubbleEntity.type,
          time: bubbleEntity.time!,
          content: FileTransfer(
              meta: sharedFile.content,
              progress: sharedFile.progress,
              state: sharedFile.state));
    default:
      throw UnimplementedError('Unknown bubble type: ${bubbleEntity.type}');
  }
}

UIBubble toUIBubble(PrimitiveBubble bubble) {
  switch (bubble.type) {
    case BubbleType.Time:
      var currentBubble = UIBubble(
          from: bubble.from,
          to: bubble.to,
          type: bubble.type,
          time: bubble.time,
          shareable: SharedText(
              id: bubble.id, content: ''), selectable: false);
      currentBubble.time = bubble.time;
      return currentBubble;
    case BubbleType.Text:
      var currentBubble = UIBubble(
          from: bubble.from,
          to: bubble.to,
          type: bubble.type,
          time: bubble.time,
          shareable: SharedText(
              id: bubble.id, content: (bubble as PrimitiveTextBubble).content));
      currentBubble.time = bubble.time;
      return currentBubble;
    case BubbleType.Image:
    case BubbleType.Video:
    case BubbleType.App:
    case BubbleType.File:
      final primitive = (bubble as PrimitiveFileBubble);
      var currentBubble = UIBubble(
          time: bubble.time,
          from: bubble.from,
          to: bubble.to,
          type: bubble.type,
          shareable: SharedFile(
              id: bubble.id,
              state: primitive.content.state,
              progress: primitive.content.progress,
              speed: primitive.content.speed,
              content: primitive.content.meta));
      currentBubble.time = primitive.time;
      return currentBubble;
    default:
      throw UnimplementedError();
  }
}
