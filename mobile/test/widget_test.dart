// Flutter widget tests for Scanner Screen
// Tests scanner screen UI and basic interactions

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vaccine_tracker/screens/scanner_screen.dart';
import 'package:vaccine_tracker/providers/auth_provider.dart';

// Mock AuthProvider for testing
class MockAuthProvider extends AuthProvider {
  MockAuthProvider() : super();

  @override
  String? get userEmail => 'test@example.com';

  @override
  bool get isAuthenticated => true;

  @override
  Future<void> signOut() async {
    // Mock sign out
  }
}

void main() {
  group('ScannerScreen Widget Tests', () {
    testWidgets('Scanner screen renders correctly', (WidgetTester tester) async {
      // Create a mock auth provider
      final mockAuth = MockAuthProvider();

      // Build the scanner screen with provider
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuth,
            child: const ScannerScreen(),
          ),
        ),
      );

      // Verify app bar title
      expect(find.text('Vaccine Scanner'), findsOneWidget);

      // Verify menu button exists
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('Scanner screen shows menu on tap', (WidgetTester tester) async {
      final mockAuth = MockAuthProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuth,
            child: const ScannerScreen(),
          ),
        ),
      );

      // Tap the menu button
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Verify menu items appear
      expect(find.text('Scan History'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
    });

    testWidgets('Scanner screen shows logout confirmation dialog', (WidgetTester tester) async {
      final mockAuth = MockAuthProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuth,
            child: const ScannerScreen(),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap Sign Out
      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      // Verify logout confirmation dialog appears
      expect(find.text('Sign Out'), findsWidgets);
      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Scanner screen shows scan history bottom sheet', (WidgetTester tester) async {
      final mockAuth = MockAuthProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuth,
            child: const ScannerScreen(),
          ),
        ),
      );

      // Open menu
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Tap Scan History
      await tester.tap(find.text('Scan History'));
      await tester.pumpAndSettle();

      // Verify scan history bottom sheet appears
      expect(find.text('Recent Scans'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('Cancel button closes logout dialog', (WidgetTester tester) async {
      final mockAuth = MockAuthProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuth,
            child: const ScannerScreen(),
          ),
        ),
      );

      // Open menu and tap Sign Out
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Out').last);
      await tester.pumpAndSettle();

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed (no Cancel button visible)
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('Close button closes scan history', (WidgetTester tester) async {
      final mockAuth = MockAuthProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuth,
            child: const ScannerScreen(),
          ),
        ),
      );

      // Open menu and tap Scan History
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Scan History'));
      await tester.pumpAndSettle();

      // Tap Close
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Verify bottom sheet is closed
      expect(find.text('Recent Scans'), findsNothing);
    });

    testWidgets('Scanner screen UI layout is correct', (WidgetTester tester) async {
      final mockAuth = MockAuthProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuth,
            child: const ScannerScreen(),
          ),
        ),
      );

      // Verify key UI elements
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Vaccine Scanner'), findsOneWidget);
      expect(find.byIcon(Icons.menu), findsOneWidget);

      // Verify the screen has a SafeArea
      expect(find.byType(SafeArea), findsOneWidget);

      // Verify Stack widget for overlay
      expect(find.byType(Stack), findsWidgets);
    });
  });

  group('Scanner Screen State Management', () {
    testWidgets('Scanner screen maintains state across rebuilds', (WidgetTester tester) async {
      final mockAuth = MockAuthProvider();

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthProvider>.value(
            value: mockAuth,
            child: const ScannerScreen(),
          ),
        ),
      );

      // Initial state check
      expect(find.text('Vaccine Scanner'), findsOneWidget);

      // Trigger a rebuild
      await tester.pump();

      // Verify state persists
      expect(find.text('Vaccine Scanner'), findsOneWidget);
    });
  });
}
