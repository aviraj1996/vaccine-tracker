-- Migration: Enable Real-time for qr_codes table
-- Created: 2025-10-05
-- Description: Adds qr_codes table to real-time publication for live updates

-- Enable real-time updates for qr_codes table
ALTER PUBLICATION supabase_realtime ADD TABLE qr_codes;
