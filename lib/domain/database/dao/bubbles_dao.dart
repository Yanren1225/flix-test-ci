import 'dart:async';

import 'package:flix/domain/database/convertor/bubble_convertor.dart';
import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/database/bubble_entity.dart';
import 'package:flix/model/database/file_content.dart';
import 'package:flix/model/database/text_content.dart';
import 'package:flix/model/ship/primitive_bubble.dart';
import 'package:drift/drift.dart';
import 'package:flix/model/ui_bubble/ui_bubble.dart';
import 'package:flix/presentation/widgets/bubbles/share_text_bubble.dart';

part 'bubbles_dao.g.dart';

@DriftAccessor(tables: [BubbleEntities, TextContents, FileContents])
class BubblesDao extends DatabaseAccessor<AppDatabase> with _$BubblesDaoMixin {
  BubblesDao(super.db);

  Future<int> insert(PrimitiveBubble bubble) async {
    return await transaction(() async {
      await into(bubbleEntities).insertOnConflictUpdate(
          BubbleEntitiesCompanion.insert(
              id: bubble.id,
              fromDevice: bubble.from,
              toDevice: bubble.to,
              type: bubble.type.index,
              time: bubble.time));
      switch (bubble.type) {
        case BubbleType.Text:
          return await into(textContents).insertOnConflictUpdate(
              TextContentsCompanion.insert(
                  id: bubble.id, content: bubble.content));
        case BubbleType.Image:
        case BubbleType.Video:
        case BubbleType.App:
        case BubbleType.File:
          final fileBubble = bubble as PrimitiveFileBubble;
          return await into(fileContents).insertOnConflictUpdate(
              FileContentsCompanion.insert(
                  id: fileBubble.id,
                  resourceId: Value(fileBubble.content.meta.resourceId),
                  name: fileBubble.content.meta.name,
                  nameWithSuffix: fileBubble.content.meta.nameWithSuffix,
                  mimeType: fileBubble.content.meta.mimeType,
                  size: fileBubble.content.meta.size,
                  path: Value(fileBubble.content.meta.path),
                  state: fileBubble.content.state.index,
                  progress: fileBubble.content.progress,
                  width: fileBubble.content.meta.width,
                  height: fileBubble.content.meta.height));
        default:
          throw UnimplementedError();
      }
    });
  }

  Stream<List<PrimitiveBubble>> watchBubblesByCid(String collebratorId) {
    return (select(bubbleEntities)
          ..where((tbl) => (tbl.fromDevice.equals(collebratorId) |
              tbl.toDevice.equals(collebratorId))))
        .watch()
        .asyncMap((bubbleEntities) async {
      final List<PrimitiveBubble?> primitiveBubbles =
          List.filled(bubbleEntities.length, null);
      final categoriedBubbleEntities =
          <int, List<MapEntry<int, BubbleEntity>>>{};
      for (int i = 0; i < bubbleEntities.length; i++) {
        final bubbleEntity = bubbleEntities[i];
        final contentType;
        // Image, Video, App, File都从FileContents表中读取
        if (BubbleType.values[bubbleEntity.type] == BubbleType.File ||
            BubbleType.values[bubbleEntity.type] == BubbleType.Video ||
            BubbleType.values[bubbleEntity.type] == BubbleType.Image ||
            BubbleType.values[bubbleEntity.type] == BubbleType.App) {
          contentType = BubbleType.File.index;
        } else {
          contentType = BubbleType.Text.index;
        }

        var entities = categoriedBubbleEntities[contentType];

        if (entities == null) {
          entities = <MapEntry<int, BubbleEntity>>[];
          categoriedBubbleEntities[contentType] = entities;
        }
        entities.add(MapEntry(i, bubbleEntity));
      }

      for (final entry in categoriedBubbleEntities.entries) {
        final type = BubbleType.values[entry.key];
        final entitiesWithIndex = entry.value;
        final ids = entitiesWithIndex.map((e) => e.value.id).toList();
        final List<dynamic> contents;

        switch (type) {
          case BubbleType.Text:
            contents = await (select(textContents)
                  ..where((tbl) => tbl.id.isIn(ids)))
                .get();
            break;
          case BubbleType.File:
            contents = await (select(fileContents)
                  ..where((tbl) => tbl.id.isIn(ids)))
                .get();
            break;
          default:
            throw UnimplementedError();
        }

        for (final entityWithIndex in entitiesWithIndex) {
          for (final _content in contents) {
            if (entityWithIndex.value.id == _content.id) {
              final index = entityWithIndex.key;
              final entity = entityWithIndex.value;
              final item = fromDBEntity(entity, _content);
              primitiveBubbles[index] = item;
            }
          }
        }
      }

      List<PrimitiveBubble?> bubblesResult = List.empty(growable: true);

      if (primitiveBubbles.isEmpty) {
        return primitiveBubbles.nonNulls.toList();
      }

      var timeBubbleSource = primitiveBubbles[0];
      var timeBubble = PrimitiveTimeBubble(
          id: timeBubbleSource!.id,
          from: timeBubbleSource.from,
          to: timeBubbleSource.to,
          type: BubbleType.Time,
          time: timeBubbleSource.time,
          content: "");
      bubblesResult.add(timeBubble);
      bubblesResult.add(timeBubbleSource);

      for (var i = 0; i < primitiveBubbles.length - 1; i++) {
        timeBubbleSource = primitiveBubbles[i + 1];
        if (primitiveBubbles[i + 1]!.time - primitiveBubbles[i]!.time >=
            5 * 60 ) {
          timeBubble = PrimitiveTimeBubble(
              id: timeBubbleSource!.id,
              from: timeBubbleSource.from,
              to: timeBubbleSource.to,
              type: BubbleType.Time,
              time: timeBubbleSource.time,
              content: "");
          timeBubble.time = timeBubbleSource.time;
          bubblesResult.add(timeBubble);
        }
        bubblesResult.add(timeBubbleSource);
      }
      talker.debug("watchBubblesByCid====>", "$bubblesResult");
      return bubblesResult.nonNulls.toList();
    });
  }

  Future<PrimitiveBubble?> getPrimitiveBubbleById(String id) async {
    final bubbleEntity = await (select(bubbleEntities)
          ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
    if (bubbleEntity == null) {
      return null;
    }
    final content = await getContentById(bubbleEntity.id, bubbleEntity.type);

    return fromDBEntity(bubbleEntity, content);
  }

  Future<dynamic> getContentById(String id, int bubbleType) async {
    final type = BubbleType.values[bubbleType];
    switch (type) {
      case BubbleType.Text:
        return await (select(textContents)..where((tbl) => tbl.id.equals(id)))
            .getSingleOrNull();
      case BubbleType.File:
      case BubbleType.Image:
      case BubbleType.Video:
      case BubbleType.App:
        return await (select(fileContents)..where((tbl) => tbl.id.equals(id)))
            .getSingleOrNull();
      default:
        throw UnimplementedError();
    }
  }

  Future<void> deleteBubbleById(String id) async {
    return transaction(() async {
      await (delete(bubbleEntities)..where((tbl) => tbl.id.equals(id))).go();
      await (delete(textContents)..where((tbl) => tbl.id.equals(id))).go();
      await (delete(fileContents)..where((tbl) => tbl.id.equals(id))).go();
    });
  }
}
