import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../shared/widgets/barcode_scanner_widget.dart';
import '../providers/scanner_provider.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  Color _frameColor = Colors.white;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scannerProvider.notifier).startScanning();
    });
  }

  @override
  void dispose() {
    // autoDispose limpia el provider automáticamente
    // no llamar stopScanning() aquí para evitar crash al navegar
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(scannerProvider, (_, next) {
      if (next is ScannerProductFound) {
        setState(() => _frameColor = const Color(0xFF22C55E));
      } else if (next is ScannerProductNotFound) {
        setState(() => _frameColor = Colors.orange);
      } else if (next is ScannerError) {
        setState(() => _frameColor = Colors.red);
      } else {
        setState(() => _frameColor = Colors.white);
      }
    });

    final state = ref.watch(scannerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Escanear código'),
      ),
      body: Stack(
        children: [
          BarcodeScannerWidget(
            frameColor: _frameColor,
            onDetected: (barcode) =>
                ref.read(scannerProvider.notifier).handleBarcode(barcode),
          ),
          _buildStateOverlay(state),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'Apunta al código de barras o QR',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateOverlay(ScannerState state) {
    switch (state) {
      case ScannerIdle():
      case ScannerScanning():
        return const SizedBox.shrink();
      case ScannerSearching(:final barcode):
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 12),
              Text(barcode, style: const TextStyle(color: Colors.white)),
            ],
          ),
        );
      case ScannerProductFound(:final barcode, :final productId):
        return _ResultOverlay(
          color: const Color(0xFF22C55E),
          icon: Icons.check_circle_outline,
          title: 'Producto encontrado',
          subtitle: barcode,
          primaryLabel: 'Ver producto',
          onPrimary: () => context.push(
            AppRoutes.productDetail.replaceAll(':id', '$productId'),
          ),
          secondaryLabel: 'Escanear otro',
          onSecondary: () => ref.read(scannerProvider.notifier).reset(),
        );
      case ScannerProductNotFound(:final barcode):
        return _ResultOverlay(
          color: Colors.orange,
          icon: Icons.qr_code_scanner,
          title: 'Código no encontrado',
          subtitle: barcode,
          primaryLabel: 'Crear producto',
          onPrimary: () => context.push(
            '${AppRoutes.productDetail.replaceAll(':id', 'new')}?barcode=${Uri.encodeComponent(barcode)}',
          ),
          secondaryLabel: 'Escanear otro',
          onSecondary: () => ref.read(scannerProvider.notifier).reset(),
        );
      case ScannerError(:final message):
        return _ResultOverlay(
          color: Colors.red,
          icon: Icons.error_outline,
          title: 'Error',
          subtitle: message,
          primaryLabel: 'Reintentar',
          onPrimary: () => ref.read(scannerProvider.notifier).reset(),
          secondaryLabel: 'Escanear otro',
          onSecondary: () => ref.read(scannerProvider.notifier).reset(),
        );
    }
  }
}

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withAlpha(220),
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 64, color: color),
                const SizedBox(height: 16),
                Text(title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 24),
                FilledButton(onPressed: onPrimary, child: Text(primaryLabel)),
                const SizedBox(height: 8),
                TextButton(
                    onPressed: onSecondary, child: Text(secondaryLabel)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
