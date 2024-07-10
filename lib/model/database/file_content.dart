import 'package:drift/drift.dart';

class FileContents extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().withDefault(const Constant(''))();
  TextColumn get resourceId => text().withDefault(const Constant(''))();
  TextColumn get name => text()();
  TextColumn get mimeType => text()();
  TextColumn get nameWithSuffix => text()();
  IntColumn get size => integer()();
  TextColumn get path => text().nullable()();
  IntColumn get state => integer()();
  RealColumn get progress => real()();
  IntColumn get speed => integer().withDefault(const Constant(0))();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
  BoolColumn get waitingForAccept => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}