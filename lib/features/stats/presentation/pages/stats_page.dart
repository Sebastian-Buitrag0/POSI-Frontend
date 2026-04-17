import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/stats_provider.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(statsPeriodProvider);
    final state = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _PeriodSelector(selected: period),
        ),
      ),
      body: switch (state) {
        StatsLoading() => const Center(child: CircularProgressIndicator()),
        StatsError(:final message) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 48),
                const SizedBox(height: 8),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      ref.read(statsProvider.notifier).load(period),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
        StatsLoaded(:final data) => RefreshIndicator(
            onRefresh: () =>
                ref.read(statsProvider.notifier).load(period),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _KpiRow(data: data),
                const SizedBox(height: 20),
                _SectionTitle('Ventas últimos 7 días'),
                const SizedBox(height: 12),
                _SalesBarChart(days: data.salesByDay),
                const SizedBox(height: 20),
                if (data.salesByPaymentMethod.isNotEmpty) ...[
                  _SectionTitle('Métodos de pago'),
                  const SizedBox(height: 12),
                  _PaymentPieChart(methods: data.salesByPaymentMethod),
                  const SizedBox(height: 20),
                ],
                if (data.topProducts.isNotEmpty) ...[
                  _SectionTitle('Productos más vendidos'),
                  const SizedBox(height: 8),
                  _TopProductsList(products: data.topProducts),
                  const SizedBox(height: 20),
                ],
                if (data.lowStockProducts.isNotEmpty) ...[
                  _SectionTitle('Stock bajo',
                      color: AppColors.error),
                  const SizedBox(height: 8),
                  _LowStockList(products: data.lowStockProducts),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          ),
      },
    );
  }
}

// ── Period Selector ────────────────────────────────────────────────────────

class _PeriodSelector extends ConsumerWidget {
  const _PeriodSelector({required this.selected});
  final String selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'today', label: Text('Hoy')),
          ButtonSegment(value: 'week', label: Text('7 días')),
          ButtonSegment(value: 'month', label: Text('Mes')),
        ],
        selected: {selected},
        onSelectionChanged: (s) =>
            ref.read(statsPeriodProvider.notifier).state = s.first,
      ),
    );
  }
}

// ── KPI Row ────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({required this.data});
  final StatsData data;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            label: 'Ingresos',
            value: CurrencyFormatter.format(data.totalRevenue),
            change: data.revenueChange,
            icon: Icons.attach_money,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            label: 'Ventas',
            value: '${data.totalSales}',
            change: data.salesCountChange,
            icon: Icons.receipt_long_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _KpiCard(
            label: 'Ticket prom.',
            value: CurrencyFormatter.format(data.averageTicket),
            icon: Icons.shopping_bag_outlined,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.change,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double? change;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = (change ?? 0) >= 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary)),
          if (change != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                  size: 10,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: 2),
                Text(
                  '${change!.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 10,
                    color:
                        isPositive ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Bar Chart ──────────────────────────────────────────────────────────────

class _SalesBarChart extends StatelessWidget {
  const _SalesBarChart({required this.days});
  final List<DailySales> days;

  @override
  Widget build(BuildContext context) {
    final maxRevenue =
        days.map((d) => d.revenue).fold(0.0, (a, b) => a > b ? a : b);
    final theme = Theme.of(context);

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: BarChart(
        BarChartData(
          maxY: maxRevenue == 0 ? 100 : maxRevenue * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxRevenue == 0 ? 50 : maxRevenue * 0.4,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.grey.withAlpha(30),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= days.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(days[i].date,
                        style: const TextStyle(fontSize: 9)),
                  );
                },
                reservedSize: 22,
              ),
            ),
            leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          barGroups: days.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.revenue,
                  color: AppColors.primary,
                  width: 18,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                  BarTooltipItem(
                CurrencyFormatter.format(rod.toY),
                const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pie Chart ──────────────────────────────────────────────────────────────

class _PaymentPieChart extends StatefulWidget {
  const _PaymentPieChart({required this.methods});
  final List<PaymentMethodStat> methods;

  @override
  State<_PaymentPieChart> createState() => _PaymentPieChartState();
}

class _PaymentPieChartState extends State<_PaymentPieChart> {
  int _touched = -1;

  static const _colors = [
    AppColors.primary,
    AppColors.secondary,
    AppColors.accent,
    AppColors.info,
    AppColors.success,
  ];

  static String _label(String method) => switch (method.toLowerCase()) {
        'cash' => 'Efectivo',
        'card' => 'Tarjeta',
        'transfer' => 'Transferencia',
        _ => method,
      };

  @override
  Widget build(BuildContext context) {
    final total = widget.methods.fold(0.0, (a, b) => a + b.revenue);
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 140,
            width: 140,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          response == null ||
                          response.touchedSection == null) {
                        _touched = -1;
                        return;
                      }
                      _touched = response
                          .touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: widget.methods.asMap().entries.map((e) {
                  final isTouch = e.key == _touched;
                  final pct = total > 0
                      ? (e.value.revenue / total * 100)
                      : 0.0;
                  return PieChartSectionData(
                    color: _colors[e.key % _colors.length],
                    value: e.value.revenue,
                    radius: isTouch ? 50 : 42,
                    title: '${pct.toStringAsFixed(0)}%',
                    titleStyle: TextStyle(
                      fontSize: isTouch ? 13 : 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.methods.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _colors[e.key % _colors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _label(e.value.method),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(e.value.revenue),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top Products ───────────────────────────────────────────────────────────

class _TopProductsList extends StatelessWidget {
  const _TopProductsList({required this.products});
  final List<TopProduct> products;

  @override
  Widget build(BuildContext context) {
    final maxQty = products.map((p) => p.quantity).fold(0, (a, b) => a > b ? a : b);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(30)),
      ),
      child: Column(
        children: products.asMap().entries.map((e) {
          final p = e.value;
          final pct = maxQty > 0 ? p.quantity / maxQty : 0.0;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(p.name,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Text('${p.quantity} uds',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Text(CurrencyFormatter.format(p.revenue),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 4,
                    backgroundColor: AppColors.primary.withAlpha(20),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                if (e.key < products.length - 1)
                  const Divider(height: 16, thickness: 0.5),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Low Stock ──────────────────────────────────────────────────────────────

class _LowStockList extends StatelessWidget {
  const _LowStockList({required this.products});
  final List<LowStockProduct> products;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withAlpha(60)),
      ),
      child: Column(
        children: products.asMap().entries.map((e) {
          final p = e.value;
          final isOut = p.stock == 0;
          return Column(
            children: [
              ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: (isOut ? AppColors.error : Colors.orange)
                      .withAlpha(20),
                  child: Text(
                    '${p.stock}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isOut ? AppColors.error : Colors.orange,
                    ),
                  ),
                ),
                title: Text(p.name,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis),
                subtitle: Text(
                  isOut ? 'Sin stock' : 'Mínimo: ${p.minStock}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isOut ? AppColors.error : Colors.orange,
                  ),
                ),
                trailing: isOut
                    ? const Chip(
                        label: Text('AGOTADO',
                            style: TextStyle(
                                fontSize: 10, color: AppColors.error)),
                        backgroundColor: Color(0x1FEF4444),
                        side: BorderSide.none,
                        padding: EdgeInsets.zero,
                      )
                    : null,
              ),
              if (e.key < products.length - 1)
                const Divider(height: 1, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.color = AppColors.textSecondary});
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 0.8,
      ),
    );
  }
}
