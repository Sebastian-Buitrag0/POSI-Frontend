import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/sales_repository_provider.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sales_summary.dart';

enum DateRangeFilter { today, week, month, custom }

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

  SalesHistoryState copyWith({
    List<Sale>? sales,
    SalesSummary? summary,
    DateRangeFilter? filter,
    DateTime? customFrom,
    DateTime? customTo,
    bool? isLoading,
    String? error,
  }) =>
      SalesHistoryState(
        sales: sales ?? this.sales,
        summary: summary ?? this.summary,
        filter: filter ?? this.filter,
        customFrom: customFrom ?? this.customFrom,
        customTo: customTo ?? this.customTo,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}

final salesHistoryProvider =
    StateNotifierProvider.autoDispose<SalesHistoryNotifier, SalesHistoryState>(
  (ref) => SalesHistoryNotifier(ref),
);

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
