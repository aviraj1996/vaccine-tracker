// QR Code Lookup API Route
// GET /api/qr/:id - Get QR code details by ID

import { NextRequest, NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { id } = params;

    // Validation
    if (!id || typeof id !== 'string') {
      return NextResponse.json(
        { error: 'QR code ID is required' },
        { status: 400 }
      );
    }

    // Lookup QR code by ID
    const { data: qrCode, error: lookupError } = await supabase
      .from('qr_codes')
      .select('*')
      .eq('id', id)
      .single();

    if (lookupError || !qrCode) {
      return NextResponse.json(
        { error: 'QR code not found' },
        { status: 404 }
      );
    }

    // Return QR code details
    return NextResponse.json(
      {
        id: qrCode.id,
        gtin: qrCode.gtin,
        batch: qrCode.batch,
        expiry: qrCode.expiry,
        serial: qrCode.serial,
        qr_data: qrCode.qr_data,
        qr_image_url: qrCode.qr_image_url || null,
        created_at: qrCode.created_at,
        created_by: qrCode.created_by,
      },
      { status: 200 }
    );
  } catch (error) {
    console.error('QR lookup API error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
