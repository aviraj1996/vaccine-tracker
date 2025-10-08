import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/qr_scanner.dart';
import '../widgets/scanned_data_display.dart';
import '../widgets/scan_history.dart';
import '../services/scan_service.dart';
import '../models/qr_code.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ScanService _scanService = ScanService();
  final GlobalKey<QRScannerWidgetState> _scannerKey = GlobalKey();
  bool _isScanning = true;

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await authProvider.signOut();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showScanHistory() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.userEmail ?? '';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Scans',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: ScanHistory(userEmail: userEmail),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleQRDetected(String qrData) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = authProvider.userEmail ?? '';

    // Haptic feedback (T063)
    HapticFeedback.mediumImpact();

    setState(() {
      _isScanning = false;
    });

    try {
      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Lookup QR code with retry logic (T062.5)
      QRCode? qrCode;
      int retries = 0;
      const maxRetries = 3;

      while (retries < maxRetries) {
        try {
          qrCode = await _scanService.lookupQRCode(qrData);
          break;
        } catch (e) {
          retries++;
          if (retries >= maxRetries) {
            rethrow;
          }
          await Future.delayed(Duration(seconds: retries));
        }
      }

      if (qrCode == null) {
        throw Exception('QR code not found');
      }

      // Save scan event
      await _scanService.saveScanEvent(
        qrCodeId: qrCode.id,
        userEmail: userEmail,
      );

      // Close loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      // Show success dialog (T064)
      if (mounted) {
        await showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text('Scan Success'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScannedDataDisplay(qrCode: qrCode!),
                const SizedBox(height: 16),
                const Text(
                  'Scan has been recorded successfully.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Scan Another'),
              ),
            ],
          ),
        );

        // Resume scanning after dialog is dismissed (whether via button or back button)
        if (mounted) {
          setState(() {
            _isScanning = true;
          });
          // Reset duplicate detection to allow scanning the same QR again after success
          _scannerKey.currentState?.resetDuplicateDetection();
        }
      }
    } catch (e) {
      // Close loading dialog if open
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error dialog (T064.5, T064.6)
      if (mounted) {
        final errorMessage = _getErrorMessage(e);

        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[600]),
                const SizedBox(width: 8),
                const Text('Scan Error'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(errorMessage),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'QR Data: $qrData',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _handleQRDetected(qrData); // Retry
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        );

        setState(() {
          _isScanning = true;
        });
        // Reset duplicate detection after error
        _scannerKey.currentState?.resetDuplicateDetection();
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();

    if (errorStr.contains('Invalid QR code format')) {
      return 'This QR code is not in the correct GS1 format. Please scan a valid vaccine QR code.';
    } else if (errorStr.contains('not found in database')) {
      return 'This QR code is not registered in the system. Please contact your administrator.';
    } else if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userEmail = authProvider.userEmail ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Scan History',
            onPressed: _showScanHistory,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => _handleLogout(context),
          ),
        ],
      ),
      body: _isScanning
          ? QRScannerWidget(
              key: _scannerKey,
              onQRDetected: _handleQRDetected,
              onError: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Camera error. Please check permissions.'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Processing QR code...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey[100],
        child: Text(
          'Signed in as: $userEmail',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }
}
