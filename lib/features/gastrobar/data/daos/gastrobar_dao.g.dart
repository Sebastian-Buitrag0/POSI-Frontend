// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gastrobar_dao.dart';

// ignore_for_file: type=lint
mixin _$GastrobarDaoMixin on DatabaseAccessor<AppDatabase> {
  $MesasTableTable get mesasTable => attachedDatabase.mesasTable;
  $ComandasTableTable get comandasTable => attachedDatabase.comandasTable;
  $ComandaItemsTableTable get comandaItemsTable =>
      attachedDatabase.comandaItemsTable;
  GastrobarDaoManager get managers => GastrobarDaoManager(this);
}

class GastrobarDaoManager {
  final _$GastrobarDaoMixin _db;
  GastrobarDaoManager(this._db);
  $$MesasTableTableTableManager get mesasTable =>
      $$MesasTableTableTableManager(_db.attachedDatabase, _db.mesasTable);
  $$ComandasTableTableTableManager get comandasTable =>
      $$ComandasTableTableTableManager(_db.attachedDatabase, _db.comandasTable);
  $$ComandaItemsTableTableTableManager get comandaItemsTable =>
      $$ComandaItemsTableTableTableManager(
        _db.attachedDatabase,
        _db.comandaItemsTable,
      );
}
