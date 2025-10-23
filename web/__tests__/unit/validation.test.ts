// Unit tests for input validation
// Tests GTIN format (14 digits), Serial uniqueness check, Expiry future date validation

import { validateGS1Data, type GS1Data } from '@/lib/gs1-encoder';

describe('Input Validation', () => {
  describe('GTIN 14 digits validation', () => {
    it('should accept 14-digit GTIN', () => {
      const data: Partial<GS1Data> = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: 'SN001',
      };
      const errors = validateGS1Data(data);
      expect(errors).toEqual([]);
    });

    it('should accept GTIN shorter than 14 digits (will be padded)', () => {
      const data: Partial<GS1Data> = {
        gtin: '123456',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: 'SN001',
      };
      const errors = validateGS1Data(data);
      expect(errors).toEqual([]);
    });

    it('should reject GTIN longer than 14 digits', () => {
      const data: Partial<GS1Data> = {
        gtin: '123456789012345', // 15 digits
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: 'SN001',
      };
      const errors = validateGS1Data(data);
      expect(errors).toContain('GTIN must be 14 digits or less');
    });

    it('should reject GTIN with non-numeric characters', () => {
      const data: Partial<GS1Data> = {
        gtin: '12345ABC',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: 'SN001',
      };
      const errors = validateGS1Data(data);
      expect(errors).toContain('GTIN must contain only digits');
    });

    it('should reject empty GTIN', () => {
      const data: Partial<GS1Data> = {
        gtin: '',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: 'SN001',
      };
      const errors = validateGS1Data(data);
      expect(errors).toContain('GTIN is required');
    });
  });

  describe('Serial uniqueness validation', () => {
    // Note: Serial uniqueness is enforced at database level (unique constraint)
    // This test validates serial format requirements

    it('should accept valid alphanumeric serial', () => {
      const data: Partial<GS1Data> = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: 'SN123ABC',
      };
      const errors = validateGS1Data(data);
      expect(errors).toEqual([]);
    });

    it('should accept serial with numbers only', () => {
      const data: Partial<GS1Data> = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: '123456',
      };
      const errors = validateGS1Data(data);
      expect(errors).toEqual([]);
    });

    it('should accept serial with letters only', () => {
      const data: Partial<GS1Data> = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: 'ABCDEF',
      };
      const errors = validateGS1Data(data);
      expect(errors).toEqual([]);
    });

    it('should reject serial with special characters', () => {
      const data: Partial<GS1Data> = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: 'SN-001',
      };
      const errors = validateGS1Data(data);
      expect(errors).toContain('Serial must be alphanumeric only');
    });

    it('should reject serial longer than 20 characters', () => {
      const data: Partial<GS1Data> = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: 'A'.repeat(21),
      };
      const errors = validateGS1Data(data);
      expect(errors).toContain('Serial must be 20 characters or less');
    });

    it('should reject empty serial', () => {
      const data: Partial<GS1Data> = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: '',
      };
      const errors = validateGS1Data(data);
      expect(errors).toContain('Serial number is required');
    });
  });

  describe('Expiry future date validation', () => {
    it('should accept future expiry date', () => {
      const futureDate = new Date();
      futureDate.setFullYear(futureDate.getFullYear() + 1);
      const data: Partial<GS1Data> = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: futureDate.toISOString().split('T')[0],
        serial: 'SN001',
      };
      const errors = validateGS1Data(data);
      expect(errors).toEqual([]);
    });

    it('should accept expiry date far in the future', () => {
      const futureDate = new Date();
      futureDate.setFullYear(futureDate.getFullYear() + 10);
      const data: Partial<GS1Data> = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: futureDate.toISOString().split('T')[0],
        serial: 'SN001',
      };
      const errors = validateGS1Data(data);
      expect(errors).toEqual([]);
    });

    it('should reject past expiry date', () => {
      const data: Partial<GS1Data> = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: '2020-01-01',
        serial: 'SN001',
      };
      const errors = validateGS1Data(data);
      expect(errors).toContain('Expiry date cannot be in the past');
    });

    it('should reject expiry date from last year', () => {
      const pastDate = new Date();
      pastDate.setFullYear(pastDate.getFullYear() - 1);
      const data: Partial<GS1Data> = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: pastDate.toISOString().split('T')[0],
        serial: 'SN001',
      };
      const errors = validateGS1Data(data);
      expect(errors).toContain('Expiry date cannot be in the past');
    });

    it('should reject invalid date format', () => {
      const data: Partial<GS1Data> = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: 'not-a-date',
        serial: 'SN001',
      };
      const errors = validateGS1Data(data);
      expect(errors).toContain('Expiry must be a valid date');
    });

    it('should reject empty expiry date', () => {
      const data: Partial<GS1Data> = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: '',
        serial: 'SN001',
      };
      const errors = validateGS1Data(data);
      expect(errors).toContain('Expiry date is required');
    });
  });

  describe('Combined validation scenarios', () => {
    it('should validate all fields together', () => {
      const data: Partial<GS1Data> = {
        gtin: '12345678901234',
        batch: 'BATCH001',
        expiry: '2025-12-31',
        serial: 'SN001',
      };
      const errors = validateGS1Data(data);
      expect(errors).toEqual([]);
    });

    it('should return multiple errors for multiple invalid fields', () => {
      const data: Partial<GS1Data> = {
        gtin: 'invalid-gtin',
        batch: '',
        expiry: '2020-01-01',
        serial: 'serial-with-dash',
      };
      const errors = validateGS1Data(data);
      expect(errors.length).toBeGreaterThan(2);
      expect(errors).toContain('GTIN must contain only digits');
      expect(errors).toContain('Batch number is required');
      expect(errors).toContain('Expiry date cannot be in the past');
      expect(errors).toContain('Serial must be alphanumeric only');
    });

    it('should validate minimum required data', () => {
      const data: Partial<GS1Data> = {
        gtin: '1',
        batch: 'B',
        expiry: '2025-12-31',
        serial: 'S',
      };
      const errors = validateGS1Data(data);
      expect(errors).toEqual([]);
    });
  });
});
