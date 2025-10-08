'use client';

// Scan Stats Card Component
// Displays total scans and scans today metrics

import { useEffect, useState } from 'react';
import { supabase } from '@/lib/supabase';

interface ScanStats {
  totalScans: number;
  scansToday: number;
}

export default function ScanStatsCard() {
  const [stats, setStats] = useState<ScanStats>({ totalScans: 0, scansToday: 0 });
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    fetchStats();

    // Subscribe to real-time updates
    const channel = supabase
      .channel('scan_stats_changes')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'scan_events',
        },
        () => {
          // Refetch stats when new scan occurs
          fetchStats();
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  const fetchStats = async () => {
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

      setStats({
        totalScans: totalCount || 0,
        scansToday: todayCount || 0,
      });
    } catch (error) {
      console.error('Error fetching scan stats:', error);
    } finally {
      setIsLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="animate-pulse">
          <div className="h-4 bg-gray-200 rounded w-1/2 mb-4"></div>
          <div className="h-8 bg-gray-200 rounded w-1/3"></div>
        </div>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
      {/* Total Scans Card */}
      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm font-medium text-gray-600 mb-1">Total Scans</p>
            <p className="text-3xl font-bold text-gray-900">{stats.totalScans}</p>
          </div>
          <div className="text-4xl">📊</div>
        </div>
      </div>

      {/* Scans Today Card */}
      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm font-medium text-gray-600 mb-1">Scans Today</p>
            <p className="text-3xl font-bold text-blue-600">{stats.scansToday}</p>
          </div>
          <div className="text-4xl">🔥</div>
        </div>
      </div>
    </div>
  );
}
