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

class $FileContentsTable extends FileContents
    with TableInfo<$FileContentsTable, FileContent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FileContentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameWithSuffixMeta =
      const VerificationMeta('nameWithSuffix');
  @override
  late final GeneratedColumn<String> nameWithSuffix = GeneratedColumn<String>(
      'name_with_suffix', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
      'size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
      'state', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _progressMeta =
      const VerificationMeta('progress');
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
      'progress', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, mimeType, nameWithSuffix, size, path, state, progress];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'file_contents';
  @override
  VerificationContext validateIntegrity(Insertable<FileContent> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('name_with_suffix')) {
      context.handle(
          _nameWithSuffixMeta,
          nameWithSuffix.isAcceptableOrUnknown(
              data['name_with_suffix']!, _nameWithSuffixMeta));
    } else if (isInserting) {
      context.missing(_nameWithSuffixMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(_progressMeta,
          progress.isAcceptableOrUnknown(data['progress']!, _progressMeta));
    } else if (isInserting) {
      context.missing(_progressMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FileContent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FileContent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type'])!,
      nameWithSuffix: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}name_with_suffix'])!,
      size: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size'])!,
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path']),
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}state'])!,
      progress: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}progress'])!,
    );
  }

  @override
  $FileContentsTable createAlias(String alias) {
    return $FileContentsTable(attachedDatabase, alias);
  }
}

class FileContent extends DataClass implements Insertable<FileContent> {
  final String id;
  final String name;
  final String mimeType;
  final String nameWithSuffix;
  final int size;
  final String? path;
  final int state;
  final double progress;
  const FileContent(
      {required this.id,
      required this.name,
      required this.mimeType,
      required this.nameWithSuffix,
      required this.size,
      this.path,
      required this.state,
      required this.progress});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['mime_type'] = Variable<String>(mimeType);
    map['name_with_suffix'] = Variable<String>(nameWithSuffix);
    map['size'] = Variable<int>(size);
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    map['state'] = Variable<int>(state);
    map['progress'] = Variable<double>(progress);
    return map;
  }

  FileContentsCompanion toCompanion(bool nullToAbsent) {
    return FileContentsCompanion(
      id: Value(id),
      name: Value(name),
      mimeType: Value(mimeType),
      nameWithSuffix: Value(nameWithSuffix),
      size: Value(size),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      state: Value(state),
      progress: Value(progress),
    );
  }

  factory FileContent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FileContent(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      nameWithSuffix: serializer.fromJson<String>(json['nameWithSuffix']),
      size: serializer.fromJson<int>(json['size']),
      path: serializer.fromJson<String?>(json['path']),
      state: serializer.fromJson<int>(json['state']),
      progress: serializer.fromJson<double>(json['progress']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'mimeType': serializer.toJson<String>(mimeType),
      'nameWithSuffix': serializer.toJson<String>(nameWithSuffix),
      'size': serializer.toJson<int>(size),
      'path': serializer.toJson<String?>(path),
      'state': serializer.toJson<int>(state),
      'progress': serializer.toJson<double>(progress),
    };
  }

  FileContent copyWith(
          {String? id,
          String? name,
          String? mimeType,
          String? nameWithSuffix,
          int? size,
          Value<String?> path = const Value.absent(),
          int? state,
          double? progress}) =>
      FileContent(
        id: id ?? this.id,
        name: name ?? this.name,
        mimeType: mimeType ?? this.mimeType,
        nameWithSuffix: nameWithSuffix ?? this.nameWithSuffix,
        size: size ?? this.size,
        path: path.present ? path.value : this.path,
        state: state ?? this.state,
        progress: progress ?? this.progress,
      );
  @override
  String toString() {
    return (StringBuffer('FileContent(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mimeType: $mimeType, ')
          ..write('nameWithSuffix: $nameWithSuffix, ')
          ..write('size: $size, ')
          ..write('path: $path, ')
          ..write('state: $state, ')
          ..write('progress: $progress')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, mimeType, nameWithSuffix, size, path, state, progress);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileContent &&
          other.id == this.id &&
          other.name == this.name &&
          other.mimeType == this.mimeType &&
          other.nameWithSuffix == this.nameWithSuffix &&
          other.size == this.size &&
          other.path == this.path &&
          other.state == this.state &&
          other.progress == this.progress);
}

class FileContentsCompanion extends UpdateCompanion<FileContent> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> mimeType;
  final Value<String> nameWithSuffix;
  final Value<int> size;
  final Value<String?> path;
  final Value<int> state;
  final Value<double> progress;
  final Value<int> rowid;
  const FileContentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.nameWithSuffix = const Value.absent(),
    this.size = const Value.absent(),
    this.path = const Value.absent(),
    this.state = const Value.absent(),
    this.progress = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FileContentsCompanion.insert({
    required String id,
    required String name,
    required String mimeType,
    required String nameWithSuffix,
    required int size,
    this.path = const Value.absent(),
    required int state,
    required double progress,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        mimeType = Value(mimeType),
        nameWithSuffix = Value(nameWithSuffix),
        size = Value(size),
        state = Value(state),
        progress = Value(progress);
  static Insertable<FileContent> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? mimeType,
    Expression<String>? nameWithSuffix,
    Expression<int>? size,
    Expression<String>? path,
    Expression<int>? state,
    Expression<double>? progress,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mimeType != null) 'mime_type': mimeType,
      if (nameWithSuffix != null) 'name_with_suffix': nameWithSuffix,
      if (size != null) 'size': size,
      if (path != null) 'path': path,
      if (state != null) 'state': state,
      if (progress != null) 'progress': progress,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FileContentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? mimeType,
      Value<String>? nameWithSuffix,
      Value<int>? size,
      Value<String?>? path,
      Value<int>? state,
      Value<double>? progress,
      Value<int>? rowid}) {
    return FileContentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      mimeType: mimeType ?? this.mimeType,
      nameWithSuffix: nameWithSuffix ?? this.nameWithSuffix,
      size: size ?? this.size,
      path: path ?? this.path,
      state: state ?? this.state,
      progress: progress ?? this.progress,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (nameWithSuffix.present) {
      map['name_with_suffix'] = Variable<String>(nameWithSuffix.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FileContentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mimeType: $mimeType, ')
          ..write('nameWithSuffix: $nameWithSuffix, ')
          ..write('size: $size, ')
          ..write('path: $path, ')
          ..write('state: $state, ')
          ..write('progress: $progress, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $BubbleEntitiesTable bubbleEntities = $BubbleEntitiesTable(this);
  late final $TextContentsTable textContents = $TextContentsTable(this);
  late final $FileContentsTable fileContents = $FileContentsTable(this);
  late final BubblesDao bubblesDao = BubblesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [bubbleEntities, textContents, fileContents];
}
