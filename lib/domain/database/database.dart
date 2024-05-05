import 'dart:async';
import 'dart:io';

import 'package:flix/domain/database/dao/bubbles_dao.dart';
import 'package:flix/domain/database/dao/devices_dao.dart';
import 'package:flix/domain/log/flix_log.dart';
import 'package:flix/model/database/bubble_entity.dart';
import 'package:flix/model/database/device/persistence_devices.dart';
import 'package:flix/model/database/file_content.dart';
import 'package:flix/model/database/text_content.dart';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:drift/native.dart';

import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'database.g.dart'; // the generated code will be there

@DriftDatabase(
    tables: [BubbleEntities, TextContents, FileContents, PersistenceDevices],
    daos: [BubblesDao, DevicesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 4;

  static LazyDatabase _openConnection() {
    // the LazyDatabase util lets us find the right location for the file async.
    return LazyDatabase(() async {
      // put the database file, called db.sqlite here, into the documents folder
      // for your app.
      final file;
      final dbFolder = await getApplicationSupportDirectory();
      talker.verbose('create db in folder: $dbFolder');
      file = File(p.join(dbFolder.path, 'db.sqlite'));
      // }

      // Also work around limitations on old Android versions
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      // Make sqlite3 pick a more suitable location for temporary files - the
      // one from the system may be inaccessible due to sandboxing.
      final cachebase = (await getTemporaryDirectory()).path;
      // We can't access /tmp on Android, which sqlite3 would try by default.
      // Explicitly tell it about the correct temporary directory.
      sqlite3.tempDirectory = cachebase;

      return NativeDatabase.createInBackground(file);
    });
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await migration1_2(m);
        }
        if (from < 3) {
          await migration2_3(m);
        }
        if (from < 4) {
          await migration3_4(m);
        }
      },
    );
  }

  Future<void> migration3_4(Migrator m) async {
    if (!(await _checkIfColumnExists(fileContents.actualTableName, fileContents.speed.name))) {
      await m.addColumn(fileContents, fileContents.speed);
    }
  }

  Future<void> migration2_3(Migrator m) async {
    if (!(await _checkIfColumnExists(bubbleEntities.actualTableName, bubbleEntities.time.name))) {
      await m.addColumn(bubbleEntities, bubbleEntities.time);
    }
  }

  Future<void> migration1_2(Migrator m) async {
    if (!(await _checkIfColumnExists(fileContents.actualTableName, fileContents.resourceId.name))) {
      await m.addColumn(fileContents, fileContents.resourceId);
    }
  }

  Future<bool> _checkIfColumnExists(String tableName, String columnName) async {
    final result = await customSelect(
      'PRAGMA table_info($tableName)',
      readsFrom: { /* 这里应该列出你的表作为依赖 */ },
    ).get();

    for (final row in result) {
      if (row.read<String>('name') == columnName) {
        return true;
      }
    }
    return false;
  }
}

AppDatabase appDatabase = AppDatabase();
