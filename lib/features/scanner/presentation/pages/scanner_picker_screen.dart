import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/barcode_scanner_widget.dart';

/// Scanner multi-escaneo para el POS: escanea varios códigos, muestra lista
/// con nombres de productos y confirma para hacer pop con la lista de códigos.
class ScannerPickerScreen extends StatefulWidget {
  const ScannerPickerScreen({super.key, this.nameResolver});

  /// Callback opcional para resolver el nombre de un producto por su código.
  final Future<String?> Function(String barcode)? nameResolver;

  @override
  State<ScannerPickerScreen> createState() => _ScannerPickerScreenState();
}

class _ScannerPickerScreenState extends State<ScannerPickerScreen> {
  // barcode → cantidad escaneada
  final Map<String, int> _scanned = {};
  // barcode → nombre de producto (resuelto async)
  final Map<String, String?> _names = {};
  bool _cooldown = false;

  Future<void> _onDetected(String barcode) async {
    if (_cooldown) return;
    setState(() {
      _scanned[barcode] = (_scanned[barcode] ?? 0) + 1;
      _cooldown = true;
    });

    // Resolver nombre si aún no lo tenemos
    if (!_names.containsKey(barcode) && widget.nameResolver != null) {
      final name = await widget.nameResolver!(barcode);
      if (mounted) setState(() => _names[barcode] = name);
    }

    // Pausa breve para evitar doble-escaneo del mismo código
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _cooldown = false);
    });
  }

  void _removeItem(String barcode) {
    setState(() {
      _scanned.remove(barcode);
      _names.remove(barcode);
    });
  }

  void _confirm() {
    // Devuelve lista plana: cada código repetido según su cantidad
    final List<String> result = [
      for (final entry in _scanned.entries)
        for (int i = 0; i < entry.value; i++) entry.key,
    ];
    context.pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = _scanned.values.fold(0, (a, b) => a + b);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text('Escanear productos'),
        actions: [
          if (_scanned.isNotEmpty)
            TextButton(
              onPressed: _confirm,
              child: Text(
                'Listo ($totalItems)',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                BarcodeScannerWidget(onDetected: _onDetected),
                // Overlay de cooldown
                if (_cooldown)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.greenAccent, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Escaneado',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                const Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Apunta al código de barras del producto',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),

          // Panel de items escaneados
          if (_scanned.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                border: Border(
                    top: BorderSide(color: Colors.white24, width: 1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$totalItems producto${totalItems == 1 ? '' : 's'} escaneado${totalItems == 1 ? '' : 's'}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                        ),
                        TextButton.icon(
                          onPressed: _confirm,
                          icon: const Icon(Icons.check,
                              color: Colors.greenAccent, size: 18),
                          label: const Text(
                            'Confirmar',
                            style: TextStyle(color: Colors.greenAccent),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      padding:
                          const EdgeInsets.only(bottom: 8, left: 8, right: 8),
                      children: _scanned.entries.map((entry) {
                        final barcode = entry.key;
                        final qty = entry.value;
                        final name = _names[barcode];
                        final displayName = name ?? barcode;
                        final isResolved = name != null;
                        return ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          leading: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withAlpha(30),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '$qty',
                                style: const TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                            ),
                          ),
                          title: Text(
                            displayName,
                            style: TextStyle(
                              color: isResolved ? Colors.white : Colors.white60,
                              fontSize: 13,
                              fontStyle: isResolved
                                  ? FontStyle.normal
                                  : FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: isResolved
                              ? null
                              : const Text(
                                  'Producto no encontrado',
                                  style: TextStyle(
                                      color: Colors.orangeAccent, fontSize: 11),
                                ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.white38, size: 18),
                            onPressed: () => _removeItem(barcode),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
