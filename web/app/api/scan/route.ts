// Scan API Route
// POST /api/scan - Record a QR code scan event from mobile app

import { NextRequest, NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';

export async function POST(request: NextRequest) {
  try {
    // Parse request body
    const body = await request.json();
    const { serial, scanned_by, device_info } = body;

    // Validation
    if (!serial || typeof serial !== 'string') {
      return NextResponse.json(
        { error: 'Serial number is required' },
        { status: 400 }
      );
    }

    if (!scanned_by || typeof scanned_by !== 'string') {
      return NextResponse.json(
        { error: 'Scanned by (user email) is required' },
        { status: 400 }
      );
    }

    // Step 1: Lookup QR code by serial number
    const { data: qrCode, error: lookupError } = await supabase
      .from('qr_codes')
      .select('*')
      .eq('serial', serial)
      .single();

    if (lookupError || !qrCode) {
      return NextResponse.json(
        { error: `QR code with serial '${serial}' not found` },
        { status: 400 }
      );
    }

    // Step 2: Create scan event
    const { data: scanEvent, error: scanError } = await supabase
      .from('scan_events')
      .insert({
        qr_code_id: qrCode.id,
        scanned_by,
        device_info: device_info || null,
      })
      .select()
      .single();

    if (scanError) {
      console.error('Failed to create scan event:', scanError);
      return NextResponse.json(
        { error: 'Failed to record scan event' },
        { status: 500 }
      );
    }

    // Step 3: Return scan event with QR code details
    return NextResponse.json(
      {
        id: scanEvent.id,
        qr_code: {
          id: qrCode.id,
          gtin: qrCode.gtin,
          batch: qrCode.batch,
          serial: qrCode.serial,
          expiry: qrCode.expiry,
          qr_data: qrCode.qr_data,
        },
        scanned_by: scanEvent.scanned_by,
        scanned_at: scanEvent.scanned_at,
        device_info: scanEvent.device_info,
      },
      { status: 201 }
    );
  } catch (error) {
    console.error('Scan API error:', error);

    // Handle JSON parse errors
    if (error instanceof SyntaxError) {
      return NextResponse.json(
        { error: 'Invalid JSON in request body' },
        { status: 400 }
      );
    }

    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
