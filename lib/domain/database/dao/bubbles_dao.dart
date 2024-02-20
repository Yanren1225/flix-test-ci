import 'dart:async';

import 'package:androp/domain/database/convertor/bubble_convertor.dart';
import 'package:androp/domain/database/database.dart';
import 'package:androp/model/database/bubble_entity.dart';
import 'package:androp/model/database/file_content.dart';
import 'package:androp/model/database/text_content.dart';
import 'package:androp/model/ship/primitive_bubble.dart';
import 'package:androp/model/ui_bubble/shared_file.dart';
import 'package:drift/drift.dart';

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
              type: bubble.type.index));
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
                  name: fileBubble.content.meta.name,
                  nameWithSuffix: fileBubble.content.meta.nameWithSuffix,
                  mimeType: fileBubble.content.meta.mimeType,
                  size: fileBubble.content.meta.size,
                  path: Value(fileBubble.content.meta.path),
                  state: fileBubble.content.state.index,
                  progress: fileBubble.content.progress));
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
          Map<int, List<MapEntry<int, BubbleEntity>>>();
      for (int i = 0; i < bubbleEntities.length; i++) {
        final bubbleEntity = bubbleEntities[i];
        final contentType;
        // Image, Video, App, File都从FileContents表中读取
        if (BubbleType.values[bubbleEntity.type] == BubbleType.File ||
            BubbleType.values[bubbleEntity.type] == BubbleType.Video ||
            BubbleType.values[bubbleEntity.type] == BubbleType.Image ||
            BubbleType.values[bubbleEntity.type] == BubbleType.App
        ) {
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

      return primitiveBubbles.nonNulls.toList();
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
}
