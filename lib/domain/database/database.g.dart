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
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
      'width', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
      'height', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _waitingForAcceptMeta =
      const VerificationMeta('waitingForAccept');
  @override
  late final GeneratedColumn<bool> waitingForAccept = GeneratedColumn<bool>(
      'waiting_for_accept', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("waiting_for_accept" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        mimeType,
        nameWithSuffix,
        size,
        path,
        state,
        progress,
        width,
        height,
        waitingForAccept
      ];
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
    if (data.containsKey('width')) {
      context.handle(
          _widthMeta, width.isAcceptableOrUnknown(data['width']!, _widthMeta));
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(_heightMeta,
          height.isAcceptableOrUnknown(data['height']!, _heightMeta));
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('waiting_for_accept')) {
      context.handle(
          _waitingForAcceptMeta,
          waitingForAccept.isAcceptableOrUnknown(
              data['waiting_for_accept']!, _waitingForAcceptMeta));
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
      width: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}width'])!,
      height: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}height'])!,
      waitingForAccept: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}waiting_for_accept'])!,
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
  final int width;
  final int height;
  final bool waitingForAccept;
  const FileContent(
      {required this.id,
      required this.name,
      required this.mimeType,
      required this.nameWithSuffix,
      required this.size,
      this.path,
      required this.state,
      required this.progress,
      required this.width,
      required this.height,
      required this.waitingForAccept});
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
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['waiting_for_accept'] = Variable<bool>(waitingForAccept);
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
      width: Value(width),
      height: Value(height),
      waitingForAccept: Value(waitingForAccept),
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
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      waitingForAccept: serializer.fromJson<bool>(json['waitingForAccept']),
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
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'waitingForAccept': serializer.toJson<bool>(waitingForAccept),
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
          double? progress,
          int? width,
          int? height,
          bool? waitingForAccept}) =>
      FileContent(
        id: id ?? this.id,
        name: name ?? this.name,
        mimeType: mimeType ?? this.mimeType,
        nameWithSuffix: nameWithSuffix ?? this.nameWithSuffix,
        size: size ?? this.size,
        path: path.present ? path.value : this.path,
        state: state ?? this.state,
        progress: progress ?? this.progress,
        width: width ?? this.width,
        height: height ?? this.height,
        waitingForAccept: waitingForAccept ?? this.waitingForAccept,
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
          ..write('progress: $progress, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('waitingForAccept: $waitingForAccept')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, mimeType, nameWithSuffix, size,
      path, state, progress, width, height, waitingForAccept);
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
          other.progress == this.progress &&
          other.width == this.width &&
          other.height == this.height &&
          other.waitingForAccept == this.waitingForAccept);
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
  final Value<int> width;
  final Value<int> height;
  final Value<bool> waitingForAccept;
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
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.waitingForAccept = const Value.absent(),
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
    required int width,
    required int height,
    this.waitingForAccept = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        mimeType = Value(mimeType),
        nameWithSuffix = Value(nameWithSuffix),
        size = Value(size),
        state = Value(state),
        progress = Value(progress),
        width = Value(width),
        height = Value(height);
  static Insertable<FileContent> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? mimeType,
    Expression<String>? nameWithSuffix,
    Expression<int>? size,
    Expression<String>? path,
    Expression<int>? state,
    Expression<double>? progress,
    Expression<int>? width,
    Expression<int>? height,
    Expression<bool>? waitingForAccept,
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
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (waitingForAccept != null) 'waiting_for_accept': waitingForAccept,
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
      Value<int>? width,
      Value<int>? height,
      Value<bool>? waitingForAccept,
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
      width: width ?? this.width,
      height: height ?? this.height,
      waitingForAccept: waitingForAccept ?? this.waitingForAccept,
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
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (waitingForAccept.present) {
      map['waiting_for_accept'] = Variable<bool>(waitingForAccept.value);
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
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('waitingForAccept: $waitingForAccept, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersistenceDevicesTable extends PersistenceDevices
    with TableInfo<$PersistenceDevicesTable, PersistenceDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersistenceDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _aliasMeta = const VerificationMeta('alias');
  @override
  late final GeneratedColumn<String> alias = GeneratedColumn<String>(
      'alias', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceModelMeta =
      const VerificationMeta('deviceModel');
  @override
  late final GeneratedColumn<String> deviceModel = GeneratedColumn<String>(
      'device_model', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _deviceTypeMeta =
      const VerificationMeta('deviceType');
  @override
  late final GeneratedColumn<int> deviceType = GeneratedColumn<int>(
      'device_type', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _fingerprintMeta =
      const VerificationMeta('fingerprint');
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
      'fingerprint', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
      'port', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ipMeta = const VerificationMeta('ip');
  @override
  late final GeneratedColumn<String> ip = GeneratedColumn<String>(
      'ip', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _insertOrUpdateTimeMeta =
      const VerificationMeta('insertOrUpdateTime');
  @override
  late final GeneratedColumn<DateTime> insertOrUpdateTime =
      GeneratedColumn<DateTime>('insert_or_update_time', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        alias,
        deviceModel,
        deviceType,
        fingerprint,
        port,
        ip,
        insertOrUpdateTime
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'persistence_devices';
  @override
  VerificationContext validateIntegrity(Insertable<PersistenceDevice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('alias')) {
      context.handle(
          _aliasMeta, alias.isAcceptableOrUnknown(data['alias']!, _aliasMeta));
    } else if (isInserting) {
      context.missing(_aliasMeta);
    }
    if (data.containsKey('device_model')) {
      context.handle(
          _deviceModelMeta,
          deviceModel.isAcceptableOrUnknown(
              data['device_model']!, _deviceModelMeta));
    }
    if (data.containsKey('device_type')) {
      context.handle(
          _deviceTypeMeta,
          deviceType.isAcceptableOrUnknown(
              data['device_type']!, _deviceTypeMeta));
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
          _fingerprintMeta,
          fingerprint.isAcceptableOrUnknown(
              data['fingerprint']!, _fingerprintMeta));
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
          _portMeta, port.isAcceptableOrUnknown(data['port']!, _portMeta));
    }
    if (data.containsKey('ip')) {
      context.handle(_ipMeta, ip.isAcceptableOrUnknown(data['ip']!, _ipMeta));
    }
    if (data.containsKey('insert_or_update_time')) {
      context.handle(
          _insertOrUpdateTimeMeta,
          insertOrUpdateTime.isAcceptableOrUnknown(
              data['insert_or_update_time']!, _insertOrUpdateTimeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fingerprint};
  @override
  PersistenceDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersistenceDevice(
      alias: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}alias'])!,
      deviceModel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_model']),
      deviceType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}device_type']),
      fingerprint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fingerprint'])!,
      port: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}port']),
      ip: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ip']),
      insertOrUpdateTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}insert_or_update_time'])!,
    );
  }

  @override
  $PersistenceDevicesTable createAlias(String alias) {
    return $PersistenceDevicesTable(attachedDatabase, alias);
  }
}

class PersistenceDevice extends DataClass
    implements Insertable<PersistenceDevice> {
  final String alias;
  final String? deviceModel;
  final int? deviceType;
  final String fingerprint;
  final int? port;
  final String? ip;
  final DateTime insertOrUpdateTime;
  const PersistenceDevice(
      {required this.alias,
      this.deviceModel,
      this.deviceType,
      required this.fingerprint,
      this.port,
      this.ip,
      required this.insertOrUpdateTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['alias'] = Variable<String>(alias);
    if (!nullToAbsent || deviceModel != null) {
      map['device_model'] = Variable<String>(deviceModel);
    }
    if (!nullToAbsent || deviceType != null) {
      map['device_type'] = Variable<int>(deviceType);
    }
    map['fingerprint'] = Variable<String>(fingerprint);
    if (!nullToAbsent || port != null) {
      map['port'] = Variable<int>(port);
    }
    if (!nullToAbsent || ip != null) {
      map['ip'] = Variable<String>(ip);
    }
    map['insert_or_update_time'] = Variable<DateTime>(insertOrUpdateTime);
    return map;
  }

  PersistenceDevicesCompanion toCompanion(bool nullToAbsent) {
    return PersistenceDevicesCompanion(
      alias: Value(alias),
      deviceModel: deviceModel == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceModel),
      deviceType: deviceType == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceType),
      fingerprint: Value(fingerprint),
      port: port == null && nullToAbsent ? const Value.absent() : Value(port),
      ip: ip == null && nullToAbsent ? const Value.absent() : Value(ip),
      insertOrUpdateTime: Value(insertOrUpdateTime),
    );
  }

  factory PersistenceDevice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersistenceDevice(
      alias: serializer.fromJson<String>(json['alias']),
      deviceModel: serializer.fromJson<String?>(json['deviceModel']),
      deviceType: serializer.fromJson<int?>(json['deviceType']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      port: serializer.fromJson<int?>(json['port']),
      ip: serializer.fromJson<String?>(json['ip']),
      insertOrUpdateTime:
          serializer.fromJson<DateTime>(json['insertOrUpdateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'alias': serializer.toJson<String>(alias),
      'deviceModel': serializer.toJson<String?>(deviceModel),
      'deviceType': serializer.toJson<int?>(deviceType),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'port': serializer.toJson<int?>(port),
      'ip': serializer.toJson<String?>(ip),
      'insertOrUpdateTime': serializer.toJson<DateTime>(insertOrUpdateTime),
    };
  }

  PersistenceDevice copyWith(
          {String? alias,
          Value<String?> deviceModel = const Value.absent(),
          Value<int?> deviceType = const Value.absent(),
          String? fingerprint,
          Value<int?> port = const Value.absent(),
          Value<String?> ip = const Value.absent(),
          DateTime? insertOrUpdateTime}) =>
      PersistenceDevice(
        alias: alias ?? this.alias,
        deviceModel: deviceModel.present ? deviceModel.value : this.deviceModel,
        deviceType: deviceType.present ? deviceType.value : this.deviceType,
        fingerprint: fingerprint ?? this.fingerprint,
        port: port.present ? port.value : this.port,
        ip: ip.present ? ip.value : this.ip,
        insertOrUpdateTime: insertOrUpdateTime ?? this.insertOrUpdateTime,
      );
  @override
  String toString() {
    return (StringBuffer('PersistenceDevice(')
          ..write('alias: $alias, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('deviceType: $deviceType, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('port: $port, ')
          ..write('ip: $ip, ')
          ..write('insertOrUpdateTime: $insertOrUpdateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(alias, deviceModel, deviceType, fingerprint,
      port, ip, insertOrUpdateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersistenceDevice &&
          other.alias == this.alias &&
          other.deviceModel == this.deviceModel &&
          other.deviceType == this.deviceType &&
          other.fingerprint == this.fingerprint &&
          other.port == this.port &&
          other.ip == this.ip &&
          other.insertOrUpdateTime == this.insertOrUpdateTime);
}

class PersistenceDevicesCompanion extends UpdateCompanion<PersistenceDevice> {
  final Value<String> alias;
  final Value<String?> deviceModel;
  final Value<int?> deviceType;
  final Value<String> fingerprint;
  final Value<int?> port;
  final Value<String?> ip;
  final Value<DateTime> insertOrUpdateTime;
  final Value<int> rowid;
  const PersistenceDevicesCompanion({
    this.alias = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.deviceType = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.port = const Value.absent(),
    this.ip = const Value.absent(),
    this.insertOrUpdateTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersistenceDevicesCompanion.insert({
    required String alias,
    this.deviceModel = const Value.absent(),
    this.deviceType = const Value.absent(),
    required String fingerprint,
    this.port = const Value.absent(),
    this.ip = const Value.absent(),
    this.insertOrUpdateTime = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : alias = Value(alias),
        fingerprint = Value(fingerprint);
  static Insertable<PersistenceDevice> custom({
    Expression<String>? alias,
    Expression<String>? deviceModel,
    Expression<int>? deviceType,
    Expression<String>? fingerprint,
    Expression<int>? port,
    Expression<String>? ip,
    Expression<DateTime>? insertOrUpdateTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (alias != null) 'alias': alias,
      if (deviceModel != null) 'device_model': deviceModel,
      if (deviceType != null) 'device_type': deviceType,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (port != null) 'port': port,
      if (ip != null) 'ip': ip,
      if (insertOrUpdateTime != null)
        'insert_or_update_time': insertOrUpdateTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersistenceDevicesCompanion copyWith(
      {Value<String>? alias,
      Value<String?>? deviceModel,
      Value<int?>? deviceType,
      Value<String>? fingerprint,
      Value<int?>? port,
      Value<String?>? ip,
      Value<DateTime>? insertOrUpdateTime,
      Value<int>? rowid}) {
    return PersistenceDevicesCompanion(
      alias: alias ?? this.alias,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceType: deviceType ?? this.deviceType,
      fingerprint: fingerprint ?? this.fingerprint,
      port: port ?? this.port,
      ip: ip ?? this.ip,
      insertOrUpdateTime: insertOrUpdateTime ?? this.insertOrUpdateTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (alias.present) {
      map['alias'] = Variable<String>(alias.value);
    }
    if (deviceModel.present) {
      map['device_model'] = Variable<String>(deviceModel.value);
    }
    if (deviceType.present) {
      map['device_type'] = Variable<int>(deviceType.value);
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (ip.present) {
      map['ip'] = Variable<String>(ip.value);
    }
    if (insertOrUpdateTime.present) {
      map['insert_or_update_time'] =
          Variable<DateTime>(insertOrUpdateTime.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersistenceDevicesCompanion(')
          ..write('alias: $alias, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('deviceType: $deviceType, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('port: $port, ')
          ..write('ip: $ip, ')
          ..write('insertOrUpdateTime: $insertOrUpdateTime, ')
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
  late final $PersistenceDevicesTable persistenceDevices =
      $PersistenceDevicesTable(this);
  late final BubblesDao bubblesDao = BubblesDao(this as AppDatabase);
  late final DevicesDao devicesDao = DevicesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [bubbleEntities, textContents, fileContents, persistenceDevices];
}
