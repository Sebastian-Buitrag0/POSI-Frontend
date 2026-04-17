import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../features/sales/domain/entities/sale.dart';
import '../../core/utils/currency_formatter.dart';

class ReceiptWidget extends StatelessWidget {
  const ReceiptWidget({super.key, required this.sale, required this.onClose});

  final Sale sale;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(sale.createdAt);
    final paymentLabel = switch (sale.paymentMethod) {
      PaymentMethod.cash => 'Efectivo',
      PaymentMethod.card => 'Tarjeta',
      PaymentMethod.transfer => 'Transferencia',
    };

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 48),
          const SizedBox(height: 8),
          Text('Venta completada',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text('Folio: ${sale.saleNumber}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          Text(dateStr,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
          const Divider(height: 24),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sale.items.length,
              itemBuilder: (_, i) {
                final item = sale.items[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(
                              '${item.quantity}x ${item.productName}',
                              style: theme.textTheme.bodyMedium)),
                      Text(CurrencyFormatter.format(item.subtotal),
                          style: theme.textTheme.bodyMedium),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 16),
          _TotalRow('Subtotal', sale.subtotal, theme),
          _TotalRow('IVA (16%)', sale.tax, theme),
          _TotalRow('TOTAL', sale.total, theme, bold: true, large: true),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(paymentLabel,
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Nueva venta'),
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(this.label, this.amount, this.theme,
      {this.bold = false, this.large = false});

  final String label;
  final double amount;
  final ThemeData theme;
  final bool bold;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final style = large
        ? theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : bold
            ? theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
            : theme.textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(CurrencyFormatter.format(amount), style: style),
        ],
      ),
    );
  }
}
