import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
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
  } on DioException catch (e) {
    final msg = e.response?.statusCode == 402
        ? 'Límite de plan alcanzado. Actualiza tu plan para sincronizar más productos.'
        : 'Error de conexión al sincronizar.';
    state = state.copyWith(isSyncing: false, error: msg);
  } catch (e) {
    state = state.copyWith(isSyncing: false, error: 'Error al sincronizar.');
  }
  }
}
