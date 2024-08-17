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
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<int> time = GeneratedColumn<int>(
      'time', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0x7FFFFFFFFFFFFFFF));
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(""));
  @override
  List<GeneratedColumn> get $columns =>
      [id, fromDevice, toDevice, type, time, groupId];
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
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
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
      time: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
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
  final int time;
  final String groupId;
  const BubbleEntity(
      {required this.id,
      required this.fromDevice,
      required this.toDevice,
      required this.type,
      required this.time,
      required this.groupId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_device'] = Variable<String>(fromDevice);
    map['to_device'] = Variable<String>(toDevice);
    map['type'] = Variable<int>(type);
    map['time'] = Variable<int>(time);
    map['group_id'] = Variable<String>(groupId);
    return map;
  }

  BubbleEntitiesCompanion toCompanion(bool nullToAbsent) {
    return BubbleEntitiesCompanion(
      id: Value(id),
      fromDevice: Value(fromDevice),
      toDevice: Value(toDevice),
      type: Value(type),
      time: Value(time),
      groupId: Value(groupId),
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
      time: serializer.fromJson<int>(json['time']),
      groupId: serializer.fromJson<String>(json['groupId']),
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
      'time': serializer.toJson<int>(time),
      'groupId': serializer.toJson<String>(groupId),
    };
  }

  BubbleEntity copyWith(
          {String? id,
          String? fromDevice,
          String? toDevice,
          int? type,
          int? time,
          String? groupId}) =>
      BubbleEntity(
        id: id ?? this.id,
        fromDevice: fromDevice ?? this.fromDevice,
        toDevice: toDevice ?? this.toDevice,
        type: type ?? this.type,
        time: time ?? this.time,
        groupId: groupId ?? this.groupId,
      );
  BubbleEntity copyWithCompanion(BubbleEntitiesCompanion data) {
    return BubbleEntity(
      id: data.id.present ? data.id.value : this.id,
      fromDevice:
          data.fromDevice.present ? data.fromDevice.value : this.fromDevice,
      toDevice: data.toDevice.present ? data.toDevice.value : this.toDevice,
      type: data.type.present ? data.type.value : this.type,
      time: data.time.present ? data.time.value : this.time,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BubbleEntity(')
          ..write('id: $id, ')
          ..write('fromDevice: $fromDevice, ')
          ..write('toDevice: $toDevice, ')
          ..write('type: $type, ')
          ..write('time: $time, ')
          ..write('groupId: $groupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fromDevice, toDevice, type, time, groupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BubbleEntity &&
          other.id == this.id &&
          other.fromDevice == this.fromDevice &&
          other.toDevice == this.toDevice &&
          other.type == this.type &&
          other.time == this.time &&
          other.groupId == this.groupId);
}

class BubbleEntitiesCompanion extends UpdateCompanion<BubbleEntity> {
  final Value<String> id;
  final Value<String> fromDevice;
  final Value<String> toDevice;
  final Value<int> type;
  final Value<int> time;
  final Value<String> groupId;
  final Value<int> rowid;
  const BubbleEntitiesCompanion({
    this.id = const Value.absent(),
    this.fromDevice = const Value.absent(),
    this.toDevice = const Value.absent(),
    this.type = const Value.absent(),
    this.time = const Value.absent(),
    this.groupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BubbleEntitiesCompanion.insert({
    required String id,
    required String fromDevice,
    required String toDevice,
    required int type,
    this.time = const Value.absent(),
    this.groupId = const Value.absent(),
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
    Expression<int>? time,
    Expression<String>? groupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromDevice != null) 'from_device': fromDevice,
      if (toDevice != null) 'to_device': toDevice,
      if (type != null) 'type': type,
      if (time != null) 'time': time,
      if (groupId != null) 'group_id': groupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BubbleEntitiesCompanion copyWith(
      {Value<String>? id,
      Value<String>? fromDevice,
      Value<String>? toDevice,
      Value<int>? type,
      Value<int>? time,
      Value<String>? groupId,
      Value<int>? rowid}) {
    return BubbleEntitiesCompanion(
      id: id ?? this.id,
      fromDevice: fromDevice ?? this.fromDevice,
      toDevice: toDevice ?? this.toDevice,
      type: type ?? this.type,
      time: time ?? this.time,
      groupId: groupId ?? this.groupId,
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
    if (time.present) {
      map['time'] = Variable<int>(time.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
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
          ..write('time: $time, ')
          ..write('groupId: $groupId, ')
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
  TextContent copyWithCompanion(TextContentsCompanion data) {
    return TextContent(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
    );
  }

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
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _resourceIdMeta =
      const VerificationMeta('resourceId');
  @override
  late final GeneratedColumn<String> resourceId = GeneratedColumn<String>(
      'resource_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
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
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<int> speed = GeneratedColumn<int>(
      'speed', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
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
        groupId,
        resourceId,
        name,
        mimeType,
        nameWithSuffix,
        size,
        path,
        state,
        progress,
        speed,
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
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    }
    if (data.containsKey('resource_id')) {
      context.handle(
          _resourceIdMeta,
          resourceId.isAcceptableOrUnknown(
              data['resource_id']!, _resourceIdMeta));
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
    if (data.containsKey('speed')) {
      context.handle(
          _speedMeta, speed.isAcceptableOrUnknown(data['speed']!, _speedMeta));
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
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      resourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}resource_id'])!,
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
      speed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}speed'])!,
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
  final String groupId;
  final String resourceId;
  final String name;
  final String mimeType;
  final String nameWithSuffix;
  final int size;
  final String? path;
  final int state;
  final double progress;
  final int speed;
  final int width;
  final int height;
  final bool waitingForAccept;
  const FileContent(
      {required this.id,
      required this.groupId,
      required this.resourceId,
      required this.name,
      required this.mimeType,
      required this.nameWithSuffix,
      required this.size,
      this.path,
      required this.state,
      required this.progress,
      required this.speed,
      required this.width,
      required this.height,
      required this.waitingForAccept});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['resource_id'] = Variable<String>(resourceId);
    map['name'] = Variable<String>(name);
    map['mime_type'] = Variable<String>(mimeType);
    map['name_with_suffix'] = Variable<String>(nameWithSuffix);
    map['size'] = Variable<int>(size);
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    map['state'] = Variable<int>(state);
    map['progress'] = Variable<double>(progress);
    map['speed'] = Variable<int>(speed);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['waiting_for_accept'] = Variable<bool>(waitingForAccept);
    return map;
  }

  FileContentsCompanion toCompanion(bool nullToAbsent) {
    return FileContentsCompanion(
      id: Value(id),
      groupId: Value(groupId),
      resourceId: Value(resourceId),
      name: Value(name),
      mimeType: Value(mimeType),
      nameWithSuffix: Value(nameWithSuffix),
      size: Value(size),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      state: Value(state),
      progress: Value(progress),
      speed: Value(speed),
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
      groupId: serializer.fromJson<String>(json['groupId']),
      resourceId: serializer.fromJson<String>(json['resourceId']),
      name: serializer.fromJson<String>(json['name']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      nameWithSuffix: serializer.fromJson<String>(json['nameWithSuffix']),
      size: serializer.fromJson<int>(json['size']),
      path: serializer.fromJson<String?>(json['path']),
      state: serializer.fromJson<int>(json['state']),
      progress: serializer.fromJson<double>(json['progress']),
      speed: serializer.fromJson<int>(json['speed']),
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
      'groupId': serializer.toJson<String>(groupId),
      'resourceId': serializer.toJson<String>(resourceId),
      'name': serializer.toJson<String>(name),
      'mimeType': serializer.toJson<String>(mimeType),
      'nameWithSuffix': serializer.toJson<String>(nameWithSuffix),
      'size': serializer.toJson<int>(size),
      'path': serializer.toJson<String?>(path),
      'state': serializer.toJson<int>(state),
      'progress': serializer.toJson<double>(progress),
      'speed': serializer.toJson<int>(speed),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'waitingForAccept': serializer.toJson<bool>(waitingForAccept),
    };
  }

  FileContent copyWith(
          {String? id,
          String? groupId,
          String? resourceId,
          String? name,
          String? mimeType,
          String? nameWithSuffix,
          int? size,
          Value<String?> path = const Value.absent(),
          int? state,
          double? progress,
          int? speed,
          int? width,
          int? height,
          bool? waitingForAccept}) =>
      FileContent(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        resourceId: resourceId ?? this.resourceId,
        name: name ?? this.name,
        mimeType: mimeType ?? this.mimeType,
        nameWithSuffix: nameWithSuffix ?? this.nameWithSuffix,
        size: size ?? this.size,
        path: path.present ? path.value : this.path,
        state: state ?? this.state,
        progress: progress ?? this.progress,
        speed: speed ?? this.speed,
        width: width ?? this.width,
        height: height ?? this.height,
        waitingForAccept: waitingForAccept ?? this.waitingForAccept,
      );
  FileContent copyWithCompanion(FileContentsCompanion data) {
    return FileContent(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      resourceId:
          data.resourceId.present ? data.resourceId.value : this.resourceId,
      name: data.name.present ? data.name.value : this.name,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      nameWithSuffix: data.nameWithSuffix.present
          ? data.nameWithSuffix.value
          : this.nameWithSuffix,
      size: data.size.present ? data.size.value : this.size,
      path: data.path.present ? data.path.value : this.path,
      state: data.state.present ? data.state.value : this.state,
      progress: data.progress.present ? data.progress.value : this.progress,
      speed: data.speed.present ? data.speed.value : this.speed,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      waitingForAccept: data.waitingForAccept.present
          ? data.waitingForAccept.value
          : this.waitingForAccept,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FileContent(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('resourceId: $resourceId, ')
          ..write('name: $name, ')
          ..write('mimeType: $mimeType, ')
          ..write('nameWithSuffix: $nameWithSuffix, ')
          ..write('size: $size, ')
          ..write('path: $path, ')
          ..write('state: $state, ')
          ..write('progress: $progress, ')
          ..write('speed: $speed, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('waitingForAccept: $waitingForAccept')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      groupId,
      resourceId,
      name,
      mimeType,
      nameWithSuffix,
      size,
      path,
      state,
      progress,
      speed,
      width,
      height,
      waitingForAccept);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FileContent &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.resourceId == this.resourceId &&
          other.name == this.name &&
          other.mimeType == this.mimeType &&
          other.nameWithSuffix == this.nameWithSuffix &&
          other.size == this.size &&
          other.path == this.path &&
          other.state == this.state &&
          other.progress == this.progress &&
          other.speed == this.speed &&
          other.width == this.width &&
          other.height == this.height &&
          other.waitingForAccept == this.waitingForAccept);
}

class FileContentsCompanion extends UpdateCompanion<FileContent> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> resourceId;
  final Value<String> name;
  final Value<String> mimeType;
  final Value<String> nameWithSuffix;
  final Value<int> size;
  final Value<String?> path;
  final Value<int> state;
  final Value<double> progress;
  final Value<int> speed;
  final Value<int> width;
  final Value<int> height;
  final Value<bool> waitingForAccept;
  final Value<int> rowid;
  const FileContentsCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.resourceId = const Value.absent(),
    this.name = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.nameWithSuffix = const Value.absent(),
    this.size = const Value.absent(),
    this.path = const Value.absent(),
    this.state = const Value.absent(),
    this.progress = const Value.absent(),
    this.speed = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.waitingForAccept = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FileContentsCompanion.insert({
    required String id,
    this.groupId = const Value.absent(),
    this.resourceId = const Value.absent(),
    required String name,
    required String mimeType,
    required String nameWithSuffix,
    required int size,
    this.path = const Value.absent(),
    required int state,
    required double progress,
    this.speed = const Value.absent(),
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
    Expression<String>? groupId,
    Expression<String>? resourceId,
    Expression<String>? name,
    Expression<String>? mimeType,
    Expression<String>? nameWithSuffix,
    Expression<int>? size,
    Expression<String>? path,
    Expression<int>? state,
    Expression<double>? progress,
    Expression<int>? speed,
    Expression<int>? width,
    Expression<int>? height,
    Expression<bool>? waitingForAccept,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (resourceId != null) 'resource_id': resourceId,
      if (name != null) 'name': name,
      if (mimeType != null) 'mime_type': mimeType,
      if (nameWithSuffix != null) 'name_with_suffix': nameWithSuffix,
      if (size != null) 'size': size,
      if (path != null) 'path': path,
      if (state != null) 'state': state,
      if (progress != null) 'progress': progress,
      if (speed != null) 'speed': speed,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (waitingForAccept != null) 'waiting_for_accept': waitingForAccept,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FileContentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<String>? resourceId,
      Value<String>? name,
      Value<String>? mimeType,
      Value<String>? nameWithSuffix,
      Value<int>? size,
      Value<String?>? path,
      Value<int>? state,
      Value<double>? progress,
      Value<int>? speed,
      Value<int>? width,
      Value<int>? height,
      Value<bool>? waitingForAccept,
      Value<int>? rowid}) {
    return FileContentsCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      resourceId: resourceId ?? this.resourceId,
      name: name ?? this.name,
      mimeType: mimeType ?? this.mimeType,
      nameWithSuffix: nameWithSuffix ?? this.nameWithSuffix,
      size: size ?? this.size,
      path: path ?? this.path,
      state: state ?? this.state,
      progress: progress ?? this.progress,
      speed: speed ?? this.speed,
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
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (resourceId.present) {
      map['resource_id'] = Variable<String>(resourceId.value);
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
    if (speed.present) {
      map['speed'] = Variable<int>(speed.value);
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
          ..write('groupId: $groupId, ')
          ..write('resourceId: $resourceId, ')
          ..write('name: $name, ')
          ..write('mimeType: $mimeType, ')
          ..write('nameWithSuffix: $nameWithSuffix, ')
          ..write('size: $size, ')
          ..write('path: $path, ')
          ..write('state: $state, ')
          ..write('progress: $progress, ')
          ..write('speed: $speed, ')
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
  static const VerificationMeta _versionMeta =
      const VerificationMeta('version');
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
      'version', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _ipMeta = const VerificationMeta('ip');
  @override
  late final GeneratedColumn<String> ip = GeneratedColumn<String>(
      'ip', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
      'host', aliasedName, true,
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
        version,
        ip,
        host,
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
    if (data.containsKey('version')) {
      context.handle(_versionMeta,
          version.isAcceptableOrUnknown(data['version']!, _versionMeta));
    }
    if (data.containsKey('ip')) {
      context.handle(_ipMeta, ip.isAcceptableOrUnknown(data['ip']!, _ipMeta));
    }
    if (data.containsKey('host')) {
      context.handle(
          _hostMeta, host.isAcceptableOrUnknown(data['host']!, _hostMeta));
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
      version: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}version']),
      ip: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ip']),
      host: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}host']),
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
  final int? version;
  final String? ip;
  final String? host;
  final DateTime insertOrUpdateTime;
  const PersistenceDevice(
      {required this.alias,
      this.deviceModel,
      this.deviceType,
      required this.fingerprint,
      this.port,
      this.version,
      this.ip,
      this.host,
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
    if (!nullToAbsent || version != null) {
      map['version'] = Variable<int>(version);
    }
    if (!nullToAbsent || ip != null) {
      map['ip'] = Variable<String>(ip);
    }
    if (!nullToAbsent || host != null) {
      map['host'] = Variable<String>(host);
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
      version: version == null && nullToAbsent
          ? const Value.absent()
          : Value(version),
      ip: ip == null && nullToAbsent ? const Value.absent() : Value(ip),
      host: host == null && nullToAbsent ? const Value.absent() : Value(host),
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
      version: serializer.fromJson<int?>(json['version']),
      ip: serializer.fromJson<String?>(json['ip']),
      host: serializer.fromJson<String?>(json['host']),
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
      'version': serializer.toJson<int?>(version),
      'ip': serializer.toJson<String?>(ip),
      'host': serializer.toJson<String?>(host),
      'insertOrUpdateTime': serializer.toJson<DateTime>(insertOrUpdateTime),
    };
  }

  PersistenceDevice copyWith(
          {String? alias,
          Value<String?> deviceModel = const Value.absent(),
          Value<int?> deviceType = const Value.absent(),
          String? fingerprint,
          Value<int?> port = const Value.absent(),
          Value<int?> version = const Value.absent(),
          Value<String?> ip = const Value.absent(),
          Value<String?> host = const Value.absent(),
          DateTime? insertOrUpdateTime}) =>
      PersistenceDevice(
        alias: alias ?? this.alias,
        deviceModel: deviceModel.present ? deviceModel.value : this.deviceModel,
        deviceType: deviceType.present ? deviceType.value : this.deviceType,
        fingerprint: fingerprint ?? this.fingerprint,
        port: port.present ? port.value : this.port,
        version: version.present ? version.value : this.version,
        ip: ip.present ? ip.value : this.ip,
        host: host.present ? host.value : this.host,
        insertOrUpdateTime: insertOrUpdateTime ?? this.insertOrUpdateTime,
      );
  PersistenceDevice copyWithCompanion(PersistenceDevicesCompanion data) {
    return PersistenceDevice(
      alias: data.alias.present ? data.alias.value : this.alias,
      deviceModel:
          data.deviceModel.present ? data.deviceModel.value : this.deviceModel,
      deviceType:
          data.deviceType.present ? data.deviceType.value : this.deviceType,
      fingerprint:
          data.fingerprint.present ? data.fingerprint.value : this.fingerprint,
      port: data.port.present ? data.port.value : this.port,
      version: data.version.present ? data.version.value : this.version,
      ip: data.ip.present ? data.ip.value : this.ip,
      host: data.host.present ? data.host.value : this.host,
      insertOrUpdateTime: data.insertOrUpdateTime.present
          ? data.insertOrUpdateTime.value
          : this.insertOrUpdateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersistenceDevice(')
          ..write('alias: $alias, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('deviceType: $deviceType, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('port: $port, ')
          ..write('version: $version, ')
          ..write('ip: $ip, ')
          ..write('host: $host, ')
          ..write('insertOrUpdateTime: $insertOrUpdateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(alias, deviceModel, deviceType, fingerprint,
      port, version, ip, host, insertOrUpdateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersistenceDevice &&
          other.alias == this.alias &&
          other.deviceModel == this.deviceModel &&
          other.deviceType == this.deviceType &&
          other.fingerprint == this.fingerprint &&
          other.port == this.port &&
          other.version == this.version &&
          other.ip == this.ip &&
          other.host == this.host &&
          other.insertOrUpdateTime == this.insertOrUpdateTime);
}

class PersistenceDevicesCompanion extends UpdateCompanion<PersistenceDevice> {
  final Value<String> alias;
  final Value<String?> deviceModel;
  final Value<int?> deviceType;
  final Value<String> fingerprint;
  final Value<int?> port;
  final Value<int?> version;
  final Value<String?> ip;
  final Value<String?> host;
  final Value<DateTime> insertOrUpdateTime;
  final Value<int> rowid;
  const PersistenceDevicesCompanion({
    this.alias = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.deviceType = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.port = const Value.absent(),
    this.version = const Value.absent(),
    this.ip = const Value.absent(),
    this.host = const Value.absent(),
    this.insertOrUpdateTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersistenceDevicesCompanion.insert({
    required String alias,
    this.deviceModel = const Value.absent(),
    this.deviceType = const Value.absent(),
    required String fingerprint,
    this.port = const Value.absent(),
    this.version = const Value.absent(),
    this.ip = const Value.absent(),
    this.host = const Value.absent(),
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
    Expression<int>? version,
    Expression<String>? ip,
    Expression<String>? host,
    Expression<DateTime>? insertOrUpdateTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (alias != null) 'alias': alias,
      if (deviceModel != null) 'device_model': deviceModel,
      if (deviceType != null) 'device_type': deviceType,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (port != null) 'port': port,
      if (version != null) 'version': version,
      if (ip != null) 'ip': ip,
      if (host != null) 'host': host,
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
      Value<int?>? version,
      Value<String?>? ip,
      Value<String?>? host,
      Value<DateTime>? insertOrUpdateTime,
      Value<int>? rowid}) {
    return PersistenceDevicesCompanion(
      alias: alias ?? this.alias,
      deviceModel: deviceModel ?? this.deviceModel,
      deviceType: deviceType ?? this.deviceType,
      fingerprint: fingerprint ?? this.fingerprint,
      port: port ?? this.port,
      version: version ?? this.version,
      ip: ip ?? this.ip,
      host: host ?? this.host,
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
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (ip.present) {
      map['ip'] = Variable<String>(ip.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
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
          ..write('version: $version, ')
          ..write('ip: $ip, ')
          ..write('host: $host, ')
          ..write('insertOrUpdateTime: $insertOrUpdateTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PairDevicesTable extends PairDevices
    with TableInfo<$PairDevicesTable, PairDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PairDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fingerprintMeta =
      const VerificationMeta('fingerprint');
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
      'fingerprint', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _insertOrUpdateTimeMeta =
      const VerificationMeta('insertOrUpdateTime');
  @override
  late final GeneratedColumn<DateTime> insertOrUpdateTime =
      GeneratedColumn<DateTime>('insert_or_update_time', aliasedName, false,
          type: DriftSqlType.dateTime,
          requiredDuringInsert: false,
          defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [fingerprint, code, insertOrUpdateTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pair_devices';
  @override
  VerificationContext validateIntegrity(Insertable<PairDevice> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fingerprint')) {
      context.handle(
          _fingerprintMeta,
          fingerprint.isAcceptableOrUnknown(
              data['fingerprint']!, _fingerprintMeta));
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
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
  PairDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PairDevice(
      fingerprint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fingerprint'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      insertOrUpdateTime: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}insert_or_update_time'])!,
    );
  }

  @override
  $PairDevicesTable createAlias(String alias) {
    return $PairDevicesTable(attachedDatabase, alias);
  }
}

class PairDevice extends DataClass implements Insertable<PairDevice> {
  final String fingerprint;
  final String code;
  final DateTime insertOrUpdateTime;
  const PairDevice(
      {required this.fingerprint,
      required this.code,
      required this.insertOrUpdateTime});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fingerprint'] = Variable<String>(fingerprint);
    map['code'] = Variable<String>(code);
    map['insert_or_update_time'] = Variable<DateTime>(insertOrUpdateTime);
    return map;
  }

  PairDevicesCompanion toCompanion(bool nullToAbsent) {
    return PairDevicesCompanion(
      fingerprint: Value(fingerprint),
      code: Value(code),
      insertOrUpdateTime: Value(insertOrUpdateTime),
    );
  }

  factory PairDevice.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PairDevice(
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      code: serializer.fromJson<String>(json['code']),
      insertOrUpdateTime:
          serializer.fromJson<DateTime>(json['insertOrUpdateTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fingerprint': serializer.toJson<String>(fingerprint),
      'code': serializer.toJson<String>(code),
      'insertOrUpdateTime': serializer.toJson<DateTime>(insertOrUpdateTime),
    };
  }

  PairDevice copyWith(
          {String? fingerprint, String? code, DateTime? insertOrUpdateTime}) =>
      PairDevice(
        fingerprint: fingerprint ?? this.fingerprint,
        code: code ?? this.code,
        insertOrUpdateTime: insertOrUpdateTime ?? this.insertOrUpdateTime,
      );
  PairDevice copyWithCompanion(PairDevicesCompanion data) {
    return PairDevice(
      fingerprint:
          data.fingerprint.present ? data.fingerprint.value : this.fingerprint,
      code: data.code.present ? data.code.value : this.code,
      insertOrUpdateTime: data.insertOrUpdateTime.present
          ? data.insertOrUpdateTime.value
          : this.insertOrUpdateTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PairDevice(')
          ..write('fingerprint: $fingerprint, ')
          ..write('code: $code, ')
          ..write('insertOrUpdateTime: $insertOrUpdateTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(fingerprint, code, insertOrUpdateTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PairDevice &&
          other.fingerprint == this.fingerprint &&
          other.code == this.code &&
          other.insertOrUpdateTime == this.insertOrUpdateTime);
}

class PairDevicesCompanion extends UpdateCompanion<PairDevice> {
  final Value<String> fingerprint;
  final Value<String> code;
  final Value<DateTime> insertOrUpdateTime;
  final Value<int> rowid;
  const PairDevicesCompanion({
    this.fingerprint = const Value.absent(),
    this.code = const Value.absent(),
    this.insertOrUpdateTime = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PairDevicesCompanion.insert({
    required String fingerprint,
    required String code,
    this.insertOrUpdateTime = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : fingerprint = Value(fingerprint),
        code = Value(code);
  static Insertable<PairDevice> custom({
    Expression<String>? fingerprint,
    Expression<String>? code,
    Expression<DateTime>? insertOrUpdateTime,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (code != null) 'code': code,
      if (insertOrUpdateTime != null)
        'insert_or_update_time': insertOrUpdateTime,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PairDevicesCompanion copyWith(
      {Value<String>? fingerprint,
      Value<String>? code,
      Value<DateTime>? insertOrUpdateTime,
      Value<int>? rowid}) {
    return PairDevicesCompanion(
      fingerprint: fingerprint ?? this.fingerprint,
      code: code ?? this.code,
      insertOrUpdateTime: insertOrUpdateTime ?? this.insertOrUpdateTime,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
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
    return (StringBuffer('PairDevicesCompanion(')
          ..write('fingerprint: $fingerprint, ')
          ..write('code: $code, ')
          ..write('insertOrUpdateTime: $insertOrUpdateTime, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DirectoryContentsTable extends DirectoryContents
    with TableInfo<$DirectoryContentsTable, DirectoryContent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DirectoryContentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
      'size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<int> state = GeneratedColumn<int>(
      'state', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  List<GeneratedColumn> get $columns =>
      [id, name, size, state, path, waitingForAccept];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'directory_contents';
  @override
  VerificationContext validateIntegrity(Insertable<DirectoryContent> instance,
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
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size']!, _sizeMeta));
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
          _stateMeta, state.isAcceptableOrUnknown(data['state']!, _stateMeta));
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
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
  DirectoryContent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DirectoryContent(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      size: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}size'])!,
      state: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}state'])!,
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path']),
      waitingForAccept: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}waiting_for_accept'])!,
    );
  }

  @override
  $DirectoryContentsTable createAlias(String alias) {
    return $DirectoryContentsTable(attachedDatabase, alias);
  }
}

class DirectoryContent extends DataClass
    implements Insertable<DirectoryContent> {
  final String id;
  final String name;
  final int size;
  final int state;
  final String? path;
  final bool waitingForAccept;
  const DirectoryContent(
      {required this.id,
      required this.name,
      required this.size,
      required this.state,
      this.path,
      required this.waitingForAccept});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['size'] = Variable<int>(size);
    map['state'] = Variable<int>(state);
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    map['waiting_for_accept'] = Variable<bool>(waitingForAccept);
    return map;
  }

  DirectoryContentsCompanion toCompanion(bool nullToAbsent) {
    return DirectoryContentsCompanion(
      id: Value(id),
      name: Value(name),
      size: Value(size),
      state: Value(state),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      waitingForAccept: Value(waitingForAccept),
    );
  }

  factory DirectoryContent.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DirectoryContent(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      size: serializer.fromJson<int>(json['size']),
      state: serializer.fromJson<int>(json['state']),
      path: serializer.fromJson<String?>(json['path']),
      waitingForAccept: serializer.fromJson<bool>(json['waitingForAccept']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'size': serializer.toJson<int>(size),
      'state': serializer.toJson<int>(state),
      'path': serializer.toJson<String?>(path),
      'waitingForAccept': serializer.toJson<bool>(waitingForAccept),
    };
  }

  DirectoryContent copyWith(
          {String? id,
          String? name,
          int? size,
          int? state,
          Value<String?> path = const Value.absent(),
          bool? waitingForAccept}) =>
      DirectoryContent(
        id: id ?? this.id,
        name: name ?? this.name,
        size: size ?? this.size,
        state: state ?? this.state,
        path: path.present ? path.value : this.path,
        waitingForAccept: waitingForAccept ?? this.waitingForAccept,
      );
  DirectoryContent copyWithCompanion(DirectoryContentsCompanion data) {
    return DirectoryContent(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      size: data.size.present ? data.size.value : this.size,
      state: data.state.present ? data.state.value : this.state,
      path: data.path.present ? data.path.value : this.path,
      waitingForAccept: data.waitingForAccept.present
          ? data.waitingForAccept.value
          : this.waitingForAccept,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DirectoryContent(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('size: $size, ')
          ..write('state: $state, ')
          ..write('path: $path, ')
          ..write('waitingForAccept: $waitingForAccept')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, size, state, path, waitingForAccept);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DirectoryContent &&
          other.id == this.id &&
          other.name == this.name &&
          other.size == this.size &&
          other.state == this.state &&
          other.path == this.path &&
          other.waitingForAccept == this.waitingForAccept);
}

class DirectoryContentsCompanion extends UpdateCompanion<DirectoryContent> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> size;
  final Value<int> state;
  final Value<String?> path;
  final Value<bool> waitingForAccept;
  final Value<int> rowid;
  const DirectoryContentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.size = const Value.absent(),
    this.state = const Value.absent(),
    this.path = const Value.absent(),
    this.waitingForAccept = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DirectoryContentsCompanion.insert({
    required String id,
    required String name,
    required int size,
    required int state,
    this.path = const Value.absent(),
    this.waitingForAccept = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        size = Value(size),
        state = Value(state);
  static Insertable<DirectoryContent> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? size,
    Expression<int>? state,
    Expression<String>? path,
    Expression<bool>? waitingForAccept,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (size != null) 'size': size,
      if (state != null) 'state': state,
      if (path != null) 'path': path,
      if (waitingForAccept != null) 'waiting_for_accept': waitingForAccept,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DirectoryContentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int>? size,
      Value<int>? state,
      Value<String?>? path,
      Value<bool>? waitingForAccept,
      Value<int>? rowid}) {
    return DirectoryContentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      state: state ?? this.state,
      path: path ?? this.path,
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
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (state.present) {
      map['state'] = Variable<int>(state.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
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
    return (StringBuffer('DirectoryContentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('size: $size, ')
          ..write('state: $state, ')
          ..write('path: $path, ')
          ..write('waitingForAccept: $waitingForAccept, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BubbleEntitiesTable bubbleEntities = $BubbleEntitiesTable(this);
  late final $TextContentsTable textContents = $TextContentsTable(this);
  late final $FileContentsTable fileContents = $FileContentsTable(this);
  late final $PersistenceDevicesTable persistenceDevices =
      $PersistenceDevicesTable(this);
  late final $PairDevicesTable pairDevices = $PairDevicesTable(this);
  late final $DirectoryContentsTable directoryContents =
      $DirectoryContentsTable(this);
  late final BubblesDao bubblesDao = BubblesDao(this as AppDatabase);
  late final DevicesDao devicesDao = DevicesDao(this as AppDatabase);
  late final PairDevicesDao pairDevicesDao =
      PairDevicesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        bubbleEntities,
        textContents,
        fileContents,
        persistenceDevices,
        pairDevices,
        directoryContents
      ];
}

typedef $$BubbleEntitiesTableCreateCompanionBuilder = BubbleEntitiesCompanion
    Function({
  required String id,
  required String fromDevice,
  required String toDevice,
  required int type,
  Value<int> time,
  Value<String> groupId,
  Value<int> rowid,
});
typedef $$BubbleEntitiesTableUpdateCompanionBuilder = BubbleEntitiesCompanion
    Function({
  Value<String> id,
  Value<String> fromDevice,
  Value<String> toDevice,
  Value<int> type,
  Value<int> time,
  Value<String> groupId,
  Value<int> rowid,
});

class $$BubbleEntitiesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BubbleEntitiesTable,
    BubbleEntity,
    $$BubbleEntitiesTableFilterComposer,
    $$BubbleEntitiesTableOrderingComposer,
    $$BubbleEntitiesTableCreateCompanionBuilder,
    $$BubbleEntitiesTableUpdateCompanionBuilder> {
  $$BubbleEntitiesTableTableManager(
      _$AppDatabase db, $BubbleEntitiesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$BubbleEntitiesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$BubbleEntitiesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> fromDevice = const Value.absent(),
            Value<String> toDevice = const Value.absent(),
            Value<int> type = const Value.absent(),
            Value<int> time = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BubbleEntitiesCompanion(
            id: id,
            fromDevice: fromDevice,
            toDevice: toDevice,
            type: type,
            time: time,
            groupId: groupId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String fromDevice,
            required String toDevice,
            required int type,
            Value<int> time = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BubbleEntitiesCompanion.insert(
            id: id,
            fromDevice: fromDevice,
            toDevice: toDevice,
            type: type,
            time: time,
            groupId: groupId,
            rowid: rowid,
          ),
        ));
}

class $$BubbleEntitiesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $BubbleEntitiesTable> {
  $$BubbleEntitiesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fromDevice => $state.composableBuilder(
      column: $state.table.fromDevice,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get toDevice => $state.composableBuilder(
      column: $state.table.toDevice,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get time => $state.composableBuilder(
      column: $state.table.time,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get groupId => $state.composableBuilder(
      column: $state.table.groupId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$BubbleEntitiesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $BubbleEntitiesTable> {
  $$BubbleEntitiesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fromDevice => $state.composableBuilder(
      column: $state.table.fromDevice,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get toDevice => $state.composableBuilder(
      column: $state.table.toDevice,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get type => $state.composableBuilder(
      column: $state.table.type,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get time => $state.composableBuilder(
      column: $state.table.time,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get groupId => $state.composableBuilder(
      column: $state.table.groupId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$TextContentsTableCreateCompanionBuilder = TextContentsCompanion
    Function({
  required String id,
  required String content,
  Value<int> rowid,
});
typedef $$TextContentsTableUpdateCompanionBuilder = TextContentsCompanion
    Function({
  Value<String> id,
  Value<String> content,
  Value<int> rowid,
});

class $$TextContentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TextContentsTable,
    TextContent,
    $$TextContentsTableFilterComposer,
    $$TextContentsTableOrderingComposer,
    $$TextContentsTableCreateCompanionBuilder,
    $$TextContentsTableUpdateCompanionBuilder> {
  $$TextContentsTableTableManager(_$AppDatabase db, $TextContentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TextContentsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TextContentsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TextContentsCompanion(
            id: id,
            content: content,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String content,
            Value<int> rowid = const Value.absent(),
          }) =>
              TextContentsCompanion.insert(
            id: id,
            content: content,
            rowid: rowid,
          ),
        ));
}

class $$TextContentsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TextContentsTable> {
  $$TextContentsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$TextContentsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TextContentsTable> {
  $$TextContentsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$FileContentsTableCreateCompanionBuilder = FileContentsCompanion
    Function({
  required String id,
  Value<String> groupId,
  Value<String> resourceId,
  required String name,
  required String mimeType,
  required String nameWithSuffix,
  required int size,
  Value<String?> path,
  required int state,
  required double progress,
  Value<int> speed,
  required int width,
  required int height,
  Value<bool> waitingForAccept,
  Value<int> rowid,
});
typedef $$FileContentsTableUpdateCompanionBuilder = FileContentsCompanion
    Function({
  Value<String> id,
  Value<String> groupId,
  Value<String> resourceId,
  Value<String> name,
  Value<String> mimeType,
  Value<String> nameWithSuffix,
  Value<int> size,
  Value<String?> path,
  Value<int> state,
  Value<double> progress,
  Value<int> speed,
  Value<int> width,
  Value<int> height,
  Value<bool> waitingForAccept,
  Value<int> rowid,
});

class $$FileContentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FileContentsTable,
    FileContent,
    $$FileContentsTableFilterComposer,
    $$FileContentsTableOrderingComposer,
    $$FileContentsTableCreateCompanionBuilder,
    $$FileContentsTableUpdateCompanionBuilder> {
  $$FileContentsTableTableManager(_$AppDatabase db, $FileContentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FileContentsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FileContentsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> resourceId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> mimeType = const Value.absent(),
            Value<String> nameWithSuffix = const Value.absent(),
            Value<int> size = const Value.absent(),
            Value<String?> path = const Value.absent(),
            Value<int> state = const Value.absent(),
            Value<double> progress = const Value.absent(),
            Value<int> speed = const Value.absent(),
            Value<int> width = const Value.absent(),
            Value<int> height = const Value.absent(),
            Value<bool> waitingForAccept = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FileContentsCompanion(
            id: id,
            groupId: groupId,
            resourceId: resourceId,
            name: name,
            mimeType: mimeType,
            nameWithSuffix: nameWithSuffix,
            size: size,
            path: path,
            state: state,
            progress: progress,
            speed: speed,
            width: width,
            height: height,
            waitingForAccept: waitingForAccept,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> groupId = const Value.absent(),
            Value<String> resourceId = const Value.absent(),
            required String name,
            required String mimeType,
            required String nameWithSuffix,
            required int size,
            Value<String?> path = const Value.absent(),
            required int state,
            required double progress,
            Value<int> speed = const Value.absent(),
            required int width,
            required int height,
            Value<bool> waitingForAccept = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FileContentsCompanion.insert(
            id: id,
            groupId: groupId,
            resourceId: resourceId,
            name: name,
            mimeType: mimeType,
            nameWithSuffix: nameWithSuffix,
            size: size,
            path: path,
            state: state,
            progress: progress,
            speed: speed,
            width: width,
            height: height,
            waitingForAccept: waitingForAccept,
            rowid: rowid,
          ),
        ));
}

class $$FileContentsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $FileContentsTable> {
  $$FileContentsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get groupId => $state.composableBuilder(
      column: $state.table.groupId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get resourceId => $state.composableBuilder(
      column: $state.table.resourceId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get mimeType => $state.composableBuilder(
      column: $state.table.mimeType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get nameWithSuffix => $state.composableBuilder(
      column: $state.table.nameWithSuffix,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get size => $state.composableBuilder(
      column: $state.table.size,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get path => $state.composableBuilder(
      column: $state.table.path,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get progress => $state.composableBuilder(
      column: $state.table.progress,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get speed => $state.composableBuilder(
      column: $state.table.speed,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get width => $state.composableBuilder(
      column: $state.table.width,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get height => $state.composableBuilder(
      column: $state.table.height,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get waitingForAccept => $state.composableBuilder(
      column: $state.table.waitingForAccept,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$FileContentsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $FileContentsTable> {
  $$FileContentsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get groupId => $state.composableBuilder(
      column: $state.table.groupId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get resourceId => $state.composableBuilder(
      column: $state.table.resourceId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get mimeType => $state.composableBuilder(
      column: $state.table.mimeType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get nameWithSuffix => $state.composableBuilder(
      column: $state.table.nameWithSuffix,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get size => $state.composableBuilder(
      column: $state.table.size,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get path => $state.composableBuilder(
      column: $state.table.path,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get progress => $state.composableBuilder(
      column: $state.table.progress,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get speed => $state.composableBuilder(
      column: $state.table.speed,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get width => $state.composableBuilder(
      column: $state.table.width,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get height => $state.composableBuilder(
      column: $state.table.height,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get waitingForAccept => $state.composableBuilder(
      column: $state.table.waitingForAccept,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$PersistenceDevicesTableCreateCompanionBuilder
    = PersistenceDevicesCompanion Function({
  required String alias,
  Value<String?> deviceModel,
  Value<int?> deviceType,
  required String fingerprint,
  Value<int?> port,
  Value<int?> version,
  Value<String?> ip,
  Value<String?> host,
  Value<DateTime> insertOrUpdateTime,
  Value<int> rowid,
});
typedef $$PersistenceDevicesTableUpdateCompanionBuilder
    = PersistenceDevicesCompanion Function({
  Value<String> alias,
  Value<String?> deviceModel,
  Value<int?> deviceType,
  Value<String> fingerprint,
  Value<int?> port,
  Value<int?> version,
  Value<String?> ip,
  Value<String?> host,
  Value<DateTime> insertOrUpdateTime,
  Value<int> rowid,
});

class $$PersistenceDevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PersistenceDevicesTable,
    PersistenceDevice,
    $$PersistenceDevicesTableFilterComposer,
    $$PersistenceDevicesTableOrderingComposer,
    $$PersistenceDevicesTableCreateCompanionBuilder,
    $$PersistenceDevicesTableUpdateCompanionBuilder> {
  $$PersistenceDevicesTableTableManager(
      _$AppDatabase db, $PersistenceDevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PersistenceDevicesTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$PersistenceDevicesTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> alias = const Value.absent(),
            Value<String?> deviceModel = const Value.absent(),
            Value<int?> deviceType = const Value.absent(),
            Value<String> fingerprint = const Value.absent(),
            Value<int?> port = const Value.absent(),
            Value<int?> version = const Value.absent(),
            Value<String?> ip = const Value.absent(),
            Value<String?> host = const Value.absent(),
            Value<DateTime> insertOrUpdateTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PersistenceDevicesCompanion(
            alias: alias,
            deviceModel: deviceModel,
            deviceType: deviceType,
            fingerprint: fingerprint,
            port: port,
            version: version,
            ip: ip,
            host: host,
            insertOrUpdateTime: insertOrUpdateTime,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String alias,
            Value<String?> deviceModel = const Value.absent(),
            Value<int?> deviceType = const Value.absent(),
            required String fingerprint,
            Value<int?> port = const Value.absent(),
            Value<int?> version = const Value.absent(),
            Value<String?> ip = const Value.absent(),
            Value<String?> host = const Value.absent(),
            Value<DateTime> insertOrUpdateTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PersistenceDevicesCompanion.insert(
            alias: alias,
            deviceModel: deviceModel,
            deviceType: deviceType,
            fingerprint: fingerprint,
            port: port,
            version: version,
            ip: ip,
            host: host,
            insertOrUpdateTime: insertOrUpdateTime,
            rowid: rowid,
          ),
        ));
}

class $$PersistenceDevicesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PersistenceDevicesTable> {
  $$PersistenceDevicesTableFilterComposer(super.$state);
  ColumnFilters<String> get alias => $state.composableBuilder(
      column: $state.table.alias,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get deviceModel => $state.composableBuilder(
      column: $state.table.deviceModel,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get deviceType => $state.composableBuilder(
      column: $state.table.deviceType,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get fingerprint => $state.composableBuilder(
      column: $state.table.fingerprint,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get port => $state.composableBuilder(
      column: $state.table.port,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get ip => $state.composableBuilder(
      column: $state.table.ip,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get host => $state.composableBuilder(
      column: $state.table.host,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get insertOrUpdateTime => $state.composableBuilder(
      column: $state.table.insertOrUpdateTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PersistenceDevicesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PersistenceDevicesTable> {
  $$PersistenceDevicesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get alias => $state.composableBuilder(
      column: $state.table.alias,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get deviceModel => $state.composableBuilder(
      column: $state.table.deviceModel,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get deviceType => $state.composableBuilder(
      column: $state.table.deviceType,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get fingerprint => $state.composableBuilder(
      column: $state.table.fingerprint,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get port => $state.composableBuilder(
      column: $state.table.port,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get version => $state.composableBuilder(
      column: $state.table.version,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get ip => $state.composableBuilder(
      column: $state.table.ip,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get host => $state.composableBuilder(
      column: $state.table.host,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get insertOrUpdateTime => $state.composableBuilder(
      column: $state.table.insertOrUpdateTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$PairDevicesTableCreateCompanionBuilder = PairDevicesCompanion
    Function({
  required String fingerprint,
  required String code,
  Value<DateTime> insertOrUpdateTime,
  Value<int> rowid,
});
typedef $$PairDevicesTableUpdateCompanionBuilder = PairDevicesCompanion
    Function({
  Value<String> fingerprint,
  Value<String> code,
  Value<DateTime> insertOrUpdateTime,
  Value<int> rowid,
});

class $$PairDevicesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PairDevicesTable,
    PairDevice,
    $$PairDevicesTableFilterComposer,
    $$PairDevicesTableOrderingComposer,
    $$PairDevicesTableCreateCompanionBuilder,
    $$PairDevicesTableUpdateCompanionBuilder> {
  $$PairDevicesTableTableManager(_$AppDatabase db, $PairDevicesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$PairDevicesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$PairDevicesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> fingerprint = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<DateTime> insertOrUpdateTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PairDevicesCompanion(
            fingerprint: fingerprint,
            code: code,
            insertOrUpdateTime: insertOrUpdateTime,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String fingerprint,
            required String code,
            Value<DateTime> insertOrUpdateTime = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PairDevicesCompanion.insert(
            fingerprint: fingerprint,
            code: code,
            insertOrUpdateTime: insertOrUpdateTime,
            rowid: rowid,
          ),
        ));
}

class $$PairDevicesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $PairDevicesTable> {
  $$PairDevicesTableFilterComposer(super.$state);
  ColumnFilters<String> get fingerprint => $state.composableBuilder(
      column: $state.table.fingerprint,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get code => $state.composableBuilder(
      column: $state.table.code,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get insertOrUpdateTime => $state.composableBuilder(
      column: $state.table.insertOrUpdateTime,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$PairDevicesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $PairDevicesTable> {
  $$PairDevicesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get fingerprint => $state.composableBuilder(
      column: $state.table.fingerprint,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get code => $state.composableBuilder(
      column: $state.table.code,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get insertOrUpdateTime => $state.composableBuilder(
      column: $state.table.insertOrUpdateTime,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$DirectoryContentsTableCreateCompanionBuilder
    = DirectoryContentsCompanion Function({
  required String id,
  required String name,
  required int size,
  required int state,
  Value<String?> path,
  Value<bool> waitingForAccept,
  Value<int> rowid,
});
typedef $$DirectoryContentsTableUpdateCompanionBuilder
    = DirectoryContentsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> size,
  Value<int> state,
  Value<String?> path,
  Value<bool> waitingForAccept,
  Value<int> rowid,
});

class $$DirectoryContentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DirectoryContentsTable,
    DirectoryContent,
    $$DirectoryContentsTableFilterComposer,
    $$DirectoryContentsTableOrderingComposer,
    $$DirectoryContentsTableCreateCompanionBuilder,
    $$DirectoryContentsTableUpdateCompanionBuilder> {
  $$DirectoryContentsTableTableManager(
      _$AppDatabase db, $DirectoryContentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DirectoryContentsTableFilterComposer(ComposerState(db, table)),
          orderingComposer: $$DirectoryContentsTableOrderingComposer(
              ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> size = const Value.absent(),
            Value<int> state = const Value.absent(),
            Value<String?> path = const Value.absent(),
            Value<bool> waitingForAccept = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DirectoryContentsCompanion(
            id: id,
            name: name,
            size: size,
            state: state,
            path: path,
            waitingForAccept: waitingForAccept,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required int size,
            required int state,
            Value<String?> path = const Value.absent(),
            Value<bool> waitingForAccept = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DirectoryContentsCompanion.insert(
            id: id,
            name: name,
            size: size,
            state: state,
            path: path,
            waitingForAccept: waitingForAccept,
            rowid: rowid,
          ),
        ));
}

class $$DirectoryContentsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $DirectoryContentsTable> {
  $$DirectoryContentsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get size => $state.composableBuilder(
      column: $state.table.size,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get path => $state.composableBuilder(
      column: $state.table.path,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get waitingForAccept => $state.composableBuilder(
      column: $state.table.waitingForAccept,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$DirectoryContentsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $DirectoryContentsTable> {
  $$DirectoryContentsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get size => $state.composableBuilder(
      column: $state.table.size,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get state => $state.composableBuilder(
      column: $state.table.state,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get path => $state.composableBuilder(
      column: $state.table.path,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get waitingForAccept => $state.composableBuilder(
      column: $state.table.waitingForAccept,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BubbleEntitiesTableTableManager get bubbleEntities =>
      $$BubbleEntitiesTableTableManager(_db, _db.bubbleEntities);
  $$TextContentsTableTableManager get textContents =>
      $$TextContentsTableTableManager(_db, _db.textContents);
  $$FileContentsTableTableManager get fileContents =>
      $$FileContentsTableTableManager(_db, _db.fileContents);
  $$PersistenceDevicesTableTableManager get persistenceDevices =>
      $$PersistenceDevicesTableTableManager(_db, _db.persistenceDevices);
  $$PairDevicesTableTableManager get pairDevices =>
      $$PairDevicesTableTableManager(_db, _db.pairDevices);
  $$DirectoryContentsTableTableManager get directoryContents =>
      $$DirectoryContentsTableTableManager(_db, _db.directoryContents);
}
