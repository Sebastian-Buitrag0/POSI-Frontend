# Spec 011-D — Pull inicial de productos (Flutter)

## Objetivo
Cuando el usuario sincroniza, primero descargar los productos del backend (`GET /api/products`)
y upsertearlos en Drift local. Así, si reinstala el app o usa un dispositivo nuevo,
los datos del servidor se restauran automáticamente.

## Infraestructura existente
- `ProductsDao.upsertProduct(companion)` — hace `insertOnConflictUpdate` por primary key local
- `ProductsDao.getByRemoteId()` — NO EXISTE todavía, hay que crearlo
- `SyncService.sync(tenantId)` — actualmente solo hace push (products + sales)
- `ApiConstants` — hay que agregar `products = '/api/products'`
- `ProductsTableCompanion` — `remoteId, tenantId, name, sku, barcode, price, cost, stock, minStock, isActive, syncStatus, updatedAt`
- `SyncStatus.synced` — valor para marcar como sincronizado desde servidor

## Lógica del pull
1. `GET /api/products` → lista de productos del tenant (con `id` como remoteId)
2. Por cada producto del servidor:
   - Si ya existe localmente con ese `remoteId` → **skip** (no sobreescribir cambios locales pendientes)
   - Si no existe → insertar con `syncStatus = SyncStatus.synced`
3. El pull ocurre **antes** del push en `SyncService.sync()`

---

## Task 11-D.0 — Agregar constante a ApiConstants

En `lib/core/constants/api_constants.dart`, agregar después de `profile`:

```dart
  // Products
  static const String products = '/api/products';
```

---

## Task 11-D.1 — Agregar getByRemoteId a ProductsDao

En `lib/features/products/data/daos/products_dao.dart`, agregar después de `getByBarcode`:

```dart
Future<ProductsTableData?> getByRemoteId(String remoteId, String tenantId) =>
    (select(productsTable)
          ..where((t) =>
              t.remoteId.equals(remoteId) & t.tenantId.equals(tenantId)))
        .getSingleOrNull();
```

**No requiere build_runner** — es un método plain.

---

## Task 11-D.2 — Agregar _pullProducts a SyncService y llamarlo primero

En `lib/core/services/sync_service.dart`:

1. Modificar el método `sync()` para llamar pull antes de push:

```dart
Future<SyncResult> sync(String tenantId) async {
  await _pullProducts(tenantId);
  final productsSynced = await _syncProducts(tenantId);
  final salesSynced = await _syncSales(tenantId);
  return SyncResult(productsSynced: productsSynced, salesSynced: salesSynced);
}
```

2. Agregar el método `_pullProducts` antes de `_syncProducts`:

```dart
Future<void> _pullProducts(String tenantId) async {
  final response = await api.get(ApiConstants.products);
  final list = (response.data as List).cast<Map<String, dynamic>>();

  for (final p in list) {
    final remoteId = p['id'] as String;
    final existing = await productsDao.getByRemoteId(remoteId, tenantId);
    if (existing != null) continue; // no sobreescribir cambios locales

    await productsDao.upsertProduct(ProductsTableCompanion(
      remoteId: Value(remoteId),
      tenantId: Value(tenantId),
      name: Value(p['name'] as String),
      sku: Value(p['sku'] as String?),
      barcode: Value(p['barcode'] as String?),
      price: Value((p['price'] as num).toDouble()),
      cost: Value((p['cost'] as num?)?.toDouble()),
      stock: Value(p['stock'] as int),
      minStock: Value(p['minStock'] as int),
      isActive: Value(p['isActive'] as bool),
      syncStatus: Value(SyncStatus.synced),
      updatedAt: Value(DateTime.parse(p['updatedAt'] as String).toLocal()),
    ));
  }
}
```

3. Agregar los imports necesarios al inicio del archivo:

```dart
import 'package:drift/drift.dart';
import '../database/tables/products_table.dart';
import '../database/sync_mixin.dart';
```

---

## Task 11-D.3 — Validación

```bash
cd /Users/sebastian-buitrago/Documents/Yo/POSI/POSI-Frontend
fvm flutter analyze
```

**0 errores.**

---

## Archivos a modificar
```
lib/core/constants/api_constants.dart                       ← Task 11-D.0
lib/features/products/data/daos/products_dao.dart           ← Task 11-D.1
lib/core/services/sync_service.dart                         ← Task 11-D.2
```

## IMPORTANTE — No hacer
- NO ejecutar build_runner
- NO modificar tablas Drift
- NO sobreescribir productos con syncStatus=pending (el `if existing != null continue` protege esto)
- El `api.get()` ya adjunta el JWT automáticamente via el interceptor de ApiClient
- `ProductsTableCompanion` no tiene campo `id` (autoincrement) ni `createdAt` (tiene default)
