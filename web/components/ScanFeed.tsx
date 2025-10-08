'use client';

// Scan Feed Component
// Displays real-time scan events with auto-scroll and latency monitoring

import { useEffect, useState, useRef } from 'react';
import { supabase } from '@/lib/supabase';
import { formatRelativeTime } from '@/lib/format-time';
import LoadingSkeleton from './LoadingSkeleton';
import EmptyState from './EmptyState';

interface ScanEvent {
  id: string;
  qr_code_id: string;
  scanned_by: string;
  scanned_at: string;
  device_info: string | null;
  qr_codes: {
    gtin: string;
    batch: string;
    serial: string;
  };
}

export default function ScanFeed() {
  const [scans, setScans] = useState<ScanEvent[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [latencyWarning, setLatencyWarning] = useState(false);
  const topRef = useRef<HTMLDivElement>(null);
  const latencyTimerRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    fetchRecentScans();

    // Subscribe to real-time scan events
    const channel = supabase
      .channel('scan_events_feed')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'scan_events',
        },
        async (payload) => {
          console.log('New scan event received:', payload);

          // Clear latency timer since we received the update
          if (latencyTimerRef.current) {
            clearTimeout(latencyTimerRef.current);
            latencyTimerRef.current = null;
          }
          setLatencyWarning(false);

          // Fetch the full scan data with QR code details
          const { data, error } = await supabase
            .from('scan_events')
            .select('*, qr_codes(gtin, batch, serial)')
            .eq('id', payload.new.id)
            .single();

          if (error) {
            console.error('Error fetching new scan details:', error);
            return;
          }

          // Prepend new scan to the list
          setScans((prev) => [data as ScanEvent, ...prev].slice(0, 50)); // Keep only 50 most recent

          // Auto-scroll to top
          if (topRef.current) {
            topRef.current.scrollIntoView({ behavior: 'smooth', block: 'start' });
          }
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
      if (latencyTimerRef.current) {
        clearTimeout(latencyTimerRef.current);
      }
    };
  }, []);

  const fetchRecentScans = async () => {
    setIsLoading(true);
    try {
      const { data, error } = await supabase
        .from('scan_events')
        .select('*, qr_codes(gtin, batch, serial)')
        .order('scanned_at', { ascending: false })
        .limit(50);

      if (error) throw error;
      setScans((data as ScanEvent[]) || []);
    } catch (error) {
      console.error('Error fetching scan events:', error);
    } finally {
      setIsLoading(false);
    }
  };

  // Start latency timer when a scan is expected (this is a simple implementation)
  // In production, you'd track this more accurately based on scan timestamps
  useEffect(() => {
    if (scans.length > 0) {
      // Start a 2-second timer for latency monitoring
      latencyTimerRef.current = setTimeout(() => {
        // If we haven't received an update in 2 seconds, show warning
        // This is a simplified implementation - in production, you'd track scan creation time
        console.warn('Real-time update latency > 2 seconds');
      }, 2000);
    }
  }, [scans.length]);

  const handleRefresh = () => {
    fetchRecentScans();
  };

  if (isLoading) {
    return (
      <div className="bg-white rounded-lg shadow-md p-6">
        <h2 className="text-xl font-semibold text-gray-900 mb-4">Recent Scans</h2>
        <LoadingSkeleton />
      </div>
    );
  }

  if (scans.length === 0) {
    return (
      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold text-gray-900">Recent Scans</h2>
          <button
            onClick={handleRefresh}
            className="text-sm text-blue-600 hover:text-blue-800 font-medium"
          >
            ↻ Refresh
          </button>
        </div>
        <EmptyState
          icon="📱"
          title="No scans yet"
          description="Scan a QR code with the mobile app to see it appear here in real-time"
          actionText="Generate QR Code"
          actionHref="/generate"
        />
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow-md p-6">
      <div className="flex justify-between items-center mb-4" ref={topRef}>
        <h2 className="text-xl font-semibold text-gray-900">Recent Scans</h2>
        <button
          onClick={handleRefresh}
          className="text-sm text-blue-600 hover:text-blue-800 font-medium"
        >
          ↻ Refresh
        </button>
      </div>

      {/* Latency Warning */}
      {latencyWarning && (
        <div className="mb-4 bg-yellow-50 border border-yellow-200 rounded-md p-3">
          <p className="text-sm text-yellow-800">
            ⚠️ Real-time update latency detected. Updates may be delayed.
          </p>
        </div>
      )}

      {/* Scan Feed Table */}
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Time
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                User
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                GTIN
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Batch
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Serial
              </th>
              <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Device
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {scans.map((scan, index) => (
              <tr
                key={scan.id}
                className={`hover:bg-gray-50 ${index === 0 ? 'bg-blue-50' : ''}`}
              >
                <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-900">
                  {formatRelativeTime(scan.scanned_at)}
                </td>
                <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-600">
                  {scan.scanned_by}
                </td>
                <td className="px-4 py-3 whitespace-nowrap text-sm font-mono text-gray-600">
                  {scan.qr_codes.gtin}
                </td>
                <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-600">
                  {scan.qr_codes.batch}
                </td>
                <td className="px-4 py-3 whitespace-nowrap text-sm font-medium text-gray-900">
                  {scan.qr_codes.serial}
                </td>
                <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500">
                  {scan.device_info || 'N/A'}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Footer Info */}
      <div className="mt-4 text-xs text-gray-500 text-center">
        Showing {scans.length} most recent scan{scans.length !== 1 ? 's' : ''}
        {' • '}
        Updates automatically in real-time
      </div>
    </div>
  );
}
