import 'package:flutter/material.dart';
import '../models/scan_event.dart';
import '../services/scan_service.dart';

class ScanHistory extends StatefulWidget {
  final String userEmail;

  const ScanHistory({super.key, required this.userEmail});

  @override
  State<ScanHistory> createState() => _ScanHistoryState();
}

class _ScanHistoryState extends State<ScanHistory> {
  final ScanService _scanService = ScanService();
  List<ScanEvent>? _recentScans;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentScans();
  }

  Future<void> _loadRecentScans() async {
    try {
      final scans = await _scanService.getRecentScans(widget.userEmail);
      if (mounted) {
        setState(() {
          _recentScans = scans;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_recentScans == null || _recentScans!.isEmpty) {
      return Center(
        child: Text(
          'No scans yet',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _recentScans!.length,
      itemBuilder: (context, index) {
        final scan = _recentScans![index];
        return ListTile(
          leading: const Icon(Icons.qr_code_scanner),
          title: Text('QR Code: ${scan.qrCodeId.substring(0, 8)}...'),
          subtitle: Text(_formatTime(scan.scannedAt)),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
