import 'package:drift/drift.dart';

enum SyncStatus { pending, synced, conflict }

mixin SyncColumns on Table {
  TextColumn get remoteId => text().nullable().named('remote_id')();
  TextColumn get tenantId => text().named('tenant_id')();
  IntColumn get syncStatus =>
      intEnum<SyncStatus>().named('sync_status').withDefault(const Constant(0))();
  DateTimeColumn get createdAt =>
      dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().named('updated_at').withDefault(currentDateAndTime)();
}
