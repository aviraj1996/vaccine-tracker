// Network Information Component
// Displays local IP address and connection instructions for mobile devices

'use client';

import { useState, useEffect } from 'react';

interface NetworkInfoProps {
  className?: string;
  collapsed?: boolean;
}

export default function NetworkInfo({ className = '', collapsed = false }: NetworkInfoProps) {
  const [ipAddress, setIpAddress] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isExpanded, setIsExpanded] = useState(!collapsed);

  useEffect(() => {
    // Fetch IP address from API
    fetch('/api/network/ip')
      .then(res => res.json())
      .then(data => {
        setIpAddress(data.ip);
        setIsLoading(false);
      })
      .catch(err => {
        console.error('Failed to fetch IP address:', err);
        setIsLoading(false);
      });
  }, []);

  if (isLoading) {
    return (
      <div className={`bg-blue-50 border border-blue-200 rounded-lg p-4 ${className}`}>
        <div className="flex items-center gap-2">
          <div className="animate-spin h-4 w-4 border-2 border-blue-600 border-t-transparent rounded-full"></div>
          <span className="text-sm text-blue-700">Detecting network...</span>
        </div>
      </div>
    );
  }

  if (!ipAddress) {
    return null;
  }

  return (
    <div className={`bg-blue-50 border border-blue-200 rounded-lg overflow-hidden ${className}`}>
      {/* Header - Always Visible */}
      <button
        onClick={() => setIsExpanded(!isExpanded)}
        className="w-full px-4 py-3 flex items-center justify-between hover:bg-blue-100 transition-colors"
      >
        <div className="flex items-center gap-3">
          <svg
            className="w-5 h-5 text-blue-600"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M8.111 16.404a5.5 5.5 0 017.778 0M12 20h.01m-7.08-7.071c3.904-3.905 10.236-3.905 14.141 0M1.394 9.393c5.857-5.857 15.355-5.857 21.213 0"
            />
          </svg>
          <div className="text-left">
            <div className="text-sm font-semibold text-blue-900">
              Local Network Address
            </div>
            <div className="text-xs text-blue-700 font-mono">
              http://{ipAddress}:3000
            </div>
          </div>
        </div>
        <svg
          className={`w-5 h-5 text-blue-600 transition-transform ${
            isExpanded ? 'rotate-180' : ''
          }`}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M19 9l-7 7-7-7"
          />
        </svg>
      </button>

      {/* Expanded Content */}
      {isExpanded && (
        <div className="px-4 pb-4 space-y-3 border-t border-blue-200 pt-3">
          <div>
            <p className="text-sm text-blue-800 font-medium mb-2">
              📱 Connect Your Mobile Device
            </p>
            <ol className="text-xs text-blue-700 space-y-1 list-decimal list-inside">
              <li>Make sure your phone is on the same WiFi network</li>
              <li>Open the mobile app and tap Settings (⚙️) on login screen</li>
              <li>Enter or auto-detect: <code className="bg-blue-100 px-1 rounded">http://{ipAddress}:3000</code></li>
              <li>Save and test the connection</li>
            </ol>
          </div>

          <div className="bg-blue-100 rounded p-2">
            <p className="text-xs text-blue-800">
              <span className="font-semibold">💡 Tip:</span> This URL is automatically detected from your computer&apos;s network interface.
              If you have multiple network connections, make sure to use the one that matches your WiFi network.
            </p>
          </div>
        </div>
      )}
    </div>
  );
}
