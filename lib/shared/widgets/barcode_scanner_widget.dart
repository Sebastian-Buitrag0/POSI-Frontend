import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerWidget extends StatefulWidget {
  const BarcodeScannerWidget({
    super.key,
    required this.onDetected,
    this.frameColor = Colors.white,
    this.frameSize = 250.0,
    this.showFlashToggle = true,
  });

  final void Function(String barcode) onDetected;
  final Color frameColor;
  final double frameSize;
  final bool showFlashToggle;

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _laserController;
  late final Animation<double> _laserAnim;

  bool _flashOn = false;

  // Lógica "esperar a que salga del encuadre"
  String? _lockedBarcode;     // código actualmente en el encuadre
  Timer? _releaseTimer;       // temporizador: si no se detecta por 600ms, libera

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = MobileScannerController();

    // Animación del láser: sube y baja indefinidamente
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserAnim = CurvedAnimation(
      parent: _laserController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _releaseTimer?.cancel();
    _controller.dispose();
    _laserController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _controller.stop();
      case AppLifecycleState.resumed:
        _controller.start();
      default:
        break;
    }
  }

  void _handleDetect(BarcodeCapture capture) {
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    // Reinicia el timer de liberación (el código sigue en el encuadre)
    _releaseTimer?.cancel();
    _releaseTimer = Timer(const Duration(milliseconds: 600), () {
      // Nadie detectó el código en 600ms → salió del encuadre
      _lockedBarcode = null;
    });

    // Si es un código nuevo, reportarlo y bloquearlo
    if (raw != _lockedBarcode) {
      _lockedBarcode = raw;
      widget.onDetected(raw);
    }
    // Si es el mismo código que ya está bloqueado → ignorar
  }

  @override
  Widget build(BuildContext context) {
    final frameSize = widget.frameSize;

    return Stack(
      children: [
        // Cámara — nunca se reconstruye por cambios externos
        MobileScanner(
          controller: _controller,
          onDetect: _handleDetect,
        ),

        // Overlay oscuro alrededor del recuadro
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withAlpha(130),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: frameSize,
                  height: frameSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Marco del encuadre
        Center(
          child: Container(
            width: frameSize,
            height: frameSize,
            decoration: BoxDecoration(
              border: Border.all(
                color: _lockedBarcode != null
                    ? Colors.greenAccent
                    : widget.frameColor,
                width: 2.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            // Láser animado dentro del recuadre
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AnimatedBuilder(
                animation: _laserAnim,
                builder: (context, _) {
                  return Stack(
                    children: [
                      Positioned(
                        top: _laserAnim.value * (frameSize - 4),
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                (_lockedBarcode != null
                                    ? Colors.greenAccent
                                    : Colors.redAccent),
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_lockedBarcode != null
                                        ? Colors.greenAccent
                                        : Colors.redAccent)
                                    .withAlpha(100),
                                blurRadius: 6,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),

        // Esquinas decorativas del marco
        Center(
          child: SizedBox(
            width: frameSize,
            height: frameSize,
            child: CustomPaint(painter: _CornerPainter(
              color: _lockedBarcode != null ? Colors.greenAccent : widget.frameColor,
            )),
          ),
        ),

        // Flash toggle
        if (widget.showFlashToggle)
          Positioned(
            top: 16,
            right: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: Icon(
                  _flashOn ? Icons.flash_on : Icons.flash_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  _controller.toggleTorch();
                  setState(() => _flashOn = !_flashOn);
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// Pinta las 4 esquinas del recuadre con líneas más gruesas.
class _CornerPainter extends CustomPainter {
  _CornerPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 24.0;
    const r = 12.0;

    // Top-left
    canvas.drawLine(Offset(r, 0), Offset(r + len, 0), paint);
    canvas.drawLine(Offset(0, r), Offset(0, r + len), paint);
    canvas.drawArc(const Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14, -1.57, false, paint);

    // Top-right
    canvas.drawLine(Offset(size.width - r - len, 0), Offset(size.width - r, 0), paint);
    canvas.drawLine(Offset(size.width, r), Offset(size.width, r + len), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, 0, r * 2, r * 2), 4.71, -1.57, false, paint);

    // Bottom-left
    canvas.drawLine(Offset(r, size.height), Offset(r + len, size.height), paint);
    canvas.drawLine(Offset(0, size.height - r), Offset(0, size.height - r - len), paint);
    canvas.drawArc(Rect.fromLTWH(0, size.height - r * 2, r * 2, r * 2), 1.57, -1.57, false, paint);

    // Bottom-right
    canvas.drawLine(Offset(size.width - r - len, size.height), Offset(size.width - r, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - r), Offset(size.width, size.height - r - len), paint);
    canvas.drawArc(Rect.fromLTWH(size.width - r * 2, size.height - r * 2, r * 2, r * 2), 0, -1.57, false, paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}
