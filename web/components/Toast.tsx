'use client';

// Toast Notification Component
// Shows success/error messages with auto-dismiss

import { useEffect } from 'react';

interface ToastProps {
  message: string;
  type: 'success' | 'error';
  onClose: () => void;
  duration?: number; // milliseconds
}

export default function Toast({ message, type, onClose, duration = 3000 }: ToastProps) {
  useEffect(() => {
    const timer = setTimeout(() => {
      onClose();
    }, duration);

    return () => clearTimeout(timer);
  }, [duration, onClose]);

  const bgColor = type === 'success' ? 'bg-green-500' : 'bg-red-500';
  const icon = type === 'success' ? '✓' : '✕';

  return (
    <div className="fixed top-4 right-4 z-50 animate-slide-in">
      <div className={`${bgColor} text-white px-6 py-3 rounded-lg shadow-lg flex items-center space-x-3 min-w-[300px]`}>
        <span className="text-xl font-bold">{icon}</span>
        <p className="flex-1">{message}</p>
        <button
          onClick={onClose}
          className="text-white hover:text-gray-200 font-bold text-lg"
        >
          ×
        </button>
      </div>
    </div>
  );
}
