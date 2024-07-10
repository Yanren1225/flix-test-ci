import 'package:drift/drift.dart';

class BubbleEntities extends Table {
  TextColumn get id => text()();
  TextColumn get fromDevice => text()();
  TextColumn get toDevice => text()();
  IntColumn get type => integer()();
  IntColumn get time => integer().withDefault(const Constant(0x7FFFFFFFFFFFFFFF))();
  TextColumn get groupId => text().withDefault(const Constant(""))();
  @override
  Set<Column> get primaryKey => {id};
}



