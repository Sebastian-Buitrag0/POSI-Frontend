import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/gastrobar_local_repository.dart';

class TablesNotifier extends AsyncNotifier<List<MesasTableData>> {
  @override
  Future<List<MesasTableData>> build() async {
    final auth = ref.watch(authProvider);
    if (auth is! AuthAuthenticated) {
      throw Exception('Not authenticated');
    }

    final repo = ref.read(gastrobarLocalRepositoryProvider);

    // Trigger background fetch from server
    unawaited(repo.fetchAndSyncTables(auth.user.tenantId));

    final stream = repo.watchActiveTables(auth.user.tenantId);

    final sub = stream.listen(
      (data) => state = AsyncData(data),
      onError: (e, st) => state = AsyncError(e, st),
    );

    ref.onDispose(sub.cancel);

    return stream.first;
  }

  Future<void> refresh() async {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) return;
    final repo = ref.read(gastrobarLocalRepositoryProvider);
    await repo.fetchAndSyncTables(auth.user.tenantId);
  }

  Future<void> createTable(String name, int capacity) async {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) return;
    final repo = ref.read(gastrobarLocalRepositoryProvider);
    await repo.createTable(name, capacity, auth.user.tenantId);
  }

  Future<void> deleteTable(int localId, String? remoteId) async {
    final repo = ref.read(gastrobarLocalRepositoryProvider);
    await repo.deleteTable(localId, remoteId);
  }

  Future<String> openOrder(String tableId) async {
    final auth = ref.read(authProvider);
    if (auth is! AuthAuthenticated) throw Exception('Not authenticated');
    final repo = ref.read(gastrobarLocalRepositoryProvider);

    int localTableId;
    final parsed = int.tryParse(tableId);
    if (parsed != null) {
      localTableId = parsed;
    } else {
      final table = await repo.dao.getTableByRemoteId(tableId);
      if (table == null) throw Exception('Table not found');
      localTableId = table.id;
    }

    final localOrderId = await repo.openOrder(localTableId, auth.user.tenantId);
    return localOrderId.toString();
  }
}

final tablesProvider =
    AsyncNotifierProvider<TablesNotifier, List<MesasTableData>>(
  TablesNotifier.new,
);
