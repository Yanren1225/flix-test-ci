// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BubbleEntitiesTable extends BubbleEntities
    with TableInfo<$BubbleEntitiesTable, BubbleEntity> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BubbleEntitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fromDeviceMeta =
      const VerificationMeta('fromDevice');
  @override
  late final GeneratedColumn<String> fromDevice = GeneratedColumn<String>(
      'from_device', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toDeviceMeta =
      const VerificationMeta('toDevice');
  @override
  late final GeneratedColumn<String> toDevice = GeneratedColumn<String>(
      'to_device', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
      'type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, fromDevice, toDevice, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bubble_entities';
  @override
  VerificationContext validateIntegrity(Insertable<BubbleEntity> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_device')) {
      context.handle(
          _fromDeviceMeta,
          fromDevice.isAcceptableOrUnknown(
              data['from_device']!, _fromDeviceMeta));
    } else if (isInserting) {
      context.missing(_fromDeviceMeta);
    }
    if (data.containsKey('to_device')) {
      context.handle(_toDeviceMeta,
          toDevice.isAcceptableOrUnknown(data['to_device']!, _toDeviceMeta));
    } else if (isInserting) {
      context.missing(_toDeviceMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BubbleEntity map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BubbleEntity(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      fromDevice: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}from_device'])!,
      toDevice: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}to_device'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}type'])!,
    );
  }

  @override
  $BubbleEntitiesTable createAlias(String alias) {
    return $BubbleEntitiesTable(attachedDatabase, alias);
  }
}

class BubbleEntity extends DataClass implements Insertable<BubbleEntity> {
  final String id;
  final String fromDevice;
  final String toDevice;
  final int type;
  const BubbleEntity(
      {required this.id,
      required this.fromDevice,
      required this.toDevice,
      required this.type});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_device'] = Variable<String>(fromDevice);
    map['to_device'] = Variable<String>(toDevice);
    map['type'] = Variable<int>(type);
    return map;
  }

  BubbleEntitiesCompanion toCompanion(bool nullToAbsent) {
    return BubbleEntitiesCompanion(
      id: Value(id),
      fromDevice: Value(fromDevice),
      toDevice: Value(toDevice),
      type: Value(type),
    );
  }

  factory BubbleEntity.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BubbleEntity(
      id: serializer.fromJson<String>(json['id']),
      fromDevice: serializer.fromJson<String>(json['fromDevice']),
      toDevice: serializer.fromJson<String>(json['toDevice']),
      type: serializer.fromJson<int>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromDevice': serializer.toJson<String>(fromDevice),
      'toDevice': serializer.toJson<String>(toDevice),
      'type': serializer.toJson<int>(type),
    };
  }

  BubbleEntity copyWith(
          {String? id, String? fromDevice, String? toDevice, int? type}) =>
      BubbleEntity(
        id: id ?? this.id,
        fromDevice: fromDevice ?? this.fromDevice,
        toDevice: toDevice ?? this.toDevice,
        type: type ?? this.type,
      );
  @override
  String toString() {
    return (StringBuffer('BubbleEntity(')
          ..write('id: $id, ')
          ..write('fromDevice: $fromDevice, ')
          ..write('toDevice: $toDevice, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, fromDevice, toDevice, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BubbleEntity &&
          other.id == this.id &&
          other.fromDevice == this.fromDevice &&
          other.toDevice == this.toDevice &&
          other.type == this.type);
}

class BubbleEntitiesCompanion extends UpdateCompanion<BubbleEntity> {
  final Value<String> id;
  final Value<String> fromDevice;
  final Value<String> toDevice;
  final Value<int> type;
  final Value<int> rowid;
  const BubbleEntitiesCompanion({
    this.id = const Value.absent(),
    this.fromDevice = const Value.absent(),
    this.toDevice = const Value.absent(),
    this.type = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BubbleEntitiesCompanion.insert({
    required String id,
    required String fromDevice,
    required String toDevice,
    required int type,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fromDevice = Value(fromDevice),
        toDevice = Value(toDevice),
        type = Value(type);
  static Insertable<BubbleEntity> custom({
    Expression<String>? id,
    Expression<String>? fromDevice,
    Expression<String>? toDevice,
    Expression<int>? type,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromDevice != null) 'from_device': fromDevice,
      if (toDevice != null) 'to_device': toDevice,
      if (type != null) 'type': type,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BubbleEntitiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? fromDevice,
      Value<String>? toDevice,
      Value<int>? type,
      Value<int>? rowid}) {
    return BubbleEntitiesCompanion(
      id: id ?? this.id,
      fromDevice: fromDevice ?? this.fromDevice,
      toDevice: toDevice ?? this.toDevice,
      type: type ?? this.type,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fromDevice.present) {
      map['from_device'] = Variable<String>(fromDevice.value);
    }
    if (toDevice.present) {
      map['to_device'] = Variable<String>(toDevice.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BubbleEntitiesCompanion(')
          ..write('id: $id, ')
          ..write('fromDevice: $fromDevice, ')
          ..write('toDevice: $toDevice, ')
          ..write('type: $type, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TextContentsTable extends TextContents
    with TableInfo<$TextContentsTable, TextContent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TextContentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, content];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'text_contents';
  @override
  VerificationContext validateIntegrity(Insertable<TextContent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TextContent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TextContent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
    );
  }

  @override
  $TextContentsTable createAlias(String alias) {
    return $TextContentsTable(attachedDatabase, alias);
  }
}

class TextContent extends DataClass implements Insertable<TextContent> {
  final String id;
  final String content;
  const TextContent({required this.id, required this.content});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<String>(content);
    return map;
  }

  TextContentsCompanion toCompanion(bool nullToAbsent) {
    return TextContentsCompanion(
      id: Value(id),
      content: Value(content),
    );
  }

  factory TextContent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TextContent(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String>(json['content']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String>(content),
    };
  }

  TextContent copyWith({String? id, String? content}) => TextContent(
        id: id ?? this.id,
        content: content ?? this.content,
      );
  @override
  String toString() {
    return (StringBuffer('TextContent(')
          ..write('id: $id, ')
          ..write('content: $content')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TextContent &&
          other.id == this.id &&
          other.content == this.content);
}

class TextContentsCompanion extends UpdateCompanion<TextContent> {
  final Value<String> id;
  final Value<String> content;
  final Value<int> rowid;
  const TextContentsCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TextContentsCompanion.insert({
    required String id,
    required String content,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        content = Value(content);
  static Insertable<TextContent> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TextContentsCompanion copyWith(
      {Value<String>? id, Value<String>? content, Value<int>? rowid}) {
    return TextContentsCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TextContentsCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $BubbleEntitiesTable bubbleEntities = $BubbleEntitiesTable(this);
  late final $TextContentsTable textContents = $TextContentsTable(this);
  late final BubblesDao bubblesDao = BubblesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [bubbleEntities, textContents];
}
