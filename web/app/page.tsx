// Dashboard Page
// Real-time scan feed and statistics for vaccine tracking MVP

import Link from 'next/link';
import ScanStatsCard from '@/components/ScanStatsCard';
import ScanFeed from '@/components/ScanFeed';

export default function Dashboard() {
  return (
    <div className="min-h-screen bg-gray-50 py-8 px-4">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">
                Vaccine Tracker Dashboard
              </h1>
              <p className="text-gray-600">
                Monitor real-time scan activity and statistics
              </p>
            </div>
            <Link
              href="/generate"
              className="mt-4 md:mt-0 inline-flex items-center px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-md transition-colors"
            >
              <span className="mr-2">+</span>
              Generate QR Code
            </Link>
          </div>
        </div>

        {/* Stats Cards */}
        <div className="mb-8">
          <ScanStatsCard />
        </div>

        {/* Scan Feed */}
        <div className="mb-8">
          <ScanFeed />
        </div>

        {/* System Info */}
        <div className="mt-8 bg-white rounded-lg shadow-md p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-3">
            Quick Info
          </h3>
          <div className="grid md:grid-cols-3 gap-4 text-sm">
            <div>
              <p className="text-gray-600 font-medium mb-1">Local Network Access</p>
              <code className="bg-gray-100 px-2 py-1 rounded text-xs">
                http://192.168.29.235:3000
              </code>
            </div>
            <div>
              <p className="text-gray-600 font-medium mb-1">Real-time Updates</p>
              <p className="text-green-600">● Active</p>
            </div>
            <div>
              <p className="text-gray-600 font-medium mb-1">System Status</p>
              <p className="text-green-600">Phase 3.4 Complete</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
