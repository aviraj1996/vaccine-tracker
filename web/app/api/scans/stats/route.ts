// API Route: GET /api/scans/stats
// Returns scan statistics (total scans, scans today, etc.)

import { NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';

export async function GET() {
  try {
    // Get total scans count
    const { count: totalCount, error: totalError } = await supabase
      .from('scan_events')
      .select('*', { count: 'exact', head: true });

    if (totalError) throw totalError;

    // Get today's scans count
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const todayISO = today.toISOString();

    const { count: todayCount, error: todayError } = await supabase
      .from('scan_events')
      .select('*', { count: 'exact', head: true })
      .gte('scanned_at', todayISO);

    if (todayError) throw todayError;

    // Get Supabase database size and usage metrics
    // Note: These are estimates as Supabase doesn't expose exact metrics via JS SDK
    // For accurate monitoring, use Supabase Dashboard or CLI
    const { data: qrCodesData, error: qrError } = await supabase
      .from('qr_codes')
      .select('*', { count: 'exact', head: true });

    if (qrError) throw qrError;

    return NextResponse.json({
      success: true,
      stats: {
        totalScans: totalCount || 0,
        scansToday: todayCount || 0,
        totalQRCodes: qrCodesData || 0,
      },
      usage: {
        note: 'For accurate database size and bandwidth monitoring, use Supabase Dashboard',
        freeTierLimits: {
          databaseSize: '450 MB',
          bandwidth: '1.8 GB',
        },
      },
    });
  } catch (error) {
    console.error('Error in GET /api/scans/stats:', error);
    return NextResponse.json(
      { success: false, error: 'Failed to fetch scan statistics' },
      { status: 500 }
    );
  }
}
