// Environment Configuration
// Stores Supabase credentials and API URLs

class Environment {
  // Supabase Configuration
  // TODO: Replace with your actual Supabase project credentials
  // Get these from: https://app.supabase.com/project/{project-id}/settings/api

  // Supabase project URL
  static const String supabaseUrl = 'https://bsdpgfhthdkuwihoomdk.supabase.co';

  // Supabase anonymous key (from Supabase Dashboard -> Settings -> API)
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJzZHBnZmh0aGRrdXdpaG9vbWRrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk2MzAxMzMsImV4cCI6MjA3NTIwNjEzM30.I-_3doMqZtW3zbkXjofw18jorGONXDNUSG0SKHwwuNc';

  // API Configuration
  // Local network IP for Next.js web app (auto-detected on web startup)
  // Change this to match your local machine's IP address
  static const String webAppUrl = 'http://192.168.29.235:3000';

  // Validate configuration
  static bool get isConfigured {
    return supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY_HERE' &&
        supabaseUrl.isNotEmpty;
  }

  // Get configuration status message
  static String get configStatus {
    if (!isConfigured) {
      return 'Environment not configured. Please update lib/config/env.dart with your Supabase credentials.';
    }
    return 'Environment configured successfully.';
  }
}
