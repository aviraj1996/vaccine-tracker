// API Route: GET /api/scans/recent
// Returns the most recent scan events with QR code details

import { NextRequest, NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const limit = parseInt(searchParams.get('limit') || '50', 10);

    const { data, error } = await supabase
      .from('scan_events')
      .select('*, qr_codes(gtin, batch, serial, expiry)')
      .order('scanned_at', { ascending: false })
      .limit(limit);

    if (error) {
      console.error('Database error fetching recent scans:', error);
      return NextResponse.json(
        { success: false, error: 'Failed to fetch recent scans' },
        { status: 500 }
      );
    }

    return NextResponse.json({
      success: true,
      scans: data,
      count: data?.length || 0,
    });
  } catch (error) {
    console.error('Error in GET /api/scans/recent:', error);
    return NextResponse.json(
      { success: false, error: 'Internal server error' },
      { status: 500 }
    );
  }
}
