# [017] Módulo Gastrobar — Frontend Flutter

## Objetivo
Implementar pantalla de mesas y pantalla de comanda para negocios tipo gastrobar/restaurante.
El módulo es **online-first** (no offline — las comandas requieren sincronización en tiempo real entre mesero y cocina).

## Contexto de la arquitectura existente
- Riverpod para estado, patrón `AsyncNotifierProvider`
- `go_router` para navegación — rutas en `AppRoutes`
- `dio` + `ApiClient` para HTTP (ver `lib/core/services/api_client.dart`)
- `AppColors` para colores, `AppTheme` para temas
- Patrón de carpetas: `lib/features/<feature>/data/`, `domain/`, `presentation/`

## Pantallas a crear: 2

### Pantalla 1: TablesPage — Grid de mesas
Ruta: `/gastrobar/tables`

**Layout:**
- AppBar: "Mesas" + botón "+" (solo admin) para crear mesa
- Body: `GridView` 2 columnas con tarjetas de mesas
- Cada tarjeta muestra:
  - Nombre de la mesa ("Mesa 1", "Barra 2")
  - Estado con color: verde=available, naranja=occupied, gris=reserved
  - Si occupied: número de items pendientes en badge
- Tap en mesa occupied → navega a OrderPage de la orden activa
- Tap en mesa available → abre diálogo de confirmación "¿Abrir comanda en Mesa X?" → crea orden y navega a OrderPage
- FAB "+" → bottom sheet para crear nueva mesa (nombre + capacidad)

### Pantalla 2: OrderPage — Comanda de una mesa
Ruta: `/gastrobar/orders/:orderId`

**Layout en 2 columnas (similar al POS):**

Columna izquierda — Lista de productos:
- Barra de búsqueda
- Grid de productos activos (igual que PosPage)
- Tap en producto → agrega item a la comanda

Columna derecha — Items de la comanda:
- Título: "Mesa X — Comanda #CMD-..."
- Lista de items agrupados por estado:
  - `pending` → gris, con botón "Enviar" 
  - `sent` → naranja, badge "En cocina"
  - `delivered` → verde, tachado
- Botón "Enviar a cocina" (marca todos los `pending` → `sent`)
- Total acumulado
- Botón "Cerrar cuenta" → bottom sheet con método de pago → llama closeOrder → navega a SalesHistory

## Archivos a CREAR

### lib/features/gastrobar/domain/entities/table_model.dart
```dart
class TableModel {
  final String id;
  final String name;
  final int capacity;
  final String status; // available | occupied | reserved
  final bool isActive;
  final int activeOrderItemCount;

  const TableModel({
    required this.id,
    required this.name,
    required this.capacity,
    required this.status,
    required this.isActive,
    required this.activeOrderItemCount,
  });

  bool get isAvailable => status == 'available';
  bool get isOccupied => status == 'occupied';

  factory TableModel.fromJson(Map<String, dynamic> json) => TableModel(
    id: json['id'] as String,
    name: json['name'] as String,
    capacity: json['capacity'] as int,
    status: json['status'] as String,
    isActive: json['isActive'] as bool,
    activeOrderItemCount: json['activeOrderItemCount'] as int,
  );
}
```

### lib/features/gastrobar/domain/entities/order_model.dart
```dart
class OrderModel {
  final String id;
  final String orderNumber;
  final String tableId;
  final String tableName;
  final String status;
  final String? waiterName;
  final DateTime openedAt;
  final List<OrderItemModel> items;
  final double total;

  const OrderModel({...});

  factory OrderModel.fromJson(Map<String, dynamic> json) => ...;
}

class OrderItemModel {
  final String id;
  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final double subtotal;
  final String status; // pending | sent | delivered | cancelled
  final String? notes;

  const OrderItemModel({...});
  factory OrderItemModel.fromJson(Map<String, dynamic> json) => ...;
}
```

### lib/features/gastrobar/data/gastrobar_repository.dart
```dart
class GastrobarRepository {
  GastrobarRepository(this._api);
  final ApiClient _api;

  Future<List<TableModel>> getTables() async {
    final res = await _api.get('/gastrobar/tables');
    return (res.data as List).map((e) => TableModel.fromJson(e)).toList();
  }

  Future<TableModel> createTable(String name, int capacity) async {
    final res = await _api.post('/gastrobar/tables', data: {'name': name, 'capacity': capacity});
    return TableModel.fromJson(res.data);
  }

  Future<OrderModel> openOrder(String tableId) async {
    final res = await _api.post('/gastrobar/tables/$tableId/orders');
    return OrderModel.fromJson(res.data);
  }

  Future<OrderModel> getOrder(String orderId) async {
    final res = await _api.get('/gastrobar/orders/$orderId');
    return OrderModel.fromJson(res.data);
  }

  Future<OrderModel> addItems(String orderId, List<Map<String, dynamic>> items) async {
    final res = await _api.post('/gastrobar/orders/$orderId/items', data: {'items': items});
    return OrderModel.fromJson(res.data);
  }

  Future<void> updateItemStatus(String orderId, String itemId, String status) async {
    await _api.patch('/gastrobar/orders/$orderId/items/$itemId/status', data: {'status': status});
  }

  Future<String> closeOrder(String orderId, String paymentMethod, String? notes) async {
    final res = await _api.post('/gastrobar/orders/$orderId/close',
        data: {'paymentMethod': paymentMethod, 'notes': notes});
    return res.data['saleId'] as String;
  }

  Future<void> cancelOrder(String orderId) async {
    await _api.post('/gastrobar/orders/$orderId/cancel');
  }
}

final gastrobarRepositoryProvider = Provider((ref) =>
    GastrobarRepository(ref.read(apiClientProvider)));
```

### lib/features/gastrobar/presentation/providers/tables_provider.dart
```dart
// AsyncNotifierProvider<TablesNotifier, List<TableModel>>
// Métodos: refresh(), createTable(name, capacity), openOrder(tableId) → String orderId
```

### lib/features/gastrobar/presentation/providers/order_provider.dart
```dart
// AsyncNotifierProvider.family<OrderNotifier, OrderModel, String>(orderId)
// Métodos: addItem(productId, qty, notes), sendToKitchen(), closeOrder(method, notes), cancelOrder()
// sendToKitchen: llama updateItemStatus en todos los items 'pending' → 'sent'
```

### lib/features/gastrobar/presentation/pages/tables_page.dart
Implementar con el layout descrito arriba.
Usar `GridView.builder` con `SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.2)`.

Widget de tarjeta de mesa:
```dart
Card con color de fondo según status:
  available → Colors.green.shade50, borde verde
  occupied  → Colors.orange.shade50, borde naranja
  reserved  → Colors.grey.shade100, borde gris
```

### lib/features/gastrobar/presentation/pages/order_page.dart
Layout igual que PosPage: `Row` con dos columnas en tablet/landscape, `Column` con tabs en portrait.
- Columna productos: reutilizar el patrón de `ProductsListView` del PosPage
- Columna comanda: lista de OrderItemWidget agrupados con headers por status

### lib/features/gastrobar/presentation/widgets/order_item_widget.dart
Widget para cada item de comanda con icono de estado y notes.

## Archivos a MODIFICAR

### lib/core/constants/app_routes.dart
Agregar:
```dart
static const String gastrobarTables = '/gastrobar/tables';
static const String gastrobarOrder = '/gastrobar/orders/:orderId';
```

### lib/main.dart
Agregar rutas en GoRouter:
```dart
GoRoute(
  path: AppRoutes.gastrobarTables,
  builder: (_, _) => const TablesPage(),
),
GoRoute(
  path: AppRoutes.gastrobarOrder,
  builder: (context, state) {
    final orderId = state.pathParameters['orderId']!;
    return OrderPage(orderId: orderId);
  },
),
```

### lib/main.dart — _HomePage grid
Agregar tarjeta "Mesas" al GridView del Dashboard:
```dart
_MenuCard(
  icon: Icons.table_restaurant,
  label: 'Mesas',
  color: Colors.deepOrange,
  onTap: () => context.push(AppRoutes.gastrobarTables),
),
```

## Restricciones
- NO usar Drift para este módulo — es online-first (solo llamadas API)
- Seguir exactamente el patrón de `ApiClient` existente para las llamadas HTTP
- Usar `AppColors` y `AppTheme` para todos los colores
- El layout de `OrderPage` debe verse bien tanto en portrait como landscape
- Los errores de red deben mostrarse con `ScaffoldMessenger.showSnackBar`

## Definición de hecho
- [ ] `flutter analyze` sin errores
- [ ] Tarjeta "Mesas" visible en el Dashboard
- [ ] TablesPage muestra grid de mesas con colores por estado
- [ ] Tap en mesa available abre diálogo y navega a OrderPage
- [ ] OrderPage permite agregar productos y ver items
- [ ] Botón "Enviar a cocina" cambia estado de items
- [ ] Botón "Cerrar cuenta" genera la venta y regresa al Dashboard
