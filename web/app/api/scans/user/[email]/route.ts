// User Scans API Route
// GET /api/scans/user/:email - Get scans for specific user

import { NextRequest, NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';

export async function GET(
  request: NextRequest,
  { params }: { params: { email: string } }
) {
  try {
    const { email } = params;

    // Get limit from query params (default: 5, max: 50)
    const { searchParams } = new URL(request.url);
    const limitParam = searchParams.get('limit');
    const limit = limitParam
      ? Math.min(Math.max(parseInt(limitParam), 1), 50)
      : 5;

    // Validation
    if (!email || typeof email !== 'string') {
      return NextResponse.json(
        { error: 'User email is required' },
        { status: 400 }
      );
    }

    // Basic email validation
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return NextResponse.json(
        { error: 'Invalid email format' },
        { status: 400 }
      );
    }

    // Get user's recent scans with QR code details
    const { data: scans, error: scansError } = await supabase
      .from('scan_events')
      .select(`
        id,
        scanned_by,
        scanned_at,
        device_info,
        qr_code_id,
        qr_codes (
          id,
          gtin,
          batch,
          expiry,
          serial,
          qr_data
        )
      `)
      .eq('scanned_by', email)
      .order('scanned_at', { ascending: false })
      .limit(limit);

    if (scansError) {
      console.error('Failed to fetch user scans:', scansError);
      return NextResponse.json(
        { error: 'Failed to fetch scans' },
        { status: 500 }
      );
    }

    // Format response
    const formattedScans = (scans || []).map((scan: any) => ({
      id: scan.id,
      qr_code: scan.qr_codes ? {
        id: scan.qr_codes.id,
        gtin: scan.qr_codes.gtin,
        batch: scan.qr_codes.batch,
        expiry: scan.qr_codes.expiry,
        serial: scan.qr_codes.serial,
        qr_data: scan.qr_codes.qr_data,
      } : null,
      scanned_by: scan.scanned_by,
      scanned_at: scan.scanned_at,
      device_info: scan.device_info,
    }));

    return NextResponse.json(
      {
        data: formattedScans,
        count: formattedScans.length,
      },
      { status: 200 }
    );
  } catch (error) {
    console.error('User scans API error:', error);
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}
