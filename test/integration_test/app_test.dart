// Integration Tests for Digital Vault Heritage v3.0
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';

import '../../lib/main.dart' as app;
import '../../lib/core/providers.dart';
import '../../lib/core/services/secure_key_service.dart';
import '../../lib/core/services/security_service.dart';
import '../../lib/core/services/pin_service.dart';
import '../../lib/features/vault/vault_provider.dart';
import '../../lib/shared/models/vault_doc.dart';
import '../test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Digital Vault Heritage Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    @IntegrationTest('Complete user flow from setup to vault usage')
    testWidgets('should complete full user onboarding flow', (WidgetTester tester) async {
      // 1. App Initialization
      app.main();
      await tester.pumpAndSettle();

      // Verify app loads
      expect(find.byType(MaterialApp), findsOneWidget);

      // 2. Welcome Screen
      expect(find.text('Welcome to Digital Vault Heritage'), findsOneWidget);
      
      // Tap "Get Started"
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // 3. PIN Setup Screen
      expect(find.text('Create Your PIN'), findsOneWidget);
      
      // Enter PIN
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pumpAndSettle();

      // Confirm PIN
      await tester.enterText(find.byKey(const Key('confirm_pin')), '1234');
      await tester.pumpAndSettle();

      // Submit PIN
      await tester.tap(find.text('Create PIN'));
      await tester.pumpAndSettle();

      // 4. Biometric Setup (optional)
      expect(find.text('Enable Biometric Authentication'), findsOneWidget);
      await tester.tap(find.text('Skip for Now'));
      await tester.pumpAndSettle();

      // 5. Vault Setup Complete
      expect(find.text('Your Vault is Ready'), findsOneWidget);
      await tester.tap(find.text('Enter Vault'));
      await tester.pumpAndSettle();

      // 6. Main Vault Screen
      expect(find.text('Your Digital Vault'), findsOneWidget);
      expect(find.text('No documents yet'), findsOneWidget);

      // 7. Add First Document
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // 8. Document Upload
      expect(find.text('Add Document'), findsOneWidget);
      
      // Select file type
      await tester.tap(find.text('Financial'));
      await tester.pumpAndSettle();

      // Enter document name
      await tester.enterText(find.byKey(const Key('document_name')), 'Bank Statement');
      await tester.pumpAndSettle();

      // Simulate file selection
      await tester.tap(find.text('Select File'));
      await tester.pumpAndSettle();

      // Mock file selection success
      await tester.tap(find.text('Upload Document'));
      await tester.pumpAndSettle();

      // 9. Verify Document Added
      expect(find.text('Bank Statement'), findsOneWidget);
      expect(find.text('pdf'), findsOneWidget);
    });

    @IntegrationTest('Dead Man\'s Switch configuration flow')
    testWidgets('should configure Dead Man\'s Switch', (WidgetTester tester) async {
      // Initialize app and login
      app.main();
      await tester.pumpAndSettle();
      
      // Skip to main app (mocking login)
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Navigate to Dead Man's Switch
      await tester.tap(find.byIcon(Icons.access_alarm));
      await tester.pumpAndSettle();

      // Configure Dead Man's Switch
      expect(find.text('Dead Man\'s Switch'), findsOneWidget);
      
      // Activate switch
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Set check-in interval
      await tester.tap(find.text('Check-in Interval'));
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('60 days'));
      await tester.pumpAndSettle();

      // Add heir
      await tester.tap(find.text('Add Heir'));
      await tester.pumpAndSettle();

      // Enter heir information
      await tester.enterText(find.byKey(const Key('heir_name')), 'John Doe');
      await tester.enterText(find.byKey(const Key('heir_email')), 'john@example.com');
      await tester.pumpAndSettle();

      // Save heir
      await tester.tap(find.text('Save Heir'));
      await tester.pumpAndSettle();

      // Activate Dead Man's Switch
      await tester.tap(find.text('Activate Dead Man\'s Switch'));
      await tester.pumpAndSettle();

      // Verify activation
      expect(find.text('Dead Man\'s Switch Active'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    @IntegrationTest('Subscription upgrade flow')
    testWidgets('should handle subscription upgrade', (WidgetTester tester) async {
      // Initialize app and login
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to subscription
      await tester.tap(find.byIcon(Icons.diamond));
      await tester.pumpAndSettle();

      // Verify free tier
      expect(find.text('Free Plan'), findsOneWidget);
      expect(find.text('Current Plan'), findsOneWidget);

      // Upgrade to Premium
      await tester.tap(find.text('Upgrade to Premium'));
      await tester.pumpAndSettle();

      // Payment form
      expect(find.text('Payment Information'), findsOneWidget);
      
      // Fill payment form
      await tester.enterText(find.byKey(const Key('card_number')), '4242424242424242');
      await tester.enterText(find.byKey(const Key('expiry')), '12/25');
      await tester.enterText(find.byKey(const Key('cvv')), '123');
      await tester.pumpAndSettle();

      // Submit payment
      await tester.tap(find.text('Complete Payment'));
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Verify upgrade success
      expect(find.text('Premium Plan Active'), findsOneWidget);
      expect(find.text('100 Documents'), findsOneWidget);
      expect(find.text('5 Heirs'), findsOneWidget);
    });

    @IntegrationTest('User reporting flow')
    testWidgets('should configure and generate user reports', (WidgetTester tester) async {
      // Initialize app and login
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to reports
      await tester.tap(find.byIcon(Icons.assessment));
      await tester.pumpAndSettle();

      // Configure report settings
      expect(find.text('Report Settings'), findsOneWidget);
      
      // Set frequency to monthly
      await tester.tap(find.byKey(const Key('report_frequency')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();

      // Enable detailed logs
      await tester.tap(find.byKey(const Key('detailed_logs')));
      await tester.pumpAndSettle();

      // Save settings
      await tester.tap(find.text('Save Settings'));
      await tester.pumpAndSettle();

      // Generate immediate report
      await tester.tap(find.text('Generate Report'));
      await tester.pumpAndSettle();

      // Verify report generation
      expect(find.text('Vault Status Report'), findsOneWidget);
      expect(find.text('Total Documents'), findsOneWidget);
      expect(find.text('Send Report'), findsOneWidget);
    });

    @IntegrationTest('Conditional inheritance configuration')
    testWidgets('should configure conditional inheritance rules', (WidgetTester tester) async {
      // Initialize app and login
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to inheritance settings
      await tester.tap(find.byIcon(Icons.account_balance));
      await tester.pumpAndSettle();

      // Create inheritance rule
      await tester.tap(find.text('Add Inheritance Rule'));
      await tester.pumpAndSettle();

      // Configure rule
      await tester.enterText(find.byKey(const Key('rule_name')), 'Financial Access Rule');
      await tester.pumpAndSettle();

      // Select condition type
      await tester.tap(find.byKey(const Key('condition_type')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Time-based'));
      await tester.pumpAndSettle();

      // Set time conditions
      await tester.tap(find.byKey(const Key('start_time')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Now'));
      await tester.pumpAndSettle();

      // Select heir
      await tester.tap(find.byKey(const Key('select_heir')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('John Doe'));
      await tester.pumpAndSettle();

      // Set access level
      await tester.tap(find.byKey(const Key('access_level')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Read-only'));
      await tester.pumpAndSettle();

      // Save rule
      await tester.tap(find.text('Save Rule'));
      await tester.pumpAndSettle();

      // Verify rule created
      expect(find.text('Financial Access Rule'), findsOneWidget);
      expect(find.text('Read-only'), findsOneWidget);
    });

    @IntegrationTest('Security features integration')
    testWidgets('should handle security features end-to-end', (WidgetTester tester) async {
      // Initialize app
      app.main();
      await tester.pumpAndSettle();

      // Test PIN authentication
      await tester.tap(find.text('Enter Vault'));
      await tester.pumpAndSettle();

      // Enter PIN
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pumpAndSettle();

      // Submit PIN
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      // Verify vault access
      expect(find.text('Your Digital Vault'), findsOneWidget);

      // Test session timeout (simulate)
      await tester.pump(Duration(hours: 25)); // Beyond session timeout
      await tester.pumpAndSettle();

      // Should require re-authentication
      expect(find.text('Session Expired'), findsOneWidget);
      expect(find.text('Please enter your PIN again'), findsOneWidget);

      // Re-authenticate
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      // Verify access restored
      expect(find.text('Your Digital Vault'), findsOneWidget);
    });

    @IntegrationTest('Error handling and recovery')
    testWidgets('should handle errors gracefully', (WidgetTester tester) async {
      // Initialize app
      app.main();
      await tester.pumpAndSettle();

      // Simulate network error during document upload
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Select File'));
      await tester.pumpAndSettle();

      // Mock network error
      await tester.pump(Duration(seconds: 10)); // Simulate timeout
      await tester.pumpAndSettle();

      // Verify error handling
      expect(find.text('Network Error'), findsOneWidget);
      expect(find.text('Unable to upload file. Please check your connection.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Test retry functionality
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Should return to file selection
      expect(find.text('Select File'), findsOneWidget);
    });

    @IntegrationTest('Data persistence and migration')
    testWidgets('should persist data across app restarts', (WidgetTester tester) async {
      // Initialize app and create data
      app.main();
      await tester.pumpAndSettle();

      // Add some test data
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byKey(const Key('document_name')), 'Test Document');
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Upload Document'));
      await tester.pumpAndSettle();

      // Verify data exists
      expect(find.text('Test Document'), findsOneWidget);

      // Simulate app restart
      await tester.pumpWidget(Container()); // Clear widget tree
      await tester.pumpAndSettle();

      // Restart app
      app.main();
      await tester.pumpAndSettle();

      // Re-authenticate
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      // Verify data persisted
      expect(find.text('Test Document'), findsOneWidget);
    });

    @IntegrationTest('Multi-user scenario')
    testWidgets('should handle multiple user profiles', (WidgetTester tester) async {
      // Initialize app with first user
      app.main();
      await tester.pumpAndSettle();

      // Create first user data
      await tester.enterText(find.byType(TextField), '1111');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      // Add document for user 1
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('document_name')), 'User 1 Document');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upload Document'));
      await tester.pumpAndSettle();

      // Logout user 1
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // Login as user 2
      await tester.enterText(find.byType(TextField), '2222');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      // Verify user 2 has separate vault
      expect(find.text('No documents yet'), findsOneWidget);
      expect(find.text('User 1 Document'), findsNothing);
    });

    @IntegrationTest('Performance under load')
    testWidgets('should handle large amounts of data efficiently', (WidgetTester tester) async {
      // Initialize app
      app.main();
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      // Add multiple documents rapidly
      for (int i = 0; i < 50; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        
        await tester.enterText(find.byKey(const Key('document_name')), 'Document $i');
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Upload Document'));
        await tester.pumpAndSettle();
      }

      // Verify all documents are displayed
      for (int i = 0; i < 50; i++) {
        expect(find.text('Document $i'), findsOneWidget);
      }

      // Test scrolling performance
      await tester.fling(find.byType(ListView), Offset(0, -500), 1000);
      await tester.pumpAndSettle();

      // Verify app remains responsive
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
