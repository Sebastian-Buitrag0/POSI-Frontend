import 'package:flutter/material.dart';
import '../../features/sales/domain/entities/sales_summary.dart';
import '../../core/utils/currency_formatter.dart';

class SalesSummaryCard extends StatelessWidget {
  const SalesSummaryCard(
      {super.key, required this.summary, this.title = 'Hoy'});

  final SalesSummary summary;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, size: 18),
                const SizedBox(width: 6),
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            if (summary.totalRevenue > 0)
              _PaymentBreakdownBar(summary: summary),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat(
                  '${summary.totalCount}',
                  'Ventas',
                  Icons.receipt_long,
                  theme,
                ),
                _Stat(
                  CurrencyFormatter.formatWithSymbol(summary.totalRevenue),
                  'Total',
                  Icons.attach_money,
                  theme,
                ),
                _Stat(
                  CurrencyFormatter.formatWithSymbol(summary.averageTicket),
                  'Prom.',
                  Icons.analytics_outlined,
                  theme,
                ),
                _Stat(
                  '${summary.totalItemsSold}',
                  'Artículos',
                  Icons.inventory_2_outlined,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentBreakdownBar extends StatelessWidget {
  const _PaymentBreakdownBar({required this.summary});

  final SalesSummary summary;

  @override
  Widget build(BuildContext context) {
    final total = summary.totalRevenue;
    if (total == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
            height: 8,
            child: Row(
              children: [
                if (summary.cashRevenue > 0)
                  Flexible(
                    flex: (summary.cashRevenue / total * 100).round(),
                    child: Container(color: const Color(0xFF22C55E)),
                  ),
                if (summary.cardRevenue > 0)
                  Flexible(
                    flex: (summary.cardRevenue / total * 100).round(),
                    child: Container(color: const Color(0xFF3B82F6)),
                  ),
                if (summary.transferRevenue > 0)
                  Flexible(
                    flex: (summary.transferRevenue / total * 100).round(),
                    child: Container(color: const Color(0xFFF59E0B)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _LegendDot(const Color(0xFF22C55E), 'Efectivo'),
            const SizedBox(width: 12),
            _LegendDot(const Color(0xFF3B82F6), 'Tarjeta'),
            const SizedBox(width: 12),
            _LegendDot(const Color(0xFFF59E0B), 'Transfer'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot(this.color, this.label);

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 3),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: Colors.grey)),
        ],
      );
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.icon, this.theme);

  final String value;
  final String label;
  final IconData icon;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.primary),
          const SizedBox(height: 2),
          Text(value,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(label,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: Colors.grey)),
        ],
      );
}
