import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../sales/data/repositories/sales_repository_provider.dart';
import '../../../sales/domain/entities/sale.dart';
import '../../../sales/domain/entities/sales_summary.dart';

class CashRegisterState {
  const CashRegisterState({
    this.isOpen = false,
    this.isRestoring = true,
    this.openingCash = 0,
    this.openedAt,
    this.sales = const [],
    this.summary = SalesSummary.empty,
    this.isLoading = false,
    this.error,
  });

  final bool isOpen;
  final bool isRestoring;
  final double openingCash;
  final DateTime? openedAt;
  final List<Sale> sales;
  final SalesSummary summary;
  final bool isLoading;
  final String? error;

  double get expectedCash => openingCash + summary.cashRevenue;

  CashRegisterState copyWith({
    bool? isOpen,
    bool? isRestoring,
    double? openingCash,
    DateTime? openedAt,
    List<Sale>? sales,
    SalesSummary? summary,
    bool? isLoading,
    String? error,
  }) =>
      CashRegisterState(
        isOpen: isOpen ?? this.isOpen,
        isRestoring: isRestoring ?? this.isRestoring,
        openingCash: openingCash ?? this.openingCash,
        openedAt: openedAt ?? this.openedAt,
        sales: sales ?? this.sales,
        summary: summary ?? this.summary,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}

final cashRegisterProvider =
    StateNotifierProvider<CashRegisterNotifier, CashRegisterState>(
  (ref) => CashRegisterNotifier(ref),
);

class CashRegisterNotifier extends StateNotifier<CashRegisterState> {
  CashRegisterNotifier(this._ref) : super(const CashRegisterState()) {
    _restoreFromStorage();
  }

  final Ref _ref;
  static const _storage = FlutterSecureStorage();
  static const _keyStatus = 'posi_cr_status';
  static const _keyOpeningCash = 'posi_cr_opening_cash';
  static const _keyOpenedAt = 'posi_cr_opened_at';

  Future<void> _restoreFromStorage() async {
    final status = await _storage.read(key: _keyStatus);
    if (status != 'open') {
      state = state.copyWith(isRestoring: false);
      return;
    }

    final cashStr = await _storage.read(key: _keyOpeningCash) ?? '0';
    final atStr = await _storage.read(key: _keyOpenedAt) ?? '';

    final openingCash = double.tryParse(cashStr) ?? 0;
    final openedAt = atStr.isNotEmpty ? DateTime.tryParse(atStr) : null;

    state = state.copyWith(
      isOpen: true,
      isRestoring: false,
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

    // Sync to backend (best effort)
    try {
      final api = _ref.read(apiClientProvider);
      await api.post(ApiConstants.cashRegisterOpen,
          data: {'openingCash': initialCash, 'notes': null});
    } on DioException {
      // Offline: local state is already saved
    }

    await _loadSales();
  }

  Future<void> clearOnLogout() async {
    await _storage.delete(key: _keyStatus);
    await _storage.delete(key: _keyOpeningCash);
    await _storage.delete(key: _keyOpenedAt);
    state = const CashRegisterState(isRestoring: false);
  }

  Future<void> closeRegister({double? actualCash}) async {
    // Sync to backend (best effort)
    try {
      final api = _ref.read(apiClientProvider);
      await api.post(ApiConstants.cashRegisterClose, data: {
        'actualCash': actualCash ?? state.expectedCash,
        'notes': null,
      });
    } on DioException {
      // Offline
    }

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
