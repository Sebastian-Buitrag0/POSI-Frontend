import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sales_summary.dart';
import '../providers/sales_history_provider.dart';

class SalesHistoryPage extends ConsumerWidget {
  const SalesHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(salesHistoryProvider);
    final notifier = ref.read(salesHistoryProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Rango personalizado',
            onPressed: () => _showDateRangePicker(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          _FilterChips(
            selected: state.filter,
            onSelected: notifier.setFilter,
          ),
          if (!state.isLoading && state.error == null)
            _SummaryBanner(summary: state.summary),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.error != null
                    ? _ErrorView(
                        message: state.error!, onRetry: notifier.refresh)
                    : state.sales.isEmpty
                        ? const _EmptyHistoryView()
                        : RefreshIndicator(
                            onRefresh: notifier.refresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: state.sales.length,
                              itemBuilder: (_, i) =>
                                  _SaleCard(sale: state.sales[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDateRangePicker(
      BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: now,
    );
    if (picked != null) {
      ref
          .read(salesHistoryProvider.notifier)
          .setCustomRange(picked.start, picked.end);
    }
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final DateRangeFilter selected;
  final void Function(DateRangeFilter) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: DateRangeFilter.values
            .where((f) => f != DateRangeFilter.custom)
            .map((f) {
          final label = switch (f) {
            DateRangeFilter.today => 'Hoy',
            DateRangeFilter.week => 'Semana',
            DateRangeFilter.month => 'Mes',
            DateRangeFilter.custom => 'Personalizado',
          };
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: selected == f,
              onSelected: (_) => onSelected(f),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.summary});

  final SalesSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.primaryContainer.withAlpha(80),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Metric('Ventas', '${summary.totalCount}', Icons.receipt_long),
          _Metric(
            'Total',
            CurrencyFormatter.formatWithSymbol(summary.totalRevenue),
            Icons.attach_money,
          ),
          _Metric(
            'Ticket Prom.',
            CurrencyFormatter.formatWithSymbol(summary.averageTicket),
            Icons.analytics_outlined,
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(height: 2),
        Text(value,
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label,
            style:
                theme.textTheme.labelSmall?.copyWith(color: Colors.grey)),
      ],
    );
  }
}

class _SaleCard extends StatelessWidget {
  const _SaleCard({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('HH:mm').format(sale.createdAt);
    final dateStr = DateFormat('dd/MM/yy').format(sale.createdAt);
    final payIcon = switch (sale.paymentMethod) {
      PaymentMethod.cash => Icons.payments_outlined,
      PaymentMethod.card => Icons.credit_card,
      PaymentMethod.transfer => Icons.phone_android,
    };

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(payIcon,
              size: 18, color: theme.colorScheme.primary),
        ),
        title: Text(
          sale.saleNumber,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle:
            Text('$dateStr  $timeStr · ${sale.items.length} ítem(s)'),
        trailing: Text(
          CurrencyFormatter.formatWithSymbol(sale.total),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...sale.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.productName}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.formatWithSymbol(item.subtotal),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Subtotal', style: theme.textTheme.bodySmall),
                    Text(CurrencyFormatter.formatWithSymbol(sale.subtotal),
                        style: theme.textTheme.bodySmall),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('IVA', style: theme.textTheme.bodySmall),
                    Text(CurrencyFormatter.formatWithSymbol(sale.tax),
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text('Sin ventas en este período',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey)),
          ],
        ),
      );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
}
