// GS1 Parser Utility
// Parses GS1-formatted QR code data to extract GTIN, Batch, Expiry, Serial

class GS1ParseResult {
  final String? gtin;
  final String? batch;
  final String? expiry;
  final String? serial;
  final bool isValid;
  final String? errorMessage;

  GS1ParseResult({
    this.gtin,
    this.batch,
    this.expiry,
    this.serial,
    required this.isValid,
    this.errorMessage,
  });

  @override
  String toString() {
    if (!isValid) {
      return 'GS1ParseResult(isValid: false, error: $errorMessage)';
    }
    return 'GS1ParseResult(gtin: $gtin, batch: $batch, expiry: $expiry, serial: $serial)';
  }
}

class GS1Parser {
  // GS1 Application Identifiers
  static const String AI_GTIN = '01';
  static const String AI_BATCH = '10';
  static const String AI_EXPIRY = '17';
  static const String AI_SERIAL = '21';

  /// Parse GS1-formatted QR code data
  ///
  /// Expected format: (01)GTIN(10)BATCH(17)EXPIRY(21)SERIAL
  /// Example: (01)12345678901234(10)BATCH001(17)251231(21)SN001
  static GS1ParseResult parse(String qrData) {
    if (qrData.isEmpty) {
      return GS1ParseResult(
        isValid: false,
        errorMessage: 'QR data is empty',
      );
    }

    try {
      final Map<String, String> extractedData = {};

      // Find all AI groups: (AI)VALUE
      final RegExp aiPattern = RegExp(r'\((\d{2})\)([^(]+)');
      final Iterable<RegExpMatch> matches = aiPattern.allMatches(qrData);

      for (final match in matches) {
        final String ai = match.group(1)!;
        final String value = match.group(2)!.trim();
        extractedData[ai] = value;
      }

      // Extract required fields
      final String? gtin = extractedData[AI_GTIN];
      final String? batch = extractedData[AI_BATCH];
      final String? expiry = extractedData[AI_EXPIRY];
      final String? serial = extractedData[AI_SERIAL];

      // Validate required fields exist
      if (gtin == null || batch == null || expiry == null || serial == null) {
        return GS1ParseResult(
          isValid: false,
          errorMessage: 'Missing required GS1 fields. Expected: (01)GTIN(10)BATCH(17)EXPIRY(21)SERIAL',
          gtin: gtin,
          batch: batch,
          expiry: expiry,
          serial: serial,
        );
      }

      // Validate GTIN (should be 14 digits)
      if (gtin.length != 14 || !RegExp(r'^\d+$').hasMatch(gtin)) {
        return GS1ParseResult(
          isValid: false,
          errorMessage: 'Invalid GTIN: must be exactly 14 digits',
          gtin: gtin,
          batch: batch,
          expiry: expiry,
          serial: serial,
        );
      }

      // Validate expiry format (YYMMDD)
      if (expiry.length != 6 || !RegExp(r'^\d+$').hasMatch(expiry)) {
        return GS1ParseResult(
          isValid: false,
          errorMessage: 'Invalid expiry date: must be YYMMDD format',
          gtin: gtin,
          batch: batch,
          expiry: expiry,
          serial: serial,
        );
      }

      return GS1ParseResult(
        gtin: gtin,
        batch: batch,
        expiry: _formatExpiryDate(expiry),
        serial: serial,
        isValid: true,
      );
    } catch (e) {
      return GS1ParseResult(
        isValid: false,
        errorMessage: 'Failed to parse GS1 data: $e',
      );
    }
  }

  /// Convert YYMMDD to YYYY-MM-DD format
  /// Example: "251231" -> "2025-12-31"
  static String _formatExpiryDate(String yymmdd) {
    if (yymmdd.length != 6) return yymmdd;

    final String yy = yymmdd.substring(0, 2);
    final String mm = yymmdd.substring(2, 4);
    final String dd = yymmdd.substring(4, 6);

    // Assume 20xx for years 00-99
    final String yyyy = '20$yy';

    return '$yyyy-$mm-$dd';
  }

  /// Validate a complete GS1 string
  static bool isValidGS1(String qrData) {
    final result = parse(qrData);
    return result.isValid;
  }

  /// Extract only the serial number from GS1 data
  static String? extractSerial(String qrData) {
    final result = parse(qrData);
    return result.isValid ? result.serial : null;
  }

  /// Extract only the GTIN from GS1 data
  static String? extractGTIN(String qrData) {
    final result = parse(qrData);
    return result.isValid ? result.gtin : null;
  }

  /// Extract only the batch from GS1 data
  static String? extractBatch(String qrData) {
    final result = parse(qrData);
    return result.isValid ? result.batch : null;
  }

  /// Extract only the expiry date from GS1 data
  static String? extractExpiry(String qrData) {
    final result = parse(qrData);
    return result.isValid ? result.expiry : null;
  }
}
