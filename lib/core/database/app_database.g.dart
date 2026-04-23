// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTableTable extends CategoriesTable
    with TableInfo<$CategoriesTableTable, CategoriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($CategoriesTableTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    tenantId,
    syncStatus,
    createdAt,
    updatedAt,
    id,
    name,
    description,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoriesTableData(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      syncStatus: $CategoriesTableTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $CategoriesTableTable createAlias(String alias) {
    return $CategoriesTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class CategoriesTableData extends DataClass
    implements Insertable<CategoriesTableData> {
  final String? remoteId;
  final String tenantId;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  const CategoriesTableData({
    this.remoteId,
    required this.tenantId,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['tenant_id'] = Variable<String>(tenantId);
    {
      map['sync_status'] = Variable<int>(
        $CategoriesTableTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  CategoriesTableCompanion toCompanion(bool nullToAbsent) {
    return CategoriesTableCompanion(
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      tenantId: Value(tenantId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isActive: Value(isActive),
    );
  }

  factory CategoriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoriesTableData(
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      syncStatus: $CategoriesTableTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String?>(remoteId),
      'tenantId': serializer.toJson<String>(tenantId),
      'syncStatus': serializer.toJson<int>(
        $CategoriesTableTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  CategoriesTableData copyWith({
    Value<String?> remoteId = const Value.absent(),
    String? tenantId,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? id,
    String? name,
    Value<String?> description = const Value.absent(),
    bool? isActive,
  }) => CategoriesTableData(
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    tenantId: tenantId ?? this.tenantId,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    isActive: isActive ?? this.isActive,
  );
  CategoriesTableData copyWithCompanion(CategoriesTableCompanion data) {
    return CategoriesTableData(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableData(')
          ..write('remoteId: $remoteId, ')
          ..write('tenantId: $tenantId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    tenantId,
    syncStatus,
    createdAt,
    updatedAt,
    id,
    name,
    description,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoriesTableData &&
          other.remoteId == this.remoteId &&
          other.tenantId == this.tenantId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.isActive == this.isActive);
}

class CategoriesTableCompanion extends UpdateCompanion<CategoriesTableData> {
  final Value<String?> remoteId;
  final Value<String> tenantId;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<bool> isActive;
  const CategoriesTableCompanion({
    this.remoteId = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  CategoriesTableCompanion.insert({
    this.remoteId = const Value.absent(),
    required String tenantId,
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : tenantId = Value(tenantId),
       name = Value(name);
  static Insertable<CategoriesTableData> custom({
    Expression<String>? remoteId,
    Expression<String>? tenantId,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (tenantId != null) 'tenant_id': tenantId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
    });
  }

  CategoriesTableCompanion copyWith({
    Value<String?>? remoteId,
    Value<String>? tenantId,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<bool>? isActive,
  }) {
    return CategoriesTableCompanion(
      remoteId: remoteId ?? this.remoteId,
      tenantId: tenantId ?? this.tenantId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $CategoriesTableTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesTableCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('tenantId: $tenantId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $ProductsTableTable extends ProductsTable
    with TableInfo<$ProductsTableTable, ProductsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($ProductsTableTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<int> stock = GeneratedColumn<int>(
    'stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _minStockMeta = const VerificationMeta(
    'minStock',
  );
  @override
  late final GeneratedColumn<int> minStock = GeneratedColumn<int>(
    'min_stock',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    tenantId,
    syncStatus,
    createdAt,
    updatedAt,
    id,
    name,
    sku,
    barcode,
    price,
    cost,
    stock,
    minStock,
    categoryId,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('stock')) {
      context.handle(
        _stockMeta,
        stock.isAcceptableOrUnknown(data['stock']!, _stockMeta),
      );
    }
    if (data.containsKey('min_stock')) {
      context.handle(
        _minStockMeta,
        minStock.isAcceptableOrUnknown(data['min_stock']!, _minStockMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductsTableData(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      syncStatus: $ProductsTableTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      ),
      stock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock'],
      )!,
      minStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_stock'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $ProductsTableTable createAlias(String alias) {
    return $ProductsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class ProductsTableData extends DataClass
    implements Insertable<ProductsTableData> {
  final String? remoteId;
  final String tenantId;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final String name;
  final String? sku;
  final String? barcode;
  final double price;
  final double? cost;
  final int stock;
  final int minStock;
  final int? categoryId;
  final bool isActive;
  const ProductsTableData({
    this.remoteId,
    required this.tenantId,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.name,
    this.sku,
    this.barcode,
    required this.price,
    this.cost,
    required this.stock,
    required this.minStock,
    this.categoryId,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['tenant_id'] = Variable<String>(tenantId);
    {
      map['sync_status'] = Variable<int>(
        $ProductsTableTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['price'] = Variable<double>(price);
    if (!nullToAbsent || cost != null) {
      map['cost'] = Variable<double>(cost);
    }
    map['stock'] = Variable<int>(stock);
    map['min_stock'] = Variable<int>(minStock);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  ProductsTableCompanion toCompanion(bool nullToAbsent) {
    return ProductsTableCompanion(
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      tenantId: Value(tenantId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      price: Value(price),
      cost: cost == null && nullToAbsent ? const Value.absent() : Value(cost),
      stock: Value(stock),
      minStock: Value(minStock),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      isActive: Value(isActive),
    );
  }

  factory ProductsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductsTableData(
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      syncStatus: $ProductsTableTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sku: serializer.fromJson<String?>(json['sku']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      price: serializer.fromJson<double>(json['price']),
      cost: serializer.fromJson<double?>(json['cost']),
      stock: serializer.fromJson<int>(json['stock']),
      minStock: serializer.fromJson<int>(json['minStock']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String?>(remoteId),
      'tenantId': serializer.toJson<String>(tenantId),
      'syncStatus': serializer.toJson<int>(
        $ProductsTableTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sku': serializer.toJson<String?>(sku),
      'barcode': serializer.toJson<String?>(barcode),
      'price': serializer.toJson<double>(price),
      'cost': serializer.toJson<double?>(cost),
      'stock': serializer.toJson<int>(stock),
      'minStock': serializer.toJson<int>(minStock),
      'categoryId': serializer.toJson<int?>(categoryId),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  ProductsTableData copyWith({
    Value<String?> remoteId = const Value.absent(),
    String? tenantId,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? id,
    String? name,
    Value<String?> sku = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    double? price,
    Value<double?> cost = const Value.absent(),
    int? stock,
    int? minStock,
    Value<int?> categoryId = const Value.absent(),
    bool? isActive,
  }) => ProductsTableData(
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    tenantId: tenantId ?? this.tenantId,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    sku: sku.present ? sku.value : this.sku,
    barcode: barcode.present ? barcode.value : this.barcode,
    price: price ?? this.price,
    cost: cost.present ? cost.value : this.cost,
    stock: stock ?? this.stock,
    minStock: minStock ?? this.minStock,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    isActive: isActive ?? this.isActive,
  );
  ProductsTableData copyWithCompanion(ProductsTableCompanion data) {
    return ProductsTableData(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sku: data.sku.present ? data.sku.value : this.sku,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      price: data.price.present ? data.price.value : this.price,
      cost: data.cost.present ? data.cost.value : this.cost,
      stock: data.stock.present ? data.stock.value : this.stock,
      minStock: data.minStock.present ? data.minStock.value : this.minStock,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableData(')
          ..write('remoteId: $remoteId, ')
          ..write('tenantId: $tenantId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('price: $price, ')
          ..write('cost: $cost, ')
          ..write('stock: $stock, ')
          ..write('minStock: $minStock, ')
          ..write('categoryId: $categoryId, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    tenantId,
    syncStatus,
    createdAt,
    updatedAt,
    id,
    name,
    sku,
    barcode,
    price,
    cost,
    stock,
    minStock,
    categoryId,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductsTableData &&
          other.remoteId == this.remoteId &&
          other.tenantId == this.tenantId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.sku == this.sku &&
          other.barcode == this.barcode &&
          other.price == this.price &&
          other.cost == this.cost &&
          other.stock == this.stock &&
          other.minStock == this.minStock &&
          other.categoryId == this.categoryId &&
          other.isActive == this.isActive);
}

class ProductsTableCompanion extends UpdateCompanion<ProductsTableData> {
  final Value<String?> remoteId;
  final Value<String> tenantId;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<String> name;
  final Value<String?> sku;
  final Value<String?> barcode;
  final Value<double> price;
  final Value<double?> cost;
  final Value<int> stock;
  final Value<int> minStock;
  final Value<int?> categoryId;
  final Value<bool> isActive;
  const ProductsTableCompanion({
    this.remoteId = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    this.price = const Value.absent(),
    this.cost = const Value.absent(),
    this.stock = const Value.absent(),
    this.minStock = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  ProductsTableCompanion.insert({
    this.remoteId = const Value.absent(),
    required String tenantId,
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String name,
    this.sku = const Value.absent(),
    this.barcode = const Value.absent(),
    required double price,
    this.cost = const Value.absent(),
    this.stock = const Value.absent(),
    this.minStock = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : tenantId = Value(tenantId),
       name = Value(name),
       price = Value(price);
  static Insertable<ProductsTableData> custom({
    Expression<String>? remoteId,
    Expression<String>? tenantId,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? sku,
    Expression<String>? barcode,
    Expression<double>? price,
    Expression<double>? cost,
    Expression<int>? stock,
    Expression<int>? minStock,
    Expression<int>? categoryId,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (tenantId != null) 'tenant_id': tenantId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sku != null) 'sku': sku,
      if (barcode != null) 'barcode': barcode,
      if (price != null) 'price': price,
      if (cost != null) 'cost': cost,
      if (stock != null) 'stock': stock,
      if (minStock != null) 'min_stock': minStock,
      if (categoryId != null) 'category_id': categoryId,
      if (isActive != null) 'is_active': isActive,
    });
  }

  ProductsTableCompanion copyWith({
    Value<String?>? remoteId,
    Value<String>? tenantId,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? id,
    Value<String>? name,
    Value<String?>? sku,
    Value<String?>? barcode,
    Value<double>? price,
    Value<double?>? cost,
    Value<int>? stock,
    Value<int>? minStock,
    Value<int?>? categoryId,
    Value<bool>? isActive,
  }) {
    return ProductsTableCompanion(
      remoteId: remoteId ?? this.remoteId,
      tenantId: tenantId ?? this.tenantId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stock: stock ?? this.stock,
      minStock: minStock ?? this.minStock,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $ProductsTableTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (cost.present) {
      map['cost'] = Variable<double>(cost.value);
    }
    if (stock.present) {
      map['stock'] = Variable<int>(stock.value);
    }
    if (minStock.present) {
      map['min_stock'] = Variable<int>(minStock.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsTableCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('tenantId: $tenantId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sku: $sku, ')
          ..write('barcode: $barcode, ')
          ..write('price: $price, ')
          ..write('cost: $cost, ')
          ..write('stock: $stock, ')
          ..write('minStock: $minStock, ')
          ..write('categoryId: $categoryId, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $SalesTableTable extends SalesTable
    with TableInfo<$SalesTableTable, SalesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($SalesTableTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _saleNumberMeta = const VerificationMeta(
    'saleNumber',
  );
  @override
  late final GeneratedColumn<String> saleNumber = GeneratedColumn<String>(
    'sale_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxMeta = const VerificationMeta('tax');
  @override
  late final GeneratedColumn<double> tax = GeneratedColumn<double>(
    'tax',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('completed'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    tenantId,
    syncStatus,
    createdAt,
    updatedAt,
    id,
    saleNumber,
    subtotal,
    tax,
    total,
    paymentMethod,
    status,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<SalesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sale_number')) {
      context.handle(
        _saleNumberMeta,
        saleNumber.isAcceptableOrUnknown(data['sale_number']!, _saleNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_saleNumberMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('tax')) {
      context.handle(
        _taxMeta,
        tax.isAcceptableOrUnknown(data['tax']!, _taxMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SalesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SalesTableData(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      syncStatus: $SalesTableTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      saleNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sale_number'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      tax: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SalesTableTable createAlias(String alias) {
    return $SalesTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class SalesTableData extends DataClass implements Insertable<SalesTableData> {
  final String? remoteId;
  final String tenantId;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final String saleNumber;
  final double subtotal;
  final double tax;
  final double total;
  final String paymentMethod;
  final String status;
  final String? notes;
  const SalesTableData({
    this.remoteId,
    required this.tenantId,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.saleNumber,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.status,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['tenant_id'] = Variable<String>(tenantId);
    {
      map['sync_status'] = Variable<int>(
        $SalesTableTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<int>(id);
    map['sale_number'] = Variable<String>(saleNumber);
    map['subtotal'] = Variable<double>(subtotal);
    map['tax'] = Variable<double>(tax);
    map['total'] = Variable<double>(total);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SalesTableCompanion toCompanion(bool nullToAbsent) {
    return SalesTableCompanion(
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      tenantId: Value(tenantId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      saleNumber: Value(saleNumber),
      subtotal: Value(subtotal),
      tax: Value(tax),
      total: Value(total),
      paymentMethod: Value(paymentMethod),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory SalesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SalesTableData(
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      syncStatus: $SalesTableTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      saleNumber: serializer.fromJson<String>(json['saleNumber']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      tax: serializer.fromJson<double>(json['tax']),
      total: serializer.fromJson<double>(json['total']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String?>(remoteId),
      'tenantId': serializer.toJson<String>(tenantId),
      'syncStatus': serializer.toJson<int>(
        $SalesTableTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'saleNumber': serializer.toJson<String>(saleNumber),
      'subtotal': serializer.toJson<double>(subtotal),
      'tax': serializer.toJson<double>(tax),
      'total': serializer.toJson<double>(total),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SalesTableData copyWith({
    Value<String?> remoteId = const Value.absent(),
    String? tenantId,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? id,
    String? saleNumber,
    double? subtotal,
    double? tax,
    double? total,
    String? paymentMethod,
    String? status,
    Value<String?> notes = const Value.absent(),
  }) => SalesTableData(
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    tenantId: tenantId ?? this.tenantId,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    saleNumber: saleNumber ?? this.saleNumber,
    subtotal: subtotal ?? this.subtotal,
    tax: tax ?? this.tax,
    total: total ?? this.total,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
  );
  SalesTableData copyWithCompanion(SalesTableCompanion data) {
    return SalesTableData(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      saleNumber: data.saleNumber.present
          ? data.saleNumber.value
          : this.saleNumber,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      tax: data.tax.present ? data.tax.value : this.tax,
      total: data.total.present ? data.total.value : this.total,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SalesTableData(')
          ..write('remoteId: $remoteId, ')
          ..write('tenantId: $tenantId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('saleNumber: $saleNumber, ')
          ..write('subtotal: $subtotal, ')
          ..write('tax: $tax, ')
          ..write('total: $total, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('status: $status, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    tenantId,
    syncStatus,
    createdAt,
    updatedAt,
    id,
    saleNumber,
    subtotal,
    tax,
    total,
    paymentMethod,
    status,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SalesTableData &&
          other.remoteId == this.remoteId &&
          other.tenantId == this.tenantId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.saleNumber == this.saleNumber &&
          other.subtotal == this.subtotal &&
          other.tax == this.tax &&
          other.total == this.total &&
          other.paymentMethod == this.paymentMethod &&
          other.status == this.status &&
          other.notes == this.notes);
}

class SalesTableCompanion extends UpdateCompanion<SalesTableData> {
  final Value<String?> remoteId;
  final Value<String> tenantId;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<String> saleNumber;
  final Value<double> subtotal;
  final Value<double> tax;
  final Value<double> total;
  final Value<String> paymentMethod;
  final Value<String> status;
  final Value<String?> notes;
  const SalesTableCompanion({
    this.remoteId = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.saleNumber = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.tax = const Value.absent(),
    this.total = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SalesTableCompanion.insert({
    this.remoteId = const Value.absent(),
    required String tenantId,
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String saleNumber,
    required double subtotal,
    this.tax = const Value.absent(),
    required double total,
    required String paymentMethod,
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
  }) : tenantId = Value(tenantId),
       saleNumber = Value(saleNumber),
       subtotal = Value(subtotal),
       total = Value(total),
       paymentMethod = Value(paymentMethod);
  static Insertable<SalesTableData> custom({
    Expression<String>? remoteId,
    Expression<String>? tenantId,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<String>? saleNumber,
    Expression<double>? subtotal,
    Expression<double>? tax,
    Expression<double>? total,
    Expression<String>? paymentMethod,
    Expression<String>? status,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (tenantId != null) 'tenant_id': tenantId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (saleNumber != null) 'sale_number': saleNumber,
      if (subtotal != null) 'subtotal': subtotal,
      if (tax != null) 'tax': tax,
      if (total != null) 'total': total,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
    });
  }

  SalesTableCompanion copyWith({
    Value<String?>? remoteId,
    Value<String>? tenantId,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? id,
    Value<String>? saleNumber,
    Value<double>? subtotal,
    Value<double>? tax,
    Value<double>? total,
    Value<String>? paymentMethod,
    Value<String>? status,
    Value<String?>? notes,
  }) {
    return SalesTableCompanion(
      remoteId: remoteId ?? this.remoteId,
      tenantId: tenantId ?? this.tenantId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      saleNumber: saleNumber ?? this.saleNumber,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $SalesTableTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (saleNumber.present) {
      map['sale_number'] = Variable<String>(saleNumber.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (tax.present) {
      map['tax'] = Variable<double>(tax.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesTableCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('tenantId: $tenantId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('saleNumber: $saleNumber, ')
          ..write('subtotal: $subtotal, ')
          ..write('tax: $tax, ')
          ..write('total: $total, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('status: $status, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $SaleItemsTableTable extends SaleItemsTable
    with TableInfo<$SaleItemsTableTable, SaleItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($SaleItemsTableTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<int> saleId = GeneratedColumn<int>(
    'sale_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sales (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    tenantId,
    syncStatus,
    createdAt,
    updatedAt,
    id,
    saleId,
    productId,
    productName,
    unitPrice,
    quantity,
    subtotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sale_id')) {
      context.handle(
        _saleIdMeta,
        saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleItemsTableData(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      syncStatus: $SaleItemsTableTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      saleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sale_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
    );
  }

  @override
  $SaleItemsTableTable createAlias(String alias) {
    return $SaleItemsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class SaleItemsTableData extends DataClass
    implements Insertable<SaleItemsTableData> {
  final String? remoteId;
  final String tenantId;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final int saleId;
  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;
  const SaleItemsTableData({
    this.remoteId,
    required this.tenantId,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['tenant_id'] = Variable<String>(tenantId);
    {
      map['sync_status'] = Variable<int>(
        $SaleItemsTableTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<int>(id);
    map['sale_id'] = Variable<int>(saleId);
    map['product_id'] = Variable<int>(productId);
    map['product_name'] = Variable<String>(productName);
    map['unit_price'] = Variable<double>(unitPrice);
    map['quantity'] = Variable<int>(quantity);
    map['subtotal'] = Variable<double>(subtotal);
    return map;
  }

  SaleItemsTableCompanion toCompanion(bool nullToAbsent) {
    return SaleItemsTableCompanion(
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      tenantId: Value(tenantId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      saleId: Value(saleId),
      productId: Value(productId),
      productName: Value(productName),
      unitPrice: Value(unitPrice),
      quantity: Value(quantity),
      subtotal: Value(subtotal),
    );
  }

  factory SaleItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleItemsTableData(
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      syncStatus: $SaleItemsTableTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      saleId: serializer.fromJson<int>(json['saleId']),
      productId: serializer.fromJson<int>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      quantity: serializer.fromJson<int>(json['quantity']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String?>(remoteId),
      'tenantId': serializer.toJson<String>(tenantId),
      'syncStatus': serializer.toJson<int>(
        $SaleItemsTableTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'saleId': serializer.toJson<int>(saleId),
      'productId': serializer.toJson<int>(productId),
      'productName': serializer.toJson<String>(productName),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'quantity': serializer.toJson<int>(quantity),
      'subtotal': serializer.toJson<double>(subtotal),
    };
  }

  SaleItemsTableData copyWith({
    Value<String?> remoteId = const Value.absent(),
    String? tenantId,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? id,
    int? saleId,
    int? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    double? subtotal,
  }) => SaleItemsTableData(
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    tenantId: tenantId ?? this.tenantId,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    unitPrice: unitPrice ?? this.unitPrice,
    quantity: quantity ?? this.quantity,
    subtotal: subtotal ?? this.subtotal,
  );
  SaleItemsTableData copyWithCompanion(SaleItemsTableCompanion data) {
    return SaleItemsTableData(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemsTableData(')
          ..write('remoteId: $remoteId, ')
          ..write('tenantId: $tenantId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('quantity: $quantity, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    tenantId,
    syncStatus,
    createdAt,
    updatedAt,
    id,
    saleId,
    productId,
    productName,
    unitPrice,
    quantity,
    subtotal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleItemsTableData &&
          other.remoteId == this.remoteId &&
          other.tenantId == this.tenantId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.unitPrice == this.unitPrice &&
          other.quantity == this.quantity &&
          other.subtotal == this.subtotal);
}

class SaleItemsTableCompanion extends UpdateCompanion<SaleItemsTableData> {
  final Value<String?> remoteId;
  final Value<String> tenantId;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<int> saleId;
  final Value<int> productId;
  final Value<String> productName;
  final Value<double> unitPrice;
  final Value<int> quantity;
  final Value<double> subtotal;
  const SaleItemsTableCompanion({
    this.remoteId = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.quantity = const Value.absent(),
    this.subtotal = const Value.absent(),
  });
  SaleItemsTableCompanion.insert({
    this.remoteId = const Value.absent(),
    required String tenantId,
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required int saleId,
    required int productId,
    required String productName,
    required double unitPrice,
    required int quantity,
    required double subtotal,
  }) : tenantId = Value(tenantId),
       saleId = Value(saleId),
       productId = Value(productId),
       productName = Value(productName),
       unitPrice = Value(unitPrice),
       quantity = Value(quantity),
       subtotal = Value(subtotal);
  static Insertable<SaleItemsTableData> custom({
    Expression<String>? remoteId,
    Expression<String>? tenantId,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<int>? saleId,
    Expression<int>? productId,
    Expression<String>? productName,
    Expression<double>? unitPrice,
    Expression<int>? quantity,
    Expression<double>? subtotal,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (tenantId != null) 'tenant_id': tenantId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (quantity != null) 'quantity': quantity,
      if (subtotal != null) 'subtotal': subtotal,
    });
  }

  SaleItemsTableCompanion copyWith({
    Value<String?>? remoteId,
    Value<String>? tenantId,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? id,
    Value<int>? saleId,
    Value<int>? productId,
    Value<String>? productName,
    Value<double>? unitPrice,
    Value<int>? quantity,
    Value<double>? subtotal,
  }) {
    return SaleItemsTableCompanion(
      remoteId: remoteId ?? this.remoteId,
      tenantId: tenantId ?? this.tenantId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $SaleItemsTableTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<int>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemsTableCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('tenantId: $tenantId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('quantity: $quantity, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }
}

class $MesasTableTable extends MesasTable
    with TableInfo<$MesasTableTable, MesasTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MesasTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($MesasTableTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(4),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('available'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    tenantId,
    syncStatus,
    createdAt,
    updatedAt,
    id,
    name,
    capacity,
    status,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mesas_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MesasTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MesasTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MesasTableData(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      syncStatus: $MesasTableTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $MesasTableTable createAlias(String alias) {
    return $MesasTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class MesasTableData extends DataClass implements Insertable<MesasTableData> {
  final String? remoteId;
  final String tenantId;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final String name;
  final int capacity;
  final String status;
  final bool isActive;
  const MesasTableData({
    this.remoteId,
    required this.tenantId,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.name,
    required this.capacity,
    required this.status,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['tenant_id'] = Variable<String>(tenantId);
    {
      map['sync_status'] = Variable<int>(
        $MesasTableTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['capacity'] = Variable<int>(capacity);
    map['status'] = Variable<String>(status);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  MesasTableCompanion toCompanion(bool nullToAbsent) {
    return MesasTableCompanion(
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      tenantId: Value(tenantId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      name: Value(name),
      capacity: Value(capacity),
      status: Value(status),
      isActive: Value(isActive),
    );
  }

  factory MesasTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MesasTableData(
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      syncStatus: $MesasTableTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      capacity: serializer.fromJson<int>(json['capacity']),
      status: serializer.fromJson<String>(json['status']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String?>(remoteId),
      'tenantId': serializer.toJson<String>(tenantId),
      'syncStatus': serializer.toJson<int>(
        $MesasTableTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'capacity': serializer.toJson<int>(capacity),
      'status': serializer.toJson<String>(status),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  MesasTableData copyWith({
    Value<String?> remoteId = const Value.absent(),
    String? tenantId,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? id,
    String? name,
    int? capacity,
    String? status,
    bool? isActive,
  }) => MesasTableData(
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    tenantId: tenantId ?? this.tenantId,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    name: name ?? this.name,
    capacity: capacity ?? this.capacity,
    status: status ?? this.status,
    isActive: isActive ?? this.isActive,
  );
  MesasTableData copyWithCompanion(MesasTableCompanion data) {
    return MesasTableData(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      status: data.status.present ? data.status.value : this.status,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MesasTableData(')
          ..write('remoteId: $remoteId, ')
          ..write('tenantId: $tenantId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('capacity: $capacity, ')
          ..write('status: $status, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    tenantId,
    syncStatus,
    createdAt,
    updatedAt,
    id,
    name,
    capacity,
    status,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MesasTableData &&
          other.remoteId == this.remoteId &&
          other.tenantId == this.tenantId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.name == this.name &&
          other.capacity == this.capacity &&
          other.status == this.status &&
          other.isActive == this.isActive);
}

class MesasTableCompanion extends UpdateCompanion<MesasTableData> {
  final Value<String?> remoteId;
  final Value<String> tenantId;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<String> name;
  final Value<int> capacity;
  final Value<String> status;
  final Value<bool> isActive;
  const MesasTableCompanion({
    this.remoteId = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.capacity = const Value.absent(),
    this.status = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  MesasTableCompanion.insert({
    this.remoteId = const Value.absent(),
    required String tenantId,
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required String name,
    this.capacity = const Value.absent(),
    this.status = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : tenantId = Value(tenantId),
       name = Value(name);
  static Insertable<MesasTableData> custom({
    Expression<String>? remoteId,
    Expression<String>? tenantId,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? capacity,
    Expression<String>? status,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (tenantId != null) 'tenant_id': tenantId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (capacity != null) 'capacity': capacity,
      if (status != null) 'status': status,
      if (isActive != null) 'is_active': isActive,
    });
  }

  MesasTableCompanion copyWith({
    Value<String?>? remoteId,
    Value<String>? tenantId,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? id,
    Value<String>? name,
    Value<int>? capacity,
    Value<String>? status,
    Value<bool>? isActive,
  }) {
    return MesasTableCompanion(
      remoteId: remoteId ?? this.remoteId,
      tenantId: tenantId ?? this.tenantId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $MesasTableTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MesasTableCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('tenantId: $tenantId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('capacity: $capacity, ')
          ..write('status: $status, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $ComandasTableTable extends ComandasTable
    with TableInfo<$ComandasTableTable, ComandasTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComandasTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($ComandasTableTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _localMesaIdMeta = const VerificationMeta(
    'localMesaId',
  );
  @override
  late final GeneratedColumn<int> localMesaId = GeneratedColumn<int>(
    'local_mesa_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mesas_table (id)',
    ),
  );
  static const VerificationMeta _orderNumberMeta = const VerificationMeta(
    'orderNumber',
  );
  @override
  late final GeneratedColumn<String> orderNumber = GeneratedColumn<String>(
    'order_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _waiterIdMeta = const VerificationMeta(
    'waiterId',
  );
  @override
  late final GeneratedColumn<String> waiterId = GeneratedColumn<String>(
    'waiter_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteSaleIdMeta = const VerificationMeta(
    'remoteSaleId',
  );
  @override
  late final GeneratedColumn<String> remoteSaleId = GeneratedColumn<String>(
    'remote_sale_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    tenantId,
    syncStatus,
    createdAt,
    updatedAt,
    id,
    localMesaId,
    orderNumber,
    status,
    waiterId,
    notes,
    openedAt,
    closedAt,
    remoteSaleId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comandas_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ComandasTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_mesa_id')) {
      context.handle(
        _localMesaIdMeta,
        localMesaId.isAcceptableOrUnknown(
          data['local_mesa_id']!,
          _localMesaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localMesaIdMeta);
    }
    if (data.containsKey('order_number')) {
      context.handle(
        _orderNumberMeta,
        orderNumber.isAcceptableOrUnknown(
          data['order_number']!,
          _orderNumberMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('waiter_id')) {
      context.handle(
        _waiterIdMeta,
        waiterId.isAcceptableOrUnknown(data['waiter_id']!, _waiterIdMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    if (data.containsKey('remote_sale_id')) {
      context.handle(
        _remoteSaleIdMeta,
        remoteSaleId.isAcceptableOrUnknown(
          data['remote_sale_id']!,
          _remoteSaleIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ComandasTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ComandasTableData(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      syncStatus: $ComandasTableTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      localMesaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_mesa_id'],
      )!,
      orderNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_number'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      waiterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}waiter_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
      remoteSaleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_sale_id'],
      ),
    );
  }

  @override
  $ComandasTableTable createAlias(String alias) {
    return $ComandasTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class ComandasTableData extends DataClass
    implements Insertable<ComandasTableData> {
  final String? remoteId;
  final String tenantId;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final int localMesaId;
  final String orderNumber;
  final String status;
  final String? waiterId;
  final String? notes;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String? remoteSaleId;
  const ComandasTableData({
    this.remoteId,
    required this.tenantId,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.localMesaId,
    required this.orderNumber,
    required this.status,
    this.waiterId,
    this.notes,
    required this.openedAt,
    this.closedAt,
    this.remoteSaleId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['tenant_id'] = Variable<String>(tenantId);
    {
      map['sync_status'] = Variable<int>(
        $ComandasTableTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<int>(id);
    map['local_mesa_id'] = Variable<int>(localMesaId);
    map['order_number'] = Variable<String>(orderNumber);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || waiterId != null) {
      map['waiter_id'] = Variable<String>(waiterId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    if (!nullToAbsent || remoteSaleId != null) {
      map['remote_sale_id'] = Variable<String>(remoteSaleId);
    }
    return map;
  }

  ComandasTableCompanion toCompanion(bool nullToAbsent) {
    return ComandasTableCompanion(
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      tenantId: Value(tenantId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      localMesaId: Value(localMesaId),
      orderNumber: Value(orderNumber),
      status: Value(status),
      waiterId: waiterId == null && nullToAbsent
          ? const Value.absent()
          : Value(waiterId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      remoteSaleId: remoteSaleId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteSaleId),
    );
  }

  factory ComandasTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ComandasTableData(
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      syncStatus: $ComandasTableTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      localMesaId: serializer.fromJson<int>(json['localMesaId']),
      orderNumber: serializer.fromJson<String>(json['orderNumber']),
      status: serializer.fromJson<String>(json['status']),
      waiterId: serializer.fromJson<String?>(json['waiterId']),
      notes: serializer.fromJson<String?>(json['notes']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      remoteSaleId: serializer.fromJson<String?>(json['remoteSaleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String?>(remoteId),
      'tenantId': serializer.toJson<String>(tenantId),
      'syncStatus': serializer.toJson<int>(
        $ComandasTableTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'localMesaId': serializer.toJson<int>(localMesaId),
      'orderNumber': serializer.toJson<String>(orderNumber),
      'status': serializer.toJson<String>(status),
      'waiterId': serializer.toJson<String?>(waiterId),
      'notes': serializer.toJson<String?>(notes),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'remoteSaleId': serializer.toJson<String?>(remoteSaleId),
    };
  }

  ComandasTableData copyWith({
    Value<String?> remoteId = const Value.absent(),
    String? tenantId,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? id,
    int? localMesaId,
    String? orderNumber,
    String? status,
    Value<String?> waiterId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? openedAt,
    Value<DateTime?> closedAt = const Value.absent(),
    Value<String?> remoteSaleId = const Value.absent(),
  }) => ComandasTableData(
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    tenantId: tenantId ?? this.tenantId,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    localMesaId: localMesaId ?? this.localMesaId,
    orderNumber: orderNumber ?? this.orderNumber,
    status: status ?? this.status,
    waiterId: waiterId.present ? waiterId.value : this.waiterId,
    notes: notes.present ? notes.value : this.notes,
    openedAt: openedAt ?? this.openedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
    remoteSaleId: remoteSaleId.present ? remoteSaleId.value : this.remoteSaleId,
  );
  ComandasTableData copyWithCompanion(ComandasTableCompanion data) {
    return ComandasTableData(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      localMesaId: data.localMesaId.present
          ? data.localMesaId.value
          : this.localMesaId,
      orderNumber: data.orderNumber.present
          ? data.orderNumber.value
          : this.orderNumber,
      status: data.status.present ? data.status.value : this.status,
      waiterId: data.waiterId.present ? data.waiterId.value : this.waiterId,
      notes: data.notes.present ? data.notes.value : this.notes,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      remoteSaleId: data.remoteSaleId.present
          ? data.remoteSaleId.value
          : this.remoteSaleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ComandasTableData(')
          ..write('remoteId: $remoteId, ')
          ..write('tenantId: $tenantId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('localMesaId: $localMesaId, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('status: $status, ')
          ..write('waiterId: $waiterId, ')
          ..write('notes: $notes, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('remoteSaleId: $remoteSaleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    tenantId,
    syncStatus,
    createdAt,
    updatedAt,
    id,
    localMesaId,
    orderNumber,
    status,
    waiterId,
    notes,
    openedAt,
    closedAt,
    remoteSaleId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComandasTableData &&
          other.remoteId == this.remoteId &&
          other.tenantId == this.tenantId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.localMesaId == this.localMesaId &&
          other.orderNumber == this.orderNumber &&
          other.status == this.status &&
          other.waiterId == this.waiterId &&
          other.notes == this.notes &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt &&
          other.remoteSaleId == this.remoteSaleId);
}

class ComandasTableCompanion extends UpdateCompanion<ComandasTableData> {
  final Value<String?> remoteId;
  final Value<String> tenantId;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<int> localMesaId;
  final Value<String> orderNumber;
  final Value<String> status;
  final Value<String?> waiterId;
  final Value<String?> notes;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<String?> remoteSaleId;
  const ComandasTableCompanion({
    this.remoteId = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.localMesaId = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.waiterId = const Value.absent(),
    this.notes = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.remoteSaleId = const Value.absent(),
  });
  ComandasTableCompanion.insert({
    this.remoteId = const Value.absent(),
    required String tenantId,
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required int localMesaId,
    this.orderNumber = const Value.absent(),
    this.status = const Value.absent(),
    this.waiterId = const Value.absent(),
    this.notes = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.remoteSaleId = const Value.absent(),
  }) : tenantId = Value(tenantId),
       localMesaId = Value(localMesaId);
  static Insertable<ComandasTableData> custom({
    Expression<String>? remoteId,
    Expression<String>? tenantId,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<int>? localMesaId,
    Expression<String>? orderNumber,
    Expression<String>? status,
    Expression<String>? waiterId,
    Expression<String>? notes,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<String>? remoteSaleId,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (tenantId != null) 'tenant_id': tenantId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (localMesaId != null) 'local_mesa_id': localMesaId,
      if (orderNumber != null) 'order_number': orderNumber,
      if (status != null) 'status': status,
      if (waiterId != null) 'waiter_id': waiterId,
      if (notes != null) 'notes': notes,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (remoteSaleId != null) 'remote_sale_id': remoteSaleId,
    });
  }

  ComandasTableCompanion copyWith({
    Value<String?>? remoteId,
    Value<String>? tenantId,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? id,
    Value<int>? localMesaId,
    Value<String>? orderNumber,
    Value<String>? status,
    Value<String?>? waiterId,
    Value<String?>? notes,
    Value<DateTime>? openedAt,
    Value<DateTime?>? closedAt,
    Value<String?>? remoteSaleId,
  }) {
    return ComandasTableCompanion(
      remoteId: remoteId ?? this.remoteId,
      tenantId: tenantId ?? this.tenantId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      localMesaId: localMesaId ?? this.localMesaId,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      waiterId: waiterId ?? this.waiterId,
      notes: notes ?? this.notes,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      remoteSaleId: remoteSaleId ?? this.remoteSaleId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $ComandasTableTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localMesaId.present) {
      map['local_mesa_id'] = Variable<int>(localMesaId.value);
    }
    if (orderNumber.present) {
      map['order_number'] = Variable<String>(orderNumber.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (waiterId.present) {
      map['waiter_id'] = Variable<String>(waiterId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (remoteSaleId.present) {
      map['remote_sale_id'] = Variable<String>(remoteSaleId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComandasTableCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('tenantId: $tenantId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('localMesaId: $localMesaId, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('status: $status, ')
          ..write('waiterId: $waiterId, ')
          ..write('notes: $notes, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('remoteSaleId: $remoteSaleId')
          ..write(')'))
        .toString();
  }
}

class $ComandaItemsTableTable extends ComandaItemsTable
    with TableInfo<$ComandaItemsTableTable, ComandaItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ComandaItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, int> syncStatus =
      GeneratedColumn<int>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<SyncStatus>($ComandaItemsTableTable.$convertersyncStatus);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _localComandaIdMeta = const VerificationMeta(
    'localComandaId',
  );
  @override
  late final GeneratedColumn<int> localComandaId = GeneratedColumn<int>(
    'local_comanda_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES comandas_table (id)',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemStatusMeta = const VerificationMeta(
    'itemStatus',
  );
  @override
  late final GeneratedColumn<String> itemStatus = GeneratedColumn<String>(
    'item_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    remoteId,
    tenantId,
    syncStatus,
    createdAt,
    updatedAt,
    id,
    localComandaId,
    productId,
    productName,
    unitPrice,
    quantity,
    subtotal,
    itemStatus,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comanda_items_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<ComandaItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
      );
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('local_comanda_id')) {
      context.handle(
        _localComandaIdMeta,
        localComandaId.isAcceptableOrUnknown(
          data['local_comanda_id']!,
          _localComandaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_localComandaIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('item_status')) {
      context.handle(
        _itemStatusMeta,
        itemStatus.isAcceptableOrUnknown(data['item_status']!, _itemStatusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ComandaItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ComandaItemsTableData(
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
      ),
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      syncStatus: $ComandaItemsTableTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      localComandaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}local_comanda_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      itemStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $ComandaItemsTableTable createAlias(String alias) {
    return $ComandaItemsTableTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, int, int> $convertersyncStatus =
      const EnumIndexConverter<SyncStatus>(SyncStatus.values);
}

class ComandaItemsTableData extends DataClass
    implements Insertable<ComandaItemsTableData> {
  final String? remoteId;
  final String tenantId;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int id;
  final int localComandaId;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;
  final String itemStatus;
  final String? notes;
  const ComandaItemsTableData({
    this.remoteId,
    required this.tenantId,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.id,
    required this.localComandaId,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    required this.itemStatus,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['tenant_id'] = Variable<String>(tenantId);
    {
      map['sync_status'] = Variable<int>(
        $ComandaItemsTableTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['id'] = Variable<int>(id);
    map['local_comanda_id'] = Variable<int>(localComandaId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['unit_price'] = Variable<double>(unitPrice);
    map['quantity'] = Variable<int>(quantity);
    map['subtotal'] = Variable<double>(subtotal);
    map['item_status'] = Variable<String>(itemStatus);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  ComandaItemsTableCompanion toCompanion(bool nullToAbsent) {
    return ComandaItemsTableCompanion(
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      tenantId: Value(tenantId),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      id: Value(id),
      localComandaId: Value(localComandaId),
      productId: Value(productId),
      productName: Value(productName),
      unitPrice: Value(unitPrice),
      quantity: Value(quantity),
      subtotal: Value(subtotal),
      itemStatus: Value(itemStatus),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory ComandaItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ComandaItemsTableData(
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      syncStatus: $ComandaItemsTableTable.$convertersyncStatus.fromJson(
        serializer.fromJson<int>(json['syncStatus']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      id: serializer.fromJson<int>(json['id']),
      localComandaId: serializer.fromJson<int>(json['localComandaId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      quantity: serializer.fromJson<int>(json['quantity']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      itemStatus: serializer.fromJson<String>(json['itemStatus']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'remoteId': serializer.toJson<String?>(remoteId),
      'tenantId': serializer.toJson<String>(tenantId),
      'syncStatus': serializer.toJson<int>(
        $ComandaItemsTableTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'id': serializer.toJson<int>(id),
      'localComandaId': serializer.toJson<int>(localComandaId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'quantity': serializer.toJson<int>(quantity),
      'subtotal': serializer.toJson<double>(subtotal),
      'itemStatus': serializer.toJson<String>(itemStatus),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  ComandaItemsTableData copyWith({
    Value<String?> remoteId = const Value.absent(),
    String? tenantId,
    SyncStatus? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? id,
    int? localComandaId,
    String? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    double? subtotal,
    String? itemStatus,
    Value<String?> notes = const Value.absent(),
  }) => ComandaItemsTableData(
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    tenantId: tenantId ?? this.tenantId,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    id: id ?? this.id,
    localComandaId: localComandaId ?? this.localComandaId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    unitPrice: unitPrice ?? this.unitPrice,
    quantity: quantity ?? this.quantity,
    subtotal: subtotal ?? this.subtotal,
    itemStatus: itemStatus ?? this.itemStatus,
    notes: notes.present ? notes.value : this.notes,
  );
  ComandaItemsTableData copyWithCompanion(ComandaItemsTableCompanion data) {
    return ComandaItemsTableData(
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      id: data.id.present ? data.id.value : this.id,
      localComandaId: data.localComandaId.present
          ? data.localComandaId.value
          : this.localComandaId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      itemStatus: data.itemStatus.present
          ? data.itemStatus.value
          : this.itemStatus,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ComandaItemsTableData(')
          ..write('remoteId: $remoteId, ')
          ..write('tenantId: $tenantId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('localComandaId: $localComandaId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('quantity: $quantity, ')
          ..write('subtotal: $subtotal, ')
          ..write('itemStatus: $itemStatus, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    remoteId,
    tenantId,
    syncStatus,
    createdAt,
    updatedAt,
    id,
    localComandaId,
    productId,
    productName,
    unitPrice,
    quantity,
    subtotal,
    itemStatus,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ComandaItemsTableData &&
          other.remoteId == this.remoteId &&
          other.tenantId == this.tenantId &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.id == this.id &&
          other.localComandaId == this.localComandaId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.unitPrice == this.unitPrice &&
          other.quantity == this.quantity &&
          other.subtotal == this.subtotal &&
          other.itemStatus == this.itemStatus &&
          other.notes == this.notes);
}

class ComandaItemsTableCompanion
    extends UpdateCompanion<ComandaItemsTableData> {
  final Value<String?> remoteId;
  final Value<String> tenantId;
  final Value<SyncStatus> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> id;
  final Value<int> localComandaId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<double> unitPrice;
  final Value<int> quantity;
  final Value<double> subtotal;
  final Value<String> itemStatus;
  final Value<String?> notes;
  const ComandaItemsTableCompanion({
    this.remoteId = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    this.localComandaId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.quantity = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.itemStatus = const Value.absent(),
    this.notes = const Value.absent(),
  });
  ComandaItemsTableCompanion.insert({
    this.remoteId = const Value.absent(),
    required String tenantId,
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.id = const Value.absent(),
    required int localComandaId,
    required String productId,
    required String productName,
    required double unitPrice,
    required int quantity,
    required double subtotal,
    this.itemStatus = const Value.absent(),
    this.notes = const Value.absent(),
  }) : tenantId = Value(tenantId),
       localComandaId = Value(localComandaId),
       productId = Value(productId),
       productName = Value(productName),
       unitPrice = Value(unitPrice),
       quantity = Value(quantity),
       subtotal = Value(subtotal);
  static Insertable<ComandaItemsTableData> custom({
    Expression<String>? remoteId,
    Expression<String>? tenantId,
    Expression<int>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? id,
    Expression<int>? localComandaId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<double>? unitPrice,
    Expression<int>? quantity,
    Expression<double>? subtotal,
    Expression<String>? itemStatus,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (remoteId != null) 'remote_id': remoteId,
      if (tenantId != null) 'tenant_id': tenantId,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (id != null) 'id': id,
      if (localComandaId != null) 'local_comanda_id': localComandaId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (quantity != null) 'quantity': quantity,
      if (subtotal != null) 'subtotal': subtotal,
      if (itemStatus != null) 'item_status': itemStatus,
      if (notes != null) 'notes': notes,
    });
  }

  ComandaItemsTableCompanion copyWith({
    Value<String?>? remoteId,
    Value<String>? tenantId,
    Value<SyncStatus>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? id,
    Value<int>? localComandaId,
    Value<String>? productId,
    Value<String>? productName,
    Value<double>? unitPrice,
    Value<int>? quantity,
    Value<double>? subtotal,
    Value<String>? itemStatus,
    Value<String?>? notes,
  }) {
    return ComandaItemsTableCompanion(
      remoteId: remoteId ?? this.remoteId,
      tenantId: tenantId ?? this.tenantId,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      id: id ?? this.id,
      localComandaId: localComandaId ?? this.localComandaId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
      itemStatus: itemStatus ?? this.itemStatus,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<int>(
        $ComandaItemsTableTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (localComandaId.present) {
      map['local_comanda_id'] = Variable<int>(localComandaId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (itemStatus.present) {
      map['item_status'] = Variable<String>(itemStatus.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ComandaItemsTableCompanion(')
          ..write('remoteId: $remoteId, ')
          ..write('tenantId: $tenantId, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('id: $id, ')
          ..write('localComandaId: $localComandaId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('quantity: $quantity, ')
          ..write('subtotal: $subtotal, ')
          ..write('itemStatus: $itemStatus, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTableTable categoriesTable = $CategoriesTableTable(
    this,
  );
  late final $ProductsTableTable productsTable = $ProductsTableTable(this);
  late final $SalesTableTable salesTable = $SalesTableTable(this);
  late final $SaleItemsTableTable saleItemsTable = $SaleItemsTableTable(this);
  late final $MesasTableTable mesasTable = $MesasTableTable(this);
  late final $ComandasTableTable comandasTable = $ComandasTableTable(this);
  late final $ComandaItemsTableTable comandaItemsTable =
      $ComandaItemsTableTable(this);
  late final ProductsDao productsDao = ProductsDao(this as AppDatabase);
  late final SalesDao salesDao = SalesDao(this as AppDatabase);
  late final GastrobarDao gastrobarDao = GastrobarDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categoriesTable,
    productsTable,
    salesTable,
    saleItemsTable,
    mesasTable,
    comandasTable,
    comandaItemsTable,
  ];
}

typedef $$CategoriesTableTableCreateCompanionBuilder =
    CategoriesTableCompanion Function({
      Value<String?> remoteId,
      required String tenantId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      required String name,
      Value<String?> description,
      Value<bool> isActive,
    });
typedef $$CategoriesTableTableUpdateCompanionBuilder =
    CategoriesTableCompanion Function({
      Value<String?> remoteId,
      Value<String> tenantId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      Value<String> name,
      Value<String?> description,
      Value<bool> isActive,
    });

final class $$CategoriesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CategoriesTableTable,
          CategoriesTableData
        > {
  $$CategoriesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$ProductsTableTable, List<ProductsTableData>>
  _productsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.productsTable,
    aliasName: $_aliasNameGenerator(
      db.categoriesTable.id,
      db.productsTable.categoryId,
    ),
  );

  $$ProductsTableTableProcessedTableManager get productsTableRefs {
    final manager = $$ProductsTableTableTableManager(
      $_db,
      $_db.productsTable,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_productsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> productsTableRefs(
    Expression<bool> Function($$ProductsTableTableFilterComposer f) f,
  ) {
    final $$ProductsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableFilterComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTableTable> {
  $$CategoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> productsTableRefs<T extends Object>(
    Expression<T> Function($$ProductsTableTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTableTable,
          CategoriesTableData,
          $$CategoriesTableTableFilterComposer,
          $$CategoriesTableTableOrderingComposer,
          $$CategoriesTableTableAnnotationComposer,
          $$CategoriesTableTableCreateCompanionBuilder,
          $$CategoriesTableTableUpdateCompanionBuilder,
          (CategoriesTableData, $$CategoriesTableTableReferences),
          CategoriesTableData,
          PrefetchHooks Function({bool productsTableRefs})
        > {
  $$CategoriesTableTableTableManager(
    _$AppDatabase db,
    $CategoriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> remoteId = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => CategoriesTableCompanion(
                remoteId: remoteId,
                tenantId: tenantId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                description: description,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<String?> remoteId = const Value.absent(),
                required String tenantId,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => CategoriesTableCompanion.insert(
                remoteId: remoteId,
                tenantId: tenantId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                description: description,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (productsTableRefs) db.productsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsTableRefs)
                    await $_getPrefetchedData<
                      CategoriesTableData,
                      $CategoriesTableTable,
                      ProductsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriesTableTableReferences
                          ._productsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriesTableTableReferences(
                            db,
                            table,
                            p0,
                          ).productsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.categoryId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTableTable,
      CategoriesTableData,
      $$CategoriesTableTableFilterComposer,
      $$CategoriesTableTableOrderingComposer,
      $$CategoriesTableTableAnnotationComposer,
      $$CategoriesTableTableCreateCompanionBuilder,
      $$CategoriesTableTableUpdateCompanionBuilder,
      (CategoriesTableData, $$CategoriesTableTableReferences),
      CategoriesTableData,
      PrefetchHooks Function({bool productsTableRefs})
    >;
typedef $$ProductsTableTableCreateCompanionBuilder =
    ProductsTableCompanion Function({
      Value<String?> remoteId,
      required String tenantId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      required String name,
      Value<String?> sku,
      Value<String?> barcode,
      required double price,
      Value<double?> cost,
      Value<int> stock,
      Value<int> minStock,
      Value<int?> categoryId,
      Value<bool> isActive,
    });
typedef $$ProductsTableTableUpdateCompanionBuilder =
    ProductsTableCompanion Function({
      Value<String?> remoteId,
      Value<String> tenantId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      Value<String> name,
      Value<String?> sku,
      Value<String?> barcode,
      Value<double> price,
      Value<double?> cost,
      Value<int> stock,
      Value<int> minStock,
      Value<int?> categoryId,
      Value<bool> isActive,
    });

final class $$ProductsTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $ProductsTableTable, ProductsTableData> {
  $$ProductsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTableTable _categoryIdTable(_$AppDatabase db) =>
      db.categoriesTable.createAlias(
        $_aliasNameGenerator(
          db.productsTable.categoryId,
          db.categoriesTable.id,
        ),
      );

  $$CategoriesTableTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableTableManager(
      $_db,
      $_db.categoriesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$SaleItemsTableTable, List<SaleItemsTableData>>
  _saleItemsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItemsTable,
    aliasName: $_aliasNameGenerator(
      db.productsTable.id,
      db.saleItemsTable.productId,
    ),
  );

  $$SaleItemsTableTableProcessedTableManager get saleItemsTableRefs {
    final manager = $$SaleItemsTableTableTableManager(
      $_db,
      $_db.saleItemsTable,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleItemsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minStock => $composableBuilder(
    column: $table.minStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableTableFilterComposer get categoryId {
    final $$CategoriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categoriesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableTableFilterComposer(
            $db: $db,
            $table: $db.categoriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> saleItemsTableRefs(
    Expression<bool> Function($$SaleItemsTableTableFilterComposer f) f,
  ) {
    final $$SaleItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItemsTable,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.saleItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stock => $composableBuilder(
    column: $table.stock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minStock => $composableBuilder(
    column: $table.minStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableTableOrderingComposer get categoryId {
    final $$CategoriesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categoriesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableTableOrderingComposer(
            $db: $db,
            $table: $db.categoriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTableTable> {
  $$ProductsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<int> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<int> get minStock =>
      $composableBuilder(column: $table.minStock, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$CategoriesTableTableAnnotationComposer get categoryId {
    final $$CategoriesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categoriesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.categoriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> saleItemsTableRefs<T extends Object>(
    Expression<T> Function($$SaleItemsTableTableAnnotationComposer a) f,
  ) {
    final $$SaleItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItemsTable,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTableTable,
          ProductsTableData,
          $$ProductsTableTableFilterComposer,
          $$ProductsTableTableOrderingComposer,
          $$ProductsTableTableAnnotationComposer,
          $$ProductsTableTableCreateCompanionBuilder,
          $$ProductsTableTableUpdateCompanionBuilder,
          (ProductsTableData, $$ProductsTableTableReferences),
          ProductsTableData,
          PrefetchHooks Function({bool categoryId, bool saleItemsTableRefs})
        > {
  $$ProductsTableTableTableManager(_$AppDatabase db, $ProductsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> remoteId = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> sku = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<double?> cost = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int> minStock = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => ProductsTableCompanion(
                remoteId: remoteId,
                tenantId: tenantId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                sku: sku,
                barcode: barcode,
                price: price,
                cost: cost,
                stock: stock,
                minStock: minStock,
                categoryId: categoryId,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<String?> remoteId = const Value.absent(),
                required String tenantId,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> sku = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required double price,
                Value<double?> cost = const Value.absent(),
                Value<int> stock = const Value.absent(),
                Value<int> minStock = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => ProductsTableCompanion.insert(
                remoteId: remoteId,
                tenantId: tenantId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                sku: sku,
                barcode: barcode,
                price: price,
                cost: cost,
                stock: stock,
                minStock: minStock,
                categoryId: categoryId,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoryId = false, saleItemsTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (saleItemsTableRefs) db.saleItemsTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$ProductsTableTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$ProductsTableTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (saleItemsTableRefs)
                        await $_getPrefetchedData<
                          ProductsTableData,
                          $ProductsTableTable,
                          SaleItemsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableTableReferences
                              ._saleItemsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableTableReferences(
                                db,
                                table,
                                p0,
                              ).saleItemsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTableTable,
      ProductsTableData,
      $$ProductsTableTableFilterComposer,
      $$ProductsTableTableOrderingComposer,
      $$ProductsTableTableAnnotationComposer,
      $$ProductsTableTableCreateCompanionBuilder,
      $$ProductsTableTableUpdateCompanionBuilder,
      (ProductsTableData, $$ProductsTableTableReferences),
      ProductsTableData,
      PrefetchHooks Function({bool categoryId, bool saleItemsTableRefs})
    >;
typedef $$SalesTableTableCreateCompanionBuilder =
    SalesTableCompanion Function({
      Value<String?> remoteId,
      required String tenantId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      required String saleNumber,
      required double subtotal,
      Value<double> tax,
      required double total,
      required String paymentMethod,
      Value<String> status,
      Value<String?> notes,
    });
typedef $$SalesTableTableUpdateCompanionBuilder =
    SalesTableCompanion Function({
      Value<String?> remoteId,
      Value<String> tenantId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      Value<String> saleNumber,
      Value<double> subtotal,
      Value<double> tax,
      Value<double> total,
      Value<String> paymentMethod,
      Value<String> status,
      Value<String?> notes,
    });

final class $$SalesTableTableReferences
    extends BaseReferences<_$AppDatabase, $SalesTableTable, SalesTableData> {
  $$SalesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SaleItemsTableTable, List<SaleItemsTableData>>
  _saleItemsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.saleItemsTable,
    aliasName: $_aliasNameGenerator(db.salesTable.id, db.saleItemsTable.saleId),
  );

  $$SaleItemsTableTableProcessedTableManager get saleItemsTableRefs {
    final manager = $$SaleItemsTableTableTableManager(
      $_db,
      $_db.saleItemsTable,
    ).filter((f) => f.saleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_saleItemsTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SalesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SalesTableTable> {
  $$SalesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get saleNumber => $composableBuilder(
    column: $table.saleNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tax => $composableBuilder(
    column: $table.tax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> saleItemsTableRefs(
    Expression<bool> Function($$SaleItemsTableTableFilterComposer f) f,
  ) {
    final $$SaleItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItemsTable,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.saleItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTableTable> {
  $$SalesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get saleNumber => $composableBuilder(
    column: $table.saleNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tax => $composableBuilder(
    column: $table.tax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SalesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTableTable> {
  $$SalesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get saleNumber => $composableBuilder(
    column: $table.saleNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get tax =>
      $composableBuilder(column: $table.tax, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> saleItemsTableRefs<T extends Object>(
    Expression<T> Function($$SaleItemsTableTableAnnotationComposer a) f,
  ) {
    final $$SaleItemsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.saleItemsTable,
      getReferencedColumn: (t) => t.saleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SaleItemsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.saleItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SalesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTableTable,
          SalesTableData,
          $$SalesTableTableFilterComposer,
          $$SalesTableTableOrderingComposer,
          $$SalesTableTableAnnotationComposer,
          $$SalesTableTableCreateCompanionBuilder,
          $$SalesTableTableUpdateCompanionBuilder,
          (SalesTableData, $$SalesTableTableReferences),
          SalesTableData,
          PrefetchHooks Function({bool saleItemsTableRefs})
        > {
  $$SalesTableTableTableManager(_$AppDatabase db, $SalesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> remoteId = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> saleNumber = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> tax = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SalesTableCompanion(
                remoteId: remoteId,
                tenantId: tenantId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                saleNumber: saleNumber,
                subtotal: subtotal,
                tax: tax,
                total: total,
                paymentMethod: paymentMethod,
                status: status,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<String?> remoteId = const Value.absent(),
                required String tenantId,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String saleNumber,
                required double subtotal,
                Value<double> tax = const Value.absent(),
                required double total,
                required String paymentMethod,
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => SalesTableCompanion.insert(
                remoteId: remoteId,
                tenantId: tenantId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                saleNumber: saleNumber,
                subtotal: subtotal,
                tax: tax,
                total: total,
                paymentMethod: paymentMethod,
                status: status,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SalesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleItemsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (saleItemsTableRefs) db.saleItemsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (saleItemsTableRefs)
                    await $_getPrefetchedData<
                      SalesTableData,
                      $SalesTableTable,
                      SaleItemsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$SalesTableTableReferences
                          ._saleItemsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SalesTableTableReferences(
                            db,
                            table,
                            p0,
                          ).saleItemsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.saleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SalesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTableTable,
      SalesTableData,
      $$SalesTableTableFilterComposer,
      $$SalesTableTableOrderingComposer,
      $$SalesTableTableAnnotationComposer,
      $$SalesTableTableCreateCompanionBuilder,
      $$SalesTableTableUpdateCompanionBuilder,
      (SalesTableData, $$SalesTableTableReferences),
      SalesTableData,
      PrefetchHooks Function({bool saleItemsTableRefs})
    >;
typedef $$SaleItemsTableTableCreateCompanionBuilder =
    SaleItemsTableCompanion Function({
      Value<String?> remoteId,
      required String tenantId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      required int saleId,
      required int productId,
      required String productName,
      required double unitPrice,
      required int quantity,
      required double subtotal,
    });
typedef $$SaleItemsTableTableUpdateCompanionBuilder =
    SaleItemsTableCompanion Function({
      Value<String?> remoteId,
      Value<String> tenantId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      Value<int> saleId,
      Value<int> productId,
      Value<String> productName,
      Value<double> unitPrice,
      Value<int> quantity,
      Value<double> subtotal,
    });

final class $$SaleItemsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SaleItemsTableTable,
          SaleItemsTableData
        > {
  $$SaleItemsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SalesTableTable _saleIdTable(_$AppDatabase db) =>
      db.salesTable.createAlias(
        $_aliasNameGenerator(db.saleItemsTable.saleId, db.salesTable.id),
      );

  $$SalesTableTableProcessedTableManager get saleId {
    final $_column = $_itemColumn<int>('sale_id')!;

    final manager = $$SalesTableTableTableManager(
      $_db,
      $_db.salesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTableTable _productIdTable(_$AppDatabase db) =>
      db.productsTable.createAlias(
        $_aliasNameGenerator(db.saleItemsTable.productId, db.productsTable.id),
      );

  $$ProductsTableTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableTableManager(
      $_db,
      $_db.productsTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SaleItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SaleItemsTableTable> {
  $$SaleItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  $$SalesTableTableFilterComposer get saleId {
    final $$SalesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableFilterComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableTableFilterComposer get productId {
    final $$ProductsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableFilterComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleItemsTableTable> {
  $$SaleItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  $$SalesTableTableOrderingComposer get saleId {
    final $$SalesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableOrderingComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableTableOrderingComposer get productId {
    final $$ProductsTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableOrderingComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleItemsTableTable> {
  $$SaleItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  $$SalesTableTableAnnotationComposer get saleId {
    final $$SalesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.saleId,
      referencedTable: $db.salesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.salesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableTableAnnotationComposer get productId {
    final $$ProductsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.productsTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.productsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SaleItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleItemsTableTable,
          SaleItemsTableData,
          $$SaleItemsTableTableFilterComposer,
          $$SaleItemsTableTableOrderingComposer,
          $$SaleItemsTableTableAnnotationComposer,
          $$SaleItemsTableTableCreateCompanionBuilder,
          $$SaleItemsTableTableUpdateCompanionBuilder,
          (SaleItemsTableData, $$SaleItemsTableTableReferences),
          SaleItemsTableData,
          PrefetchHooks Function({bool saleId, bool productId})
        > {
  $$SaleItemsTableTableTableManager(
    _$AppDatabase db,
    $SaleItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleItemsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> remoteId = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> saleId = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
              }) => SaleItemsTableCompanion(
                remoteId: remoteId,
                tenantId: tenantId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                saleId: saleId,
                productId: productId,
                productName: productName,
                unitPrice: unitPrice,
                quantity: quantity,
                subtotal: subtotal,
              ),
          createCompanionCallback:
              ({
                Value<String?> remoteId = const Value.absent(),
                required String tenantId,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int saleId,
                required int productId,
                required String productName,
                required double unitPrice,
                required int quantity,
                required double subtotal,
              }) => SaleItemsTableCompanion.insert(
                remoteId: remoteId,
                tenantId: tenantId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                saleId: saleId,
                productId: productId,
                productName: productName,
                unitPrice: unitPrice,
                quantity: quantity,
                subtotal: subtotal,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SaleItemsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({saleId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (saleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.saleId,
                                referencedTable: $$SaleItemsTableTableReferences
                                    ._saleIdTable(db),
                                referencedColumn:
                                    $$SaleItemsTableTableReferences
                                        ._saleIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$SaleItemsTableTableReferences
                                    ._productIdTable(db),
                                referencedColumn:
                                    $$SaleItemsTableTableReferences
                                        ._productIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SaleItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleItemsTableTable,
      SaleItemsTableData,
      $$SaleItemsTableTableFilterComposer,
      $$SaleItemsTableTableOrderingComposer,
      $$SaleItemsTableTableAnnotationComposer,
      $$SaleItemsTableTableCreateCompanionBuilder,
      $$SaleItemsTableTableUpdateCompanionBuilder,
      (SaleItemsTableData, $$SaleItemsTableTableReferences),
      SaleItemsTableData,
      PrefetchHooks Function({bool saleId, bool productId})
    >;
typedef $$MesasTableTableCreateCompanionBuilder =
    MesasTableCompanion Function({
      Value<String?> remoteId,
      required String tenantId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      required String name,
      Value<int> capacity,
      Value<String> status,
      Value<bool> isActive,
    });
typedef $$MesasTableTableUpdateCompanionBuilder =
    MesasTableCompanion Function({
      Value<String?> remoteId,
      Value<String> tenantId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      Value<String> name,
      Value<int> capacity,
      Value<String> status,
      Value<bool> isActive,
    });

final class $$MesasTableTableReferences
    extends BaseReferences<_$AppDatabase, $MesasTableTable, MesasTableData> {
  $$MesasTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ComandasTableTable, List<ComandasTableData>>
  _comandasTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.comandasTable,
    aliasName: $_aliasNameGenerator(
      db.mesasTable.id,
      db.comandasTable.localMesaId,
    ),
  );

  $$ComandasTableTableProcessedTableManager get comandasTableRefs {
    final manager = $$ComandasTableTableTableManager(
      $_db,
      $_db.comandasTable,
    ).filter((f) => f.localMesaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_comandasTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MesasTableTableFilterComposer
    extends Composer<_$AppDatabase, $MesasTableTable> {
  $$MesasTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> comandasTableRefs(
    Expression<bool> Function($$ComandasTableTableFilterComposer f) f,
  ) {
    final $$ComandasTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comandasTable,
      getReferencedColumn: (t) => t.localMesaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComandasTableTableFilterComposer(
            $db: $db,
            $table: $db.comandasTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MesasTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MesasTableTable> {
  $$MesasTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MesasTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MesasTableTable> {
  $$MesasTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  Expression<T> comandasTableRefs<T extends Object>(
    Expression<T> Function($$ComandasTableTableAnnotationComposer a) f,
  ) {
    final $$ComandasTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comandasTable,
      getReferencedColumn: (t) => t.localMesaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComandasTableTableAnnotationComposer(
            $db: $db,
            $table: $db.comandasTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MesasTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MesasTableTable,
          MesasTableData,
          $$MesasTableTableFilterComposer,
          $$MesasTableTableOrderingComposer,
          $$MesasTableTableAnnotationComposer,
          $$MesasTableTableCreateCompanionBuilder,
          $$MesasTableTableUpdateCompanionBuilder,
          (MesasTableData, $$MesasTableTableReferences),
          MesasTableData,
          PrefetchHooks Function({bool comandasTableRefs})
        > {
  $$MesasTableTableTableManager(_$AppDatabase db, $MesasTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MesasTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MesasTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MesasTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> remoteId = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> capacity = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => MesasTableCompanion(
                remoteId: remoteId,
                tenantId: tenantId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                capacity: capacity,
                status: status,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<String?> remoteId = const Value.absent(),
                required String tenantId,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required String name,
                Value<int> capacity = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => MesasTableCompanion.insert(
                remoteId: remoteId,
                tenantId: tenantId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                name: name,
                capacity: capacity,
                status: status,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MesasTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({comandasTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (comandasTableRefs) db.comandasTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (comandasTableRefs)
                    await $_getPrefetchedData<
                      MesasTableData,
                      $MesasTableTable,
                      ComandasTableData
                    >(
                      currentTable: table,
                      referencedTable: $$MesasTableTableReferences
                          ._comandasTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MesasTableTableReferences(
                            db,
                            table,
                            p0,
                          ).comandasTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.localMesaId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MesasTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MesasTableTable,
      MesasTableData,
      $$MesasTableTableFilterComposer,
      $$MesasTableTableOrderingComposer,
      $$MesasTableTableAnnotationComposer,
      $$MesasTableTableCreateCompanionBuilder,
      $$MesasTableTableUpdateCompanionBuilder,
      (MesasTableData, $$MesasTableTableReferences),
      MesasTableData,
      PrefetchHooks Function({bool comandasTableRefs})
    >;
typedef $$ComandasTableTableCreateCompanionBuilder =
    ComandasTableCompanion Function({
      Value<String?> remoteId,
      required String tenantId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      required int localMesaId,
      Value<String> orderNumber,
      Value<String> status,
      Value<String?> waiterId,
      Value<String?> notes,
      Value<DateTime> openedAt,
      Value<DateTime?> closedAt,
      Value<String?> remoteSaleId,
    });
typedef $$ComandasTableTableUpdateCompanionBuilder =
    ComandasTableCompanion Function({
      Value<String?> remoteId,
      Value<String> tenantId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      Value<int> localMesaId,
      Value<String> orderNumber,
      Value<String> status,
      Value<String?> waiterId,
      Value<String?> notes,
      Value<DateTime> openedAt,
      Value<DateTime?> closedAt,
      Value<String?> remoteSaleId,
    });

final class $$ComandasTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $ComandasTableTable, ComandasTableData> {
  $$ComandasTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MesasTableTable _localMesaIdTable(_$AppDatabase db) =>
      db.mesasTable.createAlias(
        $_aliasNameGenerator(db.comandasTable.localMesaId, db.mesasTable.id),
      );

  $$MesasTableTableProcessedTableManager get localMesaId {
    final $_column = $_itemColumn<int>('local_mesa_id')!;

    final manager = $$MesasTableTableTableManager(
      $_db,
      $_db.mesasTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_localMesaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ComandaItemsTableTable,
    List<ComandaItemsTableData>
  >
  _comandaItemsTableRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.comandaItemsTable,
        aliasName: $_aliasNameGenerator(
          db.comandasTable.id,
          db.comandaItemsTable.localComandaId,
        ),
      );

  $$ComandaItemsTableTableProcessedTableManager get comandaItemsTableRefs {
    final manager = $$ComandaItemsTableTableTableManager(
      $_db,
      $_db.comandaItemsTable,
    ).filter((f) => f.localComandaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _comandaItemsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ComandasTableTableFilterComposer
    extends Composer<_$AppDatabase, $ComandasTableTable> {
  $$ComandasTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get waiterId => $composableBuilder(
    column: $table.waiterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteSaleId => $composableBuilder(
    column: $table.remoteSaleId,
    builder: (column) => ColumnFilters(column),
  );

  $$MesasTableTableFilterComposer get localMesaId {
    final $$MesasTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localMesaId,
      referencedTable: $db.mesasTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MesasTableTableFilterComposer(
            $db: $db,
            $table: $db.mesasTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> comandaItemsTableRefs(
    Expression<bool> Function($$ComandaItemsTableTableFilterComposer f) f,
  ) {
    final $$ComandaItemsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.comandaItemsTable,
      getReferencedColumn: (t) => t.localComandaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComandaItemsTableTableFilterComposer(
            $db: $db,
            $table: $db.comandaItemsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ComandasTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ComandasTableTable> {
  $$ComandasTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get waiterId => $composableBuilder(
    column: $table.waiterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteSaleId => $composableBuilder(
    column: $table.remoteSaleId,
    builder: (column) => ColumnOrderings(column),
  );

  $$MesasTableTableOrderingComposer get localMesaId {
    final $$MesasTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localMesaId,
      referencedTable: $db.mesasTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MesasTableTableOrderingComposer(
            $db: $db,
            $table: $db.mesasTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComandasTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComandasTableTable> {
  $$ComandasTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get waiterId =>
      $composableBuilder(column: $table.waiterId, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get remoteSaleId => $composableBuilder(
    column: $table.remoteSaleId,
    builder: (column) => column,
  );

  $$MesasTableTableAnnotationComposer get localMesaId {
    final $$MesasTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localMesaId,
      referencedTable: $db.mesasTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MesasTableTableAnnotationComposer(
            $db: $db,
            $table: $db.mesasTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> comandaItemsTableRefs<T extends Object>(
    Expression<T> Function($$ComandaItemsTableTableAnnotationComposer a) f,
  ) {
    final $$ComandaItemsTableTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.comandaItemsTable,
          getReferencedColumn: (t) => t.localComandaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ComandaItemsTableTableAnnotationComposer(
                $db: $db,
                $table: $db.comandaItemsTable,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ComandasTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComandasTableTable,
          ComandasTableData,
          $$ComandasTableTableFilterComposer,
          $$ComandasTableTableOrderingComposer,
          $$ComandasTableTableAnnotationComposer,
          $$ComandasTableTableCreateCompanionBuilder,
          $$ComandasTableTableUpdateCompanionBuilder,
          (ComandasTableData, $$ComandasTableTableReferences),
          ComandasTableData,
          PrefetchHooks Function({bool localMesaId, bool comandaItemsTableRefs})
        > {
  $$ComandasTableTableTableManager(_$AppDatabase db, $ComandasTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComandasTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComandasTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComandasTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> remoteId = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> localMesaId = const Value.absent(),
                Value<String> orderNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> waiterId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<String?> remoteSaleId = const Value.absent(),
              }) => ComandasTableCompanion(
                remoteId: remoteId,
                tenantId: tenantId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                localMesaId: localMesaId,
                orderNumber: orderNumber,
                status: status,
                waiterId: waiterId,
                notes: notes,
                openedAt: openedAt,
                closedAt: closedAt,
                remoteSaleId: remoteSaleId,
              ),
          createCompanionCallback:
              ({
                Value<String?> remoteId = const Value.absent(),
                required String tenantId,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int localMesaId,
                Value<String> orderNumber = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> waiterId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<String?> remoteSaleId = const Value.absent(),
              }) => ComandasTableCompanion.insert(
                remoteId: remoteId,
                tenantId: tenantId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                localMesaId: localMesaId,
                orderNumber: orderNumber,
                status: status,
                waiterId: waiterId,
                notes: notes,
                openedAt: openedAt,
                closedAt: closedAt,
                remoteSaleId: remoteSaleId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ComandasTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({localMesaId = false, comandaItemsTableRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (comandaItemsTableRefs) db.comandaItemsTable,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (localMesaId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.localMesaId,
                                    referencedTable:
                                        $$ComandasTableTableReferences
                                            ._localMesaIdTable(db),
                                    referencedColumn:
                                        $$ComandasTableTableReferences
                                            ._localMesaIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (comandaItemsTableRefs)
                        await $_getPrefetchedData<
                          ComandasTableData,
                          $ComandasTableTable,
                          ComandaItemsTableData
                        >(
                          currentTable: table,
                          referencedTable: $$ComandasTableTableReferences
                              ._comandaItemsTableRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ComandasTableTableReferences(
                                db,
                                table,
                                p0,
                              ).comandaItemsTableRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.localComandaId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ComandasTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComandasTableTable,
      ComandasTableData,
      $$ComandasTableTableFilterComposer,
      $$ComandasTableTableOrderingComposer,
      $$ComandasTableTableAnnotationComposer,
      $$ComandasTableTableCreateCompanionBuilder,
      $$ComandasTableTableUpdateCompanionBuilder,
      (ComandasTableData, $$ComandasTableTableReferences),
      ComandasTableData,
      PrefetchHooks Function({bool localMesaId, bool comandaItemsTableRefs})
    >;
typedef $$ComandaItemsTableTableCreateCompanionBuilder =
    ComandaItemsTableCompanion Function({
      Value<String?> remoteId,
      required String tenantId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      required int localComandaId,
      required String productId,
      required String productName,
      required double unitPrice,
      required int quantity,
      required double subtotal,
      Value<String> itemStatus,
      Value<String?> notes,
    });
typedef $$ComandaItemsTableTableUpdateCompanionBuilder =
    ComandaItemsTableCompanion Function({
      Value<String?> remoteId,
      Value<String> tenantId,
      Value<SyncStatus> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> id,
      Value<int> localComandaId,
      Value<String> productId,
      Value<String> productName,
      Value<double> unitPrice,
      Value<int> quantity,
      Value<double> subtotal,
      Value<String> itemStatus,
      Value<String?> notes,
    });

final class $$ComandaItemsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ComandaItemsTableTable,
          ComandaItemsTableData
        > {
  $$ComandaItemsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ComandasTableTable _localComandaIdTable(_$AppDatabase db) =>
      db.comandasTable.createAlias(
        $_aliasNameGenerator(
          db.comandaItemsTable.localComandaId,
          db.comandasTable.id,
        ),
      );

  $$ComandasTableTableProcessedTableManager get localComandaId {
    final $_column = $_itemColumn<int>('local_comanda_id')!;

    final manager = $$ComandasTableTableTableManager(
      $_db,
      $_db.comandasTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_localComandaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ComandaItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ComandaItemsTableTable> {
  $$ComandaItemsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemStatus => $composableBuilder(
    column: $table.itemStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$ComandasTableTableFilterComposer get localComandaId {
    final $$ComandasTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localComandaId,
      referencedTable: $db.comandasTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComandasTableTableFilterComposer(
            $db: $db,
            $table: $db.comandasTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComandaItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ComandaItemsTableTable> {
  $$ComandaItemsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemStatus => $composableBuilder(
    column: $table.itemStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ComandasTableTableOrderingComposer get localComandaId {
    final $$ComandasTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localComandaId,
      referencedTable: $db.comandasTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComandasTableTableOrderingComposer(
            $db: $db,
            $table: $db.comandasTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComandaItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ComandaItemsTableTable> {
  $$ComandaItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, int> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<String> get itemStatus => $composableBuilder(
    column: $table.itemStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$ComandasTableTableAnnotationComposer get localComandaId {
    final $$ComandasTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.localComandaId,
      referencedTable: $db.comandasTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ComandasTableTableAnnotationComposer(
            $db: $db,
            $table: $db.comandasTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ComandaItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ComandaItemsTableTable,
          ComandaItemsTableData,
          $$ComandaItemsTableTableFilterComposer,
          $$ComandaItemsTableTableOrderingComposer,
          $$ComandaItemsTableTableAnnotationComposer,
          $$ComandaItemsTableTableCreateCompanionBuilder,
          $$ComandaItemsTableTableUpdateCompanionBuilder,
          (ComandaItemsTableData, $$ComandaItemsTableTableReferences),
          ComandaItemsTableData,
          PrefetchHooks Function({bool localComandaId})
        > {
  $$ComandaItemsTableTableTableManager(
    _$AppDatabase db,
    $ComandaItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ComandaItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ComandaItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ComandaItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String?> remoteId = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                Value<int> localComandaId = const Value.absent(),
                Value<String> productId = const Value.absent(),
                Value<String> productName = const Value.absent(),
                Value<double> unitPrice = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<String> itemStatus = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ComandaItemsTableCompanion(
                remoteId: remoteId,
                tenantId: tenantId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                localComandaId: localComandaId,
                productId: productId,
                productName: productName,
                unitPrice: unitPrice,
                quantity: quantity,
                subtotal: subtotal,
                itemStatus: itemStatus,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<String?> remoteId = const Value.absent(),
                required String tenantId,
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> id = const Value.absent(),
                required int localComandaId,
                required String productId,
                required String productName,
                required double unitPrice,
                required int quantity,
                required double subtotal,
                Value<String> itemStatus = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => ComandaItemsTableCompanion.insert(
                remoteId: remoteId,
                tenantId: tenantId,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                id: id,
                localComandaId: localComandaId,
                productId: productId,
                productName: productName,
                unitPrice: unitPrice,
                quantity: quantity,
                subtotal: subtotal,
                itemStatus: itemStatus,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ComandaItemsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localComandaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (localComandaId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.localComandaId,
                                referencedTable:
                                    $$ComandaItemsTableTableReferences
                                        ._localComandaIdTable(db),
                                referencedColumn:
                                    $$ComandaItemsTableTableReferences
                                        ._localComandaIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ComandaItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ComandaItemsTableTable,
      ComandaItemsTableData,
      $$ComandaItemsTableTableFilterComposer,
      $$ComandaItemsTableTableOrderingComposer,
      $$ComandaItemsTableTableAnnotationComposer,
      $$ComandaItemsTableTableCreateCompanionBuilder,
      $$ComandaItemsTableTableUpdateCompanionBuilder,
      (ComandaItemsTableData, $$ComandaItemsTableTableReferences),
      ComandaItemsTableData,
      PrefetchHooks Function({bool localComandaId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableTableManager get categoriesTable =>
      $$CategoriesTableTableTableManager(_db, _db.categoriesTable);
  $$ProductsTableTableTableManager get productsTable =>
      $$ProductsTableTableTableManager(_db, _db.productsTable);
  $$SalesTableTableTableManager get salesTable =>
      $$SalesTableTableTableManager(_db, _db.salesTable);
  $$SaleItemsTableTableTableManager get saleItemsTable =>
      $$SaleItemsTableTableTableManager(_db, _db.saleItemsTable);
  $$MesasTableTableTableManager get mesasTable =>
      $$MesasTableTableTableManager(_db, _db.mesasTable);
  $$ComandasTableTableTableManager get comandasTable =>
      $$ComandasTableTableTableManager(_db, _db.comandasTable);
  $$ComandaItemsTableTableTableManager get comandaItemsTable =>
      $$ComandaItemsTableTableTableManager(_db, _db.comandaItemsTable);
}
