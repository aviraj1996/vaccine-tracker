// Main Entry Point
// Vaccine Tracker Mobile App with Authentication

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/supabase_service.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/scanner_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  try {
    await SupabaseService.initialize();
  } catch (e) {
    print('Failed to initialize Supabase: $e');
    print('Please update lib/config/env.dart with your Supabase credentials');
  }

  runApp(const VaccineTrackerApp());
}

class VaccineTrackerApp extends StatelessWidget {
  const VaccineTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Vaccine Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper widget that handles navigation based on auth state
/// Implements auth state persistence (T053)
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen while checking auth state
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Navigate based on authentication state
        // This handles auth persistence automatically:
        // - If user was logged in before app restart, they go to scanner
        // - If not authenticated, they go to login
        if (authProvider.isAuthenticated) {
          return const ScannerScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
