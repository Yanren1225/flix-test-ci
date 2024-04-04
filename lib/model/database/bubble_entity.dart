import 'package:drift/drift.dart';

class BubbleEntities extends Table {
  TextColumn get id => text()();
  TextColumn get fromDevice => text()();
  TextColumn get toDevice => text()();
  IntColumn get type => integer()();
  IntColumn get time => integer()();
  @override
  Set<Column> get primaryKey => {id};
}



