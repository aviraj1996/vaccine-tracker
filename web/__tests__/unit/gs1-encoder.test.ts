// Unit tests for GS1 encoder utility
// Tests encoding, validation, and formatting functions

import {
  encodeGS1,
  encodeGS1Safe,
  validateGS1Data,
  formatExpiryForGS1,
  padGTIN,
  type GS1Data,
} from '@/lib/gs1-encoder';

describe('GS1 Encoder', () => {
  describe('padGTIN', () => {
    it('should pad GTIN to 14 digits', () => {
      expect(padGTIN('123')).toBe('00000000000123');
      expect(padGTIN('123456789012')).toBe('00123456789012');
      expect(padGTIN('12345678901234')).toBe('12345678901234');
    });

    it('should not change GTIN if already 14 digits', () => {
      expect(padGTIN('12345678901234')).toBe('12345678901234');
    });
  });

  describe('formatExpiryForGS1', () => {
    it('should format expiry date to YYMMDD', () => {
      expect(formatExpiryForGS1('2025-12-31')).toBe('251231');
      expect(formatExpiryForGS1('2024-01-01')).toBe('240101');
      expect(formatExpiryForGS1('2030-06-15')).toBe('300615');
    });

    it('should handle different date formats', () => {
      expect(formatExpiryForGS1('2025-12-31')).toBe('251231');
    });
  });

  describe('encodeGS1', () => {
    it('should encode valid GS1 data', () => {
      const data: GS1Data = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: 'SN001',
      };

      const result = encodeGS1(data);
      expect(result).toBe('(01)12345678901234(10)BATCH001(17)251231(21)SN001');
    });

    it('should pad short GTINs', () => {
      const data: GS1Data = {
        gtin: '123456',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: 'SN001',
      };

      const result = encodeGS1(data);
      expect(result).toBe('(01)00000000123456(10)BATCH001(17)251231(21)SN001');
    });

    it('should handle alphanumeric batch and serial', () => {
      const data: GS1Data = {
        gtin: '12345678901234',
        batch: 'ABC123',
        expiry: '2025-12-31',
        serial: 'XYZ999',
      };

      const result = encodeGS1(data);
      expect(result).toBe('(01)12345678901234(10)ABC123(17)251231(21)XYZ999');
    });
  });

  describe('validateGS1Data', () => {
    const validData: GS1Data = {
      gtin: '12345678901234',
      batch: 'BATCH001',
      expiry: '2025-12-31',
      serial: 'SN001',
    };

    it('should return no errors for valid data', () => {
      const errors = validateGS1Data(validData);
      expect(errors).toEqual([]);
    });

    describe('GTIN validation', () => {
      it('should reject missing GTIN', () => {
        const data = { ...validData, gtin: '' };
        const errors = validateGS1Data(data);
        expect(errors).toContain('GTIN is required');
      });

      it('should reject non-numeric GTIN', () => {
        const data = { ...validData, gtin: '1234ABC' };
        const errors = validateGS1Data(data);
        expect(errors).toContain('GTIN must contain only digits');
      });

      it('should reject GTIN longer than 14 digits', () => {
        const data = { ...validData, gtin: '123456789012345' };
        const errors = validateGS1Data(data);
        expect(errors).toContain('GTIN must be 14 digits or less');
      });

      it('should accept GTIN with leading zeros', () => {
        const data = { ...validData, gtin: '00123456789012' };
        const errors = validateGS1Data(data);
        expect(errors).toEqual([]);
      });
    });

    describe('Batch validation', () => {
      it('should reject missing batch', () => {
        const data = { ...validData, batch: '' };
        const errors = validateGS1Data(data);
        expect(errors).toContain('Batch number is required');
      });

      it('should reject non-alphanumeric batch', () => {
        const data = { ...validData, batch: 'BATCH-001' };
        const errors = validateGS1Data(data);
        expect(errors).toContain('Batch must be alphanumeric only');
      });

      it('should reject batch longer than 20 characters', () => {
        const data = { ...validData, batch: 'A'.repeat(21) };
        const errors = validateGS1Data(data);
        expect(errors).toContain('Batch must be 20 characters or less');
      });
    });

    describe('Expiry validation', () => {
      it('should reject missing expiry', () => {
        const data = { ...validData, expiry: '' };
        const errors = validateGS1Data(data);
        expect(errors).toContain('Expiry date is required');
      });

      it('should reject invalid date format', () => {
        const data = { ...validData, expiry: 'invalid-date' };
        const errors = validateGS1Data(data);
        expect(errors).toContain('Expiry must be a valid date');
      });

      it('should reject past expiry dates', () => {
        const data = { ...validData, expiry: '2020-01-01' };
        const errors = validateGS1Data(data);
        expect(errors).toContain('Expiry date cannot be in the past');
      });

      it('should accept future expiry dates', () => {
        const futureDate = new Date();
        futureDate.setFullYear(futureDate.getFullYear() + 1);
        const data = {
          ...validData,
          expiry: futureDate.toISOString().split('T')[0]
        };
        const errors = validateGS1Data(data);
        expect(errors).toEqual([]);
      });
    });

    describe('Serial validation', () => {
      it('should reject missing serial', () => {
        const data = { ...validData, serial: '' };
        const errors = validateGS1Data(data);
        expect(errors).toContain('Serial number is required');
      });

      it('should reject non-alphanumeric serial', () => {
        const data = { ...validData, serial: 'SN-001' };
        const errors = validateGS1Data(data);
        expect(errors).toContain('Serial must be alphanumeric only');
      });

      it('should reject serial longer than 20 characters', () => {
        const data = { ...validData, serial: 'S'.repeat(21) };
        const errors = validateGS1Data(data);
        expect(errors).toContain('Serial must be 20 characters or less');
      });
    });

    it('should return multiple errors for multiple invalid fields', () => {
      const data = {
        gtin: 'invalid',
        batch: '',
        expiry: '2020-01-01',
        serial: 'SERIAL-WITH-DASHES',
      };
      const errors = validateGS1Data(data);
      expect(errors.length).toBeGreaterThan(1);
    });
  });

  describe('encodeGS1Safe', () => {
    it('should return QR data for valid input', () => {
      const data: GS1Data = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: 'SN001',
      };

      const result = encodeGS1Safe(data);
      expect(result.qrData).toBe('(01)12345678901234(10)BATCH001(17)251231(21)SN001');
      expect(result.errors).toEqual([]);
    });

    it('should return errors for invalid input', () => {
      const data: GS1Data = {
        gtin: 'invalid',
        batch: '',
        expiry: '2020-01-01',
        serial: '',
      };

      const result = encodeGS1Safe(data);
      expect(result.qrData).toBe('');
      expect(result.errors.length).toBeGreaterThan(0);
    });

    it('should not return QR data when validation fails', () => {
      const data: GS1Data = {
        gtin: '',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: 'SN001',
      };

      const result = encodeGS1Safe(data);
      expect(result.qrData).toBe('');
      expect(result.errors).toContain('GTIN is required');
    });
  });
});
