// Unit Tests for EnhancedDeadMansSwitchService v3.0
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../../lib/core/services/enhanced_dead_mans_switch_service.dart';
import '../../lib/core/services/security_service.dart';
import '../../lib/core/services/advanced_security_logging_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockSecurityService extends Mock implements SecurityService {}
class MockAdvancedSecurityLoggingService extends Mock implements AdvancedSecurityLoggingService {}
class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('EnhancedDeadMansSwitchService Tests', () {
    late EnhancedDeadMansSwitchService dmsService;
    late MockFlutterSecureStorage mockStorage;
    late MockSharedPreferences mockPrefs;
    late MockSecurityService mockSecurityService;
    late MockAdvancedSecurityLoggingService mockLoggingService;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      mockPrefs = MockSharedPreferences();
      mockSecurityService = MockSecurityService();
      mockLoggingService = MockAdvancedSecurityLoggingService();
      mockHttpClient = MockHttpClient();

      dmsService = EnhancedDeadMansSwitchService();
    });

    group('Configuration Validation', () {
      test('should validate correct configuration', () {
        // Arrange
        final config = const CheckInConfig(
          channels: [CheckInChannel.email, CheckInChannel.in_app],
          interval: Duration(days: 30),
          maxMissedCheckIns: 3,
          gracePeriod: Duration(hours: 48),
          requiredChannelConfirmations: 2,
        );
        final heirs = [
          HeirConfig(
            id: 'heir1',
            name: 'John Doe',
            email: 'john@example.com',
          ),
        ];

        // Act & Assert
        expect(() => dmsService._validateConfig(config, heirs), returnsNormally);
      });

      test('should reject configuration with no heirs', () {
        // Arrange
        final config = const CheckInConfig();
        final heirs = <HeirConfig>[];

        // Act & Assert
        expect(
          () => dmsService._validateConfig(config, heirs),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject configuration with no channels', () {
        // Arrange
        final config = const CheckInConfig(channels: []);
        final heirs = [
          HeirConfig(
            id: 'heir1',
            name: 'John Doe',
            email: 'john@example.com',
          ),
        ];

        // Act & Assert
        expect(
          () => dmsService._validateConfig(config, heirs),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject configuration with invalid email', () {
        // Arrange
        final config = const CheckInConfig();
        final heirs = [
          HeirConfig(
            id: 'heir1',
            name: 'John Doe',
            email: 'invalid-email',
          ),
        ];

        // Act & Assert
        expect(
          () => dmsService._validateConfig(config, heirs),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should reject configuration with too many required confirmations', () {
        // Arrange
        final config = const CheckInConfig(
          requiredChannelConfirmations: 5,
          channels: [CheckInChannel.email, CheckInChannel.in_app],
        );
        final heirs = [
          HeirConfig(
            id: 'heir1',
            name: 'John Doe',
            email: 'john@example.com',
          ),
        ];

        // Act & Assert
        expect(
          () => dmsService._validateConfig(config, heirs),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('Activation', () {
      test('should activate Dead Man\'s Switch successfully', () async {
        // Arrange
        final config = const CheckInConfig(
          channels: [CheckInChannel.in_app],
          interval: Duration(days: 30),
        );
        final heirs = [
          HeirConfig(
            id: 'heir1',
            name: 'John Doe',
            email: 'john@example.com',
          ),
        ];
        
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockSecurityService.isValidEmail(anyNamed('email')))
            .thenReturn(true);

        // Act
        await dmsService.activate(config: config, heirs: heirs);

        // Assert
        verify(mockStorage.write('enhanced_dead_mans_switch_state_v3', any)).called(1);
      });

      test('should log activation event', () async {
        // Arrange
        final config = const CheckInConfig();
        final heirs = [
          HeirConfig(
            id: 'heir1',
            name: 'John Doe',
            email: 'john@example.com',
          ),
        ];
        
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockSecurityService.isValidEmail(anyNamed('email')))
            .thenReturn(true);

        // Act
        await dmsService.activate(config: config, heirs: heirs);

        // Assert
        verify(mockLoggingService.logDeadMansSwitchEvent(
          userId: anyNamed('userId'),
          action: 'activated',
          metadata: anyNamed('metadata'),
        )).called(1);
      });
    });

    group('Multi-channel Check-in', () {
      test('should perform successful check-in on multiple channels', () async {
        // Arrange
        final state = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.active,
          config: const CheckInConfig(
            channels: [CheckInChannel.email, CheckInChannel.in_app],
            requiredChannelConfirmations: 2,
          ),
          lastCheckIn: DateTime.now().subtract(Duration(hours: 25)),
        );
        
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(state.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        final results = await dmsService.performCheckIn(
          channels: [CheckInChannel.email, CheckInChannel.in_app],
        );

        // Assert
        expect(results, isNotNull);
        expect(results.length, equals(2));
        expect(results[CheckInChannel.in_app], isTrue);
        verify(mockStorage.write('enhanced_dead_mans_switch_state_v3', any)).called(1);
      });

      test('should handle check-in when not active', () async {
        // Arrange
        final state = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.inactive,
        );
        
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(state.toJson()));

        // Act & Assert
        expect(
          () async => await dmsService.performCheckIn(),
          throwsA(isA<StateError>()),
        );
      });

      test('should track check-in history', () async {
        // Arrange
        final state = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.active,
          config: const CheckInConfig(channels: [CheckInChannel.in_app]),
          lastCheckIn: DateTime.now().subtract(Duration(hours: 25)),
        );
        
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(state.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        await dmsService.performCheckIn();

        // Assert
        final captured = verify(mockStorage.write('enhanced_dead_mans_switch_state_v3', captureAny)).captured;
        final updatedState = EnhancedDeadMansSwitchState.fromJson(jsonDecode(captured as String));
        expect(updatedState.checkInHistory.length, equals(2)); // Original + new
      });
    });

    group('Grace Period', () {
      test('should start grace period after missed check-ins', () async {
        // Arrange
        final state = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.active,
          config: const CheckInConfig(
            maxMissedCheckIns: 3,
            gracePeriod: Duration(hours: 48),
          ),
          lastCheckIn: DateTime.now().subtract(Duration(days: 65)), // Overdue
          checkInHistory: List.generate(3, (i) => CheckInRecord(
            id: 'check_$i',
            channel: CheckInChannel.in_app,
            timestamp: DateTime.now().subtract(Duration(days: 65 - i)),
            success: false,
          )),
        );
        
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(state.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        await dmsService._handleMissedCheckIn(state);

        // Assert
        final captured = verify(mockStorage.write('enhanced_dead_mans_switch_state_v3', captureAny)).captured;
        final updatedState = EnhancedDeadMansSwitchState.fromJson(jsonDecode(captured as String));
        expect(updatedState.status, equals(DeadMansSwitchStatus.grace_period_active));
        expect(updatedState.gracePeriodStart, isNotNull);
        expect(updatedState.gracePeriodEnd, isNotNull);
      });

      test('should cancel grace period', () async {
        // Arrange
        final state = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.grace_period_active,
          gracePeriodStart: DateTime.now().subtract(Duration(hours: 24)),
          gracePeriodEnd: DateTime.now().add(Duration(hours: 24)),
        );
        
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(state.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        await dmsService.cancelGracePeriod();

        // Assert
        final captured = verify(mockStorage.write('enhanced_dead_mans_switch_state_v3', captureAny)).captured;
        final updatedState = EnhancedDeadMansSwitchState.fromJson(jsonDecode(captured as String));
        expect(updatedState.status, equals(DeadMansSwitchStatus.active));
        expect(updatedState.gracePeriodStart, isNull);
        expect(updatedState.gracePeriodEnd, isNull);
      });

      test('should trigger after grace period expires', () async {
        // Arrange
        final state = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.grace_period_active,
          gracePeriodStart: DateTime.now().subtract(Duration(hours: 49)),
          gracePeriodEnd: DateTime.now().subtract(Duration(hours: 1)), // Expired
          heirConfirmations: {'heir1': 'token1'},
        );
        
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(state.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        await dmsService._triggerDeadMansSwitch(state);

        // Assert
        final captured = verify(mockStorage.write('enhanced_dead_mans_switch_state_v3', captureAny)).captured;
        final updatedState = EnhancedDeadMansSwitchState.fromJson(jsonDecode(captured as String));
        expect(updatedState.status, equals(DeadMansSwitchStatus.triggered));
        expect(updatedState.triggeredAt, isNotNull);
      });
    });

    group('Heir Confirmation', () {
      test('should confirm heir access with valid token', () async {
        // Arrange
        final state = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.grace_period_active,
          heirs: [
            HeirConfig(
              id: 'heir1',
              name: 'John Doe',
              email: 'john@example.com',
              canReceiveAll: true,
            ),
          ],
        );
        
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(state.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        final result = await dmsService.confirmHeirAccess(
          heirId: 'heir1',
          token: 'valid_token_12345',
        );

        // Assert
        expect(result, isTrue);
        final captured = verify(mockStorage.write('enhanced_dead_mans_switch_state_v3', captureAny)).captured;
        final updatedState = EnhancedDeadMansSwitchState.fromJson(jsonDecode(captured as String));
        expect(updatedState.heirConfirmations.containsKey('heir1'), isTrue);
      });

      test('should reject heir access with invalid token', () async {
        // Arrange
        final state = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.grace_period_active,
          heirs: [
            HeirConfig(
              id: 'heir1',
              name: 'John Doe',
              email: 'john@example.com',
            ),
          ],
        );
        
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(state.toJson()));

        // Act
        final result = await dmsService.confirmHeirAccess(
          heirId: 'heir1',
          token: 'short',
        );

        // Assert
        expect(result, isFalse);
      });

      test('should handle conditional inheritance access', () async {
        // Arrange
        final state = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.grace_period_active,
          heirs: [
            HeirConfig(
              id: 'heir1',
              name: 'John Doe',
              email: 'john@example.com',
              canReceiveAll: false,
              allowedFolders: ['financial', 'legal'],
            ),
          ],
        );
        
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(state.toJson()));

        // Act
        final result = await dmsService.confirmHeirAccess(
          heirId: 'heir1',
          token: 'valid_token_12345',
          accessRequest: {'folders': ['financial', 'legal']},
        );

        // Assert
        expect(result, isTrue);
      });

      test('should reject conditional inheritance with wrong folders', () async {
        // Arrange
        final state = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.grace_period_active,
          heirs: [
            HeirConfig(
              id: 'heir1',
              name: 'John Doe',
              email: 'john@example.com',
              canReceiveAll: false,
              allowedFolders: ['financial', 'legal'],
            ),
          ],
        );
        
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(state.toJson()));

        // Act
        final result = await dmsService.confirmHeirAccess(
          heirId: 'heir1',
          token: 'valid_token_12345',
          accessRequest: {'folders': ['medical', 'personal']},
        );

        // Assert
        expect(result, isFalse);
      });
    });

    group('State Management', () {
      test('should load and save state correctly', () async {
        // Arrange
        final originalState = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.active,
          config: const CheckInConfig(
            interval: Duration(days: 60),
            maxMissedCheckIns: 3,
          ),
          lastCheckIn: DateTime.now(),
        );
        
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(originalState.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        final loadedState = await dmsService._loadState();

        // Assert
        expect(loadedState.status, equals(originalState.status));
        expect(loadedState.config.interval, equals(originalState.config.interval));
        expect(loadedState.lastCheckIn, equals(originalState.lastCheckIn));
      });

      test('should handle missing state gracefully', () async {
        // Arrange
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => null);

        // Act
        final state = await dmsService._loadState();

        // Assert
        expect(state.status, equals(DeadMansSwitchStatus.inactive));
        expect(state.config, equals(const CheckInConfig()));
      });

      test('should handle corrupted state gracefully', () async {
        // Arrange
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => 'invalid json');

        // Act
        final state = await dmsService._loadState();

        // Assert
        expect(state.status, equals(DeadMansSwitchStatus.inactive));
      });
    });

    group('Channel Check-ins', () {
      test('should perform in-app check-in successfully', () async {
        // Act
        final result = await dmsService._performInAppCheckIn();

        // Assert
        expect(result, isTrue);
      });

      test('should handle email check-in failure', () async {
        // Arrange
        dmsService.initialize(emailServiceEndpoint: 'https://api.test.com');
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await dmsService._performEmailCheckIn();

        // Assert
        expect(result, isFalse);
      });

      test('should handle SMS check-in failure', () async {
        // Arrange
        dmsService.initialize(smsServiceEndpoint: 'https://api.test.com');
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await dmsService._performSmsCheckIn();

        // Assert
        expect(result, isFalse);
      });

      test('should handle push check-in failure', () async {
        // Arrange
        dmsService.initialize(pushServiceEndpoint: 'https://api.test.com');
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await dmsService._performPushCheckIn();

        // Assert
        expect(result, isFalse);
      });
    });

    group('Notification System', () {
      test('should send notifications to all channels', () async {
        // Arrange
        final heir = HeirConfig(
          id: 'heir1',
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+1234567890',
          deviceTokens: ['token1', 'token2'],
        );
        
        dmsService.initialize(
          emailServiceEndpoint: 'https://api.test.com',
          smsServiceEndpoint: 'https://api.test.com',
          pushServiceEndpoint: 'https://api.test.com',
        );
        
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => jsonEncode(EnhancedDeadMansSwitchState().toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('{"status": "ok"}', 200)));

        // Act
        await dmsService._sendNotificationToHeir(heir, 'test_notification', {'message': 'test'});

        // Assert
        verify(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')), called(3));
      });

      test('should handle notification failures gracefully', () async {
        // Arrange
        final heir = HeirConfig(
          id: 'heir1',
          name: 'John Doe',
          email: 'john@example.com',
        );
        
        dmsService.initialize(emailServiceEndpoint: 'https://api.test.com');
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => jsonEncode(EnhancedDeadMansSwitchState().toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenThrow(Exception('Network error'));

        // Act
        await dmsService._sendNotificationToHeir(heir, 'test_notification', {'message': 'test'});

        // Assert
        verify(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')), called(1));
      });
    });

    group('Emergency Protocol', () {
      test('should execute emergency protocol when triggered', () async {
        // Arrange
        final state = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.triggered,
          heirs: [
            HeirConfig(
              id: 'heir1',
              name: 'John Doe',
              email: 'john@example.com',
            ),
          ],
          heirConfirmations: {'heir1': 'token1'},
        );
        
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => jsonEncode(state.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        await dmsService._executeEmergencyProtocol(state);

        // Assert
        verify(mockLoggingService.logDeadMansSwitchEvent(
          userId: anyNamed('userId'),
          action: 'access_granted_to_heir',
          metadata: anyNamed('metadata'),
        )).called(1);
      });

      test('should grant access to confirmed heirs', () async {
        // Arrange
        final heir = HeirConfig(
          id: 'heir1',
          name: 'John Doe',
          email: 'john@example.com',
        );

        // Act
        await dmsService._grantAccessToHeir(heir);

        // Assert
        verify(mockLoggingService.logDeadMansSwitchEvent(
          userId: anyNamed('userId'),
          action: 'access_granted_to_heir',
          metadata: anyNamed('metadata'),
        )).called(1);
      });
    });

    group('Heartbeat and Monitoring', () {
      test('should start heartbeat timer', () async {
        // Act
        dmsService._startHeartbeat();

        // Assert
        expect(dmsService._heartbeatTimer, isNotNull);
        expect(dmsService._heartbeatTimer!.isActive, isTrue);
      });

      test('should start monitoring timer', () async {
        // Act
        dmsService._startMonitoring();

        // Assert
        expect(dmsService._monitorTimer, isNotNull);
        expect(dmsService._monitorTimer!.isActive, isTrue);
      });

      test('should dispose timers', () {
        // Act
        dmsService.dispose();

        // Assert
        expect(dmsService._heartbeatTimer, isNull);
        expect(dmsService._monitorTimer, isNull);
        expect(dmsService._gracePeriodTimer, isNull);
      });
    });

    group('Edge Cases', () {
      test('should handle empty heir list', () async {
        // Arrange
        final config = const CheckInConfig();
        final heirs = <HeirConfig>[];

        // Act & Assert
        expect(
          () => dmsService._validateConfig(config, heirs),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should handle unknown heir ID', () async {
        // Arrange
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(EnhancedDeadMansSwitchState().toJson()));

        // Act
        final result = await dmsService.confirmHeirAccess(
          heirId: 'unknown_heir',
          token: 'valid_token',
        );

        // Assert
        expect(result, isFalse);
      });

      test('should handle very long token', () async {
        // Arrange
        final state = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.grace_period_active,
          heirs: [
            HeirConfig(
              id: 'heir1',
              name: 'John Doe',
              email: 'john@example.com',
            ),
          ],
        );
        
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(state.toJson()));

        // Act
        final result = await dmsService.confirmHeirAccess(
          heirId: 'heir1',
          token: 'a' * 1000, // Very long token
        );

        // Assert
        expect(result, isTrue); // Should accept long tokens
      });

      test('should handle null access request', () async {
        // Arrange
        final state = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.grace_period_active,
          heirs: [
            HeirConfig(
              id: 'heir1',
              name: 'John Doe',
              email: 'john@example.com',
              canReceiveAll: false,
              allowedFolders: ['financial'],
            ),
          ],
        );
        
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(state.toJson()));

        // Act
        final result = await dmsService.confirmHeirAccess(
          heirId: 'heir1',
          token: 'valid_token',
          accessRequest: null,
        );

        // Assert
        expect(result, isTrue); // Should allow full access when no request specified
      });
    });

    group('Error Handling', () {
      test('should handle storage errors during activation', () async {
        // Arrange
        final config = const CheckInConfig();
        final heirs = [
          HeirConfig(
            id: 'heir1',
            name: 'John Doe',
            email: 'john@example.com',
          ),
        ];
        
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenThrow(Exception('Storage error'));
        when(mockSecurityService.isValidEmail(anyNamed('email')))
            .thenReturn(true);

        // Act & Assert
        expect(() async => await dmsService.activate(config: config, heirs: heirs),
               throwsA(isA<Exception>()));
      });

      test('should handle network errors during check-in', () async {
        // Arrange
        final state = EnhancedDeadMansSwitchState(
          status: DeadMansSwitchStatus.active,
          config: const CheckInConfig(channels: [CheckInChannel.email]),
        );
        
        dmsService.initialize(emailServiceEndpoint: 'https://api.test.com');
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => jsonEncode(state.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenThrow(Exception('Network error'));

        // Act
        final results = await dmsService.performCheckIn();

        // Assert
        expect(results[CheckInChannel.email], isFalse);
        expect(results[CheckInChannel.in_app], isTrue);
      });

      test('should handle malformed state data', () async {
        // Arrange
        when(mockStorage.read(key: 'enhanced_dead_mans_switch_state_v3'))
            .thenAnswer((_) async => '{invalid json}');

        // Act
        final state = await dmsService._loadState();

        // Assert
        expect(state.status, equals(DeadMansSwitchStatus.inactive));
      });
    });
  });
}
