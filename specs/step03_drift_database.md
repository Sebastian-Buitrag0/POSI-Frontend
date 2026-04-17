# SPEC: Base de Datos Drift (Paso 3)

## Contexto
Flutter 3.24, Drift 2.20, Riverpod 2.6, proyecto POSI (POS + Inventario, offline-first, multi-tenant SaaS).
Directorio raíz del proyecto: `/Users/sebastian-buitrago/Documents/Yo/POSI/POSI-Frontend`
Todo el código va dentro de `lib/`.

## Regla de oro para TODAS las tablas
Cada tabla DEBE tener estas columnas obligatorias:
```dart
IntColumn get id => integer().autoIncrement()();
TextColumn get remoteId => text().nullable().named('remote_id')();
TextColumn get tenantId => text().named('tenant_id')();
IntColumn get syncStatus => intEnum<SyncStatus>().named('sync_status').withDefault(Constant(0))();
DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();
DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();
```

## SyncStatus enum
```dart
enum SyncStatus { pending, synced, conflict }
```

---

## TASK 1 — Enum + Mixin de columnas sync

**Archivo:** `lib/core/database/sync_mixin.dart`

```dart
import 'package:drift/drift.dart';

enum SyncStatus { pending, synced, conflict }

mixin SyncColumns on Table {
  TextColumn get remoteId => text().nullable().named('remote_id')();
  TextColumn get tenantId => text().named('tenant_id')();
  IntColumn get syncStatus =>
      intEnum<SyncStatus>().named('sync_status').withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
}
```

**Validación:** archivo existe, compila sin errores (`flutter analyze`).

---

## TASK 2 — Tablas Drift

Crear los 4 archivos siguientes en `lib/core/database/tables/`:

### `categories_table.dart`
```dart
import 'package:drift/drift.dart';
import '../sync_mixin.dart';

class CategoriesTable extends Table with SyncColumns {
  @override
  String get tableName => 'categories';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().named('is_active').withDefault(const Constant(true))();
}
```

### `products_table.dart`
```dart
import 'package:drift/drift.dart';
import '../sync_mixin.dart';
import 'categories_table.dart';

class ProductsTable extends Table with SyncColumns {
  @override
  String get tableName => 'products';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get sku => text().nullable()();
  TextColumn get barcode => text().nullable()();
  RealColumn get price => real()();
  RealColumn get cost => real().nullable()();
  IntColumn get stock => integer().withDefault(const Constant(0))();
  IntColumn get minStock => integer().named('min_stock').withDefault(const Constant(0))();
  IntColumn get categoryId => integer().named('category_id').nullable().references(CategoriesTable, #id)();
  BoolColumn get isActive => boolean().named('is_active').withDefault(const Constant(true))();
}
```

### `sales_table.dart`
```dart
import 'package:drift/drift.dart';
import '../sync_mixin.dart';

class SalesTable extends Table with SyncColumns {
  @override
  String get tableName => 'sales';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get saleNumber => text().named('sale_number')();
  RealColumn get subtotal => real()();
  RealColumn get tax => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  TextColumn get paymentMethod => text().named('payment_method')();
  TextColumn get status => text().withDefault(const Constant('completed'))();
  TextColumn get notes => text().nullable()();
}
```

### `sale_items_table.dart`
```dart
import 'package:drift/drift.dart';
import '../sync_mixin.dart';
import 'sales_table.dart';
import 'products_table.dart';

class SaleItemsTable extends Table with SyncColumns {
  @override
  String get tableName => 'sale_items';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get saleId => integer().named('sale_id').references(SalesTable, #id)();
  IntColumn get productId => integer().named('product_id').references(ProductsTable, #id)();
  TextColumn get productName => text().named('product_name')();
  RealColumn get unitPrice => real().named('unit_price')();
  IntColumn get quantity => integer()();
  RealColumn get subtotal => real()();
}
```

**Validación:** los 4 archivos existen en `lib/core/database/tables/`.

---

## TASK 3 — Database class + provider Riverpod

### `lib/core/database/app_database.dart`
```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/categories_table.dart';
import 'tables/products_table.dart';
import 'tables/sales_table.dart';
import 'tables/sale_items_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  CategoriesTable,
  ProductsTable,
  SalesTable,
  SaleItemsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'posi.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
```

### `lib/core/database/database_provider.dart`
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
```

**Validación:** ambos archivos existen.

---

## TASK 4 — Generar código Drift + verificar

Ejecutar en orden dentro del directorio del proyecto:

```bash
cd /Users/sebastian-buitrago/Documents/Yo/POSI/POSI-Frontend
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

**Output esperado:**
- `lib/core/database/app_database.g.dart` generado sin errores
- `flutter analyze` sin errores (warnings de estilo son aceptables)

---

## Estructura final esperada
```
lib/
  core/
    database/
      sync_mixin.dart
      app_database.dart
      app_database.g.dart      ← generado
      database_provider.dart
      tables/
        categories_table.dart
        products_table.dart
        sales_table.dart
        sale_items_table.dart
```
