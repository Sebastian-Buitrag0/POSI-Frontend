# Spec 008 — Historial de Ventas y Cierre de Caja

## Objetivo
Implementar historial de ventas con filtros por fecha y el módulo de apertura/cierre de caja.
Las rutas `/sales` y `/cash-register` existen en `AppRoutes` y en `app_database.dart`,
pero NO están añadidas al GoRouter en `main.dart` — hay que agregarlas.

## Paquetes disponibles (ya en pubspec.yaml)
- `drift: ^2.20.0` — consultas con filtro por fecha
- `flutter_riverpod: ^2.6.1`
- `flutter_secure_storage: ^9.2.0` — persistir estado de caja (no requiere tabla nueva)
- `intl: ^0.20.2` — formateo de fechas
- **NO agregar ningún paquete nuevo**

## Patrones del proyecto
- Sealed classes para estados de notifiers
- `CurrencyFormatter.formatWithSymbol(double)` en `lib/core/utils/currency_formatter.dart`
- `authProvider` → `auth.user.tenantId` cuando `auth is AuthAuthenticated`
- `salesRepositoryProvider` en `lib/features/sales/data/repositories/sales_repository_provider.dart`
- `databaseProvider` expone `AppDatabase` con `db.salesDao`
- `SaleMapper.toDomain(items)` y `SaleItemMapper.toDomain()` existen en `lib/features/sales/domain/mappers/sale_mapper.dart`

## Archivos ya existentes — NO recrear
- `lib/features/sales/data/daos/sales_dao.dart` — tiene `watchAll`, `insertSale`, `insertSaleItem`, `getById`, `getItemsBySaleId`
- `lib/features/sales/domain/repositories/sales_repository.dart` — tiene `completeSale`, `watchAll`
- `lib/features/sales/data/repositories/local_sales_repository.dart`
- `lib/features/sales/data/repositories/sales_repository_provider.dart`
- `lib/features/sales/domain/entities/sale.dart` — contiene `Sale`, `SaleItem`, `PaymentMethod`, `SaleStatus`

---

## Task 8.0 — Extender `SalesDao` con consultas por fecha

**Archivo:** `lib/features/sales/data/daos/sales_dao.dart`

Añadir los siguientes métodos a la clase `SalesDao` existente (NO modificar nada de lo que ya existe):

```dart
/// Ventas en un rango de fechas (resultado único, no stream)
Future<List<SalesTableData>> getByDateRange(
    String tenantId, DateTime from, DateTime to) =>
    (select(salesTable)
          ..where((t) =>
              t.tenantId.equals(tenantId) &
              t.createdAt.isBiggerOrEqualValue(from) &
              t.createdAt.isSmallerOrEqualValue(to))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();

/// Stream reactivo para un rango de fechas
Stream<List<SalesTableData>> watchByDateRange(
    String tenantId, DateTime from, DateTime to) =>
    (select(salesTable)
          ..where((t) =>
              t.tenantId.equals(tenantId) &
              t.createdAt.isBiggerOrEqualValue(from) &
              t.createdAt.isSmallerOrEqualValue(to))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
```

**NOTA:** No se requiere build_runner — estos son métodos normales que usan el mixin ya generado.

---

## Task 8.1 — Extender `SalesRepository` con métodos de historial

### `lib/features/sales/domain/repositories/sales_repository.dart`

Añadir las firmas a la clase abstracta existente:

```dart
Future<List<Sale>> getByDateRange(
    String tenantId, DateTime from, DateTime to);

Future<List<Sale>> getTodaySales(String tenantId);
```

### `lib/features/sales/data/repositories/local_sales_repository.dart`

Añadir las implementaciones (NO modificar los métodos existentes):

```dart
@override
Future<List<Sale>> getByDateRange(
    String tenantId, DateTime from, DateTime to) async {
  final rows = await salesDao.getByDateRange(tenantId, from, to);
  final sales = <Sale>[];
  for (final row in rows) {
    final itemRows = await salesDao.getItemsBySaleId(row.id);
    sales.add(row.toDomain(itemRows.map((r) => r.toDomain()).toList()));
  }
  return sales;
}

@override
Future<List<Sale>> getTodaySales(String tenantId) {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = startOfDay.add(const Duration(days: 1));
  return getByDateRange(tenantId, startOfDay, endOfDay);
}
```

---

## Task 8.2 — `lib/features/sales/domain/entities/sales_summary.dart`

Objeto de dominio que encapsula métricas de un conjunto de ventas.

```dart
import 'sale.dart';

class SalesSummary {
  const SalesSummary({
    required this.totalCount,
    required this.totalRevenue,
    required this.cashRevenue,
    required this.cardRevenue,
    required this.transferRevenue,
    required this.totalItemsSold,
  });

  final int totalCount;
  final double totalRevenue;
  final double cashRevenue;
  final double cardRevenue;
  final double transferRevenue;
  final int totalItemsSold;

  double get averageTicket =>
      totalCount == 0 ? 0 : totalRevenue / totalCount;

  /// Construir desde una lista de ventas
  factory SalesSummary.fromSales(List<Sale> sales) {
    double cash = 0, card = 0, transfer = 0;
    int items = 0;
    for (final s in sales) {
      switch (s.paymentMethod) {
        case PaymentMethod.cash:
          cash += s.total;
        case PaymentMethod.card:
          card += s.total;
        case PaymentMethod.transfer:
          transfer += s.total;
      }
      items += s.items.fold(0, (sum, i) => sum + i.quantity);
    }
    return SalesSummary(
      totalCount: sales.length,
      totalRevenue: cash + card + transfer,
      cashRevenue: cash,
      cardRevenue: card,
      transferRevenue: transfer,
      totalItemsSold: items,
    );
  }

  static const empty = SalesSummary(
    totalCount: 0,
    totalRevenue: 0,
    cashRevenue: 0,
    cardRevenue: 0,
    transferRevenue: 0,
    totalItemsSold: 0,
  );
}
```

---

## Task 8.3 — `lib/features/sales/presentation/providers/sales_history_provider.dart`

### Filtro de fecha (enum)
```dart
enum DateRangeFilter { today, week, month, custom }
```

### Estado
```dart
class SalesHistoryState {
  const SalesHistoryState({
    this.sales = const [],
    this.summary = SalesSummary.empty,
    this.filter = DateRangeFilter.today,
    this.customFrom,
    this.customTo,
    this.isLoading = false,
    this.error,
  });

  final List<Sale> sales;
  final SalesSummary summary;
  final DateRangeFilter filter;
  final DateTime? customFrom;
  final DateTime? customTo;
  final bool isLoading;
  final String? error;

  SalesHistoryState copyWith({ ... }); // todos los campos opcionales
}
```

### Provider
```dart
final salesHistoryProvider =
    StateNotifierProvider.autoDispose<SalesHistoryNotifier, SalesHistoryState>(
  (ref) => SalesHistoryNotifier(ref),
);
```

### Notifier

```dart
class SalesHistoryNotifier extends StateNotifier<SalesHistoryState> {
  SalesHistoryNotifier(this._ref) : super(const SalesHistoryState()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final auth = _ref.read(authProvider);
    if (auth is! AuthAuthenticated) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(salesRepositoryProvider);
      final (from, to) = _dateRange();
      final sales = await repo.getByDateRange(auth.user.tenantId, from, to);
      state = state.copyWith(
        sales: sales,
        summary: SalesSummary.fromSales(sales),
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Devuelve (from, to) según el filtro activo
  (DateTime, DateTime) _dateRange() {
    final now = DateTime.now();
    return switch (state.filter) {
      DateRangeFilter.today => (
          DateTime(now.year, now.month, now.day),
          DateTime(now.year, now.month, now.day, 23, 59, 59),
        ),
      DateRangeFilter.week => (
          now.subtract(const Duration(days: 7)),
          now,
        ),
      DateRangeFilter.month => (
          DateTime(now.year, now.month, 1),
          now,
        ),
      DateRangeFilter.custom => (
          state.customFrom ?? DateTime(now.year, now.month, now.day),
          state.customTo ?? now,
        ),
    };
  }

  void setFilter(DateRangeFilter filter) {
    state = state.copyWith(filter: filter);
    _load();
  }

  void setCustomRange(DateTime from, DateTime to) {
    state = state.copyWith(
      filter: DateRangeFilter.custom,
      customFrom: from,
      customTo: to,
    );
    _load();
  }

  Future<void> refresh() => _load();
}
```

**Imports necesarios:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/sales_repository_provider.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sales_summary.dart';
```

---

## Task 8.4 — `lib/features/sales/presentation/pages/sales_history_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sales_summary.dart';
import '../providers/sales_history_provider.dart';

class SalesHistoryPage extends ConsumerWidget {
  const SalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesHistoryProvider);
    final notifier = ref.read(salesHistoryProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Rango personalizado',
            onPressed: () => _showDateRangePicker(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros rápidos
          _FilterChips(
            selected: state.filter,
            onSelected: notifier.setFilter,
          ),
          // Tarjeta de resumen
          if (!state.isLoading && state.error == null)
            _SummaryBanner(summary: state.summary),
          // Lista de ventas
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? _ErrorView(message: state.error!, onRetry: notifier.refresh)
                    : state.sales.isEmpty
                        ? const _EmptyHistoryView()
                        : RefreshIndicator(
                            onRefresh: notifier.refresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: state.sales.length,
                              itemBuilder: (_, i) =>
                                  _SaleCard(sale: state.sales[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null) {
      ref
          .read(salesHistoryProvider.notifier)
          .setCustomRange(picked.start, picked.end);
    }
  }
}

// ── Filtros rápidos ────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final DateRangeFilter selected;
  final void Function(DateRangeFilter) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: DateRangeFilter.values
            .where((f) => f != DateRangeFilter.custom)
            .map((f) {
          final label = switch (f) {
            DateRangeFilter.today => 'Hoy',
            DateRangeFilter.week => 'Semana',
            DateRangeFilter.month => 'Mes',
            DateRangeFilter.custom => 'Personalizado',
          };
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: selected == f,
              onSelected: (_) => onSelected(f),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Banner de resumen ──────────────────────────────────────────────────────

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.summary});

  final SalesSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer.withAlpha(80),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Metric('Ventas', '${summary.totalCount}', Icons.receipt_long),
          _Metric(
            'Total',
            CurrencyFormatter.formatWithSymbol(summary.totalRevenue),
            Icons.attach_money,
          ),
          _Metric(
            'Ticket Prom.',
            CurrencyFormatter.formatWithSymbol(summary.averageTicket),
            Icons.analytics_outlined,
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(height: 2),
        Text(value,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: Colors.grey)),
      ],
    );
  }
}

// ── Tarjeta de venta ───────────────────────────────────────────────────────

class _SaleCard extends StatelessWidget {
  const _SaleCard({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('HH:mm').format(sale.createdAt);
    final dateStr = DateFormat('dd/MM/yy').format(sale.createdAt);
    final payIcon = switch (sale.paymentMethod) {
      PaymentMethod.cash => Icons.payments_outlined,
      PaymentMethod.card => Icons.credit_card,
      PaymentMethod.transfer => Icons.phone_android,
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(payIcon,
              size: 18, color: theme.colorScheme.primary),
        ),
        title: Text(
          sale.saleNumber,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text('$dateStr  $timeStr · ${sale.items.length} ítem(s)'),
        trailing: Text(
          CurrencyFormatter.formatWithSymbol(sale.total),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...sale.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.productName}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatWithSymbol(item.subtotal),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal', style: theme.textTheme.bodySmall),
                    Text(CurrencyFormatter.formatWithSymbol(sale.subtotal),
                        style: theme.textTheme.bodySmall),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('IVA', style: theme.textTheme.bodySmall),
                    Text(CurrencyFormatter.formatWithSymbol(sale.tax),
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Vistas auxiliares ──────────────────────────────────────────────────────

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('Sin ventas en este período',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey)),
          ],
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
}
```

---

## Task 8.5 — `lib/features/cash-register/presentation/providers/cash_register_provider.dart`

**Persistencia:** `flutter_secure_storage` (ya en pubspec). Estado persiste entre sesiones de app.

### Estado
```dart
class CashRegisterState {
  const CashRegisterState({
    this.isOpen = false,
    this.openingCash = 0,
    this.openedAt,
    this.sales = const [],
    this.summary = SalesSummary.empty,
    this.isLoading = false,
    this.error,
  });

  final bool isOpen;
  final double openingCash;
  final DateTime? openedAt;
  final List<Sale> sales;       // ventas del período abierto
  final SalesSummary summary;
  final bool isLoading;
  final String? error;

  double get expectedCash => openingCash + summary.cashRevenue;

  CashRegisterState copyWith({ ... }); // todos los campos opcionales
}
```

### Provider
```dart
final cashRegisterProvider =
    StateNotifierProvider<CashRegisterNotifier, CashRegisterState>(
  (ref) => CashRegisterNotifier(ref),
);
```

### Notifier

```dart
class CashRegisterNotifier extends StateNotifier<CashRegisterState> {
  CashRegisterNotifier(this._ref) : super(const CashRegisterState()) {
    _restoreFromStorage();
  }

  final Ref _ref;
  static const _storage = FlutterSecureStorage();
  static const _keyStatus = 'posi_cr_status';
  static const _keyOpeningCash = 'posi_cr_opening_cash';
  static const _keyOpenedAt = 'posi_cr_opened_at';

  /// Al iniciar la app, restaurar estado de caja
  Future<void> _restoreFromStorage() async {
    final status = await _storage.read(key: _keyStatus);
    if (status != 'open') return;

    final cashStr = await _storage.read(key: _keyOpeningCash) ?? '0';
    final atStr = await _storage.read(key: _keyOpenedAt) ?? '';

    final openingCash = double.tryParse(cashStr) ?? 0;
    final openedAt = atStr.isNotEmpty ? DateTime.tryParse(atStr) : null;

    state = state.copyWith(
      isOpen: true,
      openingCash: openingCash,
      openedAt: openedAt,
    );
    await _loadSales();
  }

  Future<void> openRegister(double initialCash) async {
    final now = DateTime.now();
    await _storage.write(key: _keyStatus, value: 'open');
    await _storage.write(key: _keyOpeningCash, value: '$initialCash');
    await _storage.write(key: _keyOpenedAt, value: now.toIso8601String());
    state = state.copyWith(
      isOpen: true,
      openingCash: initialCash,
      openedAt: now,
      sales: [],
      summary: SalesSummary.empty,
    );
    await _loadSales();
  }

  Future<void> closeRegister() async {
    await _storage.delete(key: _keyStatus);
    await _storage.delete(key: _keyOpeningCash);
    await _storage.delete(key: _keyOpenedAt);
    state = const CashRegisterState();
  }

  Future<void> _loadSales() async {
    final auth = _ref.read(authProvider);
    if (auth is! AuthAuthenticated) return;
    if (state.openedAt == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final repo = _ref.read(salesRepositoryProvider);
      final sales = await repo.getByDateRange(
        auth.user.tenantId,
        state.openedAt!,
        DateTime.now(),
      );
      state = state.copyWith(
        sales: sales,
        summary: SalesSummary.fromSales(sales),
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => _loadSales();
}
```

**Imports necesarios:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../sales/data/repositories/sales_repository_provider.dart';
import '../../../sales/domain/entities/sale.dart';
import '../../../sales/domain/entities/sales_summary.dart';
```

**NOTA: El archivo debe estar en:**
`lib/features/cash-register/presentation/providers/cash_register_provider.dart`

El directorio `cash-register` usa guión, que es válido en Flutter. Dart ignora el nombre del directorio para imports.

---

## Task 8.6 — `lib/features/cash-register/presentation/pages/cash_register_page.dart`

Página única que muestra vista de apertura o cierre según el estado de la caja.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../presentation/providers/cash_register_provider.dart';

class CashRegisterPage extends ConsumerWidget {
  const CashRegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cashRegisterProvider);

    if (state.isLoading && !state.isOpen) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return state.isOpen
        ? _CloseRegisterView(state: state)
        : const _OpenRegisterView();
  }
}
```

### `_OpenRegisterView` (widget privado en el mismo archivo)

```dart
class _OpenRegisterView extends ConsumerStatefulWidget {
  const _OpenRegisterView();

  @override
  ConsumerState<_OpenRegisterView> createState() => _OpenRegisterViewState();
}

class _OpenRegisterViewState extends ConsumerState<_OpenRegisterView> {
  final _cashController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Apertura de Caja')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_open,
                    size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text('Abrir caja',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Ingresa el monto inicial en caja',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _cashController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Monto inicial',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                    hintText: '0.00',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa el monto';
                    if (double.tryParse(v) == null) return 'Monto inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    final amount = double.parse(_cashController.text);
                    ref.read(cashRegisterProvider.notifier).openRegister(amount);
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('APERTURAR CAJA'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### `_CloseRegisterView` (widget privado en el mismo archivo)

```dart
class _CloseRegisterView extends ConsumerStatefulWidget {
  const _CloseRegisterView({required this.state});

  final CashRegisterState state;

  @override
  ConsumerState<_CloseRegisterView> createState() => _CloseRegisterViewState();
}

class _CloseRegisterViewState extends ConsumerState<_CloseRegisterView> {
  final _realCashController = TextEditingController();

  double get _realCash =>
      double.tryParse(_realCashController.text) ?? 0;
  double get _difference => _realCash - widget.state.expectedCash;
  bool get _hasDiscrepancy => _difference.abs() > 50; // umbral $50

  @override
  void dispose() {
    _realCashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.state;
    final openedStr = state.openedAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(state.openedAt!)
        : '—';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cierre de Caja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(cashRegisterProvider.notifier).refresh(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info apertura
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Apertura'),
                subtitle: Text(openedStr),
                trailing: Text(
                  CurrencyFormatter.formatWithSymbol(state.openingCash),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Resumen de ventas
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resumen del período',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _SummaryRow('Total ventas',
                        '${state.summary.totalCount}', Icons.receipt_long),
                    _SummaryRow(
                        'Ingresos totales',
                        CurrencyFormatter.formatWithSymbol(
                            state.summary.totalRevenue),
                        Icons.monetization_on_outlined),
                    _SummaryRow(
                        'Efectivo vendido',
                        CurrencyFormatter.formatWithSymbol(
                            state.summary.cashRevenue),
                        Icons.payments_outlined),
                    _SummaryRow(
                        'Tarjeta/Transfer',
                        CurrencyFormatter.formatWithSymbol(
                            state.summary.cardRevenue +
                                state.summary.transferRevenue),
                        Icons.credit_card),
                    const Divider(height: 16),
                    _SummaryRow(
                        'Efectivo esperado en caja',
                        CurrencyFormatter.formatWithSymbol(
                            state.expectedCash),
                        Icons.account_balance_wallet,
                        bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Conteo real
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Conteo físico',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _realCashController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Efectivo contado manualmente',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                        hintText: '0.00',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    if (_realCashController.text.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Diferencia:',
                              style: theme.textTheme.titleSmall),
                          Text(
                            '${_difference >= 0 ? '+' : ''}${CurrencyFormatter.formatWithSymbol(_difference)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _difference >= 0
                                  ? const Color(0xFF22C55E)
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      if (_hasDiscrepancy)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber,
                                  color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Discrepancia mayor a \$50. Verifica el conteo.',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Botón cerrar
            FilledButton.icon(
              onPressed: () => _confirmClose(context),
              icon: const Icon(Icons.lock),
              label: const Text('CERRAR CAJA'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: _hasDiscrepancy
                    ? Colors.red
                    : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClose(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar caja'),
        content: Text(
          _hasDiscrepancy
              ? '⚠️ Hay una diferencia de ${CurrencyFormatter.formatWithSymbol(_difference.abs())}. ¿Confirmas el cierre?'
              : '¿Confirmar el cierre de caja?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: _hasDiscrepancy ? Colors.red : null),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(cashRegisterProvider.notifier).closeRegister();
            },
            child: const Text('Confirmar cierre'),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar de fila de resumen
class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, this.icon, {this.bold = false});

  final String label;
  final String value;
  final IconData icon;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
```

---

## Task 8.7 — `lib/shared/widgets/sales_summary_card_widget.dart`

Widget compacto para el dashboard. Recibe una lista de ventas de hoy.

```dart
import 'package:flutter/material.dart';
import '../../features/sales/domain/entities/sales_summary.dart';
import '../../core/utils/currency_formatter.dart';

class SalesSummaryCard extends StatelessWidget {
  const SalesSummaryCard({super.key, required this.summary, this.title = 'Hoy'});

  final SalesSummary summary;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, size: 18),
                const SizedBox(width: 6),
                Text(title, style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            // Barra visual proporcional (cash vs card vs transfer)
            if (summary.totalRevenue > 0)
              _PaymentBreakdownBar(summary: summary),
            const SizedBox(height: 12),
            // Métricas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                  '${summary.totalCount}',
                  'Ventas',
                  Icons.receipt_long,
                  theme,
                ),
                _Stat(
                  CurrencyFormatter.formatWithSymbol(summary.totalRevenue),
                  'Total',
                  Icons.attach_money,
                  theme,
                ),
                _Stat(
                  CurrencyFormatter.formatWithSymbol(summary.averageTicket),
                  'Prom.',
                  Icons.analytics_outlined,
                  theme,
                ),
                _Stat(
                  '${summary.totalItemsSold}',
                  'Artículos',
                  Icons.inventory_2_outlined,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentBreakdownBar extends StatelessWidget {
  const _PaymentBreakdownBar({required this.summary});

  final SalesSummary summary;

  @override
  Widget build(BuildContext context) {
    final total = summary.totalRevenue;
    if (total == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                if (summary.cashRevenue > 0)
                  Flexible(
                    flex: (summary.cashRevenue / total * 100).round(),
                    child: Container(color: const Color(0xFF22C55E)),
                  ),
                if (summary.cardRevenue > 0)
                  Flexible(
                    flex: (summary.cardRevenue / total * 100).round(),
                    child: Container(color: const Color(0xFF3B82F6)),
                  ),
                if (summary.transferRevenue > 0)
                  Flexible(
                    flex: (summary.transferRevenue / total * 100).round(),
                    child: Container(color: const Color(0xFFF59E0B)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _LegendDot(const Color(0xFF22C55E), 'Efectivo'),
            const SizedBox(width: 12),
            _LegendDot(const Color(0xFF3B82F6), 'Tarjeta'),
            const SizedBox(width: 12),
            _LegendDot(const Color(0xFFF59E0B), 'Transfer'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot(this.color, this.label);

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle)),
          const SizedBox(width: 3),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.grey)),
        ],
      );
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.icon, this.theme);

  final String value;
  final String label;
  final IconData icon;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(height: 2),
          Text(value,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: Colors.grey)),
        ],
      );
}
```

---

## Task 8.8 — Actualizar `lib/main.dart`

Añadir imports y rutas de `/sales` y `/cash-register`:

```dart
// Añadir imports:
import 'features/sales/presentation/pages/sales_history_page.dart';
import 'features/cash-register/presentation/pages/cash_register_page.dart';

// Añadir a la lista routes (después del route de /pos):
GoRoute(
  path: AppRoutes.salesHistory,
  builder: (_, __) => const SalesHistoryPage(),
),
GoRoute(
  path: AppRoutes.cashRegister,
  builder: (_, __) => const CashRegisterPage(),
),
```

---

## Estructura de archivos a crear/modificar

### Crear (nuevos):
```
lib/features/sales/
  domain/
    entities/
      sales_summary.dart              ← Task 8.2
  presentation/
    providers/
      sales_history_provider.dart     ← Task 8.3
    pages/
      sales_history_page.dart         ← Task 8.4

lib/features/cash-register/
  presentation/
    providers/
      cash_register_provider.dart     ← Task 8.5
    pages/
      cash_register_page.dart         ← Task 8.6

lib/shared/widgets/
  sales_summary_card_widget.dart      ← Task 8.7
```

### Modificar (existentes):
```
lib/features/sales/data/daos/sales_dao.dart                         ← Task 8.0 (añadir métodos)
lib/features/sales/domain/repositories/sales_repository.dart        ← Task 8.1
lib/features/sales/data/repositories/local_sales_repository.dart    ← Task 8.1
lib/main.dart                                                        ← Task 8.8 (rutas /sales y /cash-register)
```

## Orden de ejecución OBLIGATORIO

1. Task 8.0 (SalesDao) → 8.1 (Repository) → 8.2 (SalesSummary entity)
2. Tasks 8.3–8.4 (historial provider + page)
3. Tasks 8.5–8.6 (cash register provider + page)
4. Task 8.7 (widget SalesSummaryCard)
5. Task 8.8 (main.dart)

## Validación final
```bash
flutter analyze
```
Debe terminar con `No issues found.`

## IMPORTANTE — No hacer
- NO agregar ningún paquete nuevo (no share_plus, no pdf, no fl_chart)
- NO crear tablas nuevas en Drift — no tocar app_database.dart
- NO ejecutar build_runner — no es necesario en este paso
- NO crear el directorio cash-register con el path de Dart usando guión medio en imports
  → Usar la ruta exacta: `import '../../../features/cash-register/presentation/...`
  → Dart permite directorios con guión. El nombre del package en pubspec.yaml es `posi_frontend`
  → Los imports usan el path relativo o `package:posi_frontend/features/cash-register/...`
- NO modificar el schema de Drift ni los archivos `.g.dart`
