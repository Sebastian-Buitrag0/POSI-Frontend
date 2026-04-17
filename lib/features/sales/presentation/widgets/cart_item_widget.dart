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
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${item.quantity}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
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
}
