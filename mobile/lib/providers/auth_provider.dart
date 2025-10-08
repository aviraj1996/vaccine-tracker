// Authentication Provider
// Manages authentication state using Provider pattern

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  AuthProvider() {
    _initialize();
  }

  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userEmail => _user?.email;

  /// Initialize auth provider and listen to auth state changes
  void _initialize() {
    // Get current user
    _user = _supabaseService.currentUser;
    _isLoading = false;

    // Listen to auth state changes
    _supabaseService.authStateChanges.listen((AuthState authState) {
      _user = authState.session?.user;
      notifyListeners();
    });
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      _user = response.user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabaseService.signOut();

      _user = null;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
