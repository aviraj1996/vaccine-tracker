// GS1 Encoder Utility for Vaccine Tracker MVP
// Encodes vaccine data into GS1 format: (01)GTIN(10)BATCH(17)EXPIRY(21)SERIAL

/**
 * GS1 Application Identifiers used:
 * - (01) = GTIN (Global Trade Item Number) - 14 digits
 * - (10) = BATCH/LOT number - alphanumeric, max 20 chars
 * - (17) = EXPIRY date - YYMMDD format
 * - (21) = SERIAL number - alphanumeric, max 20 chars
 */

export interface GS1Data {
  gtin: string;
  batch: string;
  expiry: string; // YYYY-MM-DD format
  serial: string;
}

/**
 * Formats expiry date from YYYY-MM-DD to YYMMDD for GS1
 * Example: "2025-12-31" → "251231"
 */
export function formatExpiryForGS1(expiry: string): string {
  const date = new Date(expiry);
  const year = date.getFullYear().toString().slice(-2); // Last 2 digits
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');
  return `${year}${month}${day}`;
}

/**
 * Pads GTIN to 14 digits (if shorter) by adding leading zeros
 * Example: "123456789012" → "00123456789012"
 */
export function padGTIN(gtin: string): string {
  return gtin.padStart(14, '0');
}

/**
 * Encodes vaccine data into GS1 format
 * Returns formatted string: (01)GTIN(10)BATCH(17)EXPIRY(21)SERIAL
 */
export function encodeGS1(data: GS1Data): string {
  const paddedGTIN = padGTIN(data.gtin);
  const formattedExpiry = formatExpiryForGS1(data.expiry);

  return `(01)${paddedGTIN}(10)${data.batch}(17)${formattedExpiry}(21)${data.serial}`;
}

/**
 * Validates GS1 data before encoding
 * Returns array of validation errors (empty if valid)
 */
export function validateGS1Data(data: Partial<GS1Data>): string[] {
  const errors: string[] = [];

  // GTIN validation
  if (!data.gtin) {
    errors.push('GTIN is required');
  } else if (!/^\d+$/.test(data.gtin)) {
    errors.push('GTIN must contain only digits');
  } else if (data.gtin.length > 14) {
    errors.push('GTIN must be 14 digits or less');
  }

  // Batch validation
  if (!data.batch) {
    errors.push('Batch number is required');
  } else if (!/^[A-Za-z0-9]+$/.test(data.batch)) {
    errors.push('Batch must be alphanumeric only');
  } else if (data.batch.length > 20) {
    errors.push('Batch must be 20 characters or less');
  }

  // Expiry validation
  if (!data.expiry) {
    errors.push('Expiry date is required');
  } else {
    const expiryDate = new Date(data.expiry);
    if (isNaN(expiryDate.getTime())) {
      errors.push('Expiry must be a valid date');
    } else if (expiryDate < new Date()) {
      errors.push('Expiry date cannot be in the past');
    }
  }

  // Serial validation
  if (!data.serial) {
    errors.push('Serial number is required');
  } else if (!/^[A-Za-z0-9]+$/.test(data.serial)) {
    errors.push('Serial must be alphanumeric only');
  } else if (data.serial.length > 20) {
    errors.push('Serial must be 20 characters or less');
  }

  return errors;
}

/**
 * Complete GS1 encoding with validation
 * Throws error if validation fails
 */
export function encodeGS1Safe(data: GS1Data): { qrData: string; errors: string[] } {
  const errors = validateGS1Data(data);

  if (errors.length > 0) {
    return { qrData: '', errors };
  }

  const qrData = encodeGS1(data);
  return { qrData, errors: [] };
}

// Example usage:
// const data = {
//   gtin: '12345678901234',
//   batch: 'BATCH001',
//   expiry: '2025-12-31',
//   serial: 'SN001'
// };
// const result = encodeGS1Safe(data);
// // result.qrData = "(01)12345678901234(10)BATCH001(17)251231(21)SN001"
