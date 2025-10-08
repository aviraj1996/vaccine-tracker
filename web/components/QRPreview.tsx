'use client';

// QR Preview Component
// Displays live QR code preview with 300ms debounce

import { useState, useEffect, useRef } from 'react';
import QRCodeSVG from 'react-qr-code';
import QRCode from 'qrcode';
import type { GS1Data } from '@/lib/gs1-encoder';

interface QRPreviewProps {
  qrData: string;
  formData: GS1Data;
}

export default function QRPreview({ qrData, formData }: QRPreviewProps) {
  const [debouncedQRData, setDebouncedQRData] = useState(qrData);
  const [isDownloading, setIsDownloading] = useState(false);
  const canvasRef = useRef<HTMLCanvasElement>(null);

  // Debounce QR data updates (300ms)
  useEffect(() => {
    const timer = setTimeout(() => {
      setDebouncedQRData(qrData);
    }, 300);

    return () => clearTimeout(timer);
  }, [qrData]);

  // Handle QR download
  const handleDownload = async () => {
    if (!debouncedQRData || !formData.serial) return;

    setIsDownloading(true);

    try {
      // Generate QR code as data URL
      const canvas = canvasRef.current;
      if (canvas) {
        // Use qrcode library to generate high-quality PNG
        await QRCode.toCanvas(canvas, debouncedQRData, {
          width: 512,
          margin: 2,
          errorCorrectionLevel: 'M',
        });

        // Convert canvas to blob
        canvas.toBlob((blob) => {
          if (blob) {
            const url = URL.createObjectURL(blob);
            const link = document.createElement('a');
            link.href = url;
            link.download = `vaccine-qr-${formData.serial}.png`;
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            URL.revokeObjectURL(url);
          }
        });
      }
    } catch (error) {
      console.error('Download error:', error);
      alert('Failed to download QR code');
    } finally {
      setIsDownloading(false);
    }
  };

  // Check if QR data is valid (not empty)
  const isValid = debouncedQRData && debouncedQRData.length > 0;

  return (
    <div className="space-y-4">
      {/* QR Code Display */}
      <div className="flex justify-center bg-white border-2 border-gray-200 rounded-lg p-4">
        {isValid ? (
          <QRCodeSVG
            value={debouncedQRData}
            size={256}
            level="M"
          />
        ) : (
          <div className="w-64 h-64 flex items-center justify-center text-gray-400">
            <p className="text-sm text-center">Fill in all fields to see QR preview</p>
          </div>
        )}
      </div>

      {/* Hidden canvas for download */}
      <canvas ref={canvasRef} className="hidden" />

      {/* GS1 Data Display */}
      {isValid && (
        <div className="bg-gray-50 rounded-md p-3">
          <p className="text-xs font-mono text-gray-700 break-all">
            {debouncedQRData}
          </p>
        </div>
      )}

      {/* Download Button */}
      {isValid && (
        <button
          onClick={handleDownload}
          disabled={isDownloading}
          className={`w-full py-2 px-4 rounded-md font-medium text-white transition-colors ${
            isDownloading
              ? 'bg-gray-400 cursor-not-allowed'
              : 'bg-green-600 hover:bg-green-700'
          }`}
        >
          {isDownloading ? 'Downloading...' : 'Download QR Code'}
        </button>
      )}

      {/* Vaccine Info */}
      {isValid && formData.gtin && (
        <div className="text-xs text-gray-600 space-y-1">
          <p><strong>GTIN:</strong> {formData.gtin}</p>
          <p><strong>Batch:</strong> {formData.batch}</p>
          <p><strong>Expiry:</strong> {formData.expiry}</p>
          <p><strong>Serial:</strong> {formData.serial}</p>
        </div>
      )}
    </div>
  );
}
