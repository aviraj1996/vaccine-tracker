import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerWidget extends StatefulWidget {
  final Function(String) onQRDetected;
  final VoidCallback? onError;

  const QRScannerWidget({
    super.key,
    required this.onQRDetected,
    this.onError,
  });

  @override
  QRScannerWidgetState createState() => QRScannerWidgetState();
}

class QRScannerWidgetState extends State<QRScannerWidget> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  bool _torchOn = false;
  String? _lastScannedCode;
  DateTime? _lastScanTime;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggleTorch() {
    setState(() {
      _torchOn = !_torchOn;
    });
    controller.toggleTorch();
  }

  /// Reset duplicate detection (called when scanner resumes)
  void resetDuplicateDetection() {
    setState(() {
      _lastScannedCode = null;
      _lastScanTime = null;
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camera viewfinder
        MobileScanner(
          controller: controller,
          onDetect: (capture) {
            if (_isProcessing) return;

            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                final qrCode = barcode.rawValue!;
                final now = DateTime.now();

                // Check if this is a duplicate scan within 3 seconds
                if (_lastScannedCode == qrCode &&
                    _lastScanTime != null &&
                    now.difference(_lastScanTime!) < const Duration(seconds: 3)) {
                  return; // Ignore duplicate
                }

                // Update last scan tracking
                _lastScannedCode = qrCode;
                _lastScanTime = now;

                setState(() => _isProcessing = true);
                widget.onQRDetected(qrCode);
                break;
              }
            }
          },
        ),

        // Overlay with scan frame
        Positioned.fill(
          child: CustomPaint(
            painter: ScannerOverlayPainter(),
          ),
        ),

        // Flashlight button (T057.5)
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingActionButton(
            onPressed: _toggleTorch,
            child: Icon(_torchOn ? Icons.flash_off : Icons.flash_on),
          ),
        ),

        // Instructions
        Positioned(
          top: 48,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black54,
            child: const Text(
              'Point camera at QR code',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: 250,
      height: 250,
    );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
