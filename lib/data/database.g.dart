// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $HouseholdsTable extends Households
    with TableInfo<$HouseholdsTable, Household> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HouseholdsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _defaultGuestsMeta =
      const VerificationMeta('defaultGuests');
  @override
  late final GeneratedColumn<int> defaultGuests = GeneratedColumn<int>(
      'default_guests', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(4));
  static const VerificationMeta _weekStartDayMeta =
      const VerificationMeta('weekStartDay');
  @override
  late final GeneratedColumn<int> weekStartDay = GeneratedColumn<int>(
      'week_start_day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _seededAtMeta =
      const VerificationMeta('seededAt');
  @override
  late final GeneratedColumn<DateTime> seededAt = GeneratedColumn<DateTime>(
      'seeded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, defaultGuests, weekStartDay, seededAt, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'household';
  @override
  VerificationContext validateIntegrity(Insertable<Household> instance,
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
    }
    if (data.containsKey('default_guests')) {
      context.handle(
          _defaultGuestsMeta,
          defaultGuests.isAcceptableOrUnknown(
              data['default_guests']!, _defaultGuestsMeta));
    }
    if (data.containsKey('week_start_day')) {
      context.handle(
          _weekStartDayMeta,
          weekStartDay.isAcceptableOrUnknown(
              data['week_start_day']!, _weekStartDayMeta));
    }
    if (data.containsKey('seeded_at')) {
      context.handle(_seededAtMeta,
          seededAt.isAcceptableOrUnknown(data['seeded_at']!, _seededAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Household map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Household(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      defaultGuests: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}default_guests'])!,
      weekStartDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}week_start_day'])!,
      seededAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}seeded_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $HouseholdsTable createAlias(String alias) {
    return $HouseholdsTable(attachedDatabase, alias);
  }
}

class Household extends DataClass implements Insertable<Household> {
  final String id;
  final String? name;
  final int defaultGuests;
  final int weekStartDay;
  final DateTime? seededAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Household(
      {required this.id,
      this.name,
      required this.defaultGuests,
      required this.weekStartDay,
      this.seededAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    map['default_guests'] = Variable<int>(defaultGuests);
    map['week_start_day'] = Variable<int>(weekStartDay);
    if (!nullToAbsent || seededAt != null) {
      map['seeded_at'] = Variable<DateTime>(seededAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HouseholdsCompanion toCompanion(bool nullToAbsent) {
    return HouseholdsCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      defaultGuests: Value(defaultGuests),
      weekStartDay: Value(weekStartDay),
      seededAt: seededAt == null && nullToAbsent
          ? const Value.absent()
          : Value(seededAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Household.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Household(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      defaultGuests: serializer.fromJson<int>(json['defaultGuests']),
      weekStartDay: serializer.fromJson<int>(json['weekStartDay']),
      seededAt: serializer.fromJson<DateTime?>(json['seededAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String?>(name),
      'defaultGuests': serializer.toJson<int>(defaultGuests),
      'weekStartDay': serializer.toJson<int>(weekStartDay),
      'seededAt': serializer.toJson<DateTime?>(seededAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Household copyWith(
          {String? id,
          Value<String?> name = const Value.absent(),
          int? defaultGuests,
          int? weekStartDay,
          Value<DateTime?> seededAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Household(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
        defaultGuests: defaultGuests ?? this.defaultGuests,
        weekStartDay: weekStartDay ?? this.weekStartDay,
        seededAt: seededAt.present ? seededAt.value : this.seededAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Household copyWithCompanion(HouseholdsCompanion data) {
    return Household(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      defaultGuests: data.defaultGuests.present
          ? data.defaultGuests.value
          : this.defaultGuests,
      weekStartDay: data.weekStartDay.present
          ? data.weekStartDay.value
          : this.weekStartDay,
      seededAt: data.seededAt.present ? data.seededAt.value : this.seededAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Household(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultGuests: $defaultGuests, ')
          ..write('weekStartDay: $weekStartDay, ')
          ..write('seededAt: $seededAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, defaultGuests, weekStartDay, seededAt, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Household &&
          other.id == this.id &&
          other.name == this.name &&
          other.defaultGuests == this.defaultGuests &&
          other.weekStartDay == this.weekStartDay &&
          other.seededAt == this.seededAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HouseholdsCompanion extends UpdateCompanion<Household> {
  final Value<String> id;
  final Value<String?> name;
  final Value<int> defaultGuests;
  final Value<int> weekStartDay;
  final Value<DateTime?> seededAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const HouseholdsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.defaultGuests = const Value.absent(),
    this.weekStartDay = const Value.absent(),
    this.seededAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HouseholdsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.defaultGuests = const Value.absent(),
    this.weekStartDay = const Value.absent(),
    this.seededAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Household> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? defaultGuests,
    Expression<int>? weekStartDay,
    Expression<DateTime>? seededAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (defaultGuests != null) 'default_guests': defaultGuests,
      if (weekStartDay != null) 'week_start_day': weekStartDay,
      if (seededAt != null) 'seeded_at': seededAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HouseholdsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? name,
      Value<int>? defaultGuests,
      Value<int>? weekStartDay,
      Value<DateTime?>? seededAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return HouseholdsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultGuests: defaultGuests ?? this.defaultGuests,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      seededAt: seededAt ?? this.seededAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (defaultGuests.present) {
      map['default_guests'] = Variable<int>(defaultGuests.value);
    }
    if (weekStartDay.present) {
      map['week_start_day'] = Variable<int>(weekStartDay.value);
    }
    if (seededAt.present) {
      map['seeded_at'] = Variable<DateTime>(seededAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HouseholdsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('defaultGuests: $defaultGuests, ')
          ..write('weekStartDay: $weekStartDay, ')
          ..write('seededAt: $seededAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembershipsTable extends Memberships
    with TableInfo<$MembershipsTable, Membership> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembershipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _deviceIdMeta =
      const VerificationMeta('deviceId');
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
      'device_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('member'));
  static const VerificationMeta _joinedAtMeta =
      const VerificationMeta('joinedAt');
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
      'joined_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, householdId, deviceId, role, joinedAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'membership';
  @override
  VerificationContext validateIntegrity(Insertable<Membership> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(_deviceIdMeta,
          deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta));
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    }
    if (data.containsKey('joined_at')) {
      context.handle(_joinedAtMeta,
          joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta));
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Membership map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Membership(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      deviceId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}device_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      joinedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}joined_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MembershipsTable createAlias(String alias) {
    return $MembershipsTable(attachedDatabase, alias);
  }
}

class Membership extends DataClass implements Insertable<Membership> {
  final String id;
  final String householdId;
  final String deviceId;
  final String role;
  final DateTime joinedAt;
  final DateTime updatedAt;
  const Membership(
      {required this.id,
      required this.householdId,
      required this.deviceId,
      required this.role,
      required this.joinedAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['device_id'] = Variable<String>(deviceId);
    map['role'] = Variable<String>(role);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MembershipsCompanion toCompanion(bool nullToAbsent) {
    return MembershipsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      deviceId: Value(deviceId),
      role: Value(role),
      joinedAt: Value(joinedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Membership.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Membership(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      role: serializer.fromJson<String>(json['role']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'deviceId': serializer.toJson<String>(deviceId),
      'role': serializer.toJson<String>(role),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Membership copyWith(
          {String? id,
          String? householdId,
          String? deviceId,
          String? role,
          DateTime? joinedAt,
          DateTime? updatedAt}) =>
      Membership(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        deviceId: deviceId ?? this.deviceId,
        role: role ?? this.role,
        joinedAt: joinedAt ?? this.joinedAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Membership copyWithCompanion(MembershipsCompanion data) {
    return Membership(
      id: data.id.present ? data.id.value : this.id,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      role: data.role.present ? data.role.value : this.role,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Membership(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('deviceId: $deviceId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, householdId, deviceId, role, joinedAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Membership &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.deviceId == this.deviceId &&
          other.role == this.role &&
          other.joinedAt == this.joinedAt &&
          other.updatedAt == this.updatedAt);
}

class MembershipsCompanion extends UpdateCompanion<Membership> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> deviceId;
  final Value<String> role;
  final Value<DateTime> joinedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MembershipsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembershipsCompanion.insert({
    required String id,
    required String householdId,
    required String deviceId,
    this.role = const Value.absent(),
    required DateTime joinedAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        householdId = Value(householdId),
        deviceId = Value(deviceId),
        joinedAt = Value(joinedAt),
        updatedAt = Value(updatedAt);
  static Insertable<Membership> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? deviceId,
    Expression<String>? role,
    Expression<DateTime>? joinedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (deviceId != null) 'device_id': deviceId,
      if (role != null) 'role': role,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembershipsCompanion copyWith(
      {Value<String>? id,
      Value<String>? householdId,
      Value<String>? deviceId,
      Value<String>? role,
      Value<DateTime>? joinedAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return MembershipsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      deviceId: deviceId ?? this.deviceId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembershipsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('deviceId: $deviceId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IngredientsTable extends Ingredients
    with TableInfo<$IngredientsTable, Ingredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isQbMeta = const VerificationMeta('isQb');
  @override
  late final GeneratedColumn<bool> isQb = GeneratedColumn<bool>(
      'is_qb', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_qb" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roundingKindMeta =
      const VerificationMeta('roundingKind');
  @override
  late final GeneratedColumn<String> roundingKind = GeneratedColumn<String>(
      'rounding_kind', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seedKeyMeta =
      const VerificationMeta('seedKey');
  @override
  late final GeneratedColumn<String> seedKey = GeneratedColumn<String>(
      'seed_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameModifiedMeta =
      const VerificationMeta('nameModified');
  @override
  late final GeneratedColumn<bool> nameModified = GeneratedColumn<bool>(
      'name_modified', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("name_modified" IN (0, 1))'));
  static const VerificationMeta _alwaysInListMeta =
      const VerificationMeta('alwaysInList');
  @override
  late final GeneratedColumn<bool> alwaysInList = GeneratedColumn<bool>(
      'always_in_list', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("always_in_list" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _defaultQtyMeta =
      const VerificationMeta('defaultQty');
  @override
  late final GeneratedColumn<double> defaultQty = GeneratedColumn<double>(
      'default_qty', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        householdId,
        name,
        unit,
        isQb,
        category,
        roundingKind,
        seedKey,
        nameModified,
        alwaysInList,
        defaultQty,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ingredient';
  @override
  VerificationContext validateIntegrity(Insertable<Ingredient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('is_qb')) {
      context.handle(
          _isQbMeta, isQb.isAcceptableOrUnknown(data['is_qb']!, _isQbMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('rounding_kind')) {
      context.handle(
          _roundingKindMeta,
          roundingKind.isAcceptableOrUnknown(
              data['rounding_kind']!, _roundingKindMeta));
    }
    if (data.containsKey('seed_key')) {
      context.handle(_seedKeyMeta,
          seedKey.isAcceptableOrUnknown(data['seed_key']!, _seedKeyMeta));
    }
    if (data.containsKey('name_modified')) {
      context.handle(
          _nameModifiedMeta,
          nameModified.isAcceptableOrUnknown(
              data['name_modified']!, _nameModifiedMeta));
    }
    if (data.containsKey('always_in_list')) {
      context.handle(
          _alwaysInListMeta,
          alwaysInList.isAcceptableOrUnknown(
              data['always_in_list']!, _alwaysInListMeta));
    }
    if (data.containsKey('default_qty')) {
      context.handle(
          _defaultQtyMeta,
          defaultQty.isAcceptableOrUnknown(
              data['default_qty']!, _defaultQtyMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {householdId, name},
      ];
  @override
  Ingredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ingredient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      isQb: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_qb'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      roundingKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rounding_kind']),
      seedKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seed_key']),
      nameModified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}name_modified']),
      alwaysInList: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}always_in_list'])!,
      defaultQty: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}default_qty']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $IngredientsTable createAlias(String alias) {
    return $IngredientsTable(attachedDatabase, alias);
  }
}

class Ingredient extends DataClass implements Insertable<Ingredient> {
  final String id;
  final String householdId;
  final String name;
  final String unit;
  final bool isQb;
  final String? category;
  final String? roundingKind;
  final String? seedKey;
  final bool? nameModified;
  final bool alwaysInList;
  final double? defaultQty;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Ingredient(
      {required this.id,
      required this.householdId,
      required this.name,
      required this.unit,
      required this.isQb,
      this.category,
      this.roundingKind,
      this.seedKey,
      this.nameModified,
      required this.alwaysInList,
      this.defaultQty,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['name'] = Variable<String>(name);
    map['unit'] = Variable<String>(unit);
    map['is_qb'] = Variable<bool>(isQb);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || roundingKind != null) {
      map['rounding_kind'] = Variable<String>(roundingKind);
    }
    if (!nullToAbsent || seedKey != null) {
      map['seed_key'] = Variable<String>(seedKey);
    }
    if (!nullToAbsent || nameModified != null) {
      map['name_modified'] = Variable<bool>(nameModified);
    }
    map['always_in_list'] = Variable<bool>(alwaysInList);
    if (!nullToAbsent || defaultQty != null) {
      map['default_qty'] = Variable<double>(defaultQty);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  IngredientsCompanion toCompanion(bool nullToAbsent) {
    return IngredientsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      name: Value(name),
      unit: Value(unit),
      isQb: Value(isQb),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      roundingKind: roundingKind == null && nullToAbsent
          ? const Value.absent()
          : Value(roundingKind),
      seedKey: seedKey == null && nullToAbsent
          ? const Value.absent()
          : Value(seedKey),
      nameModified: nameModified == null && nullToAbsent
          ? const Value.absent()
          : Value(nameModified),
      alwaysInList: Value(alwaysInList),
      defaultQty: defaultQty == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultQty),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Ingredient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ingredient(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String>(json['unit']),
      isQb: serializer.fromJson<bool>(json['isQb']),
      category: serializer.fromJson<String?>(json['category']),
      roundingKind: serializer.fromJson<String?>(json['roundingKind']),
      seedKey: serializer.fromJson<String?>(json['seedKey']),
      nameModified: serializer.fromJson<bool?>(json['nameModified']),
      alwaysInList: serializer.fromJson<bool>(json['alwaysInList']),
      defaultQty: serializer.fromJson<double?>(json['defaultQty']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String>(unit),
      'isQb': serializer.toJson<bool>(isQb),
      'category': serializer.toJson<String?>(category),
      'roundingKind': serializer.toJson<String?>(roundingKind),
      'seedKey': serializer.toJson<String?>(seedKey),
      'nameModified': serializer.toJson<bool?>(nameModified),
      'alwaysInList': serializer.toJson<bool>(alwaysInList),
      'defaultQty': serializer.toJson<double?>(defaultQty),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Ingredient copyWith(
          {String? id,
          String? householdId,
          String? name,
          String? unit,
          bool? isQb,
          Value<String?> category = const Value.absent(),
          Value<String?> roundingKind = const Value.absent(),
          Value<String?> seedKey = const Value.absent(),
          Value<bool?> nameModified = const Value.absent(),
          bool? alwaysInList,
          Value<double?> defaultQty = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Ingredient(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        name: name ?? this.name,
        unit: unit ?? this.unit,
        isQb: isQb ?? this.isQb,
        category: category.present ? category.value : this.category,
        roundingKind:
            roundingKind.present ? roundingKind.value : this.roundingKind,
        seedKey: seedKey.present ? seedKey.value : this.seedKey,
        nameModified:
            nameModified.present ? nameModified.value : this.nameModified,
        alwaysInList: alwaysInList ?? this.alwaysInList,
        defaultQty: defaultQty.present ? defaultQty.value : this.defaultQty,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Ingredient copyWithCompanion(IngredientsCompanion data) {
    return Ingredient(
      id: data.id.present ? data.id.value : this.id,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      isQb: data.isQb.present ? data.isQb.value : this.isQb,
      category: data.category.present ? data.category.value : this.category,
      roundingKind: data.roundingKind.present
          ? data.roundingKind.value
          : this.roundingKind,
      seedKey: data.seedKey.present ? data.seedKey.value : this.seedKey,
      nameModified: data.nameModified.present
          ? data.nameModified.value
          : this.nameModified,
      alwaysInList: data.alwaysInList.present
          ? data.alwaysInList.value
          : this.alwaysInList,
      defaultQty:
          data.defaultQty.present ? data.defaultQty.value : this.defaultQty,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ingredient(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('isQb: $isQb, ')
          ..write('category: $category, ')
          ..write('roundingKind: $roundingKind, ')
          ..write('seedKey: $seedKey, ')
          ..write('nameModified: $nameModified, ')
          ..write('alwaysInList: $alwaysInList, ')
          ..write('defaultQty: $defaultQty, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      householdId,
      name,
      unit,
      isQb,
      category,
      roundingKind,
      seedKey,
      nameModified,
      alwaysInList,
      defaultQty,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ingredient &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.isQb == this.isQb &&
          other.category == this.category &&
          other.roundingKind == this.roundingKind &&
          other.seedKey == this.seedKey &&
          other.nameModified == this.nameModified &&
          other.alwaysInList == this.alwaysInList &&
          other.defaultQty == this.defaultQty &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class IngredientsCompanion extends UpdateCompanion<Ingredient> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> name;
  final Value<String> unit;
  final Value<bool> isQb;
  final Value<String?> category;
  final Value<String?> roundingKind;
  final Value<String?> seedKey;
  final Value<bool?> nameModified;
  final Value<bool> alwaysInList;
  final Value<double?> defaultQty;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const IngredientsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.isQb = const Value.absent(),
    this.category = const Value.absent(),
    this.roundingKind = const Value.absent(),
    this.seedKey = const Value.absent(),
    this.nameModified = const Value.absent(),
    this.alwaysInList = const Value.absent(),
    this.defaultQty = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IngredientsCompanion.insert({
    required String id,
    required String householdId,
    required String name,
    required String unit,
    this.isQb = const Value.absent(),
    this.category = const Value.absent(),
    this.roundingKind = const Value.absent(),
    this.seedKey = const Value.absent(),
    this.nameModified = const Value.absent(),
    this.alwaysInList = const Value.absent(),
    this.defaultQty = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        householdId = Value(householdId),
        name = Value(name),
        unit = Value(unit),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Ingredient> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<bool>? isQb,
    Expression<String>? category,
    Expression<String>? roundingKind,
    Expression<String>? seedKey,
    Expression<bool>? nameModified,
    Expression<bool>? alwaysInList,
    Expression<double>? defaultQty,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (isQb != null) 'is_qb': isQb,
      if (category != null) 'category': category,
      if (roundingKind != null) 'rounding_kind': roundingKind,
      if (seedKey != null) 'seed_key': seedKey,
      if (nameModified != null) 'name_modified': nameModified,
      if (alwaysInList != null) 'always_in_list': alwaysInList,
      if (defaultQty != null) 'default_qty': defaultQty,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IngredientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? householdId,
      Value<String>? name,
      Value<String>? unit,
      Value<bool>? isQb,
      Value<String?>? category,
      Value<String?>? roundingKind,
      Value<String?>? seedKey,
      Value<bool?>? nameModified,
      Value<bool>? alwaysInList,
      Value<double?>? defaultQty,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return IngredientsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      isQb: isQb ?? this.isQb,
      category: category ?? this.category,
      roundingKind: roundingKind ?? this.roundingKind,
      seedKey: seedKey ?? this.seedKey,
      nameModified: nameModified ?? this.nameModified,
      alwaysInList: alwaysInList ?? this.alwaysInList,
      defaultQty: defaultQty ?? this.defaultQty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (isQb.present) {
      map['is_qb'] = Variable<bool>(isQb.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (roundingKind.present) {
      map['rounding_kind'] = Variable<String>(roundingKind.value);
    }
    if (seedKey.present) {
      map['seed_key'] = Variable<String>(seedKey.value);
    }
    if (nameModified.present) {
      map['name_modified'] = Variable<bool>(nameModified.value);
    }
    if (alwaysInList.present) {
      map['always_in_list'] = Variable<bool>(alwaysInList.value);
    }
    if (defaultQty.present) {
      map['default_qty'] = Variable<double>(defaultQty.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IngredientsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('isQb: $isQb, ')
          ..write('category: $category, ')
          ..write('roundingKind: $roundingKind, ')
          ..write('seedKey: $seedKey, ')
          ..write('nameModified: $nameModified, ')
          ..write('alwaysInList: $alwaysInList, ')
          ..write('defaultQty: $defaultQty, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagGroupMeta =
      const VerificationMeta('tagGroup');
  @override
  late final GeneratedColumn<String> tagGroup = GeneratedColumn<String>(
      'group', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, householdId, name, tagGroup, color, sortOrder, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('group')) {
      context.handle(_tagGroupMeta,
          tagGroup.isAcceptableOrUnknown(data['group']!, _tagGroupMeta));
    } else if (isInserting) {
      context.missing(_tagGroupMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {householdId, name},
      ];
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      tagGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String householdId;
  final String name;
  final String tagGroup;
  final String? color;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Tag(
      {required this.id,
      required this.householdId,
      required this.name,
      required this.tagGroup,
      this.color,
      required this.sortOrder,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['name'] = Variable<String>(name);
    map['group'] = Variable<String>(tagGroup);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      name: Value(name),
      tagGroup: Value(tagGroup),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      name: serializer.fromJson<String>(json['name']),
      tagGroup: serializer.fromJson<String>(json['tagGroup']),
      color: serializer.fromJson<String?>(json['color']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'name': serializer.toJson<String>(name),
      'tagGroup': serializer.toJson<String>(tagGroup),
      'color': serializer.toJson<String?>(color),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Tag copyWith(
          {String? id,
          String? householdId,
          String? name,
          String? tagGroup,
          Value<String?> color = const Value.absent(),
          int? sortOrder,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Tag(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        name: name ?? this.name,
        tagGroup: tagGroup ?? this.tagGroup,
        color: color.present ? color.value : this.color,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      name: data.name.present ? data.name.value : this.name,
      tagGroup: data.tagGroup.present ? data.tagGroup.value : this.tagGroup,
      color: data.color.present ? data.color.value : this.color,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('name: $name, ')
          ..write('tagGroup: $tagGroup, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, householdId, name, tagGroup, color, sortOrder, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.name == this.name &&
          other.tagGroup == this.tagGroup &&
          other.color == this.color &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> name;
  final Value<String> tagGroup;
  final Value<String?> color;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.name = const Value.absent(),
    this.tagGroup = const Value.absent(),
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String householdId,
    required String name,
    required String tagGroup,
    this.color = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        householdId = Value(householdId),
        name = Value(name),
        tagGroup = Value(tagGroup),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? name,
    Expression<String>? tagGroup,
    Expression<String>? color,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (name != null) 'name': name,
      if (tagGroup != null) 'group': tagGroup,
      if (color != null) 'color': color,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? householdId,
      Value<String>? name,
      Value<String>? tagGroup,
      Value<String?>? color,
      Value<int>? sortOrder,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      tagGroup: tagGroup ?? this.tagGroup,
      color: color ?? this.color,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (tagGroup.present) {
      map['group'] = Variable<String>(tagGroup.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('name: $name, ')
          ..write('tagGroup: $tagGroup, ')
          ..write('color: $color, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DishesTable extends Dishes with TableInfo<$DishesTable, Dish> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DishesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timeEstimateMeta =
      const VerificationMeta('timeEstimate');
  @override
  late final GeneratedColumn<String> timeEstimate = GeneratedColumn<String>(
      'time_estimate', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recipeUrlMeta =
      const VerificationMeta('recipeUrl');
  @override
  late final GeneratedColumn<String> recipeUrl = GeneratedColumn<String>(
      'recipe_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _seedKeyMeta =
      const VerificationMeta('seedKey');
  @override
  late final GeneratedColumn<String> seedKey = GeneratedColumn<String>(
      'seed_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nameModifiedMeta =
      const VerificationMeta('nameModified');
  @override
  late final GeneratedColumn<bool> nameModified = GeneratedColumn<bool>(
      'name_modified', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("name_modified" IN (0, 1))'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        householdId,
        name,
        difficulty,
        timeEstimate,
        recipeUrl,
        seedKey,
        nameModified,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dish';
  @override
  VerificationContext validateIntegrity(Insertable<Dish> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('time_estimate')) {
      context.handle(
          _timeEstimateMeta,
          timeEstimate.isAcceptableOrUnknown(
              data['time_estimate']!, _timeEstimateMeta));
    }
    if (data.containsKey('recipe_url')) {
      context.handle(_recipeUrlMeta,
          recipeUrl.isAcceptableOrUnknown(data['recipe_url']!, _recipeUrlMeta));
    }
    if (data.containsKey('seed_key')) {
      context.handle(_seedKeyMeta,
          seedKey.isAcceptableOrUnknown(data['seed_key']!, _seedKeyMeta));
    }
    if (data.containsKey('name_modified')) {
      context.handle(
          _nameModifiedMeta,
          nameModified.isAcceptableOrUnknown(
              data['name_modified']!, _nameModifiedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dish map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dish(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty']),
      timeEstimate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time_estimate']),
      recipeUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_url']),
      seedKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}seed_key']),
      nameModified: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}name_modified']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DishesTable createAlias(String alias) {
    return $DishesTable(attachedDatabase, alias);
  }
}

class Dish extends DataClass implements Insertable<Dish> {
  final String id;
  final String householdId;
  final String name;
  final String? difficulty;
  final String? timeEstimate;
  final String? recipeUrl;
  final String? seedKey;
  final bool? nameModified;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Dish(
      {required this.id,
      required this.householdId,
      required this.name,
      this.difficulty,
      this.timeEstimate,
      this.recipeUrl,
      this.seedKey,
      this.nameModified,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || difficulty != null) {
      map['difficulty'] = Variable<String>(difficulty);
    }
    if (!nullToAbsent || timeEstimate != null) {
      map['time_estimate'] = Variable<String>(timeEstimate);
    }
    if (!nullToAbsent || recipeUrl != null) {
      map['recipe_url'] = Variable<String>(recipeUrl);
    }
    if (!nullToAbsent || seedKey != null) {
      map['seed_key'] = Variable<String>(seedKey);
    }
    if (!nullToAbsent || nameModified != null) {
      map['name_modified'] = Variable<bool>(nameModified);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DishesCompanion toCompanion(bool nullToAbsent) {
    return DishesCompanion(
      id: Value(id),
      householdId: Value(householdId),
      name: Value(name),
      difficulty: difficulty == null && nullToAbsent
          ? const Value.absent()
          : Value(difficulty),
      timeEstimate: timeEstimate == null && nullToAbsent
          ? const Value.absent()
          : Value(timeEstimate),
      recipeUrl: recipeUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(recipeUrl),
      seedKey: seedKey == null && nullToAbsent
          ? const Value.absent()
          : Value(seedKey),
      nameModified: nameModified == null && nullToAbsent
          ? const Value.absent()
          : Value(nameModified),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Dish.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dish(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      name: serializer.fromJson<String>(json['name']),
      difficulty: serializer.fromJson<String?>(json['difficulty']),
      timeEstimate: serializer.fromJson<String?>(json['timeEstimate']),
      recipeUrl: serializer.fromJson<String?>(json['recipeUrl']),
      seedKey: serializer.fromJson<String?>(json['seedKey']),
      nameModified: serializer.fromJson<bool?>(json['nameModified']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'name': serializer.toJson<String>(name),
      'difficulty': serializer.toJson<String?>(difficulty),
      'timeEstimate': serializer.toJson<String?>(timeEstimate),
      'recipeUrl': serializer.toJson<String?>(recipeUrl),
      'seedKey': serializer.toJson<String?>(seedKey),
      'nameModified': serializer.toJson<bool?>(nameModified),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Dish copyWith(
          {String? id,
          String? householdId,
          String? name,
          Value<String?> difficulty = const Value.absent(),
          Value<String?> timeEstimate = const Value.absent(),
          Value<String?> recipeUrl = const Value.absent(),
          Value<String?> seedKey = const Value.absent(),
          Value<bool?> nameModified = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Dish(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        name: name ?? this.name,
        difficulty: difficulty.present ? difficulty.value : this.difficulty,
        timeEstimate:
            timeEstimate.present ? timeEstimate.value : this.timeEstimate,
        recipeUrl: recipeUrl.present ? recipeUrl.value : this.recipeUrl,
        seedKey: seedKey.present ? seedKey.value : this.seedKey,
        nameModified:
            nameModified.present ? nameModified.value : this.nameModified,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Dish copyWithCompanion(DishesCompanion data) {
    return Dish(
      id: data.id.present ? data.id.value : this.id,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      name: data.name.present ? data.name.value : this.name,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      timeEstimate: data.timeEstimate.present
          ? data.timeEstimate.value
          : this.timeEstimate,
      recipeUrl: data.recipeUrl.present ? data.recipeUrl.value : this.recipeUrl,
      seedKey: data.seedKey.present ? data.seedKey.value : this.seedKey,
      nameModified: data.nameModified.present
          ? data.nameModified.value
          : this.nameModified,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dish(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('name: $name, ')
          ..write('difficulty: $difficulty, ')
          ..write('timeEstimate: $timeEstimate, ')
          ..write('recipeUrl: $recipeUrl, ')
          ..write('seedKey: $seedKey, ')
          ..write('nameModified: $nameModified, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, householdId, name, difficulty,
      timeEstimate, recipeUrl, seedKey, nameModified, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dish &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.name == this.name &&
          other.difficulty == this.difficulty &&
          other.timeEstimate == this.timeEstimate &&
          other.recipeUrl == this.recipeUrl &&
          other.seedKey == this.seedKey &&
          other.nameModified == this.nameModified &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DishesCompanion extends UpdateCompanion<Dish> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> name;
  final Value<String?> difficulty;
  final Value<String?> timeEstimate;
  final Value<String?> recipeUrl;
  final Value<String?> seedKey;
  final Value<bool?> nameModified;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DishesCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.name = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.timeEstimate = const Value.absent(),
    this.recipeUrl = const Value.absent(),
    this.seedKey = const Value.absent(),
    this.nameModified = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DishesCompanion.insert({
    required String id,
    required String householdId,
    required String name,
    this.difficulty = const Value.absent(),
    this.timeEstimate = const Value.absent(),
    this.recipeUrl = const Value.absent(),
    this.seedKey = const Value.absent(),
    this.nameModified = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        householdId = Value(householdId),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Dish> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? name,
    Expression<String>? difficulty,
    Expression<String>? timeEstimate,
    Expression<String>? recipeUrl,
    Expression<String>? seedKey,
    Expression<bool>? nameModified,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (name != null) 'name': name,
      if (difficulty != null) 'difficulty': difficulty,
      if (timeEstimate != null) 'time_estimate': timeEstimate,
      if (recipeUrl != null) 'recipe_url': recipeUrl,
      if (seedKey != null) 'seed_key': seedKey,
      if (nameModified != null) 'name_modified': nameModified,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DishesCompanion copyWith(
      {Value<String>? id,
      Value<String>? householdId,
      Value<String>? name,
      Value<String?>? difficulty,
      Value<String?>? timeEstimate,
      Value<String?>? recipeUrl,
      Value<String?>? seedKey,
      Value<bool?>? nameModified,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DishesCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      difficulty: difficulty ?? this.difficulty,
      timeEstimate: timeEstimate ?? this.timeEstimate,
      recipeUrl: recipeUrl ?? this.recipeUrl,
      seedKey: seedKey ?? this.seedKey,
      nameModified: nameModified ?? this.nameModified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (timeEstimate.present) {
      map['time_estimate'] = Variable<String>(timeEstimate.value);
    }
    if (recipeUrl.present) {
      map['recipe_url'] = Variable<String>(recipeUrl.value);
    }
    if (seedKey.present) {
      map['seed_key'] = Variable<String>(seedKey.value);
    }
    if (nameModified.present) {
      map['name_modified'] = Variable<bool>(nameModified.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DishesCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('name: $name, ')
          ..write('difficulty: $difficulty, ')
          ..write('timeEstimate: $timeEstimate, ')
          ..write('recipeUrl: $recipeUrl, ')
          ..write('seedKey: $seedKey, ')
          ..write('nameModified: $nameModified, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DishTagsTable extends DishTags with TableInfo<$DishTagsTable, DishTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DishTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dishIdMeta = const VerificationMeta('dishId');
  @override
  late final GeneratedColumn<String> dishId = GeneratedColumn<String>(
      'dish_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, dishId, tagId, householdId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dish_tag';
  @override
  VerificationContext validateIntegrity(Insertable<DishTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dish_id')) {
      context.handle(_dishIdMeta,
          dishId.isAcceptableOrUnknown(data['dish_id']!, _dishIdMeta));
    } else if (isInserting) {
      context.missing(_dishIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {dishId, tagId},
      ];
  @override
  DishTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DishTag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dishId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dish_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $DishTagsTable createAlias(String alias) {
    return $DishTagsTable(attachedDatabase, alias);
  }
}

class DishTag extends DataClass implements Insertable<DishTag> {
  final String id;
  final String dishId;
  final String tagId;
  final String householdId;
  final DateTime createdAt;
  const DishTag(
      {required this.id,
      required this.dishId,
      required this.tagId,
      required this.householdId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dish_id'] = Variable<String>(dishId);
    map['tag_id'] = Variable<String>(tagId);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DishTagsCompanion toCompanion(bool nullToAbsent) {
    return DishTagsCompanion(
      id: Value(id),
      dishId: Value(dishId),
      tagId: Value(tagId),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
    );
  }

  factory DishTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DishTag(
      id: serializer.fromJson<String>(json['id']),
      dishId: serializer.fromJson<String>(json['dishId']),
      tagId: serializer.fromJson<String>(json['tagId']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dishId': serializer.toJson<String>(dishId),
      'tagId': serializer.toJson<String>(tagId),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DishTag copyWith(
          {String? id,
          String? dishId,
          String? tagId,
          String? householdId,
          DateTime? createdAt}) =>
      DishTag(
        id: id ?? this.id,
        dishId: dishId ?? this.dishId,
        tagId: tagId ?? this.tagId,
        householdId: householdId ?? this.householdId,
        createdAt: createdAt ?? this.createdAt,
      );
  DishTag copyWithCompanion(DishTagsCompanion data) {
    return DishTag(
      id: data.id.present ? data.id.value : this.id,
      dishId: data.dishId.present ? data.dishId.value : this.dishId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DishTag(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('tagId: $tagId, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, dishId, tagId, householdId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DishTag &&
          other.id == this.id &&
          other.dishId == this.dishId &&
          other.tagId == this.tagId &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt);
}

class DishTagsCompanion extends UpdateCompanion<DishTag> {
  final Value<String> id;
  final Value<String> dishId;
  final Value<String> tagId;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DishTagsCompanion({
    this.id = const Value.absent(),
    this.dishId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DishTagsCompanion.insert({
    required String id,
    required String dishId,
    required String tagId,
    required String householdId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        dishId = Value(dishId),
        tagId = Value(tagId),
        householdId = Value(householdId),
        createdAt = Value(createdAt);
  static Insertable<DishTag> custom({
    Expression<String>? id,
    Expression<String>? dishId,
    Expression<String>? tagId,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dishId != null) 'dish_id': dishId,
      if (tagId != null) 'tag_id': tagId,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DishTagsCompanion copyWith(
      {Value<String>? id,
      Value<String>? dishId,
      Value<String>? tagId,
      Value<String>? householdId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return DishTagsCompanion(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      tagId: tagId ?? this.tagId,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dishId.present) {
      map['dish_id'] = Variable<String>(dishId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DishTagsCompanion(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('tagId: $tagId, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DishIngredientsTable extends DishIngredients
    with TableInfo<$DishIngredientsTable, DishIngredient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DishIngredientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dishIdMeta = const VerificationMeta('dishId');
  @override
  late final GeneratedColumn<String> dishId = GeneratedColumn<String>(
      'dish_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ingredientIdMeta =
      const VerificationMeta('ingredientId');
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
      'ingredient_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _qtyBase4Meta =
      const VerificationMeta('qtyBase4');
  @override
  late final GeneratedColumn<double> qtyBase4 = GeneratedColumn<double>(
      'qty_base4', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, dishId, ingredientId, householdId, qtyBase4, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dish_ingredient';
  @override
  VerificationContext validateIntegrity(Insertable<DishIngredient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('dish_id')) {
      context.handle(_dishIdMeta,
          dishId.isAcceptableOrUnknown(data['dish_id']!, _dishIdMeta));
    } else if (isInserting) {
      context.missing(_dishIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
          _ingredientIdMeta,
          ingredientId.isAcceptableOrUnknown(
              data['ingredient_id']!, _ingredientIdMeta));
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('qty_base4')) {
      context.handle(_qtyBase4Meta,
          qtyBase4.isAcceptableOrUnknown(data['qty_base4']!, _qtyBase4Meta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {dishId, ingredientId},
      ];
  @override
  DishIngredient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DishIngredient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      dishId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dish_id'])!,
      ingredientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ingredient_id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      qtyBase4: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}qty_base4']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $DishIngredientsTable createAlias(String alias) {
    return $DishIngredientsTable(attachedDatabase, alias);
  }
}

class DishIngredient extends DataClass implements Insertable<DishIngredient> {
  final String id;
  final String dishId;
  final String ingredientId;
  final String householdId;
  final double? qtyBase4;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DishIngredient(
      {required this.id,
      required this.dishId,
      required this.ingredientId,
      required this.householdId,
      this.qtyBase4,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['dish_id'] = Variable<String>(dishId);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['household_id'] = Variable<String>(householdId);
    if (!nullToAbsent || qtyBase4 != null) {
      map['qty_base4'] = Variable<double>(qtyBase4);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DishIngredientsCompanion toCompanion(bool nullToAbsent) {
    return DishIngredientsCompanion(
      id: Value(id),
      dishId: Value(dishId),
      ingredientId: Value(ingredientId),
      householdId: Value(householdId),
      qtyBase4: qtyBase4 == null && nullToAbsent
          ? const Value.absent()
          : Value(qtyBase4),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DishIngredient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DishIngredient(
      id: serializer.fromJson<String>(json['id']),
      dishId: serializer.fromJson<String>(json['dishId']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      householdId: serializer.fromJson<String>(json['householdId']),
      qtyBase4: serializer.fromJson<double?>(json['qtyBase4']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dishId': serializer.toJson<String>(dishId),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'householdId': serializer.toJson<String>(householdId),
      'qtyBase4': serializer.toJson<double?>(qtyBase4),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DishIngredient copyWith(
          {String? id,
          String? dishId,
          String? ingredientId,
          String? householdId,
          Value<double?> qtyBase4 = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      DishIngredient(
        id: id ?? this.id,
        dishId: dishId ?? this.dishId,
        ingredientId: ingredientId ?? this.ingredientId,
        householdId: householdId ?? this.householdId,
        qtyBase4: qtyBase4.present ? qtyBase4.value : this.qtyBase4,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  DishIngredient copyWithCompanion(DishIngredientsCompanion data) {
    return DishIngredient(
      id: data.id.present ? data.id.value : this.id,
      dishId: data.dishId.present ? data.dishId.value : this.dishId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      qtyBase4: data.qtyBase4.present ? data.qtyBase4.value : this.qtyBase4,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DishIngredient(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('householdId: $householdId, ')
          ..write('qtyBase4: $qtyBase4, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, dishId, ingredientId, householdId, qtyBase4, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DishIngredient &&
          other.id == this.id &&
          other.dishId == this.dishId &&
          other.ingredientId == this.ingredientId &&
          other.householdId == this.householdId &&
          other.qtyBase4 == this.qtyBase4 &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DishIngredientsCompanion extends UpdateCompanion<DishIngredient> {
  final Value<String> id;
  final Value<String> dishId;
  final Value<String> ingredientId;
  final Value<String> householdId;
  final Value<double?> qtyBase4;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DishIngredientsCompanion({
    this.id = const Value.absent(),
    this.dishId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.qtyBase4 = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DishIngredientsCompanion.insert({
    required String id,
    required String dishId,
    required String ingredientId,
    required String householdId,
    this.qtyBase4 = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        dishId = Value(dishId),
        ingredientId = Value(ingredientId),
        householdId = Value(householdId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DishIngredient> custom({
    Expression<String>? id,
    Expression<String>? dishId,
    Expression<String>? ingredientId,
    Expression<String>? householdId,
    Expression<double>? qtyBase4,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dishId != null) 'dish_id': dishId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (householdId != null) 'household_id': householdId,
      if (qtyBase4 != null) 'qty_base4': qtyBase4,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DishIngredientsCompanion copyWith(
      {Value<String>? id,
      Value<String>? dishId,
      Value<String>? ingredientId,
      Value<String>? householdId,
      Value<double?>? qtyBase4,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return DishIngredientsCompanion(
      id: id ?? this.id,
      dishId: dishId ?? this.dishId,
      ingredientId: ingredientId ?? this.ingredientId,
      householdId: householdId ?? this.householdId,
      qtyBase4: qtyBase4 ?? this.qtyBase4,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dishId.present) {
      map['dish_id'] = Variable<String>(dishId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (qtyBase4.present) {
      map['qty_base4'] = Variable<double>(qtyBase4.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DishIngredientsCompanion(')
          ..write('id: $id, ')
          ..write('dishId: $dishId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('householdId: $householdId, ')
          ..write('qtyBase4: $qtyBase4, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeekPlansTable extends WeekPlans
    with TableInfo<$WeekPlansTable, WeekPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeekPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _weekMeta = const VerificationMeta('week');
  @override
  late final GeneratedColumn<int> week = GeneratedColumn<int>(
      'week', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, householdId, year, week, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'week_plan';
  @override
  VerificationContext validateIntegrity(Insertable<WeekPlan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('week')) {
      context.handle(
          _weekMeta, week.isAcceptableOrUnknown(data['week']!, _weekMeta));
    } else if (isInserting) {
      context.missing(_weekMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {householdId, year, week},
      ];
  @override
  WeekPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeekPlan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year'])!,
      week: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}week'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $WeekPlansTable createAlias(String alias) {
    return $WeekPlansTable(attachedDatabase, alias);
  }
}

class WeekPlan extends DataClass implements Insertable<WeekPlan> {
  final String id;
  final String householdId;
  final int year;
  final int week;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WeekPlan(
      {required this.id,
      required this.householdId,
      required this.year,
      required this.week,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['year'] = Variable<int>(year);
    map['week'] = Variable<int>(week);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WeekPlansCompanion toCompanion(bool nullToAbsent) {
    return WeekPlansCompanion(
      id: Value(id),
      householdId: Value(householdId),
      year: Value(year),
      week: Value(week),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WeekPlan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeekPlan(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      year: serializer.fromJson<int>(json['year']),
      week: serializer.fromJson<int>(json['week']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'year': serializer.toJson<int>(year),
      'week': serializer.toJson<int>(week),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WeekPlan copyWith(
          {String? id,
          String? householdId,
          int? year,
          int? week,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      WeekPlan(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        year: year ?? this.year,
        week: week ?? this.week,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  WeekPlan copyWithCompanion(WeekPlansCompanion data) {
    return WeekPlan(
      id: data.id.present ? data.id.value : this.id,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      year: data.year.present ? data.year.value : this.year,
      week: data.week.present ? data.week.value : this.week,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeekPlan(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('year: $year, ')
          ..write('week: $week, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, householdId, year, week, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeekPlan &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.year == this.year &&
          other.week == this.week &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WeekPlansCompanion extends UpdateCompanion<WeekPlan> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<int> year;
  final Value<int> week;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WeekPlansCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.year = const Value.absent(),
    this.week = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeekPlansCompanion.insert({
    required String id,
    required String householdId,
    required int year,
    required int week,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        householdId = Value(householdId),
        year = Value(year),
        week = Value(week),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<WeekPlan> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<int>? year,
    Expression<int>? week,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (year != null) 'year': year,
      if (week != null) 'week': week,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeekPlansCompanion copyWith(
      {Value<String>? id,
      Value<String>? householdId,
      Value<int>? year,
      Value<int>? week,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return WeekPlansCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      year: year ?? this.year,
      week: week ?? this.week,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (week.present) {
      map['week'] = Variable<int>(week.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeekPlansCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('year: $year, ')
          ..write('week: $week, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanDaysTable extends PlanDays with TableInfo<$PlanDaysTable, PlanDay> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanDaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weekPlanIdMeta =
      const VerificationMeta('weekPlanId');
  @override
  late final GeneratedColumn<String> weekPlanId = GeneratedColumn<String>(
      'week_plan_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dayOfWeekMeta =
      const VerificationMeta('dayOfWeek');
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
      'day_of_week', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _guestsMeta = const VerificationMeta('guests');
  @override
  late final GeneratedColumn<int> guests = GeneratedColumn<int>(
      'guests', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, weekPlanId, householdId, dayOfWeek, guests, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_day';
  @override
  VerificationContext validateIntegrity(Insertable<PlanDay> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('week_plan_id')) {
      context.handle(
          _weekPlanIdMeta,
          weekPlanId.isAcceptableOrUnknown(
              data['week_plan_id']!, _weekPlanIdMeta));
    } else if (isInserting) {
      context.missing(_weekPlanIdMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
          _dayOfWeekMeta,
          dayOfWeek.isAcceptableOrUnknown(
              data['day_of_week']!, _dayOfWeekMeta));
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('guests')) {
      context.handle(_guestsMeta,
          guests.isAcceptableOrUnknown(data['guests']!, _guestsMeta));
    } else if (isInserting) {
      context.missing(_guestsMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {weekPlanId, dayOfWeek},
      ];
  @override
  PlanDay map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanDay(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      weekPlanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}week_plan_id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      dayOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_week'])!,
      guests: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}guests'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PlanDaysTable createAlias(String alias) {
    return $PlanDaysTable(attachedDatabase, alias);
  }
}

class PlanDay extends DataClass implements Insertable<PlanDay> {
  final String id;
  final String weekPlanId;
  final String householdId;
  final int dayOfWeek;
  final int guests;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PlanDay(
      {required this.id,
      required this.weekPlanId,
      required this.householdId,
      required this.dayOfWeek,
      required this.guests,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['week_plan_id'] = Variable<String>(weekPlanId);
    map['household_id'] = Variable<String>(householdId);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['guests'] = Variable<int>(guests);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlanDaysCompanion toCompanion(bool nullToAbsent) {
    return PlanDaysCompanion(
      id: Value(id),
      weekPlanId: Value(weekPlanId),
      householdId: Value(householdId),
      dayOfWeek: Value(dayOfWeek),
      guests: Value(guests),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlanDay.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanDay(
      id: serializer.fromJson<String>(json['id']),
      weekPlanId: serializer.fromJson<String>(json['weekPlanId']),
      householdId: serializer.fromJson<String>(json['householdId']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      guests: serializer.fromJson<int>(json['guests']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'weekPlanId': serializer.toJson<String>(weekPlanId),
      'householdId': serializer.toJson<String>(householdId),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'guests': serializer.toJson<int>(guests),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlanDay copyWith(
          {String? id,
          String? weekPlanId,
          String? householdId,
          int? dayOfWeek,
          int? guests,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PlanDay(
        id: id ?? this.id,
        weekPlanId: weekPlanId ?? this.weekPlanId,
        householdId: householdId ?? this.householdId,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        guests: guests ?? this.guests,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PlanDay copyWithCompanion(PlanDaysCompanion data) {
    return PlanDay(
      id: data.id.present ? data.id.value : this.id,
      weekPlanId:
          data.weekPlanId.present ? data.weekPlanId.value : this.weekPlanId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      guests: data.guests.present ? data.guests.value : this.guests,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanDay(')
          ..write('id: $id, ')
          ..write('weekPlanId: $weekPlanId, ')
          ..write('householdId: $householdId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('guests: $guests, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, weekPlanId, householdId, dayOfWeek, guests, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanDay &&
          other.id == this.id &&
          other.weekPlanId == this.weekPlanId &&
          other.householdId == this.householdId &&
          other.dayOfWeek == this.dayOfWeek &&
          other.guests == this.guests &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlanDaysCompanion extends UpdateCompanion<PlanDay> {
  final Value<String> id;
  final Value<String> weekPlanId;
  final Value<String> householdId;
  final Value<int> dayOfWeek;
  final Value<int> guests;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PlanDaysCompanion({
    this.id = const Value.absent(),
    this.weekPlanId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.guests = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanDaysCompanion.insert({
    required String id,
    required String weekPlanId,
    required String householdId,
    required int dayOfWeek,
    required int guests,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        weekPlanId = Value(weekPlanId),
        householdId = Value(householdId),
        dayOfWeek = Value(dayOfWeek),
        guests = Value(guests),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PlanDay> custom({
    Expression<String>? id,
    Expression<String>? weekPlanId,
    Expression<String>? householdId,
    Expression<int>? dayOfWeek,
    Expression<int>? guests,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weekPlanId != null) 'week_plan_id': weekPlanId,
      if (householdId != null) 'household_id': householdId,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (guests != null) 'guests': guests,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanDaysCompanion copyWith(
      {Value<String>? id,
      Value<String>? weekPlanId,
      Value<String>? householdId,
      Value<int>? dayOfWeek,
      Value<int>? guests,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PlanDaysCompanion(
      id: id ?? this.id,
      weekPlanId: weekPlanId ?? this.weekPlanId,
      householdId: householdId ?? this.householdId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      guests: guests ?? this.guests,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (weekPlanId.present) {
      map['week_plan_id'] = Variable<String>(weekPlanId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (guests.present) {
      map['guests'] = Variable<int>(guests.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanDaysCompanion(')
          ..write('id: $id, ')
          ..write('weekPlanId: $weekPlanId, ')
          ..write('householdId: $householdId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('guests: $guests, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanDayDishesTable extends PlanDayDishes
    with TableInfo<$PlanDayDishesTable, PlanDayDish> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanDayDishesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _planDayIdMeta =
      const VerificationMeta('planDayId');
  @override
  late final GeneratedColumn<String> planDayId = GeneratedColumn<String>(
      'plan_day_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dishIdMeta = const VerificationMeta('dishId');
  @override
  late final GeneratedColumn<String> dishId = GeneratedColumn<String>(
      'dish_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sortOrderMeta =
      const VerificationMeta('sortOrder');
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
      'sort_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _autoAssignedMeta =
      const VerificationMeta('autoAssigned');
  @override
  late final GeneratedColumn<bool> autoAssigned = GeneratedColumn<bool>(
      'auto_assigned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_assigned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, planDayId, dishId, householdId, sortOrder, autoAssigned, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_day_dish';
  @override
  VerificationContext validateIntegrity(Insertable<PlanDayDish> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_day_id')) {
      context.handle(
          _planDayIdMeta,
          planDayId.isAcceptableOrUnknown(
              data['plan_day_id']!, _planDayIdMeta));
    } else if (isInserting) {
      context.missing(_planDayIdMeta);
    }
    if (data.containsKey('dish_id')) {
      context.handle(_dishIdMeta,
          dishId.isAcceptableOrUnknown(data['dish_id']!, _dishIdMeta));
    } else if (isInserting) {
      context.missing(_dishIdMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(_sortOrderMeta,
          sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta));
    }
    if (data.containsKey('auto_assigned')) {
      context.handle(
          _autoAssignedMeta,
          autoAssigned.isAcceptableOrUnknown(
              data['auto_assigned']!, _autoAssignedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanDayDish map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanDayDish(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      planDayId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan_day_id'])!,
      dishId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dish_id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      sortOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sort_order'])!,
      autoAssigned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}auto_assigned'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $PlanDayDishesTable createAlias(String alias) {
    return $PlanDayDishesTable(attachedDatabase, alias);
  }
}

class PlanDayDish extends DataClass implements Insertable<PlanDayDish> {
  final String id;
  final String planDayId;
  final String dishId;
  final String householdId;
  final int sortOrder;
  final bool autoAssigned;
  final DateTime createdAt;
  const PlanDayDish(
      {required this.id,
      required this.planDayId,
      required this.dishId,
      required this.householdId,
      required this.sortOrder,
      required this.autoAssigned,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_day_id'] = Variable<String>(planDayId);
    map['dish_id'] = Variable<String>(dishId);
    map['household_id'] = Variable<String>(householdId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['auto_assigned'] = Variable<bool>(autoAssigned);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PlanDayDishesCompanion toCompanion(bool nullToAbsent) {
    return PlanDayDishesCompanion(
      id: Value(id),
      planDayId: Value(planDayId),
      dishId: Value(dishId),
      householdId: Value(householdId),
      sortOrder: Value(sortOrder),
      autoAssigned: Value(autoAssigned),
      createdAt: Value(createdAt),
    );
  }

  factory PlanDayDish.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanDayDish(
      id: serializer.fromJson<String>(json['id']),
      planDayId: serializer.fromJson<String>(json['planDayId']),
      dishId: serializer.fromJson<String>(json['dishId']),
      householdId: serializer.fromJson<String>(json['householdId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      autoAssigned: serializer.fromJson<bool>(json['autoAssigned']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planDayId': serializer.toJson<String>(planDayId),
      'dishId': serializer.toJson<String>(dishId),
      'householdId': serializer.toJson<String>(householdId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'autoAssigned': serializer.toJson<bool>(autoAssigned),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PlanDayDish copyWith(
          {String? id,
          String? planDayId,
          String? dishId,
          String? householdId,
          int? sortOrder,
          bool? autoAssigned,
          DateTime? createdAt}) =>
      PlanDayDish(
        id: id ?? this.id,
        planDayId: planDayId ?? this.planDayId,
        dishId: dishId ?? this.dishId,
        householdId: householdId ?? this.householdId,
        sortOrder: sortOrder ?? this.sortOrder,
        autoAssigned: autoAssigned ?? this.autoAssigned,
        createdAt: createdAt ?? this.createdAt,
      );
  PlanDayDish copyWithCompanion(PlanDayDishesCompanion data) {
    return PlanDayDish(
      id: data.id.present ? data.id.value : this.id,
      planDayId: data.planDayId.present ? data.planDayId.value : this.planDayId,
      dishId: data.dishId.present ? data.dishId.value : this.dishId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      autoAssigned: data.autoAssigned.present
          ? data.autoAssigned.value
          : this.autoAssigned,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanDayDish(')
          ..write('id: $id, ')
          ..write('planDayId: $planDayId, ')
          ..write('dishId: $dishId, ')
          ..write('householdId: $householdId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('autoAssigned: $autoAssigned, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, planDayId, dishId, householdId, sortOrder, autoAssigned, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanDayDish &&
          other.id == this.id &&
          other.planDayId == this.planDayId &&
          other.dishId == this.dishId &&
          other.householdId == this.householdId &&
          other.sortOrder == this.sortOrder &&
          other.autoAssigned == this.autoAssigned &&
          other.createdAt == this.createdAt);
}

class PlanDayDishesCompanion extends UpdateCompanion<PlanDayDish> {
  final Value<String> id;
  final Value<String> planDayId;
  final Value<String> dishId;
  final Value<String> householdId;
  final Value<int> sortOrder;
  final Value<bool> autoAssigned;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PlanDayDishesCompanion({
    this.id = const Value.absent(),
    this.planDayId = const Value.absent(),
    this.dishId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.autoAssigned = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanDayDishesCompanion.insert({
    required String id,
    required String planDayId,
    required String dishId,
    required String householdId,
    this.sortOrder = const Value.absent(),
    this.autoAssigned = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        planDayId = Value(planDayId),
        dishId = Value(dishId),
        householdId = Value(householdId),
        createdAt = Value(createdAt);
  static Insertable<PlanDayDish> custom({
    Expression<String>? id,
    Expression<String>? planDayId,
    Expression<String>? dishId,
    Expression<String>? householdId,
    Expression<int>? sortOrder,
    Expression<bool>? autoAssigned,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planDayId != null) 'plan_day_id': planDayId,
      if (dishId != null) 'dish_id': dishId,
      if (householdId != null) 'household_id': householdId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (autoAssigned != null) 'auto_assigned': autoAssigned,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanDayDishesCompanion copyWith(
      {Value<String>? id,
      Value<String>? planDayId,
      Value<String>? dishId,
      Value<String>? householdId,
      Value<int>? sortOrder,
      Value<bool>? autoAssigned,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return PlanDayDishesCompanion(
      id: id ?? this.id,
      planDayId: planDayId ?? this.planDayId,
      dishId: dishId ?? this.dishId,
      householdId: householdId ?? this.householdId,
      sortOrder: sortOrder ?? this.sortOrder,
      autoAssigned: autoAssigned ?? this.autoAssigned,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planDayId.present) {
      map['plan_day_id'] = Variable<String>(planDayId.value);
    }
    if (dishId.present) {
      map['dish_id'] = Variable<String>(dishId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (autoAssigned.present) {
      map['auto_assigned'] = Variable<bool>(autoAssigned.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanDayDishesCompanion(')
          ..write('id: $id, ')
          ..write('planDayId: $planDayId, ')
          ..write('dishId: $dishId, ')
          ..write('householdId: $householdId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('autoAssigned: $autoAssigned, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShoppingListsTable extends ShoppingLists
    with TableInfo<$ShoppingListsTable, ShoppingList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShoppingListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _weekPlanIdMeta =
      const VerificationMeta('weekPlanId');
  @override
  late final GeneratedColumn<String> weekPlanId = GeneratedColumn<String>(
      'week_plan_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _generatedAtMeta =
      const VerificationMeta('generatedAt');
  @override
  late final GeneratedColumn<DateTime> generatedAt = GeneratedColumn<DateTime>(
      'generated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _planHashMeta =
      const VerificationMeta('planHash');
  @override
  late final GeneratedColumn<String> planHash = GeneratedColumn<String>(
      'plan_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        householdId,
        weekPlanId,
        generatedAt,
        planHash,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shopping_list';
  @override
  VerificationContext validateIntegrity(Insertable<ShoppingList> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('week_plan_id')) {
      context.handle(
          _weekPlanIdMeta,
          weekPlanId.isAcceptableOrUnknown(
              data['week_plan_id']!, _weekPlanIdMeta));
    } else if (isInserting) {
      context.missing(_weekPlanIdMeta);
    }
    if (data.containsKey('generated_at')) {
      context.handle(
          _generatedAtMeta,
          generatedAt.isAcceptableOrUnknown(
              data['generated_at']!, _generatedAtMeta));
    } else if (isInserting) {
      context.missing(_generatedAtMeta);
    }
    if (data.containsKey('plan_hash')) {
      context.handle(_planHashMeta,
          planHash.isAcceptableOrUnknown(data['plan_hash']!, _planHashMeta));
    } else if (isInserting) {
      context.missing(_planHashMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShoppingList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShoppingList(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      weekPlanId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}week_plan_id'])!,
      generatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}generated_at'])!,
      planHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan_hash'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ShoppingListsTable createAlias(String alias) {
    return $ShoppingListsTable(attachedDatabase, alias);
  }
}

class ShoppingList extends DataClass implements Insertable<ShoppingList> {
  final String id;
  final String householdId;
  final String weekPlanId;
  final DateTime generatedAt;
  final String planHash;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ShoppingList(
      {required this.id,
      required this.householdId,
      required this.weekPlanId,
      required this.generatedAt,
      required this.planHash,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['household_id'] = Variable<String>(householdId);
    map['week_plan_id'] = Variable<String>(weekPlanId);
    map['generated_at'] = Variable<DateTime>(generatedAt);
    map['plan_hash'] = Variable<String>(planHash);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ShoppingListsCompanion toCompanion(bool nullToAbsent) {
    return ShoppingListsCompanion(
      id: Value(id),
      householdId: Value(householdId),
      weekPlanId: Value(weekPlanId),
      generatedAt: Value(generatedAt),
      planHash: Value(planHash),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ShoppingList.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShoppingList(
      id: serializer.fromJson<String>(json['id']),
      householdId: serializer.fromJson<String>(json['householdId']),
      weekPlanId: serializer.fromJson<String>(json['weekPlanId']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
      planHash: serializer.fromJson<String>(json['planHash']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'householdId': serializer.toJson<String>(householdId),
      'weekPlanId': serializer.toJson<String>(weekPlanId),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
      'planHash': serializer.toJson<String>(planHash),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ShoppingList copyWith(
          {String? id,
          String? householdId,
          String? weekPlanId,
          DateTime? generatedAt,
          String? planHash,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ShoppingList(
        id: id ?? this.id,
        householdId: householdId ?? this.householdId,
        weekPlanId: weekPlanId ?? this.weekPlanId,
        generatedAt: generatedAt ?? this.generatedAt,
        planHash: planHash ?? this.planHash,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ShoppingList copyWithCompanion(ShoppingListsCompanion data) {
    return ShoppingList(
      id: data.id.present ? data.id.value : this.id,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      weekPlanId:
          data.weekPlanId.present ? data.weekPlanId.value : this.weekPlanId,
      generatedAt:
          data.generatedAt.present ? data.generatedAt.value : this.generatedAt,
      planHash: data.planHash.present ? data.planHash.value : this.planHash,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingList(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('weekPlanId: $weekPlanId, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('planHash: $planHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, householdId, weekPlanId, generatedAt, planHash, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShoppingList &&
          other.id == this.id &&
          other.householdId == this.householdId &&
          other.weekPlanId == this.weekPlanId &&
          other.generatedAt == this.generatedAt &&
          other.planHash == this.planHash &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ShoppingListsCompanion extends UpdateCompanion<ShoppingList> {
  final Value<String> id;
  final Value<String> householdId;
  final Value<String> weekPlanId;
  final Value<DateTime> generatedAt;
  final Value<String> planHash;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ShoppingListsCompanion({
    this.id = const Value.absent(),
    this.householdId = const Value.absent(),
    this.weekPlanId = const Value.absent(),
    this.generatedAt = const Value.absent(),
    this.planHash = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShoppingListsCompanion.insert({
    required String id,
    required String householdId,
    required String weekPlanId,
    required DateTime generatedAt,
    required String planHash,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        householdId = Value(householdId),
        weekPlanId = Value(weekPlanId),
        generatedAt = Value(generatedAt),
        planHash = Value(planHash),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ShoppingList> custom({
    Expression<String>? id,
    Expression<String>? householdId,
    Expression<String>? weekPlanId,
    Expression<DateTime>? generatedAt,
    Expression<String>? planHash,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (householdId != null) 'household_id': householdId,
      if (weekPlanId != null) 'week_plan_id': weekPlanId,
      if (generatedAt != null) 'generated_at': generatedAt,
      if (planHash != null) 'plan_hash': planHash,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShoppingListsCompanion copyWith(
      {Value<String>? id,
      Value<String>? householdId,
      Value<String>? weekPlanId,
      Value<DateTime>? generatedAt,
      Value<String>? planHash,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ShoppingListsCompanion(
      id: id ?? this.id,
      householdId: householdId ?? this.householdId,
      weekPlanId: weekPlanId ?? this.weekPlanId,
      generatedAt: generatedAt ?? this.generatedAt,
      planHash: planHash ?? this.planHash,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (weekPlanId.present) {
      map['week_plan_id'] = Variable<String>(weekPlanId.value);
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<DateTime>(generatedAt.value);
    }
    if (planHash.present) {
      map['plan_hash'] = Variable<String>(planHash.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShoppingListsCompanion(')
          ..write('id: $id, ')
          ..write('householdId: $householdId, ')
          ..write('weekPlanId: $weekPlanId, ')
          ..write('generatedAt: $generatedAt, ')
          ..write('planHash: $planHash, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListGeneratedRowsTable extends ListGeneratedRows
    with TableInfo<$ListGeneratedRowsTable, ListGeneratedRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListGeneratedRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shoppingListIdMeta =
      const VerificationMeta('shoppingListId');
  @override
  late final GeneratedColumn<String> shoppingListId = GeneratedColumn<String>(
      'shopping_list_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ingredientIdMeta =
      const VerificationMeta('ingredientId');
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
      'ingredient_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<double> qty = GeneratedColumn<double>(
      'qty', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isQbMeta = const VerificationMeta('isQb');
  @override
  late final GeneratedColumn<bool> isQb = GeneratedColumn<bool>(
      'is_qb', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_qb" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        shoppingListId,
        ingredientId,
        householdId,
        qty,
        unit,
        isQb,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'list_generated_row';
  @override
  VerificationContext validateIntegrity(Insertable<ListGeneratedRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shopping_list_id')) {
      context.handle(
          _shoppingListIdMeta,
          shoppingListId.isAcceptableOrUnknown(
              data['shopping_list_id']!, _shoppingListIdMeta));
    } else if (isInserting) {
      context.missing(_shoppingListIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
          _ingredientIdMeta,
          ingredientId.isAcceptableOrUnknown(
              data['ingredient_id']!, _ingredientIdMeta));
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
          _qtyMeta, qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('is_qb')) {
      context.handle(
          _isQbMeta, isQb.isAcceptableOrUnknown(data['is_qb']!, _isQbMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListGeneratedRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListGeneratedRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      shoppingListId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}shopping_list_id'])!,
      ingredientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ingredient_id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      qty: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}qty']),
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      isQb: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_qb'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ListGeneratedRowsTable createAlias(String alias) {
    return $ListGeneratedRowsTable(attachedDatabase, alias);
  }
}

class ListGeneratedRow extends DataClass
    implements Insertable<ListGeneratedRow> {
  final String id;
  final String shoppingListId;
  final String ingredientId;
  final String householdId;
  final double? qty;
  final String unit;
  final bool isQb;
  final DateTime createdAt;
  const ListGeneratedRow(
      {required this.id,
      required this.shoppingListId,
      required this.ingredientId,
      required this.householdId,
      this.qty,
      required this.unit,
      required this.isQb,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shopping_list_id'] = Variable<String>(shoppingListId);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['household_id'] = Variable<String>(householdId);
    if (!nullToAbsent || qty != null) {
      map['qty'] = Variable<double>(qty);
    }
    map['unit'] = Variable<String>(unit);
    map['is_qb'] = Variable<bool>(isQb);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ListGeneratedRowsCompanion toCompanion(bool nullToAbsent) {
    return ListGeneratedRowsCompanion(
      id: Value(id),
      shoppingListId: Value(shoppingListId),
      ingredientId: Value(ingredientId),
      householdId: Value(householdId),
      qty: qty == null && nullToAbsent ? const Value.absent() : Value(qty),
      unit: Value(unit),
      isQb: Value(isQb),
      createdAt: Value(createdAt),
    );
  }

  factory ListGeneratedRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListGeneratedRow(
      id: serializer.fromJson<String>(json['id']),
      shoppingListId: serializer.fromJson<String>(json['shoppingListId']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      householdId: serializer.fromJson<String>(json['householdId']),
      qty: serializer.fromJson<double?>(json['qty']),
      unit: serializer.fromJson<String>(json['unit']),
      isQb: serializer.fromJson<bool>(json['isQb']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shoppingListId': serializer.toJson<String>(shoppingListId),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'householdId': serializer.toJson<String>(householdId),
      'qty': serializer.toJson<double?>(qty),
      'unit': serializer.toJson<String>(unit),
      'isQb': serializer.toJson<bool>(isQb),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ListGeneratedRow copyWith(
          {String? id,
          String? shoppingListId,
          String? ingredientId,
          String? householdId,
          Value<double?> qty = const Value.absent(),
          String? unit,
          bool? isQb,
          DateTime? createdAt}) =>
      ListGeneratedRow(
        id: id ?? this.id,
        shoppingListId: shoppingListId ?? this.shoppingListId,
        ingredientId: ingredientId ?? this.ingredientId,
        householdId: householdId ?? this.householdId,
        qty: qty.present ? qty.value : this.qty,
        unit: unit ?? this.unit,
        isQb: isQb ?? this.isQb,
        createdAt: createdAt ?? this.createdAt,
      );
  ListGeneratedRow copyWithCompanion(ListGeneratedRowsCompanion data) {
    return ListGeneratedRow(
      id: data.id.present ? data.id.value : this.id,
      shoppingListId: data.shoppingListId.present
          ? data.shoppingListId.value
          : this.shoppingListId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      qty: data.qty.present ? data.qty.value : this.qty,
      unit: data.unit.present ? data.unit.value : this.unit,
      isQb: data.isQb.present ? data.isQb.value : this.isQb,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListGeneratedRow(')
          ..write('id: $id, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('householdId: $householdId, ')
          ..write('qty: $qty, ')
          ..write('unit: $unit, ')
          ..write('isQb: $isQb, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shoppingListId, ingredientId, householdId,
      qty, unit, isQb, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListGeneratedRow &&
          other.id == this.id &&
          other.shoppingListId == this.shoppingListId &&
          other.ingredientId == this.ingredientId &&
          other.householdId == this.householdId &&
          other.qty == this.qty &&
          other.unit == this.unit &&
          other.isQb == this.isQb &&
          other.createdAt == this.createdAt);
}

class ListGeneratedRowsCompanion extends UpdateCompanion<ListGeneratedRow> {
  final Value<String> id;
  final Value<String> shoppingListId;
  final Value<String> ingredientId;
  final Value<String> householdId;
  final Value<double?> qty;
  final Value<String> unit;
  final Value<bool> isQb;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ListGeneratedRowsCompanion({
    this.id = const Value.absent(),
    this.shoppingListId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.qty = const Value.absent(),
    this.unit = const Value.absent(),
    this.isQb = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListGeneratedRowsCompanion.insert({
    required String id,
    required String shoppingListId,
    required String ingredientId,
    required String householdId,
    this.qty = const Value.absent(),
    required String unit,
    this.isQb = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        shoppingListId = Value(shoppingListId),
        ingredientId = Value(ingredientId),
        householdId = Value(householdId),
        unit = Value(unit),
        createdAt = Value(createdAt);
  static Insertable<ListGeneratedRow> custom({
    Expression<String>? id,
    Expression<String>? shoppingListId,
    Expression<String>? ingredientId,
    Expression<String>? householdId,
    Expression<double>? qty,
    Expression<String>? unit,
    Expression<bool>? isQb,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shoppingListId != null) 'shopping_list_id': shoppingListId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (householdId != null) 'household_id': householdId,
      if (qty != null) 'qty': qty,
      if (unit != null) 'unit': unit,
      if (isQb != null) 'is_qb': isQb,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListGeneratedRowsCompanion copyWith(
      {Value<String>? id,
      Value<String>? shoppingListId,
      Value<String>? ingredientId,
      Value<String>? householdId,
      Value<double?>? qty,
      Value<String>? unit,
      Value<bool>? isQb,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ListGeneratedRowsCompanion(
      id: id ?? this.id,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      ingredientId: ingredientId ?? this.ingredientId,
      householdId: householdId ?? this.householdId,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      isQb: isQb ?? this.isQb,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shoppingListId.present) {
      map['shopping_list_id'] = Variable<String>(shoppingListId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (qty.present) {
      map['qty'] = Variable<double>(qty.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (isQb.present) {
      map['is_qb'] = Variable<bool>(isQb.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListGeneratedRowsCompanion(')
          ..write('id: $id, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('householdId: $householdId, ')
          ..write('qty: $qty, ')
          ..write('unit: $unit, ')
          ..write('isQb: $isQb, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListOverridesTable extends ListOverrides
    with TableInfo<$ListOverridesTable, ListOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shoppingListIdMeta =
      const VerificationMeta('shoppingListId');
  @override
  late final GeneratedColumn<String> shoppingListId = GeneratedColumn<String>(
      'shopping_list_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ingredientIdMeta =
      const VerificationMeta('ingredientId');
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
      'ingredient_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _qtyOverrideMeta =
      const VerificationMeta('qtyOverride');
  @override
  late final GeneratedColumn<double> qtyOverride = GeneratedColumn<double>(
      'qty_override', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _removedMeta =
      const VerificationMeta('removed');
  @override
  late final GeneratedColumn<bool> removed = GeneratedColumn<bool>(
      'removed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("removed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        shoppingListId,
        ingredientId,
        householdId,
        qtyOverride,
        removed,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'list_override';
  @override
  VerificationContext validateIntegrity(Insertable<ListOverride> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shopping_list_id')) {
      context.handle(
          _shoppingListIdMeta,
          shoppingListId.isAcceptableOrUnknown(
              data['shopping_list_id']!, _shoppingListIdMeta));
    } else if (isInserting) {
      context.missing(_shoppingListIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
          _ingredientIdMeta,
          ingredientId.isAcceptableOrUnknown(
              data['ingredient_id']!, _ingredientIdMeta));
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('qty_override')) {
      context.handle(
          _qtyOverrideMeta,
          qtyOverride.isAcceptableOrUnknown(
              data['qty_override']!, _qtyOverrideMeta));
    }
    if (data.containsKey('removed')) {
      context.handle(_removedMeta,
          removed.isAcceptableOrUnknown(data['removed']!, _removedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {shoppingListId, ingredientId},
      ];
  @override
  ListOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListOverride(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      shoppingListId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}shopping_list_id'])!,
      ingredientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ingredient_id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      qtyOverride: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}qty_override']),
      removed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}removed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ListOverridesTable createAlias(String alias) {
    return $ListOverridesTable(attachedDatabase, alias);
  }
}

class ListOverride extends DataClass implements Insertable<ListOverride> {
  final String id;
  final String shoppingListId;
  final String ingredientId;
  final String householdId;
  final double? qtyOverride;
  final bool removed;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ListOverride(
      {required this.id,
      required this.shoppingListId,
      required this.ingredientId,
      required this.householdId,
      this.qtyOverride,
      required this.removed,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shopping_list_id'] = Variable<String>(shoppingListId);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['household_id'] = Variable<String>(householdId);
    if (!nullToAbsent || qtyOverride != null) {
      map['qty_override'] = Variable<double>(qtyOverride);
    }
    map['removed'] = Variable<bool>(removed);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ListOverridesCompanion toCompanion(bool nullToAbsent) {
    return ListOverridesCompanion(
      id: Value(id),
      shoppingListId: Value(shoppingListId),
      ingredientId: Value(ingredientId),
      householdId: Value(householdId),
      qtyOverride: qtyOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(qtyOverride),
      removed: Value(removed),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ListOverride.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListOverride(
      id: serializer.fromJson<String>(json['id']),
      shoppingListId: serializer.fromJson<String>(json['shoppingListId']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      householdId: serializer.fromJson<String>(json['householdId']),
      qtyOverride: serializer.fromJson<double?>(json['qtyOverride']),
      removed: serializer.fromJson<bool>(json['removed']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shoppingListId': serializer.toJson<String>(shoppingListId),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'householdId': serializer.toJson<String>(householdId),
      'qtyOverride': serializer.toJson<double?>(qtyOverride),
      'removed': serializer.toJson<bool>(removed),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ListOverride copyWith(
          {String? id,
          String? shoppingListId,
          String? ingredientId,
          String? householdId,
          Value<double?> qtyOverride = const Value.absent(),
          bool? removed,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ListOverride(
        id: id ?? this.id,
        shoppingListId: shoppingListId ?? this.shoppingListId,
        ingredientId: ingredientId ?? this.ingredientId,
        householdId: householdId ?? this.householdId,
        qtyOverride: qtyOverride.present ? qtyOverride.value : this.qtyOverride,
        removed: removed ?? this.removed,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ListOverride copyWithCompanion(ListOverridesCompanion data) {
    return ListOverride(
      id: data.id.present ? data.id.value : this.id,
      shoppingListId: data.shoppingListId.present
          ? data.shoppingListId.value
          : this.shoppingListId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      qtyOverride:
          data.qtyOverride.present ? data.qtyOverride.value : this.qtyOverride,
      removed: data.removed.present ? data.removed.value : this.removed,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListOverride(')
          ..write('id: $id, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('householdId: $householdId, ')
          ..write('qtyOverride: $qtyOverride, ')
          ..write('removed: $removed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shoppingListId, ingredientId, householdId,
      qtyOverride, removed, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListOverride &&
          other.id == this.id &&
          other.shoppingListId == this.shoppingListId &&
          other.ingredientId == this.ingredientId &&
          other.householdId == this.householdId &&
          other.qtyOverride == this.qtyOverride &&
          other.removed == this.removed &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ListOverridesCompanion extends UpdateCompanion<ListOverride> {
  final Value<String> id;
  final Value<String> shoppingListId;
  final Value<String> ingredientId;
  final Value<String> householdId;
  final Value<double?> qtyOverride;
  final Value<bool> removed;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ListOverridesCompanion({
    this.id = const Value.absent(),
    this.shoppingListId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.qtyOverride = const Value.absent(),
    this.removed = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListOverridesCompanion.insert({
    required String id,
    required String shoppingListId,
    required String ingredientId,
    required String householdId,
    this.qtyOverride = const Value.absent(),
    this.removed = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        shoppingListId = Value(shoppingListId),
        ingredientId = Value(ingredientId),
        householdId = Value(householdId),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ListOverride> custom({
    Expression<String>? id,
    Expression<String>? shoppingListId,
    Expression<String>? ingredientId,
    Expression<String>? householdId,
    Expression<double>? qtyOverride,
    Expression<bool>? removed,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shoppingListId != null) 'shopping_list_id': shoppingListId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (householdId != null) 'household_id': householdId,
      if (qtyOverride != null) 'qty_override': qtyOverride,
      if (removed != null) 'removed': removed,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListOverridesCompanion copyWith(
      {Value<String>? id,
      Value<String>? shoppingListId,
      Value<String>? ingredientId,
      Value<String>? householdId,
      Value<double?>? qtyOverride,
      Value<bool>? removed,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ListOverridesCompanion(
      id: id ?? this.id,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      ingredientId: ingredientId ?? this.ingredientId,
      householdId: householdId ?? this.householdId,
      qtyOverride: qtyOverride ?? this.qtyOverride,
      removed: removed ?? this.removed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shoppingListId.present) {
      map['shopping_list_id'] = Variable<String>(shoppingListId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (qtyOverride.present) {
      map['qty_override'] = Variable<double>(qtyOverride.value);
    }
    if (removed.present) {
      map['removed'] = Variable<bool>(removed.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListOverridesCompanion(')
          ..write('id: $id, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('householdId: $householdId, ')
          ..write('qtyOverride: $qtyOverride, ')
          ..write('removed: $removed, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListManualItemsTable extends ListManualItems
    with TableInfo<$ListManualItemsTable, ListManualItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListManualItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shoppingListIdMeta =
      const VerificationMeta('shoppingListId');
  @override
  late final GeneratedColumn<String> shoppingListId = GeneratedColumn<String>(
      'shopping_list_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _qtyMeta = const VerificationMeta('qty');
  @override
  late final GeneratedColumn<double> qty = GeneratedColumn<double>(
      'qty', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, shoppingListId, householdId, name, qty, unit, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'list_manual_item';
  @override
  VerificationContext validateIntegrity(Insertable<ListManualItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shopping_list_id')) {
      context.handle(
          _shoppingListIdMeta,
          shoppingListId.isAcceptableOrUnknown(
              data['shopping_list_id']!, _shoppingListIdMeta));
    } else if (isInserting) {
      context.missing(_shoppingListIdMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('qty')) {
      context.handle(
          _qtyMeta, qty.isAcceptableOrUnknown(data['qty']!, _qtyMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListManualItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListManualItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      shoppingListId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}shopping_list_id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      qty: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}qty']),
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ListManualItemsTable createAlias(String alias) {
    return $ListManualItemsTable(attachedDatabase, alias);
  }
}

class ListManualItem extends DataClass implements Insertable<ListManualItem> {
  final String id;
  final String shoppingListId;
  final String householdId;
  final String name;
  final double? qty;
  final String? unit;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ListManualItem(
      {required this.id,
      required this.shoppingListId,
      required this.householdId,
      required this.name,
      this.qty,
      this.unit,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shopping_list_id'] = Variable<String>(shoppingListId);
    map['household_id'] = Variable<String>(householdId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || qty != null) {
      map['qty'] = Variable<double>(qty);
    }
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ListManualItemsCompanion toCompanion(bool nullToAbsent) {
    return ListManualItemsCompanion(
      id: Value(id),
      shoppingListId: Value(shoppingListId),
      householdId: Value(householdId),
      name: Value(name),
      qty: qty == null && nullToAbsent ? const Value.absent() : Value(qty),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ListManualItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListManualItem(
      id: serializer.fromJson<String>(json['id']),
      shoppingListId: serializer.fromJson<String>(json['shoppingListId']),
      householdId: serializer.fromJson<String>(json['householdId']),
      name: serializer.fromJson<String>(json['name']),
      qty: serializer.fromJson<double?>(json['qty']),
      unit: serializer.fromJson<String?>(json['unit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shoppingListId': serializer.toJson<String>(shoppingListId),
      'householdId': serializer.toJson<String>(householdId),
      'name': serializer.toJson<String>(name),
      'qty': serializer.toJson<double?>(qty),
      'unit': serializer.toJson<String?>(unit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ListManualItem copyWith(
          {String? id,
          String? shoppingListId,
          String? householdId,
          String? name,
          Value<double?> qty = const Value.absent(),
          Value<String?> unit = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ListManualItem(
        id: id ?? this.id,
        shoppingListId: shoppingListId ?? this.shoppingListId,
        householdId: householdId ?? this.householdId,
        name: name ?? this.name,
        qty: qty.present ? qty.value : this.qty,
        unit: unit.present ? unit.value : this.unit,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ListManualItem copyWithCompanion(ListManualItemsCompanion data) {
    return ListManualItem(
      id: data.id.present ? data.id.value : this.id,
      shoppingListId: data.shoppingListId.present
          ? data.shoppingListId.value
          : this.shoppingListId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      name: data.name.present ? data.name.value : this.name,
      qty: data.qty.present ? data.qty.value : this.qty,
      unit: data.unit.present ? data.unit.value : this.unit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListManualItem(')
          ..write('id: $id, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('householdId: $householdId, ')
          ..write('name: $name, ')
          ..write('qty: $qty, ')
          ..write('unit: $unit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, shoppingListId, householdId, name, qty, unit, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListManualItem &&
          other.id == this.id &&
          other.shoppingListId == this.shoppingListId &&
          other.householdId == this.householdId &&
          other.name == this.name &&
          other.qty == this.qty &&
          other.unit == this.unit &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ListManualItemsCompanion extends UpdateCompanion<ListManualItem> {
  final Value<String> id;
  final Value<String> shoppingListId;
  final Value<String> householdId;
  final Value<String> name;
  final Value<double?> qty;
  final Value<String?> unit;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ListManualItemsCompanion({
    this.id = const Value.absent(),
    this.shoppingListId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.name = const Value.absent(),
    this.qty = const Value.absent(),
    this.unit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListManualItemsCompanion.insert({
    required String id,
    required String shoppingListId,
    required String householdId,
    required String name,
    this.qty = const Value.absent(),
    this.unit = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        shoppingListId = Value(shoppingListId),
        householdId = Value(householdId),
        name = Value(name),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ListManualItem> custom({
    Expression<String>? id,
    Expression<String>? shoppingListId,
    Expression<String>? householdId,
    Expression<String>? name,
    Expression<double>? qty,
    Expression<String>? unit,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shoppingListId != null) 'shopping_list_id': shoppingListId,
      if (householdId != null) 'household_id': householdId,
      if (name != null) 'name': name,
      if (qty != null) 'qty': qty,
      if (unit != null) 'unit': unit,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListManualItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? shoppingListId,
      Value<String>? householdId,
      Value<String>? name,
      Value<double?>? qty,
      Value<String?>? unit,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ListManualItemsCompanion(
      id: id ?? this.id,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      householdId: householdId ?? this.householdId,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shoppingListId.present) {
      map['shopping_list_id'] = Variable<String>(shoppingListId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (qty.present) {
      map['qty'] = Variable<double>(qty.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListManualItemsCompanion(')
          ..write('id: $id, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('householdId: $householdId, ')
          ..write('name: $name, ')
          ..write('qty: $qty, ')
          ..write('unit: $unit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListChecksTable extends ListChecks
    with TableInfo<$ListChecksTable, ListCheck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListChecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shoppingListIdMeta =
      const VerificationMeta('shoppingListId');
  @override
  late final GeneratedColumn<String> shoppingListId = GeneratedColumn<String>(
      'shopping_list_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ingredientIdMeta =
      const VerificationMeta('ingredientId');
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
      'ingredient_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _manualItemIdMeta =
      const VerificationMeta('manualItemId');
  @override
  late final GeneratedColumn<String> manualItemId = GeneratedColumn<String>(
      'manual_item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _checkedMeta =
      const VerificationMeta('checked');
  @override
  late final GeneratedColumn<bool> checked = GeneratedColumn<bool>(
      'checked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("checked" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        shoppingListId,
        ingredientId,
        manualItemId,
        householdId,
        checked,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'list_check';
  @override
  VerificationContext validateIntegrity(Insertable<ListCheck> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shopping_list_id')) {
      context.handle(
          _shoppingListIdMeta,
          shoppingListId.isAcceptableOrUnknown(
              data['shopping_list_id']!, _shoppingListIdMeta));
    } else if (isInserting) {
      context.missing(_shoppingListIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
          _ingredientIdMeta,
          ingredientId.isAcceptableOrUnknown(
              data['ingredient_id']!, _ingredientIdMeta));
    }
    if (data.containsKey('manual_item_id')) {
      context.handle(
          _manualItemIdMeta,
          manualItemId.isAcceptableOrUnknown(
              data['manual_item_id']!, _manualItemIdMeta));
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('checked')) {
      context.handle(_checkedMeta,
          checked.isAcceptableOrUnknown(data['checked']!, _checkedMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ListCheck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListCheck(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      shoppingListId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}shopping_list_id'])!,
      ingredientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ingredient_id']),
      manualItemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manual_item_id']),
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      checked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}checked'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ListChecksTable createAlias(String alias) {
    return $ListChecksTable(attachedDatabase, alias);
  }
}

class ListCheck extends DataClass implements Insertable<ListCheck> {
  final String id;
  final String shoppingListId;
  final String? ingredientId;
  final String? manualItemId;
  final String householdId;
  final bool checked;
  final DateTime updatedAt;
  const ListCheck(
      {required this.id,
      required this.shoppingListId,
      this.ingredientId,
      this.manualItemId,
      required this.householdId,
      required this.checked,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shopping_list_id'] = Variable<String>(shoppingListId);
    if (!nullToAbsent || ingredientId != null) {
      map['ingredient_id'] = Variable<String>(ingredientId);
    }
    if (!nullToAbsent || manualItemId != null) {
      map['manual_item_id'] = Variable<String>(manualItemId);
    }
    map['household_id'] = Variable<String>(householdId);
    map['checked'] = Variable<bool>(checked);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ListChecksCompanion toCompanion(bool nullToAbsent) {
    return ListChecksCompanion(
      id: Value(id),
      shoppingListId: Value(shoppingListId),
      ingredientId: ingredientId == null && nullToAbsent
          ? const Value.absent()
          : Value(ingredientId),
      manualItemId: manualItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(manualItemId),
      householdId: Value(householdId),
      checked: Value(checked),
      updatedAt: Value(updatedAt),
    );
  }

  factory ListCheck.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListCheck(
      id: serializer.fromJson<String>(json['id']),
      shoppingListId: serializer.fromJson<String>(json['shoppingListId']),
      ingredientId: serializer.fromJson<String?>(json['ingredientId']),
      manualItemId: serializer.fromJson<String?>(json['manualItemId']),
      householdId: serializer.fromJson<String>(json['householdId']),
      checked: serializer.fromJson<bool>(json['checked']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shoppingListId': serializer.toJson<String>(shoppingListId),
      'ingredientId': serializer.toJson<String?>(ingredientId),
      'manualItemId': serializer.toJson<String?>(manualItemId),
      'householdId': serializer.toJson<String>(householdId),
      'checked': serializer.toJson<bool>(checked),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ListCheck copyWith(
          {String? id,
          String? shoppingListId,
          Value<String?> ingredientId = const Value.absent(),
          Value<String?> manualItemId = const Value.absent(),
          String? householdId,
          bool? checked,
          DateTime? updatedAt}) =>
      ListCheck(
        id: id ?? this.id,
        shoppingListId: shoppingListId ?? this.shoppingListId,
        ingredientId:
            ingredientId.present ? ingredientId.value : this.ingredientId,
        manualItemId:
            manualItemId.present ? manualItemId.value : this.manualItemId,
        householdId: householdId ?? this.householdId,
        checked: checked ?? this.checked,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ListCheck copyWithCompanion(ListChecksCompanion data) {
    return ListCheck(
      id: data.id.present ? data.id.value : this.id,
      shoppingListId: data.shoppingListId.present
          ? data.shoppingListId.value
          : this.shoppingListId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      manualItemId: data.manualItemId.present
          ? data.manualItemId.value
          : this.manualItemId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      checked: data.checked.present ? data.checked.value : this.checked,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListCheck(')
          ..write('id: $id, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('manualItemId: $manualItemId, ')
          ..write('householdId: $householdId, ')
          ..write('checked: $checked, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, shoppingListId, ingredientId,
      manualItemId, householdId, checked, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListCheck &&
          other.id == this.id &&
          other.shoppingListId == this.shoppingListId &&
          other.ingredientId == this.ingredientId &&
          other.manualItemId == this.manualItemId &&
          other.householdId == this.householdId &&
          other.checked == this.checked &&
          other.updatedAt == this.updatedAt);
}

class ListChecksCompanion extends UpdateCompanion<ListCheck> {
  final Value<String> id;
  final Value<String> shoppingListId;
  final Value<String?> ingredientId;
  final Value<String?> manualItemId;
  final Value<String> householdId;
  final Value<bool> checked;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ListChecksCompanion({
    this.id = const Value.absent(),
    this.shoppingListId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.manualItemId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.checked = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListChecksCompanion.insert({
    required String id,
    required String shoppingListId,
    this.ingredientId = const Value.absent(),
    this.manualItemId = const Value.absent(),
    required String householdId,
    this.checked = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        shoppingListId = Value(shoppingListId),
        householdId = Value(householdId),
        updatedAt = Value(updatedAt);
  static Insertable<ListCheck> custom({
    Expression<String>? id,
    Expression<String>? shoppingListId,
    Expression<String>? ingredientId,
    Expression<String>? manualItemId,
    Expression<String>? householdId,
    Expression<bool>? checked,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shoppingListId != null) 'shopping_list_id': shoppingListId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (manualItemId != null) 'manual_item_id': manualItemId,
      if (householdId != null) 'household_id': householdId,
      if (checked != null) 'checked': checked,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListChecksCompanion copyWith(
      {Value<String>? id,
      Value<String>? shoppingListId,
      Value<String?>? ingredientId,
      Value<String?>? manualItemId,
      Value<String>? householdId,
      Value<bool>? checked,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ListChecksCompanion(
      id: id ?? this.id,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      ingredientId: ingredientId ?? this.ingredientId,
      manualItemId: manualItemId ?? this.manualItemId,
      householdId: householdId ?? this.householdId,
      checked: checked ?? this.checked,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shoppingListId.present) {
      map['shopping_list_id'] = Variable<String>(shoppingListId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (manualItemId.present) {
      map['manual_item_id'] = Variable<String>(manualItemId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (checked.present) {
      map['checked'] = Variable<bool>(checked.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListChecksCompanion(')
          ..write('id: $id, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('manualItemId: $manualItemId, ')
          ..write('householdId: $householdId, ')
          ..write('checked: $checked, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ListRecurringExclusionsTable extends ListRecurringExclusions
    with TableInfo<$ListRecurringExclusionsTable, ListRecurringExclusion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListRecurringExclusionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shoppingListIdMeta =
      const VerificationMeta('shoppingListId');
  @override
  late final GeneratedColumn<String> shoppingListId = GeneratedColumn<String>(
      'shopping_list_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ingredientIdMeta =
      const VerificationMeta('ingredientId');
  @override
  late final GeneratedColumn<String> ingredientId = GeneratedColumn<String>(
      'ingredient_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _householdIdMeta =
      const VerificationMeta('householdId');
  @override
  late final GeneratedColumn<String> householdId = GeneratedColumn<String>(
      'household_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, shoppingListId, ingredientId, householdId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'list_recurring_exclusion';
  @override
  VerificationContext validateIntegrity(
      Insertable<ListRecurringExclusion> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('shopping_list_id')) {
      context.handle(
          _shoppingListIdMeta,
          shoppingListId.isAcceptableOrUnknown(
              data['shopping_list_id']!, _shoppingListIdMeta));
    } else if (isInserting) {
      context.missing(_shoppingListIdMeta);
    }
    if (data.containsKey('ingredient_id')) {
      context.handle(
          _ingredientIdMeta,
          ingredientId.isAcceptableOrUnknown(
              data['ingredient_id']!, _ingredientIdMeta));
    } else if (isInserting) {
      context.missing(_ingredientIdMeta);
    }
    if (data.containsKey('household_id')) {
      context.handle(
          _householdIdMeta,
          householdId.isAcceptableOrUnknown(
              data['household_id']!, _householdIdMeta));
    } else if (isInserting) {
      context.missing(_householdIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {shoppingListId, ingredientId},
      ];
  @override
  ListRecurringExclusion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListRecurringExclusion(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      shoppingListId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}shopping_list_id'])!,
      ingredientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ingredient_id'])!,
      householdId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}household_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ListRecurringExclusionsTable createAlias(String alias) {
    return $ListRecurringExclusionsTable(attachedDatabase, alias);
  }
}

class ListRecurringExclusion extends DataClass
    implements Insertable<ListRecurringExclusion> {
  final String id;
  final String shoppingListId;
  final String ingredientId;
  final String householdId;
  final DateTime createdAt;
  const ListRecurringExclusion(
      {required this.id,
      required this.shoppingListId,
      required this.ingredientId,
      required this.householdId,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['shopping_list_id'] = Variable<String>(shoppingListId);
    map['ingredient_id'] = Variable<String>(ingredientId);
    map['household_id'] = Variable<String>(householdId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ListRecurringExclusionsCompanion toCompanion(bool nullToAbsent) {
    return ListRecurringExclusionsCompanion(
      id: Value(id),
      shoppingListId: Value(shoppingListId),
      ingredientId: Value(ingredientId),
      householdId: Value(householdId),
      createdAt: Value(createdAt),
    );
  }

  factory ListRecurringExclusion.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListRecurringExclusion(
      id: serializer.fromJson<String>(json['id']),
      shoppingListId: serializer.fromJson<String>(json['shoppingListId']),
      ingredientId: serializer.fromJson<String>(json['ingredientId']),
      householdId: serializer.fromJson<String>(json['householdId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'shoppingListId': serializer.toJson<String>(shoppingListId),
      'ingredientId': serializer.toJson<String>(ingredientId),
      'householdId': serializer.toJson<String>(householdId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ListRecurringExclusion copyWith(
          {String? id,
          String? shoppingListId,
          String? ingredientId,
          String? householdId,
          DateTime? createdAt}) =>
      ListRecurringExclusion(
        id: id ?? this.id,
        shoppingListId: shoppingListId ?? this.shoppingListId,
        ingredientId: ingredientId ?? this.ingredientId,
        householdId: householdId ?? this.householdId,
        createdAt: createdAt ?? this.createdAt,
      );
  ListRecurringExclusion copyWithCompanion(
      ListRecurringExclusionsCompanion data) {
    return ListRecurringExclusion(
      id: data.id.present ? data.id.value : this.id,
      shoppingListId: data.shoppingListId.present
          ? data.shoppingListId.value
          : this.shoppingListId,
      ingredientId: data.ingredientId.present
          ? data.ingredientId.value
          : this.ingredientId,
      householdId:
          data.householdId.present ? data.householdId.value : this.householdId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListRecurringExclusion(')
          ..write('id: $id, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, shoppingListId, ingredientId, householdId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListRecurringExclusion &&
          other.id == this.id &&
          other.shoppingListId == this.shoppingListId &&
          other.ingredientId == this.ingredientId &&
          other.householdId == this.householdId &&
          other.createdAt == this.createdAt);
}

class ListRecurringExclusionsCompanion
    extends UpdateCompanion<ListRecurringExclusion> {
  final Value<String> id;
  final Value<String> shoppingListId;
  final Value<String> ingredientId;
  final Value<String> householdId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ListRecurringExclusionsCompanion({
    this.id = const Value.absent(),
    this.shoppingListId = const Value.absent(),
    this.ingredientId = const Value.absent(),
    this.householdId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListRecurringExclusionsCompanion.insert({
    required String id,
    required String shoppingListId,
    required String ingredientId,
    required String householdId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        shoppingListId = Value(shoppingListId),
        ingredientId = Value(ingredientId),
        householdId = Value(householdId),
        createdAt = Value(createdAt);
  static Insertable<ListRecurringExclusion> custom({
    Expression<String>? id,
    Expression<String>? shoppingListId,
    Expression<String>? ingredientId,
    Expression<String>? householdId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shoppingListId != null) 'shopping_list_id': shoppingListId,
      if (ingredientId != null) 'ingredient_id': ingredientId,
      if (householdId != null) 'household_id': householdId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListRecurringExclusionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? shoppingListId,
      Value<String>? ingredientId,
      Value<String>? householdId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return ListRecurringExclusionsCompanion(
      id: id ?? this.id,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      ingredientId: ingredientId ?? this.ingredientId,
      householdId: householdId ?? this.householdId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (shoppingListId.present) {
      map['shopping_list_id'] = Variable<String>(shoppingListId.value);
    }
    if (ingredientId.present) {
      map['ingredient_id'] = Variable<String>(ingredientId.value);
    }
    if (householdId.present) {
      map['household_id'] = Variable<String>(householdId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListRecurringExclusionsCompanion(')
          ..write('id: $id, ')
          ..write('shoppingListId: $shoppingListId, ')
          ..write('ingredientId: $ingredientId, ')
          ..write('householdId: $householdId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HouseholdsTable households = $HouseholdsTable(this);
  late final $MembershipsTable memberships = $MembershipsTable(this);
  late final $IngredientsTable ingredients = $IngredientsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $DishesTable dishes = $DishesTable(this);
  late final $DishTagsTable dishTags = $DishTagsTable(this);
  late final $DishIngredientsTable dishIngredients =
      $DishIngredientsTable(this);
  late final $WeekPlansTable weekPlans = $WeekPlansTable(this);
  late final $PlanDaysTable planDays = $PlanDaysTable(this);
  late final $PlanDayDishesTable planDayDishes = $PlanDayDishesTable(this);
  late final $ShoppingListsTable shoppingLists = $ShoppingListsTable(this);
  late final $ListGeneratedRowsTable listGeneratedRows =
      $ListGeneratedRowsTable(this);
  late final $ListOverridesTable listOverrides = $ListOverridesTable(this);
  late final $ListManualItemsTable listManualItems =
      $ListManualItemsTable(this);
  late final $ListChecksTable listChecks = $ListChecksTable(this);
  late final $ListRecurringExclusionsTable listRecurringExclusions =
      $ListRecurringExclusionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        households,
        memberships,
        ingredients,
        tags,
        dishes,
        dishTags,
        dishIngredients,
        weekPlans,
        planDays,
        planDayDishes,
        shoppingLists,
        listGeneratedRows,
        listOverrides,
        listManualItems,
        listChecks,
        listRecurringExclusions
      ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$HouseholdsTableCreateCompanionBuilder = HouseholdsCompanion Function({
  required String id,
  Value<String?> name,
  Value<int> defaultGuests,
  Value<int> weekStartDay,
  Value<DateTime?> seededAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$HouseholdsTableUpdateCompanionBuilder = HouseholdsCompanion Function({
  Value<String> id,
  Value<String?> name,
  Value<int> defaultGuests,
  Value<int> weekStartDay,
  Value<DateTime?> seededAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$HouseholdsTableFilterComposer
    extends Composer<_$AppDatabase, $HouseholdsTable> {
  $$HouseholdsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get defaultGuests => $composableBuilder(
      column: $table.defaultGuests, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weekStartDay => $composableBuilder(
      column: $table.weekStartDay, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get seededAt => $composableBuilder(
      column: $table.seededAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$HouseholdsTableOrderingComposer
    extends Composer<_$AppDatabase, $HouseholdsTable> {
  $$HouseholdsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get defaultGuests => $composableBuilder(
      column: $table.defaultGuests,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weekStartDay => $composableBuilder(
      column: $table.weekStartDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get seededAt => $composableBuilder(
      column: $table.seededAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$HouseholdsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HouseholdsTable> {
  $$HouseholdsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get defaultGuests => $composableBuilder(
      column: $table.defaultGuests, builder: (column) => column);

  GeneratedColumn<int> get weekStartDay => $composableBuilder(
      column: $table.weekStartDay, builder: (column) => column);

  GeneratedColumn<DateTime> get seededAt =>
      $composableBuilder(column: $table.seededAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HouseholdsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HouseholdsTable,
    Household,
    $$HouseholdsTableFilterComposer,
    $$HouseholdsTableOrderingComposer,
    $$HouseholdsTableAnnotationComposer,
    $$HouseholdsTableCreateCompanionBuilder,
    $$HouseholdsTableUpdateCompanionBuilder,
    (Household, BaseReferences<_$AppDatabase, $HouseholdsTable, Household>),
    Household,
    PrefetchHooks Function()> {
  $$HouseholdsTableTableManager(_$AppDatabase db, $HouseholdsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HouseholdsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HouseholdsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HouseholdsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<int> defaultGuests = const Value.absent(),
            Value<int> weekStartDay = const Value.absent(),
            Value<DateTime?> seededAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HouseholdsCompanion(
            id: id,
            name: name,
            defaultGuests: defaultGuests,
            weekStartDay: weekStartDay,
            seededAt: seededAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> name = const Value.absent(),
            Value<int> defaultGuests = const Value.absent(),
            Value<int> weekStartDay = const Value.absent(),
            Value<DateTime?> seededAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              HouseholdsCompanion.insert(
            id: id,
            name: name,
            defaultGuests: defaultGuests,
            weekStartDay: weekStartDay,
            seededAt: seededAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HouseholdsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HouseholdsTable,
    Household,
    $$HouseholdsTableFilterComposer,
    $$HouseholdsTableOrderingComposer,
    $$HouseholdsTableAnnotationComposer,
    $$HouseholdsTableCreateCompanionBuilder,
    $$HouseholdsTableUpdateCompanionBuilder,
    (Household, BaseReferences<_$AppDatabase, $HouseholdsTable, Household>),
    Household,
    PrefetchHooks Function()>;
typedef $$MembershipsTableCreateCompanionBuilder = MembershipsCompanion
    Function({
  required String id,
  required String householdId,
  required String deviceId,
  Value<String> role,
  required DateTime joinedAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$MembershipsTableUpdateCompanionBuilder = MembershipsCompanion
    Function({
  Value<String> id,
  Value<String> householdId,
  Value<String> deviceId,
  Value<String> role,
  Value<DateTime> joinedAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$MembershipsTableFilterComposer
    extends Composer<_$AppDatabase, $MembershipsTable> {
  $$MembershipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MembershipsTableOrderingComposer
    extends Composer<_$AppDatabase, $MembershipsTable> {
  $$MembershipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get deviceId => $composableBuilder(
      column: $table.deviceId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
      column: $table.joinedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MembershipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MembershipsTable> {
  $$MembershipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MembershipsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MembershipsTable,
    Membership,
    $$MembershipsTableFilterComposer,
    $$MembershipsTableOrderingComposer,
    $$MembershipsTableAnnotationComposer,
    $$MembershipsTableCreateCompanionBuilder,
    $$MembershipsTableUpdateCompanionBuilder,
    (Membership, BaseReferences<_$AppDatabase, $MembershipsTable, Membership>),
    Membership,
    PrefetchHooks Function()> {
  $$MembershipsTableTableManager(_$AppDatabase db, $MembershipsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembershipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembershipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembershipsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> deviceId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<DateTime> joinedAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MembershipsCompanion(
            id: id,
            householdId: householdId,
            deviceId: deviceId,
            role: role,
            joinedAt: joinedAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String householdId,
            required String deviceId,
            Value<String> role = const Value.absent(),
            required DateTime joinedAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MembershipsCompanion.insert(
            id: id,
            householdId: householdId,
            deviceId: deviceId,
            role: role,
            joinedAt: joinedAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MembershipsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MembershipsTable,
    Membership,
    $$MembershipsTableFilterComposer,
    $$MembershipsTableOrderingComposer,
    $$MembershipsTableAnnotationComposer,
    $$MembershipsTableCreateCompanionBuilder,
    $$MembershipsTableUpdateCompanionBuilder,
    (Membership, BaseReferences<_$AppDatabase, $MembershipsTable, Membership>),
    Membership,
    PrefetchHooks Function()>;
typedef $$IngredientsTableCreateCompanionBuilder = IngredientsCompanion
    Function({
  required String id,
  required String householdId,
  required String name,
  required String unit,
  Value<bool> isQb,
  Value<String?> category,
  Value<String?> roundingKind,
  Value<String?> seedKey,
  Value<bool?> nameModified,
  Value<bool> alwaysInList,
  Value<double?> defaultQty,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$IngredientsTableUpdateCompanionBuilder = IngredientsCompanion
    Function({
  Value<String> id,
  Value<String> householdId,
  Value<String> name,
  Value<String> unit,
  Value<bool> isQb,
  Value<String?> category,
  Value<String?> roundingKind,
  Value<String?> seedKey,
  Value<bool?> nameModified,
  Value<bool> alwaysInList,
  Value<double?> defaultQty,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$IngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isQb => $composableBuilder(
      column: $table.isQb, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get roundingKind => $composableBuilder(
      column: $table.roundingKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seedKey => $composableBuilder(
      column: $table.seedKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get nameModified => $composableBuilder(
      column: $table.nameModified, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get alwaysInList => $composableBuilder(
      column: $table.alwaysInList, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get defaultQty => $composableBuilder(
      column: $table.defaultQty, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$IngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isQb => $composableBuilder(
      column: $table.isQb, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get roundingKind => $composableBuilder(
      column: $table.roundingKind,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seedKey => $composableBuilder(
      column: $table.seedKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get nameModified => $composableBuilder(
      column: $table.nameModified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get alwaysInList => $composableBuilder(
      column: $table.alwaysInList,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get defaultQty => $composableBuilder(
      column: $table.defaultQty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$IngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $IngredientsTable> {
  $$IngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<bool> get isQb =>
      $composableBuilder(column: $table.isQb, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get roundingKind => $composableBuilder(
      column: $table.roundingKind, builder: (column) => column);

  GeneratedColumn<String> get seedKey =>
      $composableBuilder(column: $table.seedKey, builder: (column) => column);

  GeneratedColumn<bool> get nameModified => $composableBuilder(
      column: $table.nameModified, builder: (column) => column);

  GeneratedColumn<bool> get alwaysInList => $composableBuilder(
      column: $table.alwaysInList, builder: (column) => column);

  GeneratedColumn<double> get defaultQty => $composableBuilder(
      column: $table.defaultQty, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$IngredientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IngredientsTable,
    Ingredient,
    $$IngredientsTableFilterComposer,
    $$IngredientsTableOrderingComposer,
    $$IngredientsTableAnnotationComposer,
    $$IngredientsTableCreateCompanionBuilder,
    $$IngredientsTableUpdateCompanionBuilder,
    (Ingredient, BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient>),
    Ingredient,
    PrefetchHooks Function()> {
  $$IngredientsTableTableManager(_$AppDatabase db, $IngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<bool> isQb = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> roundingKind = const Value.absent(),
            Value<String?> seedKey = const Value.absent(),
            Value<bool?> nameModified = const Value.absent(),
            Value<bool> alwaysInList = const Value.absent(),
            Value<double?> defaultQty = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IngredientsCompanion(
            id: id,
            householdId: householdId,
            name: name,
            unit: unit,
            isQb: isQb,
            category: category,
            roundingKind: roundingKind,
            seedKey: seedKey,
            nameModified: nameModified,
            alwaysInList: alwaysInList,
            defaultQty: defaultQty,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String householdId,
            required String name,
            required String unit,
            Value<bool> isQb = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> roundingKind = const Value.absent(),
            Value<String?> seedKey = const Value.absent(),
            Value<bool?> nameModified = const Value.absent(),
            Value<bool> alwaysInList = const Value.absent(),
            Value<double?> defaultQty = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              IngredientsCompanion.insert(
            id: id,
            householdId: householdId,
            name: name,
            unit: unit,
            isQb: isQb,
            category: category,
            roundingKind: roundingKind,
            seedKey: seedKey,
            nameModified: nameModified,
            alwaysInList: alwaysInList,
            defaultQty: defaultQty,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$IngredientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $IngredientsTable,
    Ingredient,
    $$IngredientsTableFilterComposer,
    $$IngredientsTableOrderingComposer,
    $$IngredientsTableAnnotationComposer,
    $$IngredientsTableCreateCompanionBuilder,
    $$IngredientsTableUpdateCompanionBuilder,
    (Ingredient, BaseReferences<_$AppDatabase, $IngredientsTable, Ingredient>),
    Ingredient,
    PrefetchHooks Function()>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String householdId,
  required String name,
  required String tagGroup,
  Value<String?> color,
  Value<int> sortOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> householdId,
  Value<String> name,
  Value<String> tagGroup,
  Value<String?> color,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagGroup => $composableBuilder(
      column: $table.tagGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagGroup => $composableBuilder(
      column: $table.tagGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get tagGroup =>
      $composableBuilder(column: $table.tagGroup, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> tagGroup = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            householdId: householdId,
            name: name,
            tagGroup: tagGroup,
            color: color,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String householdId,
            required String name,
            required String tagGroup,
            Value<String?> color = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            householdId: householdId,
            name: name,
            tagGroup: tagGroup,
            color: color,
            sortOrder: sortOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()>;
typedef $$DishesTableCreateCompanionBuilder = DishesCompanion Function({
  required String id,
  required String householdId,
  required String name,
  Value<String?> difficulty,
  Value<String?> timeEstimate,
  Value<String?> recipeUrl,
  Value<String?> seedKey,
  Value<bool?> nameModified,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DishesTableUpdateCompanionBuilder = DishesCompanion Function({
  Value<String> id,
  Value<String> householdId,
  Value<String> name,
  Value<String?> difficulty,
  Value<String?> timeEstimate,
  Value<String?> recipeUrl,
  Value<String?> seedKey,
  Value<bool?> nameModified,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DishesTableFilterComposer
    extends Composer<_$AppDatabase, $DishesTable> {
  $$DishesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timeEstimate => $composableBuilder(
      column: $table.timeEstimate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recipeUrl => $composableBuilder(
      column: $table.recipeUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get seedKey => $composableBuilder(
      column: $table.seedKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get nameModified => $composableBuilder(
      column: $table.nameModified, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DishesTableOrderingComposer
    extends Composer<_$AppDatabase, $DishesTable> {
  $$DishesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timeEstimate => $composableBuilder(
      column: $table.timeEstimate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recipeUrl => $composableBuilder(
      column: $table.recipeUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get seedKey => $composableBuilder(
      column: $table.seedKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get nameModified => $composableBuilder(
      column: $table.nameModified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DishesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DishesTable> {
  $$DishesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<String> get timeEstimate => $composableBuilder(
      column: $table.timeEstimate, builder: (column) => column);

  GeneratedColumn<String> get recipeUrl =>
      $composableBuilder(column: $table.recipeUrl, builder: (column) => column);

  GeneratedColumn<String> get seedKey =>
      $composableBuilder(column: $table.seedKey, builder: (column) => column);

  GeneratedColumn<bool> get nameModified => $composableBuilder(
      column: $table.nameModified, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DishesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DishesTable,
    Dish,
    $$DishesTableFilterComposer,
    $$DishesTableOrderingComposer,
    $$DishesTableAnnotationComposer,
    $$DishesTableCreateCompanionBuilder,
    $$DishesTableUpdateCompanionBuilder,
    (Dish, BaseReferences<_$AppDatabase, $DishesTable, Dish>),
    Dish,
    PrefetchHooks Function()> {
  $$DishesTableTableManager(_$AppDatabase db, $DishesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DishesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DishesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DishesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> difficulty = const Value.absent(),
            Value<String?> timeEstimate = const Value.absent(),
            Value<String?> recipeUrl = const Value.absent(),
            Value<String?> seedKey = const Value.absent(),
            Value<bool?> nameModified = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DishesCompanion(
            id: id,
            householdId: householdId,
            name: name,
            difficulty: difficulty,
            timeEstimate: timeEstimate,
            recipeUrl: recipeUrl,
            seedKey: seedKey,
            nameModified: nameModified,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String householdId,
            required String name,
            Value<String?> difficulty = const Value.absent(),
            Value<String?> timeEstimate = const Value.absent(),
            Value<String?> recipeUrl = const Value.absent(),
            Value<String?> seedKey = const Value.absent(),
            Value<bool?> nameModified = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DishesCompanion.insert(
            id: id,
            householdId: householdId,
            name: name,
            difficulty: difficulty,
            timeEstimate: timeEstimate,
            recipeUrl: recipeUrl,
            seedKey: seedKey,
            nameModified: nameModified,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DishesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DishesTable,
    Dish,
    $$DishesTableFilterComposer,
    $$DishesTableOrderingComposer,
    $$DishesTableAnnotationComposer,
    $$DishesTableCreateCompanionBuilder,
    $$DishesTableUpdateCompanionBuilder,
    (Dish, BaseReferences<_$AppDatabase, $DishesTable, Dish>),
    Dish,
    PrefetchHooks Function()>;
typedef $$DishTagsTableCreateCompanionBuilder = DishTagsCompanion Function({
  required String id,
  required String dishId,
  required String tagId,
  required String householdId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$DishTagsTableUpdateCompanionBuilder = DishTagsCompanion Function({
  Value<String> id,
  Value<String> dishId,
  Value<String> tagId,
  Value<String> householdId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$DishTagsTableFilterComposer
    extends Composer<_$AppDatabase, $DishTagsTable> {
  $$DishTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$DishTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $DishTagsTable> {
  $$DishTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$DishTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DishTagsTable> {
  $$DishTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dishId =>
      $composableBuilder(column: $table.dishId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$DishTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DishTagsTable,
    DishTag,
    $$DishTagsTableFilterComposer,
    $$DishTagsTableOrderingComposer,
    $$DishTagsTableAnnotationComposer,
    $$DishTagsTableCreateCompanionBuilder,
    $$DishTagsTableUpdateCompanionBuilder,
    (DishTag, BaseReferences<_$AppDatabase, $DishTagsTable, DishTag>),
    DishTag,
    PrefetchHooks Function()> {
  $$DishTagsTableTableManager(_$AppDatabase db, $DishTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DishTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DishTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DishTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> dishId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DishTagsCompanion(
            id: id,
            dishId: dishId,
            tagId: tagId,
            householdId: householdId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String dishId,
            required String tagId,
            required String householdId,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DishTagsCompanion.insert(
            id: id,
            dishId: dishId,
            tagId: tagId,
            householdId: householdId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DishTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DishTagsTable,
    DishTag,
    $$DishTagsTableFilterComposer,
    $$DishTagsTableOrderingComposer,
    $$DishTagsTableAnnotationComposer,
    $$DishTagsTableCreateCompanionBuilder,
    $$DishTagsTableUpdateCompanionBuilder,
    (DishTag, BaseReferences<_$AppDatabase, $DishTagsTable, DishTag>),
    DishTag,
    PrefetchHooks Function()>;
typedef $$DishIngredientsTableCreateCompanionBuilder = DishIngredientsCompanion
    Function({
  required String id,
  required String dishId,
  required String ingredientId,
  required String householdId,
  Value<double?> qtyBase4,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$DishIngredientsTableUpdateCompanionBuilder = DishIngredientsCompanion
    Function({
  Value<String> id,
  Value<String> dishId,
  Value<String> ingredientId,
  Value<String> householdId,
  Value<double?> qtyBase4,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$DishIngredientsTableFilterComposer
    extends Composer<_$AppDatabase, $DishIngredientsTable> {
  $$DishIngredientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get qtyBase4 => $composableBuilder(
      column: $table.qtyBase4, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$DishIngredientsTableOrderingComposer
    extends Composer<_$AppDatabase, $DishIngredientsTable> {
  $$DishIngredientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get qtyBase4 => $composableBuilder(
      column: $table.qtyBase4, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$DishIngredientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DishIngredientsTable> {
  $$DishIngredientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dishId =>
      $composableBuilder(column: $table.dishId, builder: (column) => column);

  GeneratedColumn<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<double> get qtyBase4 =>
      $composableBuilder(column: $table.qtyBase4, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DishIngredientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DishIngredientsTable,
    DishIngredient,
    $$DishIngredientsTableFilterComposer,
    $$DishIngredientsTableOrderingComposer,
    $$DishIngredientsTableAnnotationComposer,
    $$DishIngredientsTableCreateCompanionBuilder,
    $$DishIngredientsTableUpdateCompanionBuilder,
    (
      DishIngredient,
      BaseReferences<_$AppDatabase, $DishIngredientsTable, DishIngredient>
    ),
    DishIngredient,
    PrefetchHooks Function()> {
  $$DishIngredientsTableTableManager(
      _$AppDatabase db, $DishIngredientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DishIngredientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DishIngredientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DishIngredientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> dishId = const Value.absent(),
            Value<String> ingredientId = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<double?> qtyBase4 = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DishIngredientsCompanion(
            id: id,
            dishId: dishId,
            ingredientId: ingredientId,
            householdId: householdId,
            qtyBase4: qtyBase4,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String dishId,
            required String ingredientId,
            required String householdId,
            Value<double?> qtyBase4 = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              DishIngredientsCompanion.insert(
            id: id,
            dishId: dishId,
            ingredientId: ingredientId,
            householdId: householdId,
            qtyBase4: qtyBase4,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DishIngredientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DishIngredientsTable,
    DishIngredient,
    $$DishIngredientsTableFilterComposer,
    $$DishIngredientsTableOrderingComposer,
    $$DishIngredientsTableAnnotationComposer,
    $$DishIngredientsTableCreateCompanionBuilder,
    $$DishIngredientsTableUpdateCompanionBuilder,
    (
      DishIngredient,
      BaseReferences<_$AppDatabase, $DishIngredientsTable, DishIngredient>
    ),
    DishIngredient,
    PrefetchHooks Function()>;
typedef $$WeekPlansTableCreateCompanionBuilder = WeekPlansCompanion Function({
  required String id,
  required String householdId,
  required int year,
  required int week,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$WeekPlansTableUpdateCompanionBuilder = WeekPlansCompanion Function({
  Value<String> id,
  Value<String> householdId,
  Value<int> year,
  Value<int> week,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$WeekPlansTableFilterComposer
    extends Composer<_$AppDatabase, $WeekPlansTable> {
  $$WeekPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get week => $composableBuilder(
      column: $table.week, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$WeekPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $WeekPlansTable> {
  $$WeekPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get week => $composableBuilder(
      column: $table.week, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$WeekPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeekPlansTable> {
  $$WeekPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get week =>
      $composableBuilder(column: $table.week, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WeekPlansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WeekPlansTable,
    WeekPlan,
    $$WeekPlansTableFilterComposer,
    $$WeekPlansTableOrderingComposer,
    $$WeekPlansTableAnnotationComposer,
    $$WeekPlansTableCreateCompanionBuilder,
    $$WeekPlansTableUpdateCompanionBuilder,
    (WeekPlan, BaseReferences<_$AppDatabase, $WeekPlansTable, WeekPlan>),
    WeekPlan,
    PrefetchHooks Function()> {
  $$WeekPlansTableTableManager(_$AppDatabase db, $WeekPlansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeekPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeekPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeekPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<int> year = const Value.absent(),
            Value<int> week = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeekPlansCompanion(
            id: id,
            householdId: householdId,
            year: year,
            week: week,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String householdId,
            required int year,
            required int week,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              WeekPlansCompanion.insert(
            id: id,
            householdId: householdId,
            year: year,
            week: week,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WeekPlansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WeekPlansTable,
    WeekPlan,
    $$WeekPlansTableFilterComposer,
    $$WeekPlansTableOrderingComposer,
    $$WeekPlansTableAnnotationComposer,
    $$WeekPlansTableCreateCompanionBuilder,
    $$WeekPlansTableUpdateCompanionBuilder,
    (WeekPlan, BaseReferences<_$AppDatabase, $WeekPlansTable, WeekPlan>),
    WeekPlan,
    PrefetchHooks Function()>;
typedef $$PlanDaysTableCreateCompanionBuilder = PlanDaysCompanion Function({
  required String id,
  required String weekPlanId,
  required String householdId,
  required int dayOfWeek,
  required int guests,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PlanDaysTableUpdateCompanionBuilder = PlanDaysCompanion Function({
  Value<String> id,
  Value<String> weekPlanId,
  Value<String> householdId,
  Value<int> dayOfWeek,
  Value<int> guests,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PlanDaysTableFilterComposer
    extends Composer<_$AppDatabase, $PlanDaysTable> {
  $$PlanDaysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weekPlanId => $composableBuilder(
      column: $table.weekPlanId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get guests => $composableBuilder(
      column: $table.guests, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PlanDaysTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanDaysTable> {
  $$PlanDaysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weekPlanId => $composableBuilder(
      column: $table.weekPlanId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
      column: $table.dayOfWeek, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get guests => $composableBuilder(
      column: $table.guests, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PlanDaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanDaysTable> {
  $$PlanDaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get weekPlanId => $composableBuilder(
      column: $table.weekPlanId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<int> get guests =>
      $composableBuilder(column: $table.guests, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlanDaysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanDaysTable,
    PlanDay,
    $$PlanDaysTableFilterComposer,
    $$PlanDaysTableOrderingComposer,
    $$PlanDaysTableAnnotationComposer,
    $$PlanDaysTableCreateCompanionBuilder,
    $$PlanDaysTableUpdateCompanionBuilder,
    (PlanDay, BaseReferences<_$AppDatabase, $PlanDaysTable, PlanDay>),
    PlanDay,
    PrefetchHooks Function()> {
  $$PlanDaysTableTableManager(_$AppDatabase db, $PlanDaysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanDaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanDaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanDaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> weekPlanId = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<int> dayOfWeek = const Value.absent(),
            Value<int> guests = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanDaysCompanion(
            id: id,
            weekPlanId: weekPlanId,
            householdId: householdId,
            dayOfWeek: dayOfWeek,
            guests: guests,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String weekPlanId,
            required String householdId,
            required int dayOfWeek,
            required int guests,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanDaysCompanion.insert(
            id: id,
            weekPlanId: weekPlanId,
            householdId: householdId,
            dayOfWeek: dayOfWeek,
            guests: guests,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlanDaysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlanDaysTable,
    PlanDay,
    $$PlanDaysTableFilterComposer,
    $$PlanDaysTableOrderingComposer,
    $$PlanDaysTableAnnotationComposer,
    $$PlanDaysTableCreateCompanionBuilder,
    $$PlanDaysTableUpdateCompanionBuilder,
    (PlanDay, BaseReferences<_$AppDatabase, $PlanDaysTable, PlanDay>),
    PlanDay,
    PrefetchHooks Function()>;
typedef $$PlanDayDishesTableCreateCompanionBuilder = PlanDayDishesCompanion
    Function({
  required String id,
  required String planDayId,
  required String dishId,
  required String householdId,
  Value<int> sortOrder,
  Value<bool> autoAssigned,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$PlanDayDishesTableUpdateCompanionBuilder = PlanDayDishesCompanion
    Function({
  Value<String> id,
  Value<String> planDayId,
  Value<String> dishId,
  Value<String> householdId,
  Value<int> sortOrder,
  Value<bool> autoAssigned,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$PlanDayDishesTableFilterComposer
    extends Composer<_$AppDatabase, $PlanDayDishesTable> {
  $$PlanDayDishesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get planDayId => $composableBuilder(
      column: $table.planDayId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoAssigned => $composableBuilder(
      column: $table.autoAssigned, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$PlanDayDishesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanDayDishesTable> {
  $$PlanDayDishesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get planDayId => $composableBuilder(
      column: $table.planDayId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dishId => $composableBuilder(
      column: $table.dishId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sortOrder => $composableBuilder(
      column: $table.sortOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoAssigned => $composableBuilder(
      column: $table.autoAssigned,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$PlanDayDishesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanDayDishesTable> {
  $$PlanDayDishesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planDayId =>
      $composableBuilder(column: $table.planDayId, builder: (column) => column);

  GeneratedColumn<String> get dishId =>
      $composableBuilder(column: $table.dishId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get autoAssigned => $composableBuilder(
      column: $table.autoAssigned, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PlanDayDishesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanDayDishesTable,
    PlanDayDish,
    $$PlanDayDishesTableFilterComposer,
    $$PlanDayDishesTableOrderingComposer,
    $$PlanDayDishesTableAnnotationComposer,
    $$PlanDayDishesTableCreateCompanionBuilder,
    $$PlanDayDishesTableUpdateCompanionBuilder,
    (
      PlanDayDish,
      BaseReferences<_$AppDatabase, $PlanDayDishesTable, PlanDayDish>
    ),
    PlanDayDish,
    PrefetchHooks Function()> {
  $$PlanDayDishesTableTableManager(_$AppDatabase db, $PlanDayDishesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanDayDishesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanDayDishesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanDayDishesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> planDayId = const Value.absent(),
            Value<String> dishId = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<int> sortOrder = const Value.absent(),
            Value<bool> autoAssigned = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanDayDishesCompanion(
            id: id,
            planDayId: planDayId,
            dishId: dishId,
            householdId: householdId,
            sortOrder: sortOrder,
            autoAssigned: autoAssigned,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String planDayId,
            required String dishId,
            required String householdId,
            Value<int> sortOrder = const Value.absent(),
            Value<bool> autoAssigned = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PlanDayDishesCompanion.insert(
            id: id,
            planDayId: planDayId,
            dishId: dishId,
            householdId: householdId,
            sortOrder: sortOrder,
            autoAssigned: autoAssigned,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlanDayDishesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlanDayDishesTable,
    PlanDayDish,
    $$PlanDayDishesTableFilterComposer,
    $$PlanDayDishesTableOrderingComposer,
    $$PlanDayDishesTableAnnotationComposer,
    $$PlanDayDishesTableCreateCompanionBuilder,
    $$PlanDayDishesTableUpdateCompanionBuilder,
    (
      PlanDayDish,
      BaseReferences<_$AppDatabase, $PlanDayDishesTable, PlanDayDish>
    ),
    PlanDayDish,
    PrefetchHooks Function()>;
typedef $$ShoppingListsTableCreateCompanionBuilder = ShoppingListsCompanion
    Function({
  required String id,
  required String householdId,
  required String weekPlanId,
  required DateTime generatedAt,
  required String planHash,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ShoppingListsTableUpdateCompanionBuilder = ShoppingListsCompanion
    Function({
  Value<String> id,
  Value<String> householdId,
  Value<String> weekPlanId,
  Value<DateTime> generatedAt,
  Value<String> planHash,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ShoppingListsTableFilterComposer
    extends Composer<_$AppDatabase, $ShoppingListsTable> {
  $$ShoppingListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get weekPlanId => $composableBuilder(
      column: $table.weekPlanId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get planHash => $composableBuilder(
      column: $table.planHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ShoppingListsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShoppingListsTable> {
  $$ShoppingListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get weekPlanId => $composableBuilder(
      column: $table.weekPlanId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get planHash => $composableBuilder(
      column: $table.planHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ShoppingListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShoppingListsTable> {
  $$ShoppingListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get weekPlanId => $composableBuilder(
      column: $table.weekPlanId, builder: (column) => column);

  GeneratedColumn<DateTime> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => column);

  GeneratedColumn<String> get planHash =>
      $composableBuilder(column: $table.planHash, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ShoppingListsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShoppingListsTable,
    ShoppingList,
    $$ShoppingListsTableFilterComposer,
    $$ShoppingListsTableOrderingComposer,
    $$ShoppingListsTableAnnotationComposer,
    $$ShoppingListsTableCreateCompanionBuilder,
    $$ShoppingListsTableUpdateCompanionBuilder,
    (
      ShoppingList,
      BaseReferences<_$AppDatabase, $ShoppingListsTable, ShoppingList>
    ),
    ShoppingList,
    PrefetchHooks Function()> {
  $$ShoppingListsTableTableManager(_$AppDatabase db, $ShoppingListsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShoppingListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShoppingListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShoppingListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> weekPlanId = const Value.absent(),
            Value<DateTime> generatedAt = const Value.absent(),
            Value<String> planHash = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShoppingListsCompanion(
            id: id,
            householdId: householdId,
            weekPlanId: weekPlanId,
            generatedAt: generatedAt,
            planHash: planHash,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String householdId,
            required String weekPlanId,
            required DateTime generatedAt,
            required String planHash,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ShoppingListsCompanion.insert(
            id: id,
            householdId: householdId,
            weekPlanId: weekPlanId,
            generatedAt: generatedAt,
            planHash: planHash,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ShoppingListsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShoppingListsTable,
    ShoppingList,
    $$ShoppingListsTableFilterComposer,
    $$ShoppingListsTableOrderingComposer,
    $$ShoppingListsTableAnnotationComposer,
    $$ShoppingListsTableCreateCompanionBuilder,
    $$ShoppingListsTableUpdateCompanionBuilder,
    (
      ShoppingList,
      BaseReferences<_$AppDatabase, $ShoppingListsTable, ShoppingList>
    ),
    ShoppingList,
    PrefetchHooks Function()>;
typedef $$ListGeneratedRowsTableCreateCompanionBuilder
    = ListGeneratedRowsCompanion Function({
  required String id,
  required String shoppingListId,
  required String ingredientId,
  required String householdId,
  Value<double?> qty,
  required String unit,
  Value<bool> isQb,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ListGeneratedRowsTableUpdateCompanionBuilder
    = ListGeneratedRowsCompanion Function({
  Value<String> id,
  Value<String> shoppingListId,
  Value<String> ingredientId,
  Value<String> householdId,
  Value<double?> qty,
  Value<String> unit,
  Value<bool> isQb,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ListGeneratedRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ListGeneratedRowsTable> {
  $$ListGeneratedRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isQb => $composableBuilder(
      column: $table.isQb, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ListGeneratedRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ListGeneratedRowsTable> {
  $$ListGeneratedRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isQb => $composableBuilder(
      column: $table.isQb, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ListGeneratedRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListGeneratedRowsTable> {
  $$ListGeneratedRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId, builder: (column) => column);

  GeneratedColumn<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<double> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<bool> get isQb =>
      $composableBuilder(column: $table.isQb, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ListGeneratedRowsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ListGeneratedRowsTable,
    ListGeneratedRow,
    $$ListGeneratedRowsTableFilterComposer,
    $$ListGeneratedRowsTableOrderingComposer,
    $$ListGeneratedRowsTableAnnotationComposer,
    $$ListGeneratedRowsTableCreateCompanionBuilder,
    $$ListGeneratedRowsTableUpdateCompanionBuilder,
    (
      ListGeneratedRow,
      BaseReferences<_$AppDatabase, $ListGeneratedRowsTable, ListGeneratedRow>
    ),
    ListGeneratedRow,
    PrefetchHooks Function()> {
  $$ListGeneratedRowsTableTableManager(
      _$AppDatabase db, $ListGeneratedRowsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListGeneratedRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListGeneratedRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListGeneratedRowsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> shoppingListId = const Value.absent(),
            Value<String> ingredientId = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<double?> qty = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<bool> isQb = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ListGeneratedRowsCompanion(
            id: id,
            shoppingListId: shoppingListId,
            ingredientId: ingredientId,
            householdId: householdId,
            qty: qty,
            unit: unit,
            isQb: isQb,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String shoppingListId,
            required String ingredientId,
            required String householdId,
            Value<double?> qty = const Value.absent(),
            required String unit,
            Value<bool> isQb = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ListGeneratedRowsCompanion.insert(
            id: id,
            shoppingListId: shoppingListId,
            ingredientId: ingredientId,
            householdId: householdId,
            qty: qty,
            unit: unit,
            isQb: isQb,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ListGeneratedRowsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ListGeneratedRowsTable,
    ListGeneratedRow,
    $$ListGeneratedRowsTableFilterComposer,
    $$ListGeneratedRowsTableOrderingComposer,
    $$ListGeneratedRowsTableAnnotationComposer,
    $$ListGeneratedRowsTableCreateCompanionBuilder,
    $$ListGeneratedRowsTableUpdateCompanionBuilder,
    (
      ListGeneratedRow,
      BaseReferences<_$AppDatabase, $ListGeneratedRowsTable, ListGeneratedRow>
    ),
    ListGeneratedRow,
    PrefetchHooks Function()>;
typedef $$ListOverridesTableCreateCompanionBuilder = ListOverridesCompanion
    Function({
  required String id,
  required String shoppingListId,
  required String ingredientId,
  required String householdId,
  Value<double?> qtyOverride,
  Value<bool> removed,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ListOverridesTableUpdateCompanionBuilder = ListOverridesCompanion
    Function({
  Value<String> id,
  Value<String> shoppingListId,
  Value<String> ingredientId,
  Value<String> householdId,
  Value<double?> qtyOverride,
  Value<bool> removed,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ListOverridesTableFilterComposer
    extends Composer<_$AppDatabase, $ListOverridesTable> {
  $$ListOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get qtyOverride => $composableBuilder(
      column: $table.qtyOverride, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get removed => $composableBuilder(
      column: $table.removed, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ListOverridesTableOrderingComposer
    extends Composer<_$AppDatabase, $ListOverridesTable> {
  $$ListOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get qtyOverride => $composableBuilder(
      column: $table.qtyOverride, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get removed => $composableBuilder(
      column: $table.removed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ListOverridesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListOverridesTable> {
  $$ListOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId, builder: (column) => column);

  GeneratedColumn<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<double> get qtyOverride => $composableBuilder(
      column: $table.qtyOverride, builder: (column) => column);

  GeneratedColumn<bool> get removed =>
      $composableBuilder(column: $table.removed, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ListOverridesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ListOverridesTable,
    ListOverride,
    $$ListOverridesTableFilterComposer,
    $$ListOverridesTableOrderingComposer,
    $$ListOverridesTableAnnotationComposer,
    $$ListOverridesTableCreateCompanionBuilder,
    $$ListOverridesTableUpdateCompanionBuilder,
    (
      ListOverride,
      BaseReferences<_$AppDatabase, $ListOverridesTable, ListOverride>
    ),
    ListOverride,
    PrefetchHooks Function()> {
  $$ListOverridesTableTableManager(_$AppDatabase db, $ListOverridesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListOverridesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListOverridesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListOverridesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> shoppingListId = const Value.absent(),
            Value<String> ingredientId = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<double?> qtyOverride = const Value.absent(),
            Value<bool> removed = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ListOverridesCompanion(
            id: id,
            shoppingListId: shoppingListId,
            ingredientId: ingredientId,
            householdId: householdId,
            qtyOverride: qtyOverride,
            removed: removed,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String shoppingListId,
            required String ingredientId,
            required String householdId,
            Value<double?> qtyOverride = const Value.absent(),
            Value<bool> removed = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ListOverridesCompanion.insert(
            id: id,
            shoppingListId: shoppingListId,
            ingredientId: ingredientId,
            householdId: householdId,
            qtyOverride: qtyOverride,
            removed: removed,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ListOverridesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ListOverridesTable,
    ListOverride,
    $$ListOverridesTableFilterComposer,
    $$ListOverridesTableOrderingComposer,
    $$ListOverridesTableAnnotationComposer,
    $$ListOverridesTableCreateCompanionBuilder,
    $$ListOverridesTableUpdateCompanionBuilder,
    (
      ListOverride,
      BaseReferences<_$AppDatabase, $ListOverridesTable, ListOverride>
    ),
    ListOverride,
    PrefetchHooks Function()>;
typedef $$ListManualItemsTableCreateCompanionBuilder = ListManualItemsCompanion
    Function({
  required String id,
  required String shoppingListId,
  required String householdId,
  required String name,
  Value<double?> qty,
  Value<String?> unit,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ListManualItemsTableUpdateCompanionBuilder = ListManualItemsCompanion
    Function({
  Value<String> id,
  Value<String> shoppingListId,
  Value<String> householdId,
  Value<String> name,
  Value<double?> qty,
  Value<String?> unit,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ListManualItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ListManualItemsTable> {
  $$ListManualItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ListManualItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ListManualItemsTable> {
  $$ListManualItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get qty => $composableBuilder(
      column: $table.qty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ListManualItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListManualItemsTable> {
  $$ListManualItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get qty =>
      $composableBuilder(column: $table.qty, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ListManualItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ListManualItemsTable,
    ListManualItem,
    $$ListManualItemsTableFilterComposer,
    $$ListManualItemsTableOrderingComposer,
    $$ListManualItemsTableAnnotationComposer,
    $$ListManualItemsTableCreateCompanionBuilder,
    $$ListManualItemsTableUpdateCompanionBuilder,
    (
      ListManualItem,
      BaseReferences<_$AppDatabase, $ListManualItemsTable, ListManualItem>
    ),
    ListManualItem,
    PrefetchHooks Function()> {
  $$ListManualItemsTableTableManager(
      _$AppDatabase db, $ListManualItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListManualItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListManualItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListManualItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> shoppingListId = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double?> qty = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ListManualItemsCompanion(
            id: id,
            shoppingListId: shoppingListId,
            householdId: householdId,
            name: name,
            qty: qty,
            unit: unit,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String shoppingListId,
            required String householdId,
            required String name,
            Value<double?> qty = const Value.absent(),
            Value<String?> unit = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ListManualItemsCompanion.insert(
            id: id,
            shoppingListId: shoppingListId,
            householdId: householdId,
            name: name,
            qty: qty,
            unit: unit,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ListManualItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ListManualItemsTable,
    ListManualItem,
    $$ListManualItemsTableFilterComposer,
    $$ListManualItemsTableOrderingComposer,
    $$ListManualItemsTableAnnotationComposer,
    $$ListManualItemsTableCreateCompanionBuilder,
    $$ListManualItemsTableUpdateCompanionBuilder,
    (
      ListManualItem,
      BaseReferences<_$AppDatabase, $ListManualItemsTable, ListManualItem>
    ),
    ListManualItem,
    PrefetchHooks Function()>;
typedef $$ListChecksTableCreateCompanionBuilder = ListChecksCompanion Function({
  required String id,
  required String shoppingListId,
  Value<String?> ingredientId,
  Value<String?> manualItemId,
  required String householdId,
  Value<bool> checked,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ListChecksTableUpdateCompanionBuilder = ListChecksCompanion Function({
  Value<String> id,
  Value<String> shoppingListId,
  Value<String?> ingredientId,
  Value<String?> manualItemId,
  Value<String> householdId,
  Value<bool> checked,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ListChecksTableFilterComposer
    extends Composer<_$AppDatabase, $ListChecksTable> {
  $$ListChecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manualItemId => $composableBuilder(
      column: $table.manualItemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get checked => $composableBuilder(
      column: $table.checked, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ListChecksTableOrderingComposer
    extends Composer<_$AppDatabase, $ListChecksTable> {
  $$ListChecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manualItemId => $composableBuilder(
      column: $table.manualItemId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get checked => $composableBuilder(
      column: $table.checked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ListChecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListChecksTable> {
  $$ListChecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId, builder: (column) => column);

  GeneratedColumn<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => column);

  GeneratedColumn<String> get manualItemId => $composableBuilder(
      column: $table.manualItemId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<bool> get checked =>
      $composableBuilder(column: $table.checked, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ListChecksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ListChecksTable,
    ListCheck,
    $$ListChecksTableFilterComposer,
    $$ListChecksTableOrderingComposer,
    $$ListChecksTableAnnotationComposer,
    $$ListChecksTableCreateCompanionBuilder,
    $$ListChecksTableUpdateCompanionBuilder,
    (ListCheck, BaseReferences<_$AppDatabase, $ListChecksTable, ListCheck>),
    ListCheck,
    PrefetchHooks Function()> {
  $$ListChecksTableTableManager(_$AppDatabase db, $ListChecksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListChecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListChecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListChecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> shoppingListId = const Value.absent(),
            Value<String?> ingredientId = const Value.absent(),
            Value<String?> manualItemId = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<bool> checked = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ListChecksCompanion(
            id: id,
            shoppingListId: shoppingListId,
            ingredientId: ingredientId,
            manualItemId: manualItemId,
            householdId: householdId,
            checked: checked,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String shoppingListId,
            Value<String?> ingredientId = const Value.absent(),
            Value<String?> manualItemId = const Value.absent(),
            required String householdId,
            Value<bool> checked = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ListChecksCompanion.insert(
            id: id,
            shoppingListId: shoppingListId,
            ingredientId: ingredientId,
            manualItemId: manualItemId,
            householdId: householdId,
            checked: checked,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ListChecksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ListChecksTable,
    ListCheck,
    $$ListChecksTableFilterComposer,
    $$ListChecksTableOrderingComposer,
    $$ListChecksTableAnnotationComposer,
    $$ListChecksTableCreateCompanionBuilder,
    $$ListChecksTableUpdateCompanionBuilder,
    (ListCheck, BaseReferences<_$AppDatabase, $ListChecksTable, ListCheck>),
    ListCheck,
    PrefetchHooks Function()>;
typedef $$ListRecurringExclusionsTableCreateCompanionBuilder
    = ListRecurringExclusionsCompanion Function({
  required String id,
  required String shoppingListId,
  required String ingredientId,
  required String householdId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$ListRecurringExclusionsTableUpdateCompanionBuilder
    = ListRecurringExclusionsCompanion Function({
  Value<String> id,
  Value<String> shoppingListId,
  Value<String> ingredientId,
  Value<String> householdId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$ListRecurringExclusionsTableFilterComposer
    extends Composer<_$AppDatabase, $ListRecurringExclusionsTable> {
  $$ListRecurringExclusionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ListRecurringExclusionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ListRecurringExclusionsTable> {
  $$ListRecurringExclusionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ListRecurringExclusionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListRecurringExclusionsTable> {
  $$ListRecurringExclusionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shoppingListId => $composableBuilder(
      column: $table.shoppingListId, builder: (column) => column);

  GeneratedColumn<String> get ingredientId => $composableBuilder(
      column: $table.ingredientId, builder: (column) => column);

  GeneratedColumn<String> get householdId => $composableBuilder(
      column: $table.householdId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ListRecurringExclusionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ListRecurringExclusionsTable,
    ListRecurringExclusion,
    $$ListRecurringExclusionsTableFilterComposer,
    $$ListRecurringExclusionsTableOrderingComposer,
    $$ListRecurringExclusionsTableAnnotationComposer,
    $$ListRecurringExclusionsTableCreateCompanionBuilder,
    $$ListRecurringExclusionsTableUpdateCompanionBuilder,
    (
      ListRecurringExclusion,
      BaseReferences<_$AppDatabase, $ListRecurringExclusionsTable,
          ListRecurringExclusion>
    ),
    ListRecurringExclusion,
    PrefetchHooks Function()> {
  $$ListRecurringExclusionsTableTableManager(
      _$AppDatabase db, $ListRecurringExclusionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListRecurringExclusionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ListRecurringExclusionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListRecurringExclusionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> shoppingListId = const Value.absent(),
            Value<String> ingredientId = const Value.absent(),
            Value<String> householdId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ListRecurringExclusionsCompanion(
            id: id,
            shoppingListId: shoppingListId,
            ingredientId: ingredientId,
            householdId: householdId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String shoppingListId,
            required String ingredientId,
            required String householdId,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ListRecurringExclusionsCompanion.insert(
            id: id,
            shoppingListId: shoppingListId,
            ingredientId: ingredientId,
            householdId: householdId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ListRecurringExclusionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ListRecurringExclusionsTable,
        ListRecurringExclusion,
        $$ListRecurringExclusionsTableFilterComposer,
        $$ListRecurringExclusionsTableOrderingComposer,
        $$ListRecurringExclusionsTableAnnotationComposer,
        $$ListRecurringExclusionsTableCreateCompanionBuilder,
        $$ListRecurringExclusionsTableUpdateCompanionBuilder,
        (
          ListRecurringExclusion,
          BaseReferences<_$AppDatabase, $ListRecurringExclusionsTable,
              ListRecurringExclusion>
        ),
        ListRecurringExclusion,
        PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HouseholdsTableTableManager get households =>
      $$HouseholdsTableTableManager(_db, _db.households);
  $$MembershipsTableTableManager get memberships =>
      $$MembershipsTableTableManager(_db, _db.memberships);
  $$IngredientsTableTableManager get ingredients =>
      $$IngredientsTableTableManager(_db, _db.ingredients);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$DishesTableTableManager get dishes =>
      $$DishesTableTableManager(_db, _db.dishes);
  $$DishTagsTableTableManager get dishTags =>
      $$DishTagsTableTableManager(_db, _db.dishTags);
  $$DishIngredientsTableTableManager get dishIngredients =>
      $$DishIngredientsTableTableManager(_db, _db.dishIngredients);
  $$WeekPlansTableTableManager get weekPlans =>
      $$WeekPlansTableTableManager(_db, _db.weekPlans);
  $$PlanDaysTableTableManager get planDays =>
      $$PlanDaysTableTableManager(_db, _db.planDays);
  $$PlanDayDishesTableTableManager get planDayDishes =>
      $$PlanDayDishesTableTableManager(_db, _db.planDayDishes);
  $$ShoppingListsTableTableManager get shoppingLists =>
      $$ShoppingListsTableTableManager(_db, _db.shoppingLists);
  $$ListGeneratedRowsTableTableManager get listGeneratedRows =>
      $$ListGeneratedRowsTableTableManager(_db, _db.listGeneratedRows);
  $$ListOverridesTableTableManager get listOverrides =>
      $$ListOverridesTableTableManager(_db, _db.listOverrides);
  $$ListManualItemsTableTableManager get listManualItems =>
      $$ListManualItemsTableTableManager(_db, _db.listManualItems);
  $$ListChecksTableTableManager get listChecks =>
      $$ListChecksTableTableManager(_db, _db.listChecks);
  $$ListRecurringExclusionsTableTableManager get listRecurringExclusions =>
      $$ListRecurringExclusionsTableTableManager(
          _db, _db.listRecurringExclusions);
}
