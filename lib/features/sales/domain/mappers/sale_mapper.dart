import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/sync_mixin.dart';
import '../entities/cart_item.dart';
import '../entities/sale.dart';

extension SaleItemMapper on SaleItemsTableData {
  SaleItem toDomain() => SaleItem(
    id: id,
    saleId: saleId,
    productId: productId,
    productName: productName,
    quantity: quantity,
    unitPrice: unitPrice,
    subtotal: subtotal,
  );
}

extension SaleMapper on SalesTableData {
  Sale toDomain(List<SaleItem> items) => Sale(
    id: id,
    saleNumber: saleNumber,
    items: items,
    subtotal: subtotal,
    tax: tax,
    total: total,
    paymentMethod: _parsePaymentMethod(paymentMethod),
    status: _parseSaleStatus(status),
    tenantId: tenantId,
    notes: notes,
    createdAt: createdAt,
  );

  static PaymentMethod _parsePaymentMethod(String s) {
    return switch (s) {
      'card' => PaymentMethod.card,
      'transfer' => PaymentMethod.transfer,
      _ => PaymentMethod.cash,
    };
  }

  static SaleStatus _parseSaleStatus(String s) {
    return switch (s) {
      'cancelled' => SaleStatus.cancelled,
      'refunded' => SaleStatus.refunded,
      _ => SaleStatus.completed,
    };
  }
}

extension CartItemToCompanion on CartItem {
  SaleItemsTableCompanion toCompanion({
    required int saleId,
    required String tenantId,
  }) => SaleItemsTableCompanion(
    saleId: Value(saleId),
    productId: Value(productId),
    productName: Value(productName),
    unitPrice: Value(unitPrice),
    quantity: Value(quantity),
    subtotal: Value(subtotal),
    tenantId: Value(tenantId),
    syncStatus: const Value(SyncStatus.pending),
  );
}
