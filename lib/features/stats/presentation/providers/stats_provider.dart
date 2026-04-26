import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/local_stats_service.dart';

// ── Models ─────────────────────────────────────────────────────────────────

class StatsData {
  const StatsData({
    required this.period,
    required this.totalSales,
    required this.totalRevenue,
    required this.averageTicket,
    required this.revenueChange,
    required this.salesCountChange,
    required this.salesByDay,
    required this.salesByPaymentMethod,
    required this.topProducts,
    required this.lowStockProducts,
  });

  final String period;
  final int totalSales;
  final double totalRevenue;
  final double averageTicket;
  final double revenueChange;
  final double salesCountChange;
  final List<DailySales> salesByDay;
  final List<PaymentMethodStat> salesByPaymentMethod;
  final List<TopProduct> topProducts;
  final List<LowStockProduct> lowStockProducts;

  factory StatsData.fromJson(Map<String, dynamic> json) => StatsData(
        period: json['period'] as String,
        totalSales: json['totalSales'] as int,
        totalRevenue: (json['totalRevenue'] as num).toDouble(),
        averageTicket: (json['averageTicket'] as num).toDouble(),
        revenueChange: (json['revenueChange'] as num).toDouble(),
        salesCountChange: (json['salesCountChange'] as num).toDouble(),
        salesByDay: (json['salesByDay'] as List)
            .map((e) => DailySales.fromJson(e as Map<String, dynamic>))
            .toList(),
        salesByPaymentMethod: (json['salesByPaymentMethod'] as List)
            .map((e) =>
                PaymentMethodStat.fromJson(e as Map<String, dynamic>))
            .toList(),
        topProducts: (json['topProducts'] as List)
            .map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
            .toList(),
        lowStockProducts: (json['lowStockProducts'] as List)
            .map((e) => LowStockProduct.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class DailySales {
  const DailySales({required this.date, required this.revenue, required this.count});
  final String date;
  final double revenue;
  final int count;
  factory DailySales.fromJson(Map<String, dynamic> json) => DailySales(
        date: json['date'] as String,
        revenue: (json['revenue'] as num).toDouble(),
        count: json['count'] as int,
      );
}

class PaymentMethodStat {
  const PaymentMethodStat(
      {required this.method, required this.revenue, required this.count});
  final String method;
  final double revenue;
  final int count;
  factory PaymentMethodStat.fromJson(Map<String, dynamic> json) =>
      PaymentMethodStat(
        method: json['method'] as String,
        revenue: (json['revenue'] as num).toDouble(),
        count: json['count'] as int,
      );
}

class TopProduct {
  const TopProduct(
      {required this.name, required this.quantity, required this.revenue});
  final String name;
  final int quantity;
  final double revenue;
  factory TopProduct.fromJson(Map<String, dynamic> json) => TopProduct(
        name: json['name'] as String,
        quantity: json['quantity'] as int,
        revenue: (json['revenue'] as num).toDouble(),
      );
}

class LowStockProduct {
  const LowStockProduct(
      {required this.id,
      required this.name,
      required this.stock,
      required this.minStock});
  final String id;
  final String name;
  final int stock;
  final int minStock;
  factory LowStockProduct.fromJson(Map<String, dynamic> json) =>
      LowStockProduct(
        id: json['id'] as String,
        name: json['name'] as String,
        stock: json['stock'] as int,
        minStock: json['minStock'] as int,
      );
}

// ── State ──────────────────────────────────────────────────────────────────

sealed class StatsState {
  const StatsState();
}

class StatsLoading extends StatsState {
  const StatsLoading();
}

class StatsLoaded extends StatsState {
  const StatsLoaded(this.data);
  final StatsData data;
}

class StatsError extends StatsState {
  const StatsError(this.message);
  final String message;
}

// ── Provider ───────────────────────────────────────────────────────────────

final statsPeriodProvider = StateProvider<String>((ref) => 'week');

final statsProvider =
    StateNotifierProvider.autoDispose<StatsNotifier, StatsState>((ref) {
  final db = ref.watch(databaseProvider);
  final auth = ref.watch(authProvider);
  final period = ref.watch(statsPeriodProvider);
  final notifier = StatsNotifier(LocalStatsService(db), auth);
  notifier.load(period);
  return notifier;
});

// ── Notifier ───────────────────────────────────────────────────────────────

class StatsNotifier extends StateNotifier<StatsState> {
  StatsNotifier(this._service, this._auth) : super(const StatsLoading());

  final LocalStatsService _service;
  final AuthState _auth;

  Future<void> load(String period) async {
    if (_auth is! AuthAuthenticated) {
      state = const StatsError('No autenticado');
      return;
    }
    state = const StatsLoading();
    try {
      final data = await _service.compute(
        (_auth).user.tenantId,
        period,
      );
      state = StatsLoaded(data);
    } catch (e) {
      state = StatsError(e.toString());
    }
  }
}
