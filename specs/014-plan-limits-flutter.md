# Spec 014-B — Planes + Límites (Flutter)

## Objetivo
Manejar la respuesta 402 del backend en dos lugares:
1. Sync service: cuando el servidor rechaza productos por límite de plan
2. Mensaje claro en SettingsPage cuando el sync falla por límite

No se necesita pantalla de upgrade todavía — eso viene con Stripe (Paso 19).

## Infraestructura existente
- `SyncState { isSyncing, lastSyncAt, error }` — `error` es String?
- `SyncNotifier.syncNow()` — catch genérico que setea `error = e.toString()`
- `SettingsPage` — ya muestra `sync.error` en rojo
- `ApiClient` usa Dio — errores HTTP llegan como `DioException`

---

## Task 14.0 — Mejorar manejo de error en SyncNotifier

En `lib/core/providers/sync_provider.dart`, modificar el bloque `catch` en `syncNow()`:

```dart
Future<void> syncNow() async {
  if (state.isSyncing) return;

  final authState = _ref.read(authProvider);
  if (authState is! AuthAuthenticated) return;

  state = state.copyWith(isSyncing: true, error: null);
  try {
    final service = _ref.read(syncServiceProvider);
    await service.sync(authState.user.tenantId);
    state = state.copyWith(isSyncing: false, lastSyncAt: DateTime.now());
  } on DioException catch (e) {
    final msg = e.response?.statusCode == 402
        ? 'Límite de plan alcanzado. Actualiza tu plan para sincronizar más productos.'
        : 'Error de conexión al sincronizar.';
    state = state.copyWith(isSyncing: false, error: msg);
  } catch (e) {
    state = state.copyWith(isSyncing: false, error: 'Error al sincronizar.');
  }
}
```

Agregar import al inicio del archivo:
```dart
import 'package:dio/dio.dart';
```

---

## Task 14.1 — Validación

```bash
cd /Users/sebastian-buitrago/Documents/Yo/POSI/POSI-Frontend
fvm flutter analyze
```

**0 errores.**

---

## Archivos a modificar
```
lib/core/providers/sync_provider.dart   ← Task 14.0
```

## IMPORTANTE — No hacer
- NO crear pantalla de upgrade — viene con Stripe (Paso 19)
- NO modificar tablas Drift ni build_runner
- El error ya se muestra en SettingsPage con el texto que definimos aquí
