import '../model/ship/primitive_bubble.dart';
import '../model/ui_bubble/shareable.dart';
import '../model/ui_bubble/shared_file.dart';
import '../model/ui_bubble/ui_bubble.dart';

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
          groupId: sharedFile.groupId,
          content: FileTransfer(
              meta: sharedFile.content,
              progress: sharedFile.progress,
              state: sharedFile.state));
    case BubbleType.Directory:
      final sharedDirectory = bubbleEntity.shareable as SharedDirectory;
      return PrimitiveDirectoryBubble(
          id: sharedDirectory.id,
          from: bubbleEntity.from,
          to: bubbleEntity.to,
          type: bubbleEntity.type,
          time: bubbleEntity.time,
          content: DirectoryTransfer(
              state: sharedDirectory.state,
              meta: sharedDirectory.meta,
              fileBubbles: sharedDirectory.content
                  .map((e) => PrimitiveFileBubble(
                      id: e.id,
                      from: bubbleEntity.from,
                      to: bubbleEntity.to,
                      type: BubbleType.File,
                      time: bubbleEntity.time,
                      groupId: sharedDirectory.id,
                      content: FileTransfer(
                          meta: e.content.copy(parent: sharedDirectory.meta),
                          progress: e.progress,
                          state: e.state)))
                  .toList()));
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
              groupId: bubble.groupId,
              state: primitive.content.state,
              progress: primitive.content.progress,
              speed: primitive.content.speed,
              content: primitive.content.meta));
      currentBubble.time = primitive.time;
      return currentBubble;
    case BubbleType.Directory:
      final primitive = (bubble as PrimitiveDirectoryBubble);
      var currentBubble = UIBubble(
          time: bubble.time,
          from: bubble.from,
          to: bubble.to,
          type: bubble.type,
          shareable: SharedDirectory(
              id: bubble.id,
              state: bubble.content.state,
              progress: bubble.content.progress,
              speed: bubble.content.speed,
              sendNum: bubble.content.sendNum,
              receiveNum: bubble.content.receiveNum,
              meta: primitive.content.meta,
              content: primitive.content.fileBubbles
                  .map((e) => SharedFile(
                      id: e.id,
                      groupId: primitive.groupId,
                      state: e.content.state,
                      progress: e.content.progress,
                      speed: e.content.speed,
                      content: e.content.meta))
                  .toList()));
      currentBubble.time = primitive.time;
      return currentBubble;
    default:
      throw UnimplementedError();
  }
}
