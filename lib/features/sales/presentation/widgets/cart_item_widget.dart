import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item.dart';
import '../providers/cart_provider.dart';
import '../../../../core/utils/currency_formatter.dart';

class CartItemWidget extends ConsumerWidget {
  const CartItemWidget({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notifier = ref.read(cartProvider.notifier);

    return Dismissible(
      key: ValueKey(item.productId),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => notifier.removeItem(item.productId),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productName,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(
                      CurrencyFormatter.format(item.unitPrice),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 20,
                    onPressed: () =>
                        notifier.updateQuantity(item.productId, item.quantity - 1),
                  ),
                  GestureDetector(
                    onTap: () => _editQuantity(context, notifier),
                    child: Container(
                      width: 36,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 20,
                    onPressed: item.quantity < item.maxStock
                        ? () => notifier.updateQuantity(
                            item.productId, item.quantity + 1)
                        : null,
                  ),
                ],
              ),
              SizedBox(
                width: 72,
                child: Text(
                  CurrencyFormatter.format(item.subtotal),
                  textAlign: TextAlign.right,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _editQuantity(BuildContext context, CartNotifier notifier) {
    final ctrl = TextEditingController(text: '${item.quantity}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.productName, maxLines: 1, overflow: TextOverflow.ellipsis),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Cantidad'),
          onSubmitted: (_) => _applyQuantity(ctx, ctrl, notifier),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => _applyQuantity(ctx, ctrl, notifier),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _applyQuantity(BuildContext ctx, TextEditingController ctrl, CartNotifier notifier) {
    final qty = int.tryParse(ctrl.text.trim()) ?? 0;
    Navigator.pop(ctx);
    if (qty <= 0) {
      notifier.removeItem(item.productId);
    } else {
      notifier.updateQuantity(item.productId, qty);
    }
  }
}
