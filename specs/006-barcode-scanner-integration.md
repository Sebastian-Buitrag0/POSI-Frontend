# Spec 006 — Barcode Scanner Integration

## Objetivo
Añadir un escáner de códigos de barras completo y reutilizable al app POSI.
Cuando se escanea un código:
- Si existe en DB → navegar a la pantalla de edición del producto
- Si NO existe → ofrecer crearlo con el barcode pre-cargado

## Paquetes relevantes (ya en pubspec.yaml)
- `mobile_scanner: ^5.2.3` — API v5: `MobileScannerController`, `BarcodeCapture`, `capture.barcodes[n].rawValue`
- `flutter_riverpod: ^2.6.1`
- Haptic: `import 'package:flutter/services.dart'` → `HapticFeedback.mediumImpact()`

## Patrones del proyecto
- Sealed classes para estados (ver `auth_provider.dart`, `products_provider.dart`)
- `ConsumerStatefulWidget` cuando hay `MobileScannerController` (tiene ciclo de vida)
- Rutas en `lib/core/constants/app_routes.dart`
- Navegación con `context.push(...)` / `context.go(...)`
- `authProvider` expone `auth.user.tenantId` cuando `auth is AuthAuthenticated`

---

## Task 6.1 — Agregar `getByBarcode` al DAO y Repository

### `lib/features/products/data/daos/products_dao.dart`
Añadir método al `ProductsDao` existente:

```dart
Future<ProductsTableData?> getByBarcode(String barcode, String tenantId) =>
    (select(productsTable)
          ..where((t) =>
              t.barcode.equals(barcode) & t.tenantId.equals(tenantId)))
        .getSingleOrNull();
```

### `lib/features/products/domain/repositories/product_repository.dart`
Añadir al abstract interface:

```dart
Future<Product?> getByBarcode(String barcode, String tenantId);
```

### `lib/features/products/data/repositories/product_repository_impl.dart`
Implementar:

```dart
@override
Future<Product?> getByBarcode(String barcode, String tenantId) async {
  final row = await _dao.getByBarcode(barcode, tenantId);
  return row?.toDomain();
}
```

---

## Task 6.2 — `lib/features/scanner/presentation/providers/scanner_provider.dart`

### Estado (sealed)
```dart
sealed class ScannerState { const ScannerState(); }

class ScannerIdle extends ScannerState { const ScannerIdle(); }

class ScannerScanning extends ScannerState { const ScannerScanning(); }

/// Barcode detectado, buscando en DB
class ScannerSearching extends ScannerState {
  const ScannerSearching(this.barcode);
  final String barcode;
}

/// Producto encontrado en DB
class ScannerProductFound extends ScannerState {
  const ScannerProductFound(this.barcode, this.productId);
  final String barcode;
  final int productId;
}

/// Código escaneado pero sin producto en DB
class ScannerProductNotFound extends ScannerState {
  const ScannerProductNotFound(this.barcode);
  final String barcode;
}

class ScannerError extends ScannerState {
  const ScannerError(this.message);
  final String message;
}
```

### Provider
```dart
final scannerProvider =
    StateNotifierProvider.autoDispose<ScannerNotifier, ScannerState>(
  (ref) => ScannerNotifier(ref),
);
```

### Notifier
```dart
class ScannerNotifier extends StateNotifier<ScannerState> {
  ScannerNotifier(this._ref) : super(const ScannerIdle());
  final Ref _ref;

  void startScanning() => state = const ScannerScanning();

  void stopScanning() => state = const ScannerIdle();

  /// Llamado desde el widget MobileScanner al detectar un barcode.
  /// Usa HapticFeedback.mediumImpact() al recibir el código.
  Future<void> handleBarcode(String rawValue) async {
    if (state is ScannerSearching) return; // evitar doble disparo
    HapticFeedback.mediumImpact();
    state = ScannerSearching(rawValue);
    try {
      final auth = _ref.read(authProvider);
      if (auth is! AuthAuthenticated) {
        state = const ScannerError('No autenticado');
        return;
      }
      final repo = _ref.read(productRepositoryProvider);
      final product = await repo.getByBarcode(rawValue, auth.user.tenantId);
      if (product != null) {
        state = ScannerProductFound(rawValue, product.id);
      } else {
        state = ScannerProductNotFound(rawValue);
      }
    } catch (e) {
      state = ScannerError(e.toString());
    }
  }

  /// Resetea al estado de escaneo activo (para escanear otro código)
  void reset() => state = const ScannerScanning();
}
```

**Imports necesarios:**
```dart
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../products/data/repositories/product_repository_provider.dart';
```

---

## Task 6.3 — `lib/shared/widgets/barcode_scanner_widget.dart`

Widget reutilizable que encapsula `MobileScanner`.

```dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerWidget extends StatefulWidget {
  const BarcodeScannerWidget({
    super.key,
    required this.onDetected,
    this.frameColor = Colors.white,
    this.frameSize = 250.0,
    this.showFlashToggle = true,
  });

  final void Function(String barcode) onDetected;
  final Color frameColor;
  final double frameSize;
  final bool showFlashToggle;

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  late final MobileScannerController _controller;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Cámara
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            final raw = capture.barcodes.firstOrNull?.rawValue;
            if (raw != null && raw.isNotEmpty) {
              widget.onDetected(raw);
            }
          },
        ),
        // Marco de escaneo centrado
        Center(
          child: Container(
            width: widget.frameSize,
            height: widget.frameSize,
            decoration: BoxDecoration(
              border: Border.all(color: widget.frameColor, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Botón de flash (esquina superior derecha)
        if (widget.showFlashToggle)
          Positioned(
            top: 16,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: Icon(
                  _flashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  _controller.toggleTorch();
                  setState(() => _flashOn = !_flashOn);
                },
              ),
            ),
          ),
      ],
    );
  }
}
```

---

## Task 6.4 — `lib/features/scanner/presentation/pages/scanner_screen.dart`

Pantalla fullscreen de escaneo. Reacciona a `scannerProvider`.

### Comportamiento
- Al entrar: llama `ref.read(scannerProvider.notifier).startScanning()`
- Al salir (pop): llama `stopScanning()`
- En `ScannerProductFound`: overlay verde, botón "Ir al producto" → navega a `/products/:id`
- En `ScannerProductNotFound`: overlay amarillo, botones "Crear producto" (con barcode pre-cargado) y "Escanear otro"
- En `ScannerSearching`: spinner con el código detectado
- En `ScannerError`: overlay rojo con mensaje

### Scaffold structure
```
Scaffold(
  backgroundColor: Colors.black,
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    foregroundColor: Colors.white,
    title: Text('Escanear código'),
  ),
  body: Stack(
    children: [
      // Cámara — BarcodeScannerWidget ocupa todo el body
      BarcodeScannerWidget(
        frameColor: _frameColor,  // blanco por defecto, verde/rojo según estado
        onDetected: (barcode) =>
            ref.read(scannerProvider.notifier).handleBarcode(barcode),
      ),
      // Overlay según estado
      _buildStateOverlay(state),
      // Hint text en la parte inferior
      Positioned(
        bottom: 40,
        left: 0, right: 0,
        child: Text(
          'Apunta al código de barras o QR',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70),
        ),
      ),
    ],
  ),
)
```

### `_buildStateOverlay`
- `ScannerIdle` / `ScannerScanning`: retorna `const SizedBox.shrink()` (sin overlay)
- `ScannerSearching(barcode)`: `Center(child: Column(children: [CircularProgressIndicator(color: Colors.white), Text(barcode, style: TextStyle(color: Colors.white))]))`
- `ScannerProductFound(barcode, productId)`:
  ```
  _ResultOverlay(
    color: Color(0xFF22C55E),  // verde
    icon: Icons.check_circle_outline,
    title: 'Producto encontrado',
    subtitle: barcode,
    primaryLabel: 'Ver producto',
    onPrimary: () => context.go(AppRoutes.productDetail.replaceAll(':id', '$productId')),
    secondaryLabel: 'Escanear otro',
    onSecondary: () => ref.read(scannerProvider.notifier).reset(),
  )
  ```
- `ScannerProductNotFound(barcode)`:
  ```
  _ResultOverlay(
    color: Colors.orange,
    icon: Icons.qr_code_scanner,
    title: 'Código no encontrado',
    subtitle: barcode,
    primaryLabel: 'Crear producto',
    onPrimary: () {
      // Navegar al form con barcode como query param
      context.go('${AppRoutes.productDetail.replaceAll(':id', 'new')}?barcode=${Uri.encodeComponent(barcode)}');
    },
    secondaryLabel: 'Escanear otro',
    onSecondary: () => ref.read(scannerProvider.notifier).reset(),
  )
  ```
- `ScannerError(message)`: similar overlay rojo

### `_ResultOverlay` (widget privado dentro del mismo archivo)
```dart
class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });
  ...
  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withAlpha(220),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 64, color: color),
                const SizedBox(height: 16),
                Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
                const SizedBox(height: 8),
                TextButton(onPressed: onSecondary, child: Text(secondaryLabel)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### `ref.listen` en `build`
```dart
ref.listen(scannerProvider, (_, next) {
  // Cambiar frameColor del scanner según estado
  // ScannerProductFound → verde, ScannerProductNotFound → naranja, resto → blanco
});
```

Usa `ConsumerStatefulWidget` con `_frameColor` en estado local, actualizado en el listener.

---

## Task 6.5 — Agregar ruta `/scanner` y actualizar integraciones

### `lib/core/constants/app_routes.dart`
Añadir:
```dart
static const String scanner = '/scanner';
```

### `lib/main.dart` — agregar ruta en GoRouter
```dart
GoRoute(
  path: AppRoutes.scanner,
  builder: (_, __) => const ScannerScreen(),
),
```

Import: `import 'features/scanner/presentation/pages/scanner_screen.dart';`

### `lib/features/products/presentation/pages/product_list_page.dart`
Cambiar el `floatingActionButton` de `FloatingActionButton.extended` a `Column` con dos FABs:
```dart
floatingActionButton: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
    FloatingActionButton(
      heroTag: 'scan',
      onPressed: () => context.push(AppRoutes.scanner),
      tooltip: 'Escanear código',
      child: const Icon(Icons.qr_code_scanner),
    ),
    const SizedBox(height: 12),
    FloatingActionButton.extended(
      heroTag: 'add',
      onPressed: () => context.push(AppRoutes.productDetail.replaceAll(':id', 'new')),
      icon: const Icon(Icons.add),
      label: const Text('Producto'),
    ),
  ],
),
```

### `lib/features/products/presentation/pages/product_form_page.dart`
El campo `barcode` ya tiene un botón de escáner (`_BarcodeScannerSheet`).
- Además, si llega un query param `?barcode=...`, pre-poblar el campo al inicializar.
- En `initState` / `didChangeDependencies`, leer `GoRouterState.of(context).uri.queryParameters['barcode']` y asignarlo al campo con `_formKey.currentState?.fields['barcode']?.didChange(barcode)`.

**NOTA:** El botón de escáner existente en el form (`_BarcodeScannerSheet`) ya usa `MobileScanner` directamente. No modificar su implementación interna; solo asegurarse que sigue funcionando.

---

## Estructura de archivos a crear/modificar

### Crear (nuevos):
```
lib/features/scanner/
  presentation/
    providers/
      scanner_provider.dart     ← Task 6.2
    pages/
      scanner_screen.dart       ← Task 6.4
lib/shared/widgets/
  barcode_scanner_widget.dart   ← Task 6.3
```

### Modificar (existentes):
```
lib/features/products/data/daos/products_dao.dart           ← Task 6.1 (add getByBarcode)
lib/features/products/domain/repositories/product_repository.dart ← Task 6.1
lib/features/products/data/repositories/product_repository_impl.dart ← Task 6.1
lib/core/constants/app_routes.dart                          ← Task 6.5 (add scanner route)
lib/main.dart                                               ← Task 6.5 (add GoRoute)
lib/features/products/presentation/pages/product_list_page.dart ← Task 6.5 (dual FAB)
lib/features/products/presentation/pages/product_form_page.dart ← Task 6.5 (barcode query param)
```

## Validación final
```bash
flutter analyze
```
Debe terminar con `No issues found.`

## IMPORTANTE — No hacer
- No ejecutar `flutter pub get` ni `build_runner` — no hay code generation en este paso
- No modificar `app_database.dart` ni `app_database.g.dart`
- No cambiar la estructura del `ProductFormState` ni del `ProductsDao` más allá de `getByBarcode`
