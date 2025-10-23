// Unit tests for GS1 Parser utility
// Tests parsing, validation, and extraction of GS1-formatted QR code data

import 'package:flutter_test/flutter_test.dart';
import 'package:vaccine_tracker/utils/gs1_parser.dart';

void main() {
  group('GS1Parser', () {
    const validQRData = '(01)12345678901234(10)BATCH001(17)251231(21)SN001';

    group('parse()', () {
      test('should parse valid GS1 data successfully', () {
        final result = GS1Parser.parse(validQRData);

        expect(result.isValid, true);
        expect(result.gtin, '12345678901234');
        expect(result.batch, 'BATCH001');
        expect(result.expiry, '2025-12-31');
        expect(result.serial, 'SN001');
        expect(result.errorMessage, null);
      });

      test('should handle different batch and serial formats', () {
        const qrData = '(01)00123456789012(10)ABC123(17)300615(21)XYZ999';
        final result = GS1Parser.parse(qrData);

        expect(result.isValid, true);
        expect(result.gtin, '00123456789012');
        expect(result.batch, 'ABC123');
        expect(result.expiry, '2030-06-15');
        expect(result.serial, 'XYZ999');
      });

      test('should reject empty QR data', () {
        final result = GS1Parser.parse('');

        expect(result.isValid, false);
        expect(result.errorMessage, 'QR data is empty');
      });

      test('should reject data missing GTIN', () {
        const qrData = '(10)BATCH001(17)251231(21)SN001';
        final result = GS1Parser.parse(qrData);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('Missing required GS1 fields'));
      });

      test('should reject data missing Batch', () {
        const qrData = '(01)12345678901234(17)251231(21)SN001';
        final result = GS1Parser.parse(qrData);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('Missing required GS1 fields'));
      });

      test('should reject data missing Expiry', () {
        const qrData = '(01)12345678901234(10)BATCH001(21)SN001';
        final result = GS1Parser.parse(qrData);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('Missing required GS1 fields'));
      });

      test('should reject data missing Serial', () {
        const qrData = '(01)12345678901234(10)BATCH001(17)251231';
        final result = GS1Parser.parse(qrData);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('Missing required GS1 fields'));
      });

      test('should reject invalid GTIN length', () {
        const qrData = '(01)123456789012(10)BATCH001(17)251231(21)SN001'; // 12 digits
        final result = GS1Parser.parse(qrData);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('Invalid GTIN'));
      });

      test('should reject non-numeric GTIN', () {
        const qrData = '(01)1234567890123A(10)BATCH001(17)251231(21)SN001';
        final result = GS1Parser.parse(qrData);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('Invalid GTIN'));
      });

      test('should reject invalid expiry format', () {
        const qrData = '(01)12345678901234(10)BATCH001(17)2512(21)SN001'; // 4 digits
        final result = GS1Parser.parse(qrData);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('Invalid expiry date'));
      });

      test('should reject non-numeric expiry', () {
        const qrData = '(01)12345678901234(10)BATCH001(17)25AB31(21)SN001';
        final result = GS1Parser.parse(qrData);

        expect(result.isValid, false);
        expect(result.errorMessage, contains('Invalid expiry date'));
      });

      test('should format expiry date correctly', () {
        const testCases = [
          ['251231', '2025-12-31'],
          ['240101', '2024-01-01'],
          ['300615', '2030-06-15'],
          ['991231', '2099-12-31'],
        ];

        for (final testCase in testCases) {
          final qrData = '(01)12345678901234(10)BATCH001(17)${testCase[0]}(21)SN001';
          final result = GS1Parser.parse(qrData);

          expect(result.isValid, true);
          expect(result.expiry, testCase[1], reason: 'Failed for ${testCase[0]}');
        }
      });
    });

    group('isValidGS1()', () {
      test('should return true for valid GS1 data', () {
        expect(GS1Parser.isValidGS1(validQRData), true);
      });

      test('should return false for invalid GS1 data', () {
        expect(GS1Parser.isValidGS1(''), false);
        expect(GS1Parser.isValidGS1('invalid-qr-data'), false);
        expect(GS1Parser.isValidGS1('(01)123'), false);
      });
    });

    group('extractSerial()', () {
      test('should extract serial from valid GS1 data', () {
        expect(GS1Parser.extractSerial(validQRData), 'SN001');
      });

      test('should return null for invalid GS1 data', () {
        expect(GS1Parser.extractSerial(''), null);
        expect(GS1Parser.extractSerial('invalid'), null);
      });

      test('should handle different serial formats', () {
        const qrData = '(01)12345678901234(10)BATCH001(17)251231(21)ABC123XYZ';
        expect(GS1Parser.extractSerial(qrData), 'ABC123XYZ');
      });
    });

    group('extractGTIN()', () {
      test('should extract GTIN from valid GS1 data', () {
        expect(GS1Parser.extractGTIN(validQRData), '12345678901234');
      });

      test('should return null for invalid GS1 data', () {
        expect(GS1Parser.extractGTIN(''), null);
        expect(GS1Parser.extractGTIN('invalid'), null);
      });

      test('should extract GTIN with leading zeros', () {
        const qrData = '(01)00123456789012(10)BATCH001(17)251231(21)SN001';
        expect(GS1Parser.extractGTIN(qrData), '00123456789012');
      });
    });

    group('extractBatch()', () {
      test('should extract batch from valid GS1 data', () {
        expect(GS1Parser.extractBatch(validQRData), 'BATCH001');
      });

      test('should return null for invalid GS1 data', () {
        expect(GS1Parser.extractBatch(''), null);
        expect(GS1Parser.extractBatch('invalid'), null);
      });

      test('should handle alphanumeric batch', () {
        const qrData = '(01)12345678901234(10)ABC123(17)251231(21)SN001';
        expect(GS1Parser.extractBatch(qrData), 'ABC123');
      });
    });

    group('extractExpiry()', () {
      test('should extract expiry from valid GS1 data', () {
        expect(GS1Parser.extractExpiry(validQRData), '2025-12-31');
      });

      test('should return null for invalid GS1 data', () {
        expect(GS1Parser.extractExpiry(''), null);
        expect(GS1Parser.extractExpiry('invalid'), null);
      });

      test('should return formatted expiry date', () {
        const qrData = '(01)12345678901234(10)BATCH001(17)300101(21)SN001';
        expect(GS1Parser.extractExpiry(qrData), '2030-01-01');
      });
    });

    group('GS1ParseResult', () {
      test('should create valid result', () {
        final result = GS1ParseResult(
          gtin: '12345678901234',
          batch: 'BATCH001',
          expiry: '2025-12-31',
          serial: 'SN001',
          isValid: true,
        );

        expect(result.isValid, true);
        expect(result.errorMessage, null);
        expect(result.toString(), contains('gtin: 12345678901234'));
      });

      test('should create invalid result with error', () {
        final result = GS1ParseResult(
          isValid: false,
          errorMessage: 'Test error',
        );

        expect(result.isValid, false);
        expect(result.errorMessage, 'Test error');
        expect(result.toString(), contains('isValid: false'));
        expect(result.toString(), contains('error: Test error'));
      });
    });

    group('Edge cases', () {
      test('should handle QR data with extra whitespace', () {
        const qrData = '(01)12345678901234(10)BATCH001 (17)251231(21)SN001';
        final result = GS1Parser.parse(qrData);

        expect(result.isValid, true);
        expect(result.batch, 'BATCH001'); // Trimmed
      });

      test('should handle multiple AIs correctly', () {
        // Test with additional AIs that should be ignored
        const qrData = '(01)12345678901234(10)BATCH001(17)251231(21)SN001(99)EXTRA';
        final result = GS1Parser.parse(qrData);

        expect(result.isValid, true);
        expect(result.serial, 'SN001');
      });

      test('should handle AIs in different order', () {
        const qrData = '(21)SN001(17)251231(10)BATCH001(01)12345678901234';
        final result = GS1Parser.parse(qrData);

        expect(result.isValid, true);
        expect(result.gtin, '12345678901234');
        expect(result.batch, 'BATCH001');
        expect(result.expiry, '2025-12-31');
        expect(result.serial, 'SN001');
      });
    });
  });
}
