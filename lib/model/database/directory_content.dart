import 'package:drift/drift.dart';

class DirectoryContents extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get size => integer()();
  IntColumn get state => integer()();
  TextColumn get path => text().nullable()();
  BoolColumn get waitingForAccept => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}