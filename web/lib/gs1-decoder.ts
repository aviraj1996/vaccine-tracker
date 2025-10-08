// GS1 Decoder Utility for Vaccine Tracker MVP
// Decodes GS1 format back to individual fields: GTIN, BATCH, EXPIRY, SERIAL

import type { GS1Data } from './gs1-encoder';

/**
 * Parses expiry date from GS1 YYMMDD format to YYYY-MM-DD
 * Example: "251231" → "2025-12-31"
 */
export function parseExpiryFromGS1(yymmdd: string): string {
  if (yymmdd.length !== 6) {
    throw new Error(`Invalid expiry format: ${yymmdd}. Expected YYMMDD (6 digits)`);
  }

  const yy = yymmdd.slice(0, 2);
  const mm = yymmdd.slice(2, 4);
  const dd = yymmdd.slice(4, 6);

  // Assume 20xx for years (will work until 2099)
  const yyyy = `20${yy}`;

  return `${yyyy}-${mm}-${dd}`;
}

/**
 * Decodes GS1 formatted string into individual fields
 * Input format: (01)GTIN(10)BATCH(17)EXPIRY(21)SERIAL
 * Returns: { gtin, batch, expiry, serial } or null if invalid
 */
export function decodeGS1(qrData: string): GS1Data | null {
  try {
    // GS1 regex pattern:
    // (01) followed by 14 digits (GTIN)
    // (10) followed by alphanumeric (BATCH)
    // (17) followed by 6 digits (EXPIRY in YYMMDD)
    // (21) followed by alphanumeric (SERIAL)
    const gs1Pattern = /\(01\)(\d{14})\(10\)([A-Za-z0-9]+)\(17\)(\d{6})\(21\)([A-Za-z0-9]+)/;

    const match = qrData.match(gs1Pattern);

    if (!match) {
      return null; // Invalid GS1 format
    }

    const [, gtin, batch, expiryYYMMDD, serial] = match;

    return {
      gtin: gtin.replace(/^0+/, '') || '0', // Remove leading zeros (keep at least one zero)
      batch,
      expiry: parseExpiryFromGS1(expiryYYMMDD),
      serial,
    };
  } catch (error) {
    console.error('GS1 decode error:', error);
    return null;
  }
}

/**
 * Validates that a string is in valid GS1 format
 * Returns true if valid, false otherwise
 */
export function isValidGS1Format(qrData: string): boolean {
  const gs1Pattern = /^\(01\)\d{14}\(10\)[A-Za-z0-9]+\(17\)\d{6}\(21\)[A-Za-z0-9]+$/;
  return gs1Pattern.test(qrData);
}

/**
 * Extracts just the serial number from GS1 data (for quick lookup)
 * Returns serial or null if invalid format
 */
export function extractSerial(qrData: string): string | null {
  const serialPattern = /\(21\)([A-Za-z0-9]+)/;
  const match = qrData.match(serialPattern);
  return match ? match[1] : null;
}

/**
 * Safe decode with error handling
 * Returns decoded data and any errors
 */
export function decodeGS1Safe(qrData: string): {
  data: GS1Data | null;
  error: string | null;
} {
  if (!qrData || typeof qrData !== 'string') {
    return {
      data: null,
      error: 'QR data is required and must be a string',
    };
  }

  if (!isValidGS1Format(qrData)) {
    return {
      data: null,
      error: 'Invalid GS1 format. Expected: (01)GTIN(10)BATCH(17)EXPIRY(21)SERIAL',
    };
  }

  const decoded = decodeGS1(qrData);

  if (!decoded) {
    return {
      data: null,
      error: 'Failed to decode GS1 data',
    };
  }

  return {
    data: decoded,
    error: null,
  };
}

// Example usage:
// const qrData = "(01)12345678901234(10)BATCH001(17)251231(21)SN001";
// const result = decodeGS1Safe(qrData);
// if (result.data) {
//   console.log(result.data);
//   // {
//   //   gtin: "12345678901234",
//   //   batch: "BATCH001",
//   //   expiry: "2025-12-31",
//   //   serial: "SN001"
//   // }
// }
