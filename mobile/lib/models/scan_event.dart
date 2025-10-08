// Scan Event Model
// Represents a single QR code scan action

class ScanEvent {
  final String id;
  final String qrCodeId;
  final String scannedBy;
  final DateTime scannedAt;
  final String? deviceInfo;

  ScanEvent({
    required this.id,
    required this.qrCodeId,
    required this.scannedBy,
    required this.scannedAt,
    this.deviceInfo,
  });

  // Create ScanEvent from JSON (Supabase response)
  factory ScanEvent.fromJson(Map<String, dynamic> json) {
    return ScanEvent(
      id: json['id'] as String,
      qrCodeId: json['qr_code_id'] as String,
      scannedBy: json['scanned_by'] as String,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      deviceInfo: json['device_info'] as String?,
    );
  }

  // Convert ScanEvent to JSON (for Supabase insert)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qr_code_id': qrCodeId,
      'scanned_by': scannedBy,
      'scanned_at': scannedAt.toIso8601String(),
      'device_info': deviceInfo,
    };
  }

  // Create ScanEvent without ID (for insert - let Supabase generate UUID)
  Map<String, dynamic> toInsertJson() {
    return {
      'qr_code_id': qrCodeId,
      'scanned_by': scannedBy,
      'scanned_at': scannedAt.toIso8601String(),
      'device_info': deviceInfo,
    };
  }

  // Create a copy with modified fields
  ScanEvent copyWith({
    String? id,
    String? qrCodeId,
    String? scannedBy,
    DateTime? scannedAt,
    String? deviceInfo,
  }) {
    return ScanEvent(
      id: id ?? this.id,
      qrCodeId: qrCodeId ?? this.qrCodeId,
      scannedBy: scannedBy ?? this.scannedBy,
      scannedAt: scannedAt ?? this.scannedAt,
      deviceInfo: deviceInfo ?? this.deviceInfo,
    );
  }

  @override
  String toString() {
    return 'ScanEvent(id: $id, qrCodeId: $qrCodeId, scannedBy: $scannedBy, scannedAt: $scannedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScanEvent && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
