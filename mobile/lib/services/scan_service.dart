import 'package:flutter/foundation.dart';
import '../models/qr_code.dart';
import '../models/scan_event.dart';
import '../utils/gs1_parser.dart';
import 'supabase_service.dart';
import 'dart:io' show Platform;

class ScanService {
  final SupabaseService _supabaseService = SupabaseService();

  /// Parse QR code data and lookup in database
  Future<QRCode?> lookupQRCode(String qrData) async {
    final parseResult = GS1Parser.parse(qrData);

    if (!parseResult.isValid) {
      throw Exception(parseResult.errorMessage ?? 'Invalid QR code format');
    }

    // Lookup by serial number
    final response = await _supabaseService.findQRBySerial(parseResult.serial!);

    if (response == null) {
      throw Exception('QR code not found in database');
    }

    return QRCode.fromJson(response);
  }

  /// Save scan event to Supabase
  Future<ScanEvent> saveScanEvent({
    required String qrCodeId,
    required String userEmail,
  }) async {
    final deviceInfo = await _getDeviceInfo();

    final response = await _supabaseService.createScanEvent(
      qrCodeId: qrCodeId,
      scannedBy: userEmail,
      deviceInfo: deviceInfo,
    );

    return ScanEvent.fromJson(response);
  }

  /// Get device information for logging
  Future<String> _getDeviceInfo() async {
    try {
      if (kIsWeb) {
        return 'Web Browser';
      } else if (Platform.isIOS) {
        return 'iOS Device';
      } else if (Platform.isAndroid) {
        return 'Android Device';
      } else {
        return 'Unknown Device';
      }
    } catch (e) {
      return 'Unknown Device';
    }
  }

  /// Get recent scans for user
  Future<List<ScanEvent>> getRecentScans(String userEmail, {int limit = 5}) async {
    final response = await _supabaseService.getRecentScans(
      userEmail: userEmail,
      limit: limit,
    );

    return response.map((json) => ScanEvent.fromJson(json)).toList();
  }

  /// Parse GS1 QR data
  GS1ParseResult parseGS1(String qrData) {
    return GS1Parser.parse(qrData);
  }
}
