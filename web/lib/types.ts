// TypeScript Types for Vaccine Tracker MVP
// Based on Supabase database schema from migration 001_initial_schema.sql

// ============================================================================
// DATABASE TYPES (Supabase Generated)
// ============================================================================

export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export interface Database {
  public: {
    Tables: {
      qr_codes: {
        Row: QRCode;
        Insert: QRCodeInsert;
        Update: QRCodeUpdate;
      };
      scan_events: {
        Row: ScanEvent;
        Insert: ScanEventInsert;
        Update: ScanEventUpdate;
      };
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      [_ in never]: never;
    };
    Enums: {
      [_ in never]: never;
    };
  };
}

// ============================================================================
// ENTITY: QRCode
// ============================================================================

export interface QRCode {
  id: string; // UUID
  gtin: string; // 14 digits
  batch: string; // Batch/Lot number (max 20 chars)
  expiry: string; // Date in YYYY-MM-DD format
  serial: string; // Unique serial number (max 20 chars)
  qr_data: string; // Full GS1 encoded string
  created_at: string; // ISO 8601 timestamp
  created_by: string | null; // Email of creator (optional)
}

export interface QRCodeInsert {
  id?: string;
  gtin: string;
  batch: string;
  expiry: string;
  serial: string;
  qr_data: string;
  created_at?: string;
  created_by?: string | null;
}

export interface QRCodeUpdate {
  id?: string;
  gtin?: string;
  batch?: string;
  expiry?: string;
  serial?: string;
  qr_data?: string;
  created_at?: string;
  created_by?: string | null;
}

// ============================================================================
// ENTITY: ScanEvent
// ============================================================================

export interface ScanEvent {
  id: string; // UUID
  qr_code_id: string; // Foreign key to qr_codes
  scanned_by: string; // Email of scanner
  scanned_at: string; // ISO 8601 timestamp
  device_info: string | null; // Optional device information
}

export interface ScanEventInsert {
  id?: string;
  qr_code_id: string;
  scanned_by: string;
  scanned_at?: string;
  device_info?: string | null;
}

export interface ScanEventUpdate {
  id?: string;
  qr_code_id?: string;
  scanned_by?: string;
  scanned_at?: string;
  device_info?: string | null;
}

// ============================================================================
// VIEW MODELS (for UI components)
// ============================================================================

// Combined scan event with QR code data (for dashboard)
export interface ScanEventWithQR extends ScanEvent {
  qr_code: QRCode;
}

// QR Generator Form Data
export interface QRGeneratorFormData {
  gtin: string;
  batch: string;
  expiry: string;
  serial: string;
}

// API Response Types
export interface QRGenerateResponse {
  success: boolean;
  data?: QRCode;
  qr_image_url?: string; // Data URL for PNG image
  error?: string;
}

export interface ScanResponse {
  success: boolean;
  data?: ScanEventWithQR;
  error?: string;
}

// Dashboard Stats
export interface DashboardStats {
  total_scans: number;
  total_qr_codes: number;
  scans_today: number;
}

// ============================================================================
// VALIDATION TYPES
// ============================================================================

export interface ValidationError {
  field: string;
  message: string;
}

export interface FormValidation {
  isValid: boolean;
  errors: ValidationError[];
}
