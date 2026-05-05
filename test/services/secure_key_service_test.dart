// Unit Tests for SecureKeyService v3.0
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'dart:typed_data';

import '../../lib/core/services/secure_key_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('SecureKeyService Tests', () {
    late SecureKeyService secureKeyService;
    late MockFlutterSecureStorage mockStorage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      secureKeyService = SecureKeyService();
    });

    group('Key Generation', () {
      test('should generate cryptographically secure key', () async {
        // Act
        final key = await secureKeyService._generateStrongKey();

        // Assert
        expect(key, isNotNull);
        expect(key.length, greaterThanOrEqualTo(32)); // Base64 encoded 256-bit key
        expect(secureKeyService.isValidKeyFormat(key), isTrue);
      });

      test('should generate different keys each time', () async {
        // Act
        final key1 = await secureKeyService._generateStrongKey();
        final key2 = await secureKeyService._generateStrongKey();

        // Assert
        expect(key1, isNot(equals(key2)));
      });

      test('should generate valid base64url format', () async {
        // Act
        final key = await secureKeyService._generateStrongKey();

        // Assert
        expect(() => base64Url.decode(key), returnsNormally);
        final decoded = base64Url.decode(key);
        expect(decoded.length, equals(32)); // 256 bits
      });
    });

    group('Key Validation', () {
      test('should validate correct key format', () {
        // Arrange
        final validKey = base64Url.encode(List<int>.generate(32, (i) => i % 256));

        // Act & Assert
        expect(secureKeyService.isValidKeyFormat(validKey), isTrue);
      });

      test('should reject invalid key format - too short', () {
        // Arrange
        final invalidKey = base64Url.encode(List<int>.generate(16, (i) => i % 256));

        // Act & Assert
        expect(secureKeyService.isValidKeyFormat(invalidKey), isFalse);
      });

      test('should reject invalid key format - too long', () {
        // Arrange
        final invalidKey = base64Url.encode(List<int>.generate(64, (i) => i % 256));

        // Act & Assert
        expect(secureKeyService.isValidKeyFormat(invalidKey), isFalse);
      });

      test('should reject invalid key format - not base64', () {
        // Arrange
        final invalidKey = 'not_a_valid_base64_key!@#$%^&*()';

        // Act & Assert
        expect(secureKeyService.isValidKeyFormat(invalidKey), isFalse);
      });
    });

    group('Key Storage and Retrieval', () {
      test('should store and retrieve key successfully', () async {
        // Arrange
        final testKey = base64Url.encode(List<int>.generate(32, (i) => i % 256));
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});

        // Act
        when(mockStorage.read(key: 'master_key_v2'))
            .thenAnswer((_) async => testKey);

        final retrievedKey = await secureKeyService.getOrCreateKey();

        // Assert
        expect(retrievedKey, equals(testKey));
        verify(mockStorage.read(key: 'master_key_v2')).called(1);
      });

      test('should create new key when none exists', () async {
        // Arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});

        // Act
        final key = await secureKeyService.getOrCreateKey();

        // Assert
        expect(key, isNotNull);
        expect(secureKeyService.isValidKeyFormat(key), isTrue);
        verify(mockStorage.read(key: 'master_key_v2')).called(1);
        verify(mockStorage.write(key: 'master_key_v2', value: key)).called(1);
        verify(mockStorage.write(key: 'master_key_version', value: '2')).called(1);
      });

      test('should migrate old weak key format', () async {
        // Arrange
        final oldWeakKey = 'weak_key_with_insufficient_entropy';
        when(mockStorage.read(key: 'master_key_v2'))
            .thenAnswer((_) async => oldWeakKey);
        when(mockStorage.read(key: 'master_key_version'))
            .thenAnswer((_) async => '1');
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});

        // Act
        final newKey = await secureKeyService.getOrCreateKey();

        // Assert
        expect(newKey, isNot(equals(oldWeakKey)));
        expect(secureKeyService.isValidKeyFormat(newKey), isTrue);
        verify(mockStorage.delete(key: 'master_key_v2')).called(1);
        verify(mockStorage.delete(key: 'master_key_version')).called(1);
        verify(mockStorage.write(key: 'master_key_v2', value: newKey)).called(1);
        verify(mockStorage.write(key: 'master_key_version', value: '2')).called(1);
      });
    });

    group('Key Rotation', () {
      test('should rotate key successfully', () async {
        // Arrange
        final originalKey = base64Url.encode(List<int>.generate(32, (i) => i % 256));
        when(mockStorage.read(key: 'master_key_v2'))
            .thenAnswer((_) async => originalKey);
        when(mockStorage.delete(key: anyNamed('key')))
            .thenAnswer((_) async {});
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async {});

        // Act
        final rotatedKey = await secureKeyService.rotateKey();

        // Assert
        expect(rotatedKey, isNot(equals(originalKey)));
        expect(secureKeyService.isValidKeyFormat(rotatedKey), isTrue);
        verify(mockStorage.delete(key: 'master_key_v2')).called(1);
        verify(mockStorage.delete(key: 'master_key_version')).called(1);
        verify(mockStorage.write(key: 'master_key_v2', value: rotatedKey)).called(1);
        verify(mockStorage.write(key: 'master_key_version', value: '2')).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle storage read errors gracefully', () async {
        // Arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(() async => await secureKeyService.getOrCreateKey(), 
               throwsA(isA<Exception>()));
      });

      test('should handle storage write errors gracefully', () async {
        // Arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenThrow(Exception('Storage write error'));

        // Act & Assert
        expect(() async => await secureKeyService.getOrCreateKey(), 
               throwsA(isA<Exception>()));
      });
    });

    group('Security Properties', () {
      test('should generate keys with sufficient entropy', () async {
        // Act
        final keys = <String>[];
        for (int i = 0; i < 100; i++) {
          keys.add(await secureKeyService._generateStrongKey());
        }

        // Assert
        final uniqueKeys = keys.toSet();
        expect(uniqueKeys.length, equals(keys.length)); // All keys should be unique
        
        // Check entropy by ensuring keys are sufficiently different
        for (final key in keys) {
          expect(secureKeyService.isValidKeyFormat(key), isTrue);
          final decoded = base64Url.decode(key);
          expect(decoded.length, equals(32));
        }
      });

      test('should use secure random number generator', () async {
        // Act
        final key = await secureKeyService._generateStrongKey();
        final decoded = base64Url.decode(key);

        // Assert
        // Check that the key contains random-looking data (all bytes should vary)
        var byteFrequency = <int, int>{};
        for (final byte in decoded) {
          byteFrequency[byte] = (byteFrequency[byte] ?? 0) + 1;
        }
        
        // In a truly random key, no single byte should appear too frequently
        final maxFrequency = byteFrequency.values.reduce((a, b) => a > b ? a : b);
        expect(maxFrequency, lessThan(5)); // No byte should appear more than 5 times in 32 bytes
      });
    });
  });
}
