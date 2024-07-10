import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flix/domain/database/convertor/bubble_convertor.dart';
import 'package:flix/domain/database/database.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/database/bubble_entity.dart';
import 'package:flix/model/database/directory_content.dart';
import 'package:flix/model/database/file_content.dart';
import 'package:flix/model/database/text_content.dart';
import 'package:flix/model/ship/primitive_bubble.dart';

part 'bubbles_dao.g.dart';

@DriftAccessor(tables: [BubbleEntities, TextContents, FileContents, DirectoryContents])
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
              groupId: Value(bubble.groupId ?? ""),
              time: Value(bubble.time)));
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
                  groupId: Value(fileBubble.groupId ?? ""),
                  name: fileBubble.content.meta.name,
                  nameWithSuffix: fileBubble.content.meta.nameWithSuffix,
                  mimeType: fileBubble.content.meta.mimeType,
                  size: fileBubble.content.meta.size,
                  path: Value(fileBubble.content.meta.path),
                  state: fileBubble.content.state.index,
                  progress: fileBubble.content.progress,
                  speed: Value(fileBubble.content.speed),
                  width: fileBubble.content.meta.width,
                  height: fileBubble.content.meta.height,
                  waitingForAccept: Value(fileBubble.content.waitingForAccept)));
        case BubbleType.Directory:
          final directoryBubble = bubble as PrimitiveDirectoryBubble;
          return await into(directoryContents)
              .insertOnConflictUpdate(DirectoryContentsCompanion.insert(
                  id: directoryBubble.id,
                  name: directoryBubble.content.meta.name,
                  state: directoryBubble.content.state.index,
                  size: directoryBubble.content.meta.size,
                  path: Value(directoryBubble.content.meta.path)));
        default:
          throw UnimplementedError();
      }
    });
  }

  Stream<List<PrimitiveBubble>> watchBubblesByCid(String collebratorId) {
    return (select(bubbleEntities)
          ..where((tbl) =>
              (tbl.fromDevice.equals(collebratorId) |
                  tbl.toDevice.equals(collebratorId)) &
              (tbl.groupId.equals("") | tbl.groupId.isNull())))
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
        } else if (BubbleType.values[bubbleEntity.type] == BubbleType.Directory) {
          contentType = BubbleType.Directory.index;
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
          case BubbleType.Directory:
            contents = await (select(directoryContents)
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
              final item = await fromDBEntity(entity, _content);
              primitiveBubbles[index] = item;
            }
          }
        }
      }

      List<PrimitiveBubble?> bubblesResult = List.empty(growable: true);
      List<PrimitiveBubble> nonNullsBubbles = primitiveBubbles.nonNulls.toList();

      if (nonNullsBubbles.isEmpty) {
        return nonNullsBubbles;
      }

      final timeGap = 3 * 60 * 1000;
      var timeBubbleSource = nonNullsBubbles[0];
      if (DateTime.now().millisecondsSinceEpoch - timeBubbleSource!.time >= timeGap) {
        final timeBubble = PrimitiveTimeBubble(
            id: timeBubbleSource!.id,
            from: timeBubbleSource.from,
            to: timeBubbleSource.to,
            type: BubbleType.Time,
            time: timeBubbleSource.time,
            content: "");
        bubblesResult.add(timeBubble);
      }

      bubblesResult.add(timeBubbleSource);

      for (var i = 0; i < nonNullsBubbles.length - 1; i++) {
        timeBubbleSource = nonNullsBubbles[i + 1];
        final beforeItem = nonNullsBubbles[i];
        if (timeBubbleSource == null) {
          talker.error('missing bubble: ${bubbleEntities[i + 1]}');
          continue;
        }
        if (beforeItem == null) {
          talker.error('missing bubble: ${bubbleEntities[i]}');
          continue;
        }

        if (timeBubbleSource.time - beforeItem.time >=
            timeGap) {
          final timeBubble = PrimitiveTimeBubble(
              id: timeBubbleSource.id,
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
      // talker.debug("watchBubblesByCid====>", "$bubblesResult");
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
      case BubbleType.Directory:
        return await (select(directoryContents)..where((tbl) => tbl.id.equals(id)))
            .getSingleOrNull();
      default:
        throw UnimplementedError();
    }
  }

  Future<dynamic> getContentsByGroupId(String groupId, int bubbleType) async {
    final type = BubbleType.values[bubbleType];
    switch (type) {
      case BubbleType.File:
      case BubbleType.Image:
      case BubbleType.Video:
      case BubbleType.App:
        return await (select(fileContents)
              ..where((tbl) => tbl.groupId.equals(groupId))).get();
      default:
        throw UnimplementedError();
    }
  }

  Future<void> deleteBubbleById(String id) async {
    return transaction(() async {
      await (delete(bubbleEntities)..where((tbl) => tbl.id.equals(id))).go();
      await (delete(textContents)..where((tbl) => tbl.id.equals(id))).go();
      await (delete(fileContents)..where((tbl) => tbl.id.equals(id))).go();
      // directory
      await (delete(directoryContents)..where((tbl) => tbl.id.equals(id))).go();
      await (delete(fileContents)..where((tbl) => tbl.groupId.equals(id))).go();
    });
  }


  Future<List<String?>> getAllDeviceId() {
      final itemType = bubbleEntities.fromDevice;
      final query = selectOnly(bubbleEntities, distinct: true)..addColumns([itemType]);
      return query.map((row) => row.read(itemType)).get();
  }

  Future<void> deleteBubblesByDeviceId(String deviceId) async {
    return transaction(() async {
      final bubbleEntitiesToDelete = await (select(bubbleEntities)
            ..where((tbl) => tbl.fromDevice.equals(deviceId) | tbl.toDevice.equals(deviceId)))
          .get();
      final ids = bubbleEntitiesToDelete.map((e) => e.id).toList();
      await (delete(bubbleEntities)..where((tbl) => tbl.fromDevice.equals(deviceId) | tbl.toDevice.equals(deviceId))).go();
      await (delete(textContents)..where((tbl) => tbl.id.isIn(ids))).go();
      await (delete(fileContents)..where((tbl) => tbl.id.isIn(ids))).go();
      // directory
      await (delete(directoryContents)..where((tbl) => tbl.id.isIn(ids))).go();
      await (delete(fileContents)..where((tbl) => tbl.groupId.isIn(ids))).go();
    });
  }

  Future<int> queryDeviceBubbleCount(String fingerprint) async {
    final query = select(bubbleEntities)..where((tbl) => tbl.fromDevice.equals(fingerprint) | tbl.toDevice.equals(fingerprint));
    return (await query.get()).length;
  }
}
