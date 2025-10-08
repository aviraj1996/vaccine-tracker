'use client';

// QR Generator Form Component
// Handles input for GTIN, Batch, Expiry, Serial with validation and live preview

import { useState, useCallback } from 'react';
import { encodeGS1Safe, validateGS1Data, type GS1Data } from '@/lib/gs1-encoder';
import QRPreview from './QRPreview';
import Toast from './Toast';
import type { QRGenerateResponse } from '@/lib/types';

interface ValidationErrors {
  gtin?: string;
  batch?: string;
  expiry?: string;
  serial?: string;
}

export default function QRGeneratorForm() {
  const [formData, setFormData] = useState<GS1Data>({
    gtin: '',
    batch: '',
    expiry: '',
    serial: '',
  });

  const [errors, setErrors] = useState<ValidationErrors>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [toast, setToast] = useState<{ message: string; type: 'success' | 'error' } | null>(null);

  // Validate individual field
  const validateField = (name: keyof GS1Data, value: string): string | undefined => {
    const tempData = { ...formData, [name]: value };
    const validationErrors = validateGS1Data(tempData);

    // Extract error for this specific field
    const fieldError = validationErrors.find(err =>
      err.toLowerCase().includes(name.toLowerCase())
    );

    return fieldError;
  };

  // Handle input change
  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    const fieldName = name as keyof GS1Data;

    setFormData(prev => ({ ...prev, [fieldName]: value }));

    // Clear error for this field when user starts typing
    if (errors[fieldName]) {
      setErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[fieldName];
        return newErrors;
      });
    }
  };

  // Handle field blur for validation
  const handleBlur = (e: React.FocusEvent<HTMLInputElement>) => {
    const { name, value } = e.target;
    const fieldName = name as keyof GS1Data;

    // Validate on blur
    const error = validateField(fieldName, value);
    if (error) {
      setErrors(prev => ({ ...prev, [fieldName]: error }));
    }
  };

  // Handle form submission
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    // Validate all fields
    const validationErrors = validateGS1Data(formData);
    if (validationErrors.length > 0) {
      // Map errors to fields
      const errorMap: ValidationErrors = {};
      validationErrors.forEach(err => {
        if (err.includes('GTIN')) errorMap.gtin = err;
        else if (err.includes('Batch') || err.includes('batch')) errorMap.batch = err;
        else if (err.includes('Expiry') || err.includes('expiry')) errorMap.expiry = err;
        else if (err.includes('Serial') || err.includes('serial')) errorMap.serial = err;
      });
      setErrors(errorMap);
      return;
    }

    setIsSubmitting(true);

    try {
      // Call API to generate and save QR code
      const response = await fetch('/api/qr/generate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData),
      });

      const result: QRGenerateResponse = await response.json();

      if (!response.ok) {
        throw new Error(result.error || 'Failed to generate QR code');
      }

      // Show success message
      setToast({ message: 'QR code generated successfully!', type: 'success' });

      // Auto-increment serial for rapid testing (e.g., TEST001 -> TEST002)
      setFormData(prev => {
        const serialMatch = prev.serial.match(/^(.*?)(\d+)$/);
        if (serialMatch) {
          const prefix = serialMatch[1];
          const number = parseInt(serialMatch[2], 10);
          const newSerial = prefix + String(number + 1).padStart(serialMatch[2].length, '0');
          return { ...prev, serial: newSerial };
        }
        return prev; // Keep form as-is if serial doesn't end with number
      });
      setErrors({});

    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred';

      // Check for duplicate serial error
      if (errorMessage.includes('already') || errorMessage.includes('duplicate') || errorMessage.includes('unique')) {
        setErrors({ serial: 'Serial number already used. Please use a different serial number.' });
        setToast({ message: 'Serial number already exists', type: 'error' });
      } else {
        setToast({ message: errorMessage, type: 'error' });
      }
    } finally {
      setIsSubmitting(false);
    }
  };

  // Generate GS1 data for preview
  const { qrData } = encodeGS1Safe(formData);

  // Check if form is valid (all fields filled and no errors)
  const isFormValid =
    formData.gtin.trim() !== '' &&
    formData.batch.trim() !== '' &&
    formData.expiry.trim() !== '' &&
    formData.serial.trim() !== '' &&
    Object.keys(errors).length === 0;

  return (
    <div className="space-y-6">
      <form onSubmit={handleSubmit} className="space-y-4">
        {/* GTIN Input */}
        <div>
          <label htmlFor="gtin" className="block text-sm font-medium text-gray-700 mb-1">
            GTIN (14 digits) <span className="text-red-500">*</span>
          </label>
          <input
            type="text"
            id="gtin"
            name="gtin"
            value={formData.gtin}
            onChange={handleChange}
            onBlur={handleBlur}
            placeholder="12345678901234"
            maxLength={14}
            className={`w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 ${
              errors.gtin
                ? 'border-red-300 focus:ring-red-500'
                : 'border-gray-300 focus:ring-blue-500'
            }`}
          />
          {errors.gtin && (
            <p className="mt-1 text-sm text-red-600">{errors.gtin}</p>
          )}
        </div>

        {/* Batch Number Input */}
        <div>
          <label htmlFor="batch" className="block text-sm font-medium text-gray-700 mb-1">
            Batch Number <span className="text-red-500">*</span>
          </label>
          <input
            type="text"
            id="batch"
            name="batch"
            value={formData.batch}
            onChange={handleChange}
            onBlur={handleBlur}
            placeholder="BATCH001"
            maxLength={20}
            className={`w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 ${
              errors.batch
                ? 'border-red-300 focus:ring-red-500'
                : 'border-gray-300 focus:ring-blue-500'
            }`}
          />
          {errors.batch && (
            <p className="mt-1 text-sm text-red-600">{errors.batch}</p>
          )}
          <p className="mt-1 text-xs text-gray-500">Alphanumeric only, max 20 characters</p>
        </div>

        {/* Expiry Date Input */}
        <div>
          <label htmlFor="expiry" className="block text-sm font-medium text-gray-700 mb-1">
            Expiry Date <span className="text-red-500">*</span>
          </label>
          <input
            type="date"
            id="expiry"
            name="expiry"
            value={formData.expiry}
            onChange={handleChange}
            onBlur={handleBlur}
            className={`w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 ${
              errors.expiry
                ? 'border-red-300 focus:ring-red-500'
                : 'border-gray-300 focus:ring-blue-500'
            }`}
          />
          {errors.expiry && (
            <p className="mt-1 text-sm text-red-600">{errors.expiry}</p>
          )}
        </div>

        {/* Serial Number Input */}
        <div>
          <label htmlFor="serial" className="block text-sm font-medium text-gray-700 mb-1">
            Serial Number <span className="text-red-500">*</span>
          </label>
          <input
            type="text"
            id="serial"
            name="serial"
            value={formData.serial}
            onChange={handleChange}
            onBlur={handleBlur}
            placeholder="SN001"
            maxLength={20}
            className={`w-full px-3 py-2 border rounded-md shadow-sm focus:outline-none focus:ring-2 ${
              errors.serial
                ? 'border-red-300 focus:ring-red-500'
                : 'border-gray-300 focus:ring-blue-500'
            }`}
          />
          {errors.serial && (
            <p className="mt-1 text-sm text-red-600">{errors.serial}</p>
          )}
          <p className="mt-1 text-xs text-gray-500">Alphanumeric only, max 20 characters</p>
        </div>

        {/* Submit Button */}
        <button
          type="submit"
          disabled={isSubmitting || !isFormValid}
          className={`w-full py-2 px-4 rounded-md font-medium text-white transition-colors ${
            isSubmitting || !isFormValid
              ? 'bg-gray-400 cursor-not-allowed'
              : 'bg-blue-600 hover:bg-blue-700'
          }`}
        >
          {isSubmitting ? 'Generating...' : 'Generate QR Code'}
        </button>
      </form>

      {/* Live QR Preview */}
      {qrData && (
        <div className="mt-6">
          <h3 className="text-sm font-medium text-gray-700 mb-2">Live Preview</h3>
          <QRPreview qrData={qrData} formData={formData} />
        </div>
      )}

      {/* Toast Notification */}
      {toast && (
        <Toast
          message={toast.message}
          type={toast.type}
          onClose={() => setToast(null)}
        />
      )}
    </div>
  );
}
