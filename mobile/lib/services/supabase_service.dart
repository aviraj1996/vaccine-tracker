// Supabase Service
// Manages Supabase client initialization and provides database access

import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

class SupabaseService {
  // Singleton instance
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Supabase client instance
  SupabaseClient? _client;

  // Get Supabase client (lazy initialization)
  SupabaseClient get client {
    if (_client == null) {
      throw Exception(
        'Supabase not initialized. Call SupabaseService.initialize() first.',
      );
    }
    return _client!;
  }

  // Check if Supabase is initialized
  bool get isInitialized => _client != null;

  /// Initialize Supabase with environment credentials
  ///
  /// Call this once at app startup in main.dart
  /// Example:
  /// ```dart
  /// await SupabaseService.initialize();
  /// ```
  static Future<void> initialize() async {
    if (_instance._client != null) {
      // Already initialized
      return;
    }

    if (!Environment.isConfigured) {
      throw Exception(Environment.configStatus);
    }

    try {
      await Supabase.initialize(
        url: Environment.supabaseUrl,
        anonKey: Environment.supabaseAnonKey,
        debug: true, // Enable debug logging in development
      );

      _instance._client = Supabase.instance.client;

      print('✅ Supabase initialized successfully');
      print('   URL: ${Environment.supabaseUrl}');
    } catch (e) {
      print('❌ Supabase initialization failed: $e');
      rethrow;
    }
  }

  /// Get current authenticated user
  User? get currentUser => client.auth.currentUser;

  /// Check if user is signed in
  bool get isSignedIn => currentUser != null;

  /// Get current user's email
  String? get currentUserEmail => currentUser?.email;

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      print('❌ Sign in failed: $e');
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
      print('✅ User signed out successfully');
    } catch (e) {
      print('❌ Sign out failed: $e');
      rethrow;
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  /// Access to qr_codes table
  SupabaseQueryBuilder get qrCodes => client.from('qr_codes');

  /// Access to scan_events table
  SupabaseQueryBuilder get scanEvents => client.from('scan_events');

  /// Lookup QR code by serial number
  Future<Map<String, dynamic>?> findQRBySerial(String serial) async {
    try {
      final response = await qrCodes
          .select()
          .eq('serial', serial)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Error finding QR by serial: $e');
      rethrow;
    }
  }

  /// Create a new scan event
  Future<Map<String, dynamic>> createScanEvent({
    required String qrCodeId,
    required String scannedBy,
    String? deviceInfo,
  }) async {
    try {
      final response = await scanEvents
          .insert({
            'qr_code_id': qrCodeId,
            'scanned_by': scannedBy,
            'device_info': deviceInfo,
          })
          .select()
          .single();

      print('✅ Scan event created: $response');
      return response;
    } catch (e) {
      print('❌ Error creating scan event: $e');
      rethrow;
    }
  }

  /// Get recent scan events for current user
  Future<List<Map<String, dynamic>>> getRecentScans({
    required String userEmail,
    int limit = 5,
  }) async {
    try {
      final response = await scanEvents
          .select('*, qr_codes(*)')
          .eq('scanned_by', userEmail)
          .order('scanned_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching recent scans: $e');
      rethrow;
    }
  }
}
