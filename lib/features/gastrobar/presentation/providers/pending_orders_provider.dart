import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/daos/gastrobar_dao.dart' show PendingPaymentOrder;
import '../../data/repositories/gastrobar_local_repository.dart';

final pendingPaymentOrdersProvider =
    StreamProvider<List<PendingPaymentOrder>>((ref) {
  final auth = ref.watch(authProvider);
  if (auth is! AuthAuthenticated) return const Stream.empty();

  final repo = ref.watch(gastrobarLocalRepositoryProvider);
  return repo.watchPendingPaymentOrders(auth.user.tenantId);
});
