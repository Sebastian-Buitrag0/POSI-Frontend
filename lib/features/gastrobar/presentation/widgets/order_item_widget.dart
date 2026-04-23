import 'package:flutter/material.dart';
import '../../domain/entities/order_model.dart';

class OrderItemWidget extends StatelessWidget {
  const OrderItemWidget({
    super.key,
    required this.item,
    this.onCancel,
  });

  final OrderItemModel item;
  final VoidCallback? onCancel;

  Color get _statusColor {
    return switch (item.status) {
      'pending' => Colors.grey,
      'sent' => Colors.orange,
      'delivered' => Colors.green,
      'cancelled' => Colors.red,
      _ => Colors.grey,
    };
  }

  String get _statusLabel {
    return switch (item.status) {
      'pending' => 'Pendiente',
      'sent' => 'En cocina',
      'delivered' => 'Entregado',
      'cancelled' => 'Cancelado',
      _ => item.status,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDelivered = item.status == 'delivered';
    final isCancelled = item.status == 'cancelled';

    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 14,
        backgroundColor: _statusColor.withValues(alpha: 0.15),
        child: Icon(
          switch (item.status) {
            'pending' => Icons.hourglass_empty,
            'sent' => Icons.room_service,
            'delivered' => Icons.check,
            'cancelled' => Icons.close,
            _ => Icons.help_outline,
          },
          size: 14,
          color: _statusColor,
        ),
      ),
      title: Text(
        item.productName,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          decoration: isDelivered || isCancelled
              ? TextDecoration.lineThrough
              : null,
          color: isCancelled ? Colors.grey : null,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.quantity} x \$${item.unitPrice.toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall,
          ),
          if (item.notes != null && item.notes!.isNotEmpty)
            Text(
              item.notes!,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${item.subtotal.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (onCancel != null && item.status == 'pending')
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
              onPressed: onCancel,
              iconSize: 20,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
