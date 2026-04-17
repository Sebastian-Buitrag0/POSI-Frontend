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

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  late final MobileScannerController _controller;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            final raw = capture.barcodes.firstOrNull?.rawValue;
            if (raw != null && raw.isNotEmpty) {
              widget.onDetected(raw);
            }
          },
        ),
        Center(
          child: Container(
            width: widget.frameSize,
            height: widget.frameSize,
            decoration: BoxDecoration(
              border: Border.all(color: widget.frameColor, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
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
