// QR Code Model
// Represents a vaccine QR code with GS1-formatted data

class QRCode {
  final String id;
  final String gtin;
  final String batch;
  final DateTime expiry;
  final String serial;
  final String qrData;
  final DateTime createdAt;
  final String? createdBy;

  QRCode({
    required this.id,
    required this.gtin,
    required this.batch,
    required this.expiry,
    required this.serial,
    required this.qrData,
    required this.createdAt,
    this.createdBy,
  });

  // Create QRCode from JSON (Supabase response)
  factory QRCode.fromJson(Map<String, dynamic> json) {
    return QRCode(
      id: json['id'] as String,
      gtin: json['gtin'] as String,
      batch: json['batch'] as String,
      expiry: DateTime.parse(json['expiry'] as String),
      serial: json['serial'] as String,
      qrData: json['qr_data'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      createdBy: json['created_by'] as String?,
    );
  }

  // Convert QRCode to JSON (for Supabase insert)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gtin': gtin,
      'batch': batch,
      'expiry': expiry.toIso8601String().split('T')[0], // Date only (YYYY-MM-DD)
      'serial': serial,
      'qr_data': qrData,
      'created_at': createdAt.toIso8601String(),
      'created_by': createdBy,
    };
  }

  // Create a copy with modified fields
  QRCode copyWith({
    String? id,
    String? gtin,
    String? batch,
    DateTime? expiry,
    String? serial,
    String? qrData,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return QRCode(
      id: id ?? this.id,
      gtin: gtin ?? this.gtin,
      batch: batch ?? this.batch,
      expiry: expiry ?? this.expiry,
      serial: serial ?? this.serial,
      qrData: qrData ?? this.qrData,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }

  @override
  String toString() {
    return 'QRCode(id: $id, serial: $serial, batch: $batch, gtin: $gtin)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QRCode && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
