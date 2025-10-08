// Homepage - Vaccine Tracker MVP
// Redirects to dashboard (will be implemented in Phase 3.4)
// For now, shows welcome page with navigation

import Link from 'next/link';

export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center p-4">
      <div className="max-w-4xl w-full">
        {/* Hero Section */}
        <div className="text-center mb-12">
          <h1 className="text-5xl font-bold text-gray-900 mb-4">
            Vaccine Tracker MVP
          </h1>
          <p className="text-xl text-gray-600">
            Generate QR codes, scan vaccines, and track in real-time
          </p>
        </div>

        {/* Action Cards */}
        <div className="grid md:grid-cols-2 gap-6">
          {/* QR Generator Card */}
          <Link href="/generate">
            <div className="bg-white rounded-lg shadow-lg p-8 hover:shadow-xl transition-shadow cursor-pointer border-2 border-transparent hover:border-blue-500">
              <div className="text-4xl mb-4">📱</div>
              <h2 className="text-2xl font-semibold text-gray-900 mb-2">
                Generate QR Code
              </h2>
              <p className="text-gray-600 mb-4">
                Create GS1-formatted QR codes for vaccine doses
              </p>
              <div className="flex items-center text-blue-600 font-medium">
                Start Generating →
              </div>
            </div>
          </Link>

          {/* Dashboard Card */}
          <div className="bg-white rounded-lg shadow-lg p-8 opacity-50 cursor-not-allowed">
            <div className="text-4xl mb-4">📊</div>
            <h2 className="text-2xl font-semibold text-gray-900 mb-2">
              Dashboard
            </h2>
            <p className="text-gray-600 mb-4">
              View real-time scan activity and statistics
            </p>
            <div className="flex items-center text-gray-400 font-medium">
              Coming in Phase 3.4
            </div>
          </div>
        </div>

        {/* Quick Info */}
        <div className="mt-12 bg-white rounded-lg shadow-md p-6">
          <h3 className="text-lg font-semibold text-gray-900 mb-3">
            Quick Start Guide
          </h3>
          <ol className="space-y-2 text-gray-700">
            <li className="flex items-start">
              <span className="font-bold text-blue-600 mr-2">1.</span>
              <span>Generate QR codes for vaccine doses (click above)</span>
            </li>
            <li className="flex items-start">
              <span className="font-bold text-blue-600 mr-2">2.</span>
              <span>Scan QR codes with mobile app (coming in Phase 3.5+)</span>
            </li>
            <li className="flex items-start">
              <span className="font-bold text-blue-600 mr-2">3.</span>
              <span>View real-time scan data on dashboard (coming in Phase 3.4)</span>
            </li>
          </ol>
        </div>

        {/* System Status */}
        <div className="mt-6 text-center">
          <div className="inline-flex items-center gap-2 bg-green-50 text-green-700 px-4 py-2 rounded-full text-sm">
            <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"></div>
            System Online • Phase 3.3 Complete
          </div>
        </div>

        {/* Footer */}
        <div className="mt-8 text-center text-sm text-gray-500">
          <p>
            Local Network: Available at{' '}
            <code className="bg-gray-100 px-2 py-1 rounded">
              http://192.168.29.235:3000
            </code>
          </p>
          <p className="mt-1">
            Use this URL to connect mobile devices on the same WiFi network
          </p>
        </div>
      </div>
    </div>
  );
}
