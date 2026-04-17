import 'package:flutter/material.dart';
import '../../features/products/domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onDelete,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icono / stock badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: product.isLowStock
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: product.isLowStock
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    if (product.barcode != null)
                      Text(product.barcode!,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _StockBadge(stock: product.stock, isLow: product.isLowStock),
                        const SizedBox(width: 8),
                        if (!product.isActive)
                          _Badge(label: 'Inactivo', color: const Color(0xFF6B7280)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B82F6)),
                  ),
                  if (onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          size: 20, color: Color(0xFFEF4444)),
                      onPressed: onDelete,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock, required this.isLow});
  final int stock;
  final bool isLow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isLow ? const Color(0xFFFEF3C7) : const Color(0xFFD1FAE5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Stock: $stock',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: isLow ? const Color(0xFFD97706) : const Color(0xFF059669),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w500, color: color)),
    );
  }
}
