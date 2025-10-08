// Supabase Client for Vaccine Tracker MVP
// This client is used for all database operations and real-time subscriptions

import { createClient } from '@supabase/supabase-js';
import type { Database } from './types';

// Get environment variables
const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error(
    'Missing Supabase environment variables. Please check your .env.local file.\n' +
    'Required variables:\n' +
    '  - NEXT_PUBLIC_SUPABASE_URL\n' +
    '  - NEXT_PUBLIC_SUPABASE_ANON_KEY\n\n' +
    'Get these from your Supabase dashboard: Settings → API'
  );
}

// Create Supabase client with TypeScript types
export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
  },
  realtime: {
    // Real-time options for dashboard updates
    params: {
      eventsPerSecond: 10,
    },
  },
});

// Helper function to check connection
export async function testSupabaseConnection() {
  try {
    const { data, error } = await supabase.from('qr_codes').select('count').limit(1);
    if (error) throw error;
    return { connected: true, error: null };
  } catch (error) {
    return { connected: false, error };
  }
}
