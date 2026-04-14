class CurrencyFormatter {
  CurrencyFormatter._();

  static String format(double amount) {
    final fixed = amount.toStringAsFixed(2);
    final parts = fixed.split('.');
    final integer = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$integer.${parts[1]}';
  }

  static String formatWithSymbol(double amount) => '\$${format(amount)}';
}
