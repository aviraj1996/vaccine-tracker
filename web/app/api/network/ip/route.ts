// Network IP API Route
// Returns the server's local IP address for mobile configuration

import { NextResponse } from 'next/server';
import { getLocalIPAddress, getAllLocalIPAddresses } from '@/lib/network-utils';

export async function GET() {
  try {
    const primaryIP = getLocalIPAddress();
    const allIPs = getAllLocalIPAddresses();

    return NextResponse.json({
      ip: primaryIP,
      all: allIPs,
      port: 3000,
      url: primaryIP ? `http://${primaryIP}:3000` : null,
    });
  } catch (error) {
    console.error('Failed to get IP address:', error);
    return NextResponse.json(
      { error: 'Failed to detect IP address' },
      { status: 500 }
    );
  }
}
