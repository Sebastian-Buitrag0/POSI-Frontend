import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/gastrobar_repository.dart';
import '../../domain/entities/table_model.dart';

class TablesNotifier extends AsyncNotifier<List<TableModel>> {
  @override
  Future<List<TableModel>> build() async {
    return _fetch();
  }

  Future<List<TableModel>> _fetch() async {
    final repo = ref.read(gastrobarRepositoryProvider);
    return repo.getTables();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<void> createTable(String name, int capacity) async {
    final repo = ref.read(gastrobarRepositoryProvider);
    await repo.createTable(name, capacity);
    await refresh();
  }

  Future<String> openOrder(String tableId) async {
    final repo = ref.read(gastrobarRepositoryProvider);
    final order = await repo.openOrder(tableId);
    await refresh();
    return order.id;
  }
}

final tablesProvider =
    AsyncNotifierProvider<TablesNotifier, List<TableModel>>(
  TablesNotifier.new,
);
