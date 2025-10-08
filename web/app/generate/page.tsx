// QR Generator Page - Vaccine Tracker MVP
// Allows users to generate GS1-formatted QR codes for vaccine doses

import QRGeneratorForm from '@/components/QRGeneratorForm';
import RecentQRTable from '@/components/RecentQRTable';
import NetworkInfo from '@/components/NetworkInfo';

export default function GeneratePage() {
  return (
    <div className="min-h-screen bg-gray-50 py-8 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold text-gray-900">
            Generate Vaccine QR Code
          </h1>
          <p className="mt-2 text-sm text-gray-600">
            Create GS1-formatted QR codes for vaccine dose tracking
          </p>
        </div>

        {/* Network Information */}
        <NetworkInfo className="mb-6" collapsed={true} />

        {/* Main Content Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* Left Column: QR Generator Form */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold text-gray-800 mb-4">
              QR Code Details
            </h2>
            <QRGeneratorForm />
          </div>

          {/* Right Column: Recent QR Codes */}
          <div className="bg-white rounded-lg shadow-md p-6">
            <h2 className="text-xl font-semibold text-gray-800 mb-4">
              Recent QR Codes
            </h2>
            <RecentQRTable />
          </div>
        </div>

        {/* Help Text */}
        <div className="mt-8 bg-blue-50 border border-blue-200 rounded-lg p-4">
          <h3 className="text-sm font-medium text-blue-900 mb-2">
            GS1 Format Information
          </h3>
          <p className="text-sm text-blue-700">
            Generated QR codes use the GS1 standard format:{' '}
            <code className="bg-blue-100 px-2 py-1 rounded text-xs">
              (01)GTIN(10)BATCH(17)EXPIRY(21)SERIAL
            </code>
          </p>
          <ul className="mt-2 text-sm text-blue-700 list-disc list-inside space-y-1">
            <li>GTIN: 14-digit Global Trade Item Number</li>
            <li>Batch: Alphanumeric lot/batch identifier (max 20 chars)</li>
            <li>Expiry: Date in YYMMDD format</li>
            <li>Serial: Unique serial number (max 20 chars)</li>
          </ul>
        </div>
      </div>
    </div>
  );
}
