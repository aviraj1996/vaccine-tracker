// API Route: POST /api/qr/generate
// Generates and saves QR codes to Supabase

import { NextRequest, NextResponse } from 'next/server';
import { supabase } from '@/lib/supabase';
import { encodeGS1Safe, validateGS1Data, type GS1Data } from '@/lib/gs1-encoder';
import QRCode from 'qrcode';
import type { QRGenerateResponse, QRCodeInsert } from '@/lib/types';

// Simple in-memory rate limiter (production should use Redis or Supabase functions)
const rateLimitMap = new Map<string, { count: number; resetTime: number }>();

function checkRateLimit(identifier: string, maxRequests = 10, windowMs = 60000): boolean {
  const now = Date.now();
  const record = rateLimitMap.get(identifier);

  if (!record || now > record.resetTime) {
    // Reset or create new record
    rateLimitMap.set(identifier, { count: 1, resetTime: now + windowMs });
    return true;
  }

  if (record.count >= maxRequests) {
    return false; // Rate limit exceeded
  }

  record.count++;
  return true;
}

export async function POST(request: NextRequest) {
  try {
    // Get client IP for rate limiting
    const clientIP = request.headers.get('x-forwarded-for') || 'unknown';

    // Check rate limit (10 requests per minute)
    if (!checkRateLimit(clientIP)) {
      return NextResponse.json(
        { success: false, error: 'Rate limit exceeded. Please try again later.' },
        { status: 429 }
      );
    }

    // Parse request body
    const body: GS1Data = await request.json();

    // Validate input
    const validationErrors = validateGS1Data(body);
    if (validationErrors.length > 0) {
      return NextResponse.json(
        { success: false, error: validationErrors.join(', ') },
        { status: 400 }
      );
    }

    // Encode to GS1 format
    const { qrData, errors } = encodeGS1Safe(body);
    if (errors.length > 0) {
      return NextResponse.json(
        { success: false, error: errors.join(', ') },
        { status: 400 }
      );
    }

    // Generate QR image as data URL
    const qrImageUrl = await QRCode.toDataURL(qrData, {
      width: 512,
      margin: 2,
      errorCorrectionLevel: 'M',
    });

    // Save to Supabase (parameterized queries handled by SDK)
    const insertData: QRCodeInsert = {
      gtin: body.gtin,
      batch: body.batch,
      expiry: body.expiry,
      serial: body.serial,
      qr_data: qrData,
      created_by: 'admin@example.com', // TODO: Get from auth session
    };

    const { data, error } = await supabase
      .from('qr_codes')
      .insert(insertData as any)
      .select()
      .single();

    if (error) {
      // Check for duplicate serial number (unique constraint violation)
      if (error.code === '23505' || error.message.includes('unique')) {
        return NextResponse.json(
          { success: false, error: 'Serial number already used. Please use a different serial number.' },
          { status: 409 }
        );
      }

      console.error('Supabase error:', error);
      return NextResponse.json(
        { success: false, error: 'Database error: ' + error.message },
        { status: 500 }
      );
    }

    // Return success response
    const response: QRGenerateResponse = {
      success: true,
      data,
      qr_image_url: qrImageUrl,
    };

    return NextResponse.json(response, { status: 201 });

  } catch (error) {
    console.error('QR generation error:', error);
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : 'Unknown error occurred',
      },
      { status: 500 }
    );
  }
}
