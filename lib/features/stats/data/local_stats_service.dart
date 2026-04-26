import 'package:drift/drift.dart';
import '../../../core/database/app_database.dart';
import '../presentation/providers/stats_provider.dart';

class LocalStatsService {
  LocalStatsService(this._db);

  final AppDatabase _db;

  Future<StatsData> compute(String tenantId, String period) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);
    final prevMonthStart = DateTime(now.year, now.month - 1, 1);

    final (start, prevStart, prevEnd) = switch (period) {
      'today' => (today, today.subtract(const Duration(days: 1)), today),
      'month' => (monthStart, prevMonthStart, monthStart),
      _ => (
          today.subtract(const Duration(days: 6)),
          today.subtract(const Duration(days: 13)),
          today.subtract(const Duration(days: 6)),
        ),
    };

    final allSales = await (_db.select(_db.salesTable)
          ..where((t) =>
              t.tenantId.equals(tenantId) &
              t.status.equals('completed') &
              t.createdAt.isBiggerOrEqualValue(start)))
        .get();

    final prevSales = await (_db.select(_db.salesTable)
          ..where((t) =>
              t.tenantId.equals(tenantId) &
              t.status.equals('completed') &
              t.createdAt.isBiggerOrEqualValue(prevStart) &
              t.createdAt.isSmallerOrEqualValue(prevEnd)))
        .get();

    final totalRevenue = allSales.fold(0.0, (s, e) => s + e.total);
    final totalCount = allSales.length;
    final avgTicket = totalCount > 0 ? totalRevenue / totalCount : 0.0;

    final prevRevenue = prevSales.fold(0.0, (s, e) => s + e.total);
    final prevCount = prevSales.length;

    final revenueChange = prevRevenue > 0
        ? (totalRevenue - prevRevenue) / prevRevenue * 100
        : totalRevenue > 0
            ? 100.0
            : 0.0;
    final countChange = prevCount > 0
        ? (totalCount - prevCount) / prevCount * 100
        : totalCount > 0
            ? 100.0
            : 0.0;

    // Ventas por día — últimos 7 días siempre
    final chartStart = today.subtract(const Duration(days: 6));
    final chartSales = await (_db.select(_db.salesTable)
          ..where((t) =>
              t.tenantId.equals(tenantId) &
              t.status.equals('completed') &
              t.createdAt.isBiggerOrEqualValue(chartStart)))
        .get();

    final salesByDay = List.generate(7, (i) {
      final day = chartStart.add(Duration(days: i));
      final dayEnd = day.add(const Duration(days: 1));
      final daySales = chartSales
          .where((s) =>
              !s.createdAt.isBefore(day) && s.createdAt.isBefore(dayEnd))
          .toList();
      final label =
          '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}';
      return DailySales(
        date: label,
        revenue: daySales.fold(0.0, (s, e) => s + e.total),
        count: daySales.length,
      );
    });

    // Ventas por método de pago
    final byMethod = <String, _MethodAcc>{};
    for (final s in allSales) {
      final m = byMethod.putIfAbsent(s.paymentMethod, () => _MethodAcc());
      m.revenue += s.total;
      m.count++;
    }
    final salesByPaymentMethod = byMethod.entries
        .map((e) => PaymentMethodStat(
            method: e.key, revenue: e.value.revenue, count: e.value.count))
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    // Top productos desde sale_items
    final saleIds = allSales.map((s) => s.id).toList();
    final topProducts = <String, _ProductAcc>{};
    if (saleIds.isNotEmpty) {
      final items = await (_db.select(_db.saleItemsTable)
            ..where((t) => t.saleId.isIn(saleIds)))
          .get();
      for (final item in items) {
        final p =
            topProducts.putIfAbsent(item.productName, () => _ProductAcc());
        p.quantity += item.quantity;
        p.revenue += item.subtotal;
      }
    }
    final topList = topProducts.entries
        .map((e) => TopProduct(
            name: e.key, quantity: e.value.quantity, revenue: e.value.revenue))
        .toList()
      ..sort((a, b) => b.revenue.compareTo(a.revenue));

    // Drift no soporta comparar dos columnas directamente en where,
    // así que cargamos todos los activos y filtramos en Dart.
    final lowStockAll = await (_db.select(_db.productsTable)
          ..where((t) =>
              t.tenantId.equals(tenantId) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.stock)]))
        .get();

    final lowStock = lowStockAll
        .where((p) => p.stock <= p.minStock)
        .take(10)
        .map((p) => LowStockProduct(
              id: p.remoteId ?? p.id.toString(),
              name: p.name,
              stock: p.stock,
              minStock: p.minStock,
            ))
        .toList();

    return StatsData(
      period: period,
      totalSales: totalCount,
      totalRevenue: totalRevenue,
      averageTicket: avgTicket,
      revenueChange: revenueChange,
      salesCountChange: countChange,
      salesByDay: salesByDay,
      salesByPaymentMethod: salesByPaymentMethod,
      topProducts: topList.take(5).toList(),
      lowStockProducts: lowStock,
    );
  }
}

class _MethodAcc {
  double revenue = 0;
  int count = 0;
}

class _ProductAcc {
  int quantity = 0;
  double revenue = 0;
}
