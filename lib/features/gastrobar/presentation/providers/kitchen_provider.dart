import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/daos/gastrobar_dao.dart';
import '../../data/repositories/gastrobar_local_repository.dart';

final kitchenProvider = StreamProvider.autoDispose<List<KitchenItem>>((ref) {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) {
    return Stream.value([]);
  }

  final db = ref.watch(databaseProvider);
  return db.gastrobarDao.watchSentItems(auth.user.tenantId);
});

final kitchenRepositoryProvider = Provider<GastrobarLocalRepository>((ref) {
  return ref.watch(gastrobarLocalRepositoryProvider);
});
