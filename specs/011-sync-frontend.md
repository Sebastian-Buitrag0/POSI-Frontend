# Spec 011-B — Sync Service (Frontend)

## Objetivo
Sincronizar automáticamente los datos offline (productos y ventas con `syncStatus == pending`)
con el backend cuando hay conectividad. Los endpoints ya existen (ver spec 011-A del backend).

## Infraestructura existente
- `ProductsDao` — ya tiene `getPendingSync(tenantId)`, le falta `markSynced()`
- `SalesDao` — le faltan AMBOS: `getPendingSync()` y `markSynced()`
- `ApiClient` — `post(path, data)` con JWT auto-adjunto
- `authProvider` — `AuthAuthenticated(user)` contiene `user.tenantId`
- `SyncStatus` enum en `sync_mixin.dart`: `pending=0, synced=1, conflict=2`
- connectivity_plus v6: `Connectivity().onConnectivityChanged` → `Stream<List<ConnectivityResult>>`

---

## Task 11.0 — Agregar métodos faltantes a los DAOs

**No requiere build_runner** (solo se agregan métodos plain a clases existentes).

### `lib/features/products/data/daos/products_dao.dart`

Agregar al final de la clase `ProductsDao`, después de `decreaseStock`:

```dart
Future<void> markSynced(int localId, String remoteId) =>
    (update(productsTable)..where((t) => t.id.equals(localId))).write(
      ProductsTableCompanion(
        remoteId: Value(remoteId),
        syncStatus: Value(SyncStatus.synced.index),
      ),
    );
```

### `lib/features/sales/data/daos/sales_dao.dart`

Agregar al final de la clase `SalesDao`:

```dart
Future<List<SalesTableData>> getPendingSync(String tenantId) =>
    (select(salesTable)
          ..where((t) =>
              t.tenantId.equals(tenantId) &
              t.syncStatus.equals(SyncStatus.pending.index)))
        .get();

Future<void> markSynced(int localId, String remoteId) =>
    (update(salesTable)..where((t) => t.id.equals(localId))).write(
      SalesTableCompanion(
        remoteId: Value(remoteId),
        syncStatus: Value(SyncStatus.synced.index),
      ),
    );
```

---

## Task 11.1 — Agregar constantes de sync a ApiConstants

### `lib/core/constants/api_constants.dart`

Agregar después de la línea de `profile`:

```dart
  // Sync
  static const String productsSync = '/api/products/sync';
  static const String salesSync = '/api/sales/sync';
```

---

## Task 11.2 — SyncService

### `lib/core/services/sync_service.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import '../services/api_client.dart';
import '../../features/products/data/daos/products_dao.dart';
import '../../features/sales/data/daos/sales_dao.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  final db = ref.watch(databaseProvider);
  final api = ref.watch(apiClientProvider);
  return SyncService(
    productsDao: db.productsDao,
    salesDao: db.salesDao,
    api: api,
  );
});

class SyncResult {
  const SyncResult({
    required this.productsSynced,
    required this.salesSynced,
  });
  final int productsSynced;
  final int salesSynced;
}

class SyncService {
  SyncService({
    required this.productsDao,
    required this.salesDao,
    required this.api,
  });

  final ProductsDao productsDao;
  final SalesDao salesDao;
  final ApiClient api;

  Future<SyncResult> sync(String tenantId) async {
    final productsSynced = await _syncProducts(tenantId);
    final salesSynced = await _syncSales(tenantId);
    return SyncResult(productsSynced: productsSynced, salesSynced: salesSynced);
  }

  Future<int> _syncProducts(String tenantId) async {
    final pending = await productsDao.getPendingSync(tenantId);
    if (pending.isEmpty) return 0;

    final response = await api.post(
      ApiConstants.productsSync,
      data: {
        'products': pending.map((p) => {
          'localId': p.id,
          'name': p.name,
          'sku': p.sku,
          'barcode': p.barcode,
          'price': p.price,
          'cost': p.cost,
          'stock': p.stock,
          'minStock': p.minStock,
          'isActive': p.isActive,
          'createdAt': p.createdAt.toUtc().toIso8601String(),
          'updatedAt': p.updatedAt.toUtc().toIso8601String(),
        }).toList(),
      },
    );

    final mappings = (response.data['mappings'] as List)
        .cast<Map<String, dynamic>>();
    for (final m in mappings) {
      await productsDao.markSynced(
        m['localId'] as int,
        m['remoteId'] as String,
      );
    }
    return response.data['synced'] as int;
  }

  Future<int> _syncSales(String tenantId) async {
    final pending = await salesDao.getPendingSync(tenantId);
    if (pending.isEmpty) return 0;

    final salesPayload = <Map<String, dynamic>>[];

    for (final sale in pending) {
      final items = await salesDao.getItemsBySaleId(sale.id);
      salesPayload.add({
        'localId': sale.id,
        'saleNumber': sale.saleNumber,
        'subtotal': sale.subtotal,
        'tax': sale.tax,
        'total': sale.total,
        'paymentMethod': sale.paymentMethod,
        'status': sale.status,
        'notes': sale.notes,
        'createdAt': sale.createdAt.toUtc().toIso8601String(),
        'items': items.map((i) => {
          'productName': i.productName,
          'unitPrice': i.unitPrice,
          'quantity': i.quantity,
          'subtotal': i.subtotal,
        }).toList(),
      });
    }

    final response = await api.post(
      ApiConstants.salesSync,
      data: {'sales': salesPayload},
    );

    final mappings = (response.data['mappings'] as List)
        .cast<Map<String, dynamic>>();
    for (final m in mappings) {
      await salesDao.markSynced(
        m['localId'] as int,
        m['remoteId'] as String,
      );
    }
    return response.data['synced'] as int;
  }
}
```

---

## Task 11.3 — SyncProvider

### `lib/core/providers/sync_provider.dart`

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

class SyncState {
  const SyncState({
    this.isSyncing = false,
    this.lastSyncAt,
    this.error,
  });

  final bool isSyncing;
  final DateTime? lastSyncAt;
  final String? error;

  SyncState copyWith({
    bool? isSyncing,
    DateTime? lastSyncAt,
    String? error,
  }) =>
      SyncState(
        isSyncing: isSyncing ?? this.isSyncing,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        error: error,
      );
}

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  return SyncNotifier(ref);
});

class SyncNotifier extends StateNotifier<SyncState> {
  SyncNotifier(this._ref) : super(const SyncState()) {
    _listenConnectivity();
  }

  final Ref _ref;

  void _listenConnectivity() {
    Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) {
        syncNow();
      }
    });
  }

  Future<void> syncNow() async {
    if (state.isSyncing) return;

    final authState = _ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;

    state = state.copyWith(isSyncing: true, error: null);
    try {
      final service = _ref.read(syncServiceProvider);
      await service.sync(authState.user.tenantId);
      state = state.copyWith(isSyncing: false, lastSyncAt: DateTime.now());
    } catch (e) {
      state = state.copyWith(isSyncing: false, error: e.toString());
    }
  }
}
```

---

## Task 11.4 — Validación frontend

```bash
cd /Users/sebastian-buitrago/Documents/Yo/POSI/POSI-Frontend
flutter analyze
```

**0 errores.**

---

## Archivos a modificar
```
lib/features/products/data/daos/products_dao.dart   ← agregar markSynced()
lib/features/sales/data/daos/sales_dao.dart          ← agregar getPendingSync() + markSynced()
lib/core/constants/api_constants.dart               ← agregar productsSync + salesSync
```

## Archivos a crear
```
lib/core/services/sync_service.dart    ← Task 11.2
lib/core/providers/sync_provider.dart  ← Task 11.3
```

## IMPORTANTE — No hacer
- NO ejecutar build_runner (los cambios son métodos plain, no nuevas tablas ni @DriftAccessor)
- NO modificar las tablas Drift ni el AppDatabase
- NO crear migraciones
- El SyncNotifier NO necesita dispose manual del stream listener — StateNotifier se ocupa
- connectivity_plus v6 devuelve `List<ConnectivityResult>` por evento, no un solo valor
