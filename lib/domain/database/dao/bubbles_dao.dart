
import 'dart:async';

import 'package:androp/domain/database/database.dart';
import 'package:androp/model/database/bubble_entity.dart';
import 'package:androp/model/database/text_content.dart';
import 'package:androp/model/ship/primitive_bubble.dart';
import 'package:drift/drift.dart';

part 'bubbles_dao.g.dart';


@DriftAccessor(tables: [BubbleEntities, TextContents])
class BubblesDao extends DatabaseAccessor<AppDatabase> with _$BubblesDaoMixin {
  BubblesDao(super.db);

  Future<int> insert(PrimitiveBubble bubble) async {
    return await transaction(() async {
      await into(bubbleEntities).insert(BubbleEntitiesCompanion.insert(id: bubble.id, fromDevice: bubble.from, toDevice: bubble.to, type: bubble.type.index));
      switch (bubble.type) {
        case BubbleType.Text:
          return await into(textContents).insert(TextContentsCompanion.insert(id: bubble.id, content: bubble.content));
        default:
          throw UnimplementedError();
      }
    });
  }

  Stream<List<PrimitiveBubble>> watchBubblesByCid(String collebratorId) {
      return (select(bubbleEntities)..where((tbl) => (tbl.fromDevice.equals(collebratorId) | tbl.toDevice.equals(collebratorId)))).watch().asyncMap((bubbleEntities) async {
        final List<PrimitiveBubble?> primitiveBubbles = List.filled(bubbleEntities.length, null);
        final categoriedBubbleEntities = Map<int, List<MapEntry<int, BubbleEntity>>>();
        for (int i = 0; i< bubbleEntities.length; i++) {
          final bubbleEntity = bubbleEntities[i];
          var entities = categoriedBubbleEntities[bubbleEntity.type];
          if (entities == null) {
            entities = <MapEntry<int, BubbleEntity>>[];
            categoriedBubbleEntities[bubbleEntity.type] = entities;
          }
          entities.add(MapEntry(i, bubbleEntity));
        }

        for (final entry in categoriedBubbleEntities.entries) {
          final type = BubbleType.values[entry.key];
          final entitiesWithIndex = entry.value;
          final ids = entitiesWithIndex.map((e) => e.value.id).toList();


          switch (type) {
            case BubbleType.Text:
              final _textContents = await (select(textContents)..where((tbl) => tbl.id.isIn(ids))).get();
              for (final entityWithIndex in entitiesWithIndex) {
                for (final textContent in _textContents) {
                  if (entityWithIndex.value.id == textContent.id) {
                    final index = entityWithIndex.key;
                    final entity = entityWithIndex.value;
                    final item = PrimitiveTextBubble(id: entity.id, from: entity.fromDevice, to: entity.toDevice, type: BubbleType.values[entity.type], content: textContent.content);
                    primitiveBubbles[index] = item;
                  }
                }
              }
              break;
            case BubbleType.File:
              throw UnimplementedError();
            default:
              throw UnimplementedError();
          }
        }

        return primitiveBubbles.nonNulls.toList();
      });
  }
}