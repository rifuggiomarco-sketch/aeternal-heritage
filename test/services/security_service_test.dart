// Unit Tests for SecurityService v3.0
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../lib/core/services/security_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  group('SecurityService Tests', () {
    late SecurityService securityService;
    late MockFlutterSecureStorage mockStorage;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      mockPrefs = MockSharedPreferences();
      securityService = SecurityService();
    });

    group('Input Sanitization', () {
      test('should sanitize normal text correctly', () {
        // Arrange
        const input = 'Hello World 123';

        // Act
        final result = securityService.sanitizeInput(input);

        // Assert
        expect(result, equals(input));
      });

      test('should remove control characters', () {
        // Arrange
        const input = 'Hello\x00\x01\x02World';

        // Act
        final result = securityService.sanitizeInput(input);

        // Assert
        expect(result, equals('HelloWorld'));
      });

      test('should remove script tags', () {
        // Arrange
        const input = 'Hello <script>alert("xss")</script> World';

        // Act
        final result = securityService.sanitizeInput(input);

        // Assert
        expect(result, equals('Hello  World'));
      });

      test('should remove javascript protocol', () {
        // Arrange
        const input = 'javascript:alert("xss")';

        // Act
        final result = securityService.sanitizeInput(input);

        // Assert
        expect(result, equals('alert("xss")'));
      });

      test('should remove event handlers', () {
        // Arrange
        const input = '<div onclick="alert("xss")">Click me</div>';

        // Act
        final result = securityService.sanitizeInput(input);

        // Assert
        expect(result, equals('<div >Click me</div>'));
      });

      test('should detect SQL injection patterns', () {
        // Arrange
        const inputs = [
          "'; DROP TABLE users; --",
          "' OR '1'='1",
          "UNION SELECT * FROM users",
          "INSERT INTO users VALUES ('test')",
        ];

        for (final input in inputs) {
          // Act & Assert
          expect(
            () => securityService.sanitizeInput(input),
            throwsA(isA<SecurityViolationException>()),
            reason: 'Should detect SQL injection in: $input',
          );
        }
      });

      test('should enforce maximum length', () {
        // Arrange
        final input = 'a' * 101;

        // Act & Assert
        expect(
          () => securityService.sanitizeInput(input, maxLength: 100),
          throwsA(isA<SecurityViolationException>()),
        );
      });

      test('should handle empty input', () {
        // Arrange
        const input = '';

        // Act
        final result = securityService.sanitizeInput(input);

        // Assert
        expect(result, equals(input));
      });
    });

    group('Email Validation', () {
      test('should validate correct email addresses', () {
        // Arrange
        const validEmails = [
          'test@example.com',
          'user.name@domain.co.uk',
          'user+tag@example.org',
          'user123@test-domain.com',
        ];

        for (final email in validEmails) {
          // Act & Assert
          expect(securityService.isValidEmail(email), isTrue,
                 reason: 'Should validate: $email');
        }
      });

      test('should reject invalid email addresses', () {
        // Arrange
        const invalidEmails = [
          'invalid-email',
          '@example.com',
          'user@',
          'user..name@example.com',
          'user@.com',
          'user@com.',
        ];

        for (final email in invalidEmails) {
          // Act & Assert
          expect(securityService.isValidEmail(email), isFalse,
                 reason: 'Should reject: $email');
        }
      });
    });

    group('Phone Validation', () {
      test('should validate correct phone numbers', () {
        // Arrange
        const validPhones = [
          '+1234567890',
          '+1 234 567 8900',
          '+44 (0) 20 1234 5678',
          '1234567890',
          '+1-234-567-8900',
        ];

        for (final phone in validPhones) {
          // Act & Assert
          expect(securityService.isValidPhoneNumber(phone), isTrue,
                 reason: 'Should validate: $phone');
        }
      });

      test('should reject invalid phone numbers', () {
        // Arrange
        const invalidPhones = [
          'abc',
          '123',
          '+',
          'phone-number',
          '',
        ];

        for (final phone in invalidPhones) {
          // Act & Assert
          expect(securityService.isValidPhoneNumber(phone), isFalse,
                 reason: 'Should reject: $phone');
        }
      });
    });

    group('Rate Limiting', () {
      test('should allow first login attempt', () async {
        // Arrange
        when(mockPrefs.getStringList(anyNamed('key')))
            .thenAnswer((_) async => []);
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        final result = await securityService.checkLoginRateLimit('user123');

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setStringList('rate_limit_login_user123', any)).called(1);
      });

      test('should block after max login attempts', () async {
        // Arrange
        final now = DateTime.now();
        final attempts = List.generate(5, (i) => 
            now.subtract(Duration(minutes: i)).toIso8601String());
        
        when(mockPrefs.getStringList('rate_limit_login_user123'))
            .thenAnswer((_) async => attempts);
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        final result = await securityService.checkLoginRateLimit('user123');

        // Assert
        expect(result, isFalse);
      });

      test('should reset rate limit after window expires', () async {
        // Arrange
        final oldAttempts = List.generate(5, (i) => 
            DateTime.now().subtract(Duration(minutes: 20)).toIso8601String());
        
        when(mockPrefs.getStringList('rate_limit_login_user123'))
            .thenAnswer((_) async => oldAttempts);
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        final result = await securityService.checkLoginRateLimit('user123');

        // Assert
        expect(result, isTrue);
      });

      test('should allow PIN rate limiting', () async {
        // Arrange
        when(mockPrefs.getStringList('rate_limit_pin'))
            .thenAnswer((_) async => []);
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        final result = await securityService.checkPinRateLimit();

        // Assert
        expect(result, isTrue);
      });

      test('should allow recovery rate limiting', () async {
        // Arrange
        when(mockPrefs.getStringList('rate_limit_recovery'))
            .thenAnswer((_) async => []);
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        final result = await securityService.checkRecoveryRateLimit();

        // Assert
        expect(result, isTrue);
      });

      test('should reset rate limit', () async {
        // Arrange
        when(mockPrefs.remove(anyNamed('key')))
            .thenAnswer((_) async => true);

        // Act
        await securityService.resetRateLimit('login_user123');

        // Assert
        verify(mockPrefs.remove('rate_limit_login_user123')).called(1);
      });
    });

    group('Session Management', () {
      test('should create session successfully', () async {
        // Arrange
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        await securityService.createSession('user123');

        // Assert
        verify(mockStorage.write('security_session', any)).called(1);
      });

      test('should validate active session', () async {
        // Arrange
        final sessionData = {
          'userId': 'user123',
          'createdAt': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
          'lastActivity': DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
          'sessionId': 'session123',
        };
        
        when(mockStorage.read(key: 'security_session'))
            .thenAnswer((_) async => jsonEncode(sessionData));

        // Act
        final result = await securityService.isSessionValid();

        // Assert
        expect(result, isTrue);
        verify(mockStorage.write('security_session', any)).called(1);
      });

      test('should invalidate expired session', () async {
        // Arrange
        final sessionData = {
          'userId': 'user123',
          'createdAt': DateTime.now().subtract(Duration(days: 8)).toIso8601String(),
          'lastActivity': DateTime.now().subtract(Duration(days: 8)).toIso8601String(),
          'sessionId': 'session123',
        };
        
        when(mockStorage.read(key: 'security_session'))
            .thenAnswer((_) async => jsonEncode(sessionData));
        when(mockStorage.delete(key: 'security_session'))
            .thenAnswer((_) async => true);

        // Act
        final result = await securityService.isSessionValid();

        // Assert
        expect(result, isFalse);
        verify(mockStorage.delete('security_session')).called(1);
      });

      test('should update session activity', () async {
        // Arrange
        final sessionData = {
          'userId': 'user123',
          'createdAt': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
          'lastActivity': DateTime.now().subtract(Duration(minutes: 30)).toIso8601String(),
          'sessionId': 'session123',
        };
        
        when(mockStorage.read(key: 'security_session'))
            .thenAnswer((_) async => jsonEncode(sessionData));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        await securityService.updateSessionActivity();

        // Assert
        verify(mockStorage.write('security_session', any)).called(1);
      });

      test('should invalidate session', () async {
        // Arrange
        when(mockStorage.delete(key: 'security_session'))
            .thenAnswer((_) async => true);

        // Act
        await securityService.invalidateSession();

        // Assert
        verify(mockStorage.delete('security_session')).called(1);
      });
    });

    group('Security Event Logging', () {
      test('should log security events', () async {
        // Arrange
        when(mockPrefs.getStringList(anyNamed('key')))
            .thenAnswer((_) async => []);
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        await securityService.logSecurityEvent(
          'test_event',
          userId: 'user123',
          metadata: {'key': 'value'},
        );

        // Assert
        verify(mockPrefs.setStringList('security_audit_log', any)).called(1);
      });

      test('should get recent security events', () async {
        // Arrange
        final events = [
          {
            'eventType': 'test_event',
            'timestamp': DateTime.now().toIso8601String(),
            'userId': 'user123',
            'metadata': {'key': 'value'},
          },
        ];
        
        when(mockPrefs.getStringList('security_audit_log'))
            .thenAnswer((_) async => events.map((e) => jsonEncode(e)).toList());

        // Act
        final result = await securityService.getSecurityEvents(limit: 10);

        // Assert
        expect(result, isNotEmpty);
        expect(result.first.eventType, equals('test_event'));
      });

      test('should clear security data', () async {
        // Arrange
        final keys = ['rate_limit_test', 'security_audit_log', 'security_session'];
        for (final key in keys) {
          when(mockPrefs.remove(key))
              .thenAnswer((_) async => true);
        }
        when(mockStorage.delete('security_session'))
            .thenAnswer((_) async => true);

        // Act
        await securityService.clearAllSecurityData();

        // Assert
        for (final key in keys) {
          verify(mockPrefs.remove(key)).called(1);
        }
        verify(mockStorage.delete('security_session')).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle storage errors gracefully', () async {
        // Arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(() async => await securityService.isSessionValid(), 
               throwsA(isA<Exception>()));
      });

      test('should handle preference errors gracefully', () async {
        // Arrange
        when(mockPrefs.getStringList(anyNamed('key')))
            .thenThrow(Exception('Preference error'));

        // Act & Assert
        expect(() async => await securityService.checkLoginRateLimit('user123'), 
               throwsA(isA<Exception>()));
      });
    });

    group('Edge Cases', () {
      test('should handle null values in session validation', () async {
        // Arrange
        when(mockStorage.read(key: 'security_session'))
            .thenAnswer((_) async => null);

        // Act
        final result = await securityService.isSessionValid();

        // Assert
        expect(result, isFalse);
      });

      test('should handle malformed session data', () async {
        // Arrange
        when(mockStorage.read(key: 'security_session'))
            .thenAnswer((_) async => 'invalid json');

        // Act
        final result = await securityService.isSessionValid();

        // Assert
        expect(result, isFalse);
      });

      test('should handle very long input strings', () {
        // Arrange
        final longInput = 'a' * 10000;

        // Act
        final result = securityService.sanitizeInput(longInput, maxLength: 100);

        // Assert
        expect(result.length, lessThanOrEqualTo(100));
      });

      test('should handle unicode characters in sanitization', () {
        // Arrange
        const input = 'Hello 🌍 World with émojis and àccénts';

        // Act
        final result = securityService.sanitizeInput(input);

        // Assert
        expect(result, contains('Hello'));
        expect(result, contains('World'));
      });
    });
  });
}
