import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/cash_register_provider.dart';

class CashRegisterPage extends ConsumerWidget {
  const CashRegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cashRegisterProvider);

    if (state.isLoading && !state.isOpen) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return state.isOpen
        ? _CloseRegisterView(state: state)
        : const _OpenRegisterView();
  }
}

class _OpenRegisterView extends ConsumerStatefulWidget {
  const _OpenRegisterView();

  @override
  ConsumerState<_OpenRegisterView> createState() =>
      _OpenRegisterViewState();
}

class _OpenRegisterViewState extends ConsumerState<_OpenRegisterView> {
  final _cashController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Apertura de Caja')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_open,
                    size: 64, color: theme.colorScheme.primary),
                const SizedBox(height: 24),
                Text('Abrir caja',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  'Ingresa el monto inicial en caja',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _cashController,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Monto inicial',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                    hintText: '0.00',
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Ingresa el monto';
                    }
                    if (double.tryParse(v) == null) {
                      return 'Monto inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    final amount = double.parse(_cashController.text);
                    ref
                        .read(cashRegisterProvider.notifier)
                        .openRegister(amount);
                  },
                  icon: const Icon(Icons.login),
                  label: const Text('APERTURAR CAJA'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseRegisterView extends ConsumerStatefulWidget {
  const _CloseRegisterView({required this.state});

  final CashRegisterState state;

  @override
  ConsumerState<_CloseRegisterView> createState() =>
      _CloseRegisterViewState();
}

class _CloseRegisterViewState extends ConsumerState<_CloseRegisterView> {
  final _realCashController = TextEditingController();

  double get _realCash =>
      double.tryParse(_realCashController.text) ?? 0;
  double get _difference => _realCash - widget.state.expectedCash;
  bool get _hasDiscrepancy => _difference.abs() > 50;

  @override
  void dispose() {
    _realCashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.state;
    final openedStr = state.openedAt != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(state.openedAt!)
        : '—';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cierre de Caja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(cashRegisterProvider.notifier).refresh(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Apertura'),
                subtitle: Text(openedStr),
                trailing: Text(
                  CurrencyFormatter.formatWithSymbol(state.openingCash),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resumen del período',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _SummaryRow('Total ventas',
                        '${state.summary.totalCount}', Icons.receipt_long),
                    _SummaryRow(
                        'Ingresos totales',
                        CurrencyFormatter.formatWithSymbol(
                            state.summary.totalRevenue),
                        Icons.monetization_on_outlined),
                    _SummaryRow(
                        'Efectivo vendido',
                        CurrencyFormatter.formatWithSymbol(
                            state.summary.cashRevenue),
                        Icons.payments_outlined),
                    _SummaryRow(
                        'Tarjeta/Transfer',
                        CurrencyFormatter.formatWithSymbol(
                            state.summary.cardRevenue +
                                state.summary.transferRevenue),
                        Icons.credit_card),
                    const Divider(height: 16),
                    _SummaryRow(
                        'Efectivo esperado en caja',
                        CurrencyFormatter.formatWithSymbol(
                            state.expectedCash),
                        Icons.account_balance_wallet,
                        bold: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Conteo físico',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _realCashController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Efectivo contado manualmente',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                        hintText: '0.00',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    if (_realCashController.text.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Diferencia:',
                              style: theme.textTheme.titleSmall),
                          Text(
                            '${_difference >= 0 ? '+' : ''}${CurrencyFormatter.formatWithSymbol(_difference)}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _difference >= 0
                                  ? const Color(0xFF22C55E)
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      if (_hasDiscrepancy)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber,
                                  color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Discrepancia mayor a \$50. Verifica el conteo.',
                                  style: theme.textTheme.bodySmall
                                      ?.copyWith(color: Colors.orange),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _confirmClose(context),
              icon: const Icon(Icons.lock),
              label: const Text('CERRAR CAJA'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: _hasDiscrepancy
                    ? Colors.red
                    : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClose(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar caja'),
        content: Text(
          _hasDiscrepancy
              ? '⚠️ Hay una diferencia de ${CurrencyFormatter.formatWithSymbol(_difference.abs())}. ¿Confirmas el cierre?'
              : '¿Confirmar el cierre de caja?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(
                foregroundColor: _hasDiscrepancy ? Colors.red : null),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(cashRegisterProvider.notifier).closeRegister();
            },
            child: const Text('Confirmar cierre'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow(this.label, this.value, this.icon,
      {this.bold = false});

  final String label;
  final String value;
  final IconData icon;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}
