'use client';

// Recent QR Table Component
// Shows last 10 generated QR codes with real-time updates

import { useState, useEffect } from 'react';
import { supabase } from '@/lib/supabase';
import type { QRCode } from '@/lib/types';
import EmptyState from './EmptyState';

export default function RecentQRTable() {
  const [qrCodes, setQRCodes] = useState<QRCode[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [copyFeedback, setCopyFeedback] = useState<string | null>(null);

  // Fetch recent QR codes
  useEffect(() => {
    fetchRecentQRCodes();

    // Subscribe to real-time inserts
    const channel = supabase
      .channel('qr_codes_changes')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'qr_codes',
        },
        (payload) => {
          console.log('New QR code inserted:', payload);
          // Prepend new QR code to the list
          setQRCodes((prev) => [payload.new as QRCode, ...prev].slice(0, 10));
        }
      )
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  const fetchRecentQRCodes = async () => {
    setIsLoading(true);
    try {
      const { data, error } = await supabase
        .from('qr_codes')
        .select('*')
        .order('created_at', { ascending: false })
        .limit(10);

      if (error) throw error;
      setQRCodes(data || []);
    } catch (error) {
      console.error('Error fetching QR codes:', error);
    } finally {
      setIsLoading(false);
    }
  };

  // Copy QR data to clipboard
  const handleCopyToClipboard = async (qrData: string, serial: string) => {
    try {
      await navigator.clipboard.writeText(qrData);
      setCopyFeedback(serial);
      setTimeout(() => setCopyFeedback(null), 2000);
    } catch (error) {
      console.error('Failed to copy:', error);
      alert('Failed to copy to clipboard');
    }
  };

  // Format date
  const formatDate = (dateString: string) => {
    const date = new Date(dateString);
    return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
  };

  if (isLoading) {
    return (
      <div className="flex justify-center items-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
      </div>
    );
  }

  if (qrCodes.length === 0) {
    return (
      <EmptyState
        icon="📄"
        title="No QR codes generated yet"
        description="Generate your first QR code to get started"
        actionText="Go to QR Generator"
        actionHref="/generate"
      />
    );
  }

  return (
    <div className="overflow-x-auto">
      <table className="min-w-full divide-y divide-gray-200">
        <thead className="bg-gray-50">
          <tr>
            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Serial
            </th>
            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Batch
            </th>
            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Expiry
            </th>
            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Created
            </th>
            <th className="px-4 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
              Actions
            </th>
          </tr>
        </thead>
        <tbody className="bg-white divide-y divide-gray-200">
          {qrCodes.map((qr) => (
            <tr key={qr.id} className="hover:bg-gray-50">
              <td className="px-4 py-3 whitespace-nowrap text-sm font-medium text-gray-900">
                {qr.serial}
              </td>
              <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500">
                {qr.batch}
              </td>
              <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500">
                {qr.expiry}
              </td>
              <td className="px-4 py-3 whitespace-nowrap text-sm text-gray-500">
                {formatDate(qr.created_at)}
              </td>
              <td className="px-4 py-3 whitespace-nowrap text-sm">
                <button
                  onClick={() => handleCopyToClipboard(qr.qr_data, qr.serial)}
                  className="text-blue-600 hover:text-blue-800 font-medium"
                >
                  {copyFeedback === qr.serial ? '✓ Copied!' : 'Copy'}
                </button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
