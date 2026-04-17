import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

const _syncInterval = Duration(minutes: 5);

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
    _listenAuth();
    _startPeriodicSync();
  }

  final Ref _ref;
  Timer? _timer;
  bool _didInitialSync = false;

  void _listenConnectivity() {
    Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline) syncNow();
    });
  }

  void _listenAuth() {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (next is AuthAuthenticated && prev is! AuthAuthenticated) {
        // Sync when user just logged in
        _didInitialSync = false;
        syncNow();
      }
    });
    // Also sync immediately if already authenticated at creation time
    final auth = _ref.read(authProvider);
    if (auth is AuthAuthenticated && !_didInitialSync) {
      Future.microtask(syncNow);
    }
  }

  void _startPeriodicSync() {
    _timer = Timer.periodic(_syncInterval, (_) => syncNow());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> syncNow() async {
    if (state.isSyncing) return;

    final authState = _ref.read(authProvider);
    if (authState is! AuthAuthenticated) return;

    _didInitialSync = true;
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
