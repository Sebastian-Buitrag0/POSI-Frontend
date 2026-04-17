import 'package:flutter/material.dart';
import '../../features/sales/domain/entities/sale.dart';

class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final PaymentMethod selected;
  final void Function(PaymentMethod) onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<PaymentMethod>(
      segments: const [
        ButtonSegment(
          value: PaymentMethod.cash,
          label: Text('Efectivo'),
          icon: Icon(Icons.payments_outlined),
        ),
        ButtonSegment(
          value: PaymentMethod.card,
          label: Text('Tarjeta'),
          icon: Icon(Icons.credit_card),
        ),
        ButtonSegment(
          value: PaymentMethod.transfer,
          label: Text('Transferencia'),
          icon: Icon(Icons.phone_android),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
