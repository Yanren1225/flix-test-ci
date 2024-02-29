import 'package:anydrop/model/ship/primitive_bubble.dart';
import 'package:drift/drift.dart';

class BubbleEntities extends Table {
  TextColumn get id => text()();
  TextColumn get fromDevice => text()();
  TextColumn get toDevice => text()();
  IntColumn get type => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// class BubbleEntity {
//   final String id;
//   final String fromDevice;
//   final String toDevice;
//   final int type;
//
//   BubbleEntity({required this.id, required this.fromDevice, required this.toDevice, required this.type});
//
//   BubbleType get typeEnum => BubbleType.values[type];
// }



