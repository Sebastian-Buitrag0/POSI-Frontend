# Spec 007 — Módulo POS (Punto de Venta)

## Objetivo
Implementar el módulo central del POS: carrito interactivo, checkout transaccional,
descuento de stock y recibo visual. La ruta `/pos` ya existe pero apunta a un placeholder.

## Paquetes disponibles (ya en pubspec.yaml)
- `drift: ^2.20.0`, `drift_dev`, `build_runner`
- `flutter_riverpod: ^2.6.1`
- `uuid: ^4.5.1` — para generar `saleNumber`
- `intl: ^0.20.2` — para formateo de fecha/moneda
- `go_router: ^14.6.2`

## Patrones del proyecto
- Sealed classes para estados de notifiers
- `ConsumerStatefulWidget` cuando el widget necesita ciclo de vida
- Rutas en `AppRoutes` constantes; `context.push()` / `context.go()`
- Repositories: abstract interface → local impl → Provider
- Drift DAOs: `@DriftAccessor(tables: [...])` + `part 'file.g.dart'` + build_runner
- `authProvider` → `auth.user.tenantId` cuando `auth is AuthAuthenticated`
- `databaseProvider` expone `AppDatabase` (ya existe en `lib/core/database/database_provider.dart`)

## Archivos ya existentes (NO recrear):
- `lib/core/database/tables/sales_table.dart` — campos: id, saleNumber, subtotal, tax, total, paymentMethod, status, notes + SyncColumns
- `lib/core/database/tables/sale_items_table.dart` — campos: id, saleId(FK), productId(FK), productName, unitPrice, quantity, subtotal + SyncColumns
- `lib/core/database/app_database.dart` — contiene `@DriftDatabase(tables: [...], daos: [ProductsDao])`
- `lib/features/products/data/daos/products_dao.dart` — `ProductsDao`

---

## Task 7.0 — SalesDao + actualizar AppDatabase + build_runner

### IMPORTANTE: Este task DEBE ejecutarse primero. Requiere build_runner al final.

### Paso 1: Agregar `decreaseStock` a `ProductsDao`
Archivo: `lib/features/products/data/daos/products_dao.dart`

Añadir el siguiente método al final de la clase `ProductsDao` (antes del último `}`):

```dart
Future<void> decreaseStock(int productId, int quantity) =>
    customUpdate(
      'UPDATE products SET stock = stock - ?, updated_at = ? WHERE id = ?',
      variables: [
        Variable.withInt(quantity),
        Variable<DateTime>(DateTime.now()),
        Variable.withInt(productId),
      ],
      updates: {productsTable},
    );
```

### Paso 2: Crear `lib/features/sales/data/daos/sales_dao.dart`

```dart
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/sales_table.dart';
import '../../../../core/database/tables/sale_items_table.dart';

part 'sales_dao.g.dart';

@DriftAccessor(tables: [SalesTable, SaleItemsTable])
class SalesDao extends DatabaseAccessor<AppDatabase>
    with _$SalesDaoMixin {
  SalesDao(super.db);

  Future<int> insertSale(SalesTableCompanion sale) =>
      into(salesTable).insert(sale);

  Future<int> insertSaleItem(SaleItemsTableCompanion item) =>
      into(saleItemsTable).insert(item);

  Stream<List<SalesTableData>> watchAll(String tenantId) =>
      (select(salesTable)
            ..where((t) => t.tenantId.equals(tenantId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .watch();

  Future<SalesTableData?> getById(int id) =>
      (select(salesTable)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<SaleItemsTableData>> getItemsBySaleId(int saleId) =>
      (select(saleItemsTable)
            ..where((t) => t.saleId.equals(saleId)))
          .get();
}
```

### Paso 3: Actualizar `lib/core/database/app_database.dart`

Cambiar la anotación y añadir el import del DAO:

```dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'sync_mixin.dart';
import 'tables/categories_table.dart';
import 'tables/products_table.dart';
import 'tables/sales_table.dart';
import 'tables/sale_items_table.dart';
import '../../features/products/data/daos/products_dao.dart';
import '../../features/sales/data/daos/sales_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CategoriesTable,
    ProductsTable,
    SalesTable,
    SaleItemsTable,
  ],
  daos: [ProductsDao, SalesDao],
)
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

### Paso 4: Ejecutar build_runner

```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

**Verificar que se generaron:** `sales_dao.g.dart` y `app_database.g.dart` actualizados.

---

## Task 7.1 — `lib/features/sales/domain/entities/sale.dart`

```dart
enum PaymentMethod {
  cash,    // Efectivo
  card,    // Tarjeta
  transfer // Transferencia
}

enum SaleStatus { completed, cancelled, refunded }

class SaleItem {
  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  final int id;
  final int saleId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItem copyWith({
    int? id,
    int? saleId,
    int? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? subtotal,
  }) => SaleItem(
    id: id ?? this.id,
    saleId: saleId ?? this.saleId,
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    subtotal: subtotal ?? this.subtotal,
  );
}

class Sale {
  const Sale({
    required this.id,
    required this.saleNumber,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.tenantId,
    required this.createdAt,
    this.notes,
  });

  final int id;
  final String saleNumber;
  final List<SaleItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final PaymentMethod paymentMethod;
  final SaleStatus status;
  final String tenantId;
  final String? notes;
  final DateTime createdAt;

  Sale copyWith({
    int? id,
    String? saleNumber,
    List<SaleItem>? items,
    double? subtotal,
    double? tax,
    double? total,
    PaymentMethod? paymentMethod,
    SaleStatus? status,
    String? tenantId,
    String? notes,
    DateTime? createdAt,
  }) => Sale(
    id: id ?? this.id,
    saleNumber: saleNumber ?? this.saleNumber,
    items: items ?? this.items,
    subtotal: subtotal ?? this.subtotal,
    tax: tax ?? this.tax,
    total: total ?? this.total,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    status: status ?? this.status,
    tenantId: tenantId ?? this.tenantId,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
}
```

---

## Task 7.2 — `lib/features/sales/domain/entities/cart_item.dart`

CartItem es transiente (en memoria). No se persiste directamente — se convierte a `SaleItem` al hacer checkout.

```dart
class CartItem {
  const CartItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.maxStock = 999,
  });

  final int productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final int maxStock; // límite de stock disponible

  double get subtotal => unitPrice * quantity;

  CartItem copyWith({
    int? productId,
    String? productName,
    double? unitPrice,
    int? quantity,
    int? maxStock,
  }) => CartItem(
    productId: productId ?? this.productId,
    productName: productName ?? this.productName,
    unitPrice: unitPrice ?? this.unitPrice,
    quantity: quantity ?? this.quantity,
    maxStock: maxStock ?? this.maxStock,
  );

  @override
  bool operator ==(Object other) =>
      other is CartItem && other.productId == productId;

  @override
  int get hashCode => productId.hashCode;
}
```

---

## Task 7.3 — `lib/features/sales/domain/mappers/sale_mapper.dart`

```dart
import 'package:drift/drift.dart';
import '../../../../core/database/sync_mixin.dart';
import '../../../../core/database/tables/sales_table.dart';
import '../../../../core/database/tables/sale_items_table.dart';
import '../entities/sale.dart';

extension SaleItemMapper on SaleItemsTableData {
  SaleItem toDomain() => SaleItem(
    id: id,
    saleId: saleId,
    productId: productId,
    productName: productName,
    quantity: quantity,
    unitPrice: unitPrice,
    subtotal: subtotal,
  );
}

extension SaleMapper on SalesTableData {
  Sale toDomain(List<SaleItem> items) => Sale(
    id: id,
    saleNumber: saleNumber,
    items: items,
    subtotal: subtotal,
    tax: tax,
    total: total,
    paymentMethod: _parsePaymentMethod(paymentMethod),
    status: _parseSaleStatus(status),
    tenantId: tenantId,
    notes: notes,
    createdAt: createdAt,
  );

  static PaymentMethod _parsePaymentMethod(String s) {
    return switch (s) {
      'card' => PaymentMethod.card,
      'transfer' => PaymentMethod.transfer,
      _ => PaymentMethod.cash,
    };
  }

  static SaleStatus _parseSaleStatus(String s) {
    return switch (s) {
      'cancelled' => SaleStatus.cancelled,
      'refunded' => SaleStatus.refunded,
      _ => SaleStatus.completed,
    };
  }
}

extension CartItemToCompanion on CartItem {
  /// Genera el companion de SaleItem. El [saleId] se provee en checkout.
  SaleItemsTableCompanion toCompanion({
    required int saleId,
    required String tenantId,
  }) => SaleItemsTableCompanion(
    saleId: Value(saleId),
    productId: Value(productId),
    productName: Value(productName),
    unitPrice: Value(unitPrice),
    quantity: Value(quantity),
    subtotal: Value(subtotal),
    tenantId: Value(tenantId),
    syncStatus: const Value(SyncStatus.pending),
  );
}
```

---

## Task 7.4 — `lib/features/sales/data/repositories/sales_repository_provider.dart`

Primero crear la interfaz abstract:

### `lib/features/sales/domain/repositories/sales_repository.dart`

```dart
import '../entities/sale.dart';

abstract class SalesRepository {
  Future<Sale> completeSale({
    required List<CartItem> items,
    required PaymentMethod paymentMethod,
    required String tenantId,
    String? notes,
  });

  Stream<List<Sale>> watchAll(String tenantId);
}
```

### `lib/features/sales/data/repositories/local_sales_repository.dart`

```dart
import 'package:uuid/uuid.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables/sales_table.dart';
import '../../../../core/database/sync_mixin.dart';
import 'package:drift/drift.dart';
import '../../domain/entities/sale.dart';
import '../../domain/mappers/sale_mapper.dart';
import '../../domain/repositories/sales_repository.dart';
import '../daos/sales_dao.dart';
import '../../../products/data/daos/products_dao.dart';

class LocalSalesRepository implements SalesRepository {
  const LocalSalesRepository({
    required this.db,
    required this.salesDao,
    required this.productsDao,
  });

  final AppDatabase db;
  final SalesDao salesDao;
  final ProductsDao productsDao;

  @override
  Future<Sale> completeSale({
    required List<CartItem> items,
    required PaymentMethod paymentMethod,
    required String tenantId,
    String? notes,
  }) async {
    final now = DateTime.now();
    final saleNumber = 'S${now.millisecondsSinceEpoch}';
    final subtotal = items.fold(0.0, (sum, i) => sum + i.subtotal);
    final tax = subtotal * 0.16;
    final total = subtotal + tax;

    return db.transaction<Sale>(() async {
      // 1. Insertar venta
      final saleId = await salesDao.insertSale(
        SalesTableCompanion(
          saleNumber: Value(saleNumber),
          subtotal: Value(subtotal),
          tax: Value(tax),
          total: Value(total),
          paymentMethod: Value(paymentMethod.name),
          status: const Value('completed'),
          notes: Value(notes),
          tenantId: Value(tenantId),
          syncStatus: const Value(SyncStatus.pending),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      // 2. Insertar items y descontar stock
      for (final item in items) {
        await salesDao.insertSaleItem(
          item.toCompanion(saleId: saleId, tenantId: tenantId),
        );
        await productsDao.decreaseStock(item.productId, item.quantity);
      }

      // 3. Cargar la venta recién creada
      final saleRow = (await salesDao.getById(saleId))!;
      final itemRows = await salesDao.getItemsBySaleId(saleId);
      return saleRow.toDomain(itemRows.map((r) => r.toDomain()).toList());
    });
  }

  @override
  Stream<List<Sale>> watchAll(String tenantId) {
    return salesDao.watchAll(tenantId).asyncMap((rows) async {
      final sales = <Sale>[];
      for (final row in rows) {
        final itemRows = await salesDao.getItemsBySaleId(row.id);
        sales.add(row.toDomain(itemRows.map((r) => r.toDomain()).toList()));
      }
      return sales;
    });
  }
}
```

### `lib/features/sales/data/repositories/sales_repository_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../domain/repositories/sales_repository.dart';
import '../daos/sales_dao.dart';
import 'local_sales_repository.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalSalesRepository(
    db: db,
    salesDao: db.salesDao,
    productsDao: db.productsDao,
  );
});
```

---

## Task 7.5 — `lib/features/sales/presentation/providers/cart_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/sale.dart';
import '../../../products/domain/entities/product.dart';

// ── CartState ──────────────────────────────────────────────────────────────

class CartState {
  const CartState({
    this.items = const [],
    this.paymentMethod = PaymentMethod.cash,
    this.isProcessing = false,
  });

  final List<CartItem> items;
  final PaymentMethod paymentMethod;
  final bool isProcessing;

  double get subtotal => items.fold(0.0, (s, i) => s + i.subtotal);
  double get tax => subtotal * 0.16;
  double get total => subtotal + tax;
  int get itemCount => items.fold(0, (s, i) => s + i.quantity);
  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    PaymentMethod? paymentMethod,
    bool? isProcessing,
  }) => CartState(
    items: items ?? this.items,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    isProcessing: isProcessing ?? this.isProcessing,
  );
}

// ── Provider ───────────────────────────────────────────────────────────────

final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);

// ── Notifier ───────────────────────────────────────────────────────────────

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  /// Agrega o incrementa un producto en el carrito.
  /// Valida que haya stock disponible.
  void addItem(Product product) {
    if (!product.isActive || product.stock <= 0) return;

    final existing = state.items.where((i) => i.productId == product.id).firstOrNull;
    if (existing != null) {
      if (existing.quantity >= product.stock) return; // sin más stock
      final updated = state.items.map((i) =>
        i.productId == product.id
          ? i.copyWith(quantity: i.quantity + 1)
          : i,
      ).toList();
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(
            productId: product.id,
            productName: product.name,
            unitPrice: product.price,
            quantity: 1,
            maxStock: product.stock,
          ),
        ],
      );
    }
  }

  void removeItem(int productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.productId != productId).toList(),
    );
  }

  void updateQuantity(int productId, int newQty) {
    if (newQty <= 0) {
      removeItem(productId);
      return;
    }
    state = state.copyWith(
      items: state.items.map((i) {
        if (i.productId != productId) return i;
        final clamped = newQty.clamp(1, i.maxStock);
        return i.copyWith(quantity: clamped);
      }).toList(),
    );
  }

  void setPaymentMethod(PaymentMethod method) =>
      state = state.copyWith(paymentMethod: method);

  void clearCart() => state = const CartState();
}
```

---

## Task 7.6 — `lib/features/sales/presentation/providers/checkout_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/sale.dart';
import '../../data/repositories/sales_repository_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'cart_provider.dart';

// ── Estado ─────────────────────────────────────────────────────────────────

sealed class CheckoutState { const CheckoutState(); }
class CheckoutIdle extends CheckoutState { const CheckoutIdle(); }
class CheckoutProcessing extends CheckoutState { const CheckoutProcessing(); }
class CheckoutSuccess extends CheckoutState {
  const CheckoutSuccess(this.sale);
  final Sale sale;
}
class CheckoutError extends CheckoutState {
  const CheckoutError(this.message);
  final String message;
}

// ── Provider ───────────────────────────────────────────────────────────────

final checkoutProvider =
    StateNotifierProvider.autoDispose<CheckoutNotifier, CheckoutState>(
  (ref) => CheckoutNotifier(ref),
);

// ── Notifier ───────────────────────────────────────────────────────────────

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier(this._ref) : super(const CheckoutIdle());

  final Ref _ref;

  Future<void> processCheckout() async {
    final cart = _ref.read(cartProvider);
    if (cart.isEmpty) {
      state = const CheckoutError('El carrito está vacío');
      return;
    }

    final auth = _ref.read(authProvider);
    if (auth is! AuthAuthenticated) {
      state = const CheckoutError('No autenticado');
      return;
    }

    state = const CheckoutProcessing();
    try {
      final repo = _ref.read(salesRepositoryProvider);
      final sale = await repo.completeSale(
        items: cart.items,
        paymentMethod: cart.paymentMethod,
        tenantId: auth.user.tenantId,
      );
      _ref.read(cartProvider.notifier).clearCart();
      state = CheckoutSuccess(sale);
    } on Exception catch (e) {
      state = CheckoutError(e.toString());
    }
  }

  void reset() => state = const CheckoutIdle();
}
```

---

## Task 7.7 — `lib/features/sales/presentation/widgets/cart_item_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_provider.dart';
import '../../../../core/utils/currency_formatter.dart';

class CartItemWidget extends ConsumerWidget {
  const CartItemWidget({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(cartProvider.notifier);

    return Dismissible(
      key: ValueKey(item.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => notifier.removeItem(item.productId),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // Nombre e info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(
                      CurrencyFormatter.format(item.unitPrice),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
              // Selector de cantidad
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 20,
                    onPressed: () =>
                        notifier.updateQuantity(item.productId, item.quantity - 1),
                  ),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 20,
                    onPressed: item.quantity < item.maxStock
                        ? () => notifier.updateQuantity(
                            item.productId, item.quantity + 1)
                        : null,
                  ),
                ],
              ),
              // Subtotal
              SizedBox(
                width: 72,
                child: Text(
                  CurrencyFormatter.format(item.subtotal),
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**NOTA:** `CurrencyFormatter.format()` ya existe en `lib/core/utils/currency_formatter.dart`.
Si no existe, crearlo con:
```dart
import 'package:intl/intl.dart';
class CurrencyFormatter {
  static final _fmt = NumberFormat.currency(locale: 'es_MX', symbol: '\$');
  static String format(double amount) => _fmt.format(amount);
}
```

---

## Task 7.8 — `lib/shared/widgets/payment_method_selector.dart`

```dart
import 'package:flutter/material.dart';
import '../../features/sales/domain/entities/sale.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PaymentMethod selected;
  final void Function(PaymentMethod) onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PaymentMethod>(
      segments: const [
        ButtonSegment(
          value: PaymentMethod.cash,
          label: Text('Efectivo'),
          icon: Icon(Icons.payments_outlined),
        ),
        ButtonSegment(
          value: PaymentMethod.card,
          label: Text('Tarjeta'),
          icon: Icon(Icons.credit_card),
        ),
        ButtonSegment(
          value: PaymentMethod.transfer,
          label: Text('Transferencia'),
          icon: Icon(Icons.phone_android),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
```

---

## Task 7.9 — `lib/shared/widgets/receipt_widget.dart`

Mostrado como modal bottom sheet. Recibe una `Sale` ya procesada.

```dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/sales/domain/entities/sale.dart';
import '../../core/utils/currency_formatter.dart';

class ReceiptWidget extends StatelessWidget {
  const ReceiptWidget({super.key, required this.sale, required this.onClose});

  final Sale sale;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt);
    final paymentLabel = switch (sale.paymentMethod) {
      PaymentMethod.cash => 'Efectivo',
      PaymentMethod.card => 'Tarjeta',
      PaymentMethod.transfer => 'Transferencia',
    };

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Encabezado
          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 48),
          const SizedBox(height: 8),
          Text('¡Venta completada!',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text('Folio: ${sale.saleNumber}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          Text(dateStr,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const Divider(height: 24),
          // Items
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sale.items.length,
              itemBuilder: (_, i) {
                final item = sale.items[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                              '${item.quantity}x ${item.productName}',
                              style: theme.textTheme.bodyMedium)),
                      Text(CurrencyFormatter.format(item.subtotal),
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 16),
          // Totales
          _TotalRow('Subtotal', sale.subtotal, theme),
          _TotalRow('IVA (16%)', sale.tax, theme),
          _TotalRow('TOTAL', sale.total, theme, bold: true, large: true),
          const SizedBox(height: 8),
          // Método de pago
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(paymentLabel,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),
          // Botón cerrar
          FilledButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Nueva venta'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.amount, this.theme,
      {this.bold = false, this.large = false});

  final String label;
  final double amount;
  final ThemeData theme;
  final bool bold;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final style = large
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : bold
            ? theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
            : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(CurrencyFormatter.format(amount), style: style),
        ],
      ),
    );
  }
}
```

---

## Task 7.10 — `lib/features/sales/presentation/pages/pos_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../shared/widgets/payment_method_selector.dart';
import '../../../../shared/widgets/receipt_widget.dart';
import '../../domain/entities/sale.dart';
import '../providers/cart_provider.dart';
import '../providers/checkout_provider.dart';
import '../widgets/cart_item_widget.dart';
import '../../../products/domain/entities/product.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PosPage extends ConsumerStatefulWidget {
  const PosPage({super.key});

  @override
  ConsumerState<PosPage> createState() => _PosPageState();
}

class _PosPageState extends ConsumerState<PosPage> {
  @override
  void initState() {
    super.initState();
    // Resetear checkout al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final checkout = ref.watch(checkoutProvider);

    // Reaccionar al checkout exitoso
    ref.listen(checkoutProvider, (_, next) {
      if (next is CheckoutSuccess) {
        _showReceipt(context, next.sale);
      }
      if (next is CheckoutError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final isProcessing = checkout is CheckoutProcessing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Venta'),
        actions: [
          // Botón escáner
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Escanear',
            onPressed: () => context.push(AppRoutes.scanner),
          ),
          // Limpiar carrito
          if (!cart.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Vaciar carrito',
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: Column(
        children: [
          // Lista de items (ocupa espacio disponible)
          Expanded(
            child: cart.isEmpty
                ? _EmptyCart(onAddProduct: () => _showProductPicker(context))
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) => CartItemWidget(item: cart.items[i]),
                  ),
          ),
          // Panel inferior: totales + selector pago + botón cobrar
          _CheckoutPanel(cart: cart, isProcessing: isProcessing),
        ],
      ),
      floatingActionButton: cart.isEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showProductPicker(context),
              icon: const Icon(Icons.add),
              label: const Text('Agregar producto'),
            )
          : FloatingActionButton(
              onPressed: () => _showProductPicker(context),
              child: const Icon(Icons.add),
            ),
    );
  }

  void _showProductPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _ProductPickerSheet(),
    );
  }

  void _showReceipt(BuildContext context, Sale sale) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => ReceiptWidget(
        sale: sale,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  void _confirmClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Vaciar carrito'),
        content: const Text('¿Eliminar todos los productos del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(cartProvider.notifier).clearCart();
            },
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }
}

// ── Panel de totales y cobro ───────────────────────────────────────────────

class _CheckoutPanel extends ConsumerWidget {
  const _CheckoutPanel({required this.cart, required this.isProcessing});

  final CartState cart;
  final bool isProcessing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Totales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: theme.textTheme.bodyMedium),
              Text(CurrencyFormatter.format(cart.subtotal),
                  style: theme.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('IVA 16%',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey)),
              Text(CurrencyFormatter.format(cart.tax),
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('TOTAL',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                CurrencyFormatter.format(cart.total),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Selector método de pago
          PaymentMethodSelector(
            selected: cart.paymentMethod,
            onChanged: (m) =>
                ref.read(cartProvider.notifier).setPaymentMethod(m),
          ),
          const SizedBox(height: 12),
          // Botón COBRAR
          FilledButton.icon(
            onPressed: cart.isEmpty || isProcessing
                ? null
                : () => ref.read(checkoutProvider.notifier).processCheckout(),
            icon: isProcessing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.point_of_sale),
            label: Text(
              isProcessing ? 'Procesando...' : 'COBRAR ${CurrencyFormatter.format(cart.total)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Estado vacío ───────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onAddProduct});

  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined,
              size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Carrito vacío',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onAddProduct,
            icon: const Icon(Icons.add),
            label: const Text('Agregar producto'),
          ),
        ],
      ),
    );
  }
}

// ── Product Picker Modal ───────────────────────────────────────────────────

class _ProductPickerSheet extends ConsumerStatefulWidget {
  const _ProductPickerSheet();

  @override
  ConsumerState<_ProductPickerSheet> createState() =>
      _ProductPickerSheetState();
}

class _ProductPickerSheetState extends ConsumerState<_ProductPickerSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    ref.read(productSearchQueryProvider.notifier).state = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Buscar producto...',
              leading: const Icon(Icons.search),
              onChanged: (v) =>
                  ref.read(productSearchQueryProvider.notifier).state = v,
            ),
          ),
          // Lista de productos
          Expanded(
            child: productsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (products) => ListView.builder(
                controller: scrollController,
                itemCount: products.length,
                itemBuilder: (_, i) {
                  final p = products[i];
                  final inCart = ref
                      .read(cartProvider)
                      .items
                      .any((ci) => ci.productId == p.id);
                  return ListTile(
                    title: Text(p.name),
                    subtitle: Text('\$${p.price.toStringAsFixed(2)} — Stock: ${p.stock}'),
                    trailing: p.stock > 0
                        ? IconButton(
                            icon: Icon(
                              inCart
                                  ? Icons.add_circle
                                  : Icons.add_circle_outline,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              ref.read(cartProvider.notifier).addItem(p);
                            },
                          )
                        : const Chip(label: Text('Sin stock')),
                    enabled: p.stock > 0 && p.isActive,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## Task 7.11 — Actualizar `lib/main.dart`: reemplazar placeholder de POS

Cambiar el route de `/pos` de `_PlaceholderPage` a `PosPage`:

```dart
// Añadir import al inicio del archivo:
import 'features/sales/presentation/pages/pos_page.dart';

// Cambiar en routes:
// ANTES:
GoRoute(
  path: AppRoutes.pos,
  builder: (context, state) => const _PlaceholderPage('Punto de Venta'),
),
// DESPUÉS:
GoRoute(
  path: AppRoutes.pos,
  builder: (context, state) => const PosPage(),
),
```

---

## Estructura de archivos a crear/modificar

### Crear (nuevos):
```
lib/features/sales/
  domain/
    entities/
      sale.dart               ← Task 7.1
      cart_item.dart          ← Task 7.2
    mappers/
      sale_mapper.dart        ← Task 7.3
    repositories/
      sales_repository.dart   ← Task 7.4
  data/
    daos/
      sales_dao.dart          ← Task 7.0
    repositories/
      local_sales_repository.dart    ← Task 7.4
      sales_repository_provider.dart ← Task 7.4
  presentation/
    providers/
      cart_provider.dart      ← Task 7.5
      checkout_provider.dart  ← Task 7.6
    pages/
      pos_page.dart           ← Task 7.10
    widgets/
      cart_item_widget.dart   ← Task 7.7

lib/shared/widgets/
  payment_method_selector.dart ← Task 7.8
  receipt_widget.dart          ← Task 7.9
```

### Modificar (existentes):
```
lib/features/products/data/daos/products_dao.dart  ← Task 7.0 (add decreaseStock)
lib/core/database/app_database.dart                ← Task 7.0 (add SalesDao to daos[])
lib/main.dart                                      ← Task 7.11 (PosPage replace placeholder)
```

### Crear si no existe:
```
lib/core/utils/currency_formatter.dart  ← solo si no existe (verificar primero)
```

---

## Orden de ejecución OBLIGATORIO

1. **Task 7.0** primero (DAO + build_runner) — el resto depende del código generado
2. Tasks 7.1–7.4 (entidades, mappers, repositories)
3. Tasks 7.5–7.6 (providers cart y checkout)
4. Tasks 7.7–7.9 (widgets)
5. Task 7.10 (PosPage — usa todos los anteriores)
6. Task 7.11 (main.dart)

## Validación final
```bash
flutter analyze
```
Debe terminar con `No issues found.`

## IMPORTANTE — No hacer
- NO recrear `SalesTable` ni `SaleItemsTable` (ya existen)
- NO incrementar `schemaVersion` en `app_database.dart` (el schema no cambió)
- NO agregar `share_plus` ni ningún nuevo paquete
- NO modificar `products_provider.dart` ni `products_dao.dart` más allá del método `decreaseStock`
