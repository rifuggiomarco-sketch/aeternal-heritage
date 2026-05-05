// Unit Tests for ConditionalInheritanceService v3.0
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../lib/core/services/conditional_inheritance_service.dart';
import '../../lib/core/services/security_service.dart';
import '../../lib/core/services/advanced_security_logging_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockSecurityService extends Mock implements SecurityService {}
class MockAdvancedSecurityLoggingService extends Mock implements AdvancedSecurityLoggingService {}

void main() {
  group('ConditionalInheritanceService Tests', () {
    late ConditionalInheritanceService inheritanceService;
    late MockFlutterSecureStorage mockStorage;
    late MockSharedPreferences mockPrefs;
    late MockSecurityService mockSecurityService;
    late MockAdvancedSecurityLoggingService mockLoggingService;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      mockPrefs = MockSharedPreferences();
      mockSecurityService = MockSecurityService();
      mockLoggingService = MockAdvancedSecurityLoggingService();

      inheritanceService = ConditionalInheritanceService();
    });

    group('Rule Creation', () {
      test('should create inheritance rule successfully', () async {
        // Arrange
        when(mockPrefs.getStringList(anyNamed('key')))
            .thenAnswer((_) async => []);
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('Test Rule');

        // Act
        final rule = await inheritanceService.createRule(
          name: 'Test Rule',
          description: 'Test description',
          conditionType: ConditionType.time_based,
          conditionData: {
            'startTime': DateTime.now().toIso8601String(),
            'endTime': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
          },
          allowedHeirs: ['heir1', 'heir2'],
          allowedFolders: ['financial', 'legal'],
          allowedDocumentTypes: ['pdf', 'doc'],
          accessLevel: AccessLevel.read_only,
        );

        // Assert
        expect(rule.name, equals('Test Rule'));
        expect(rule.description, equals('Test description'));
        expect(rule.conditionType, equals(ConditionType.time_based));
        expect(rule.allowedHeirs, contains('heir1'));
        expect(rule.allowedHeirs, contains('heir2'));
        expect(rule.accessLevel, equals(AccessLevel.read_only));
        verify(mockPrefs.setStringList('inheritance_rules_v3', any)).called(1);
      });

      test('should validate rule inputs correctly', () async {
        // Arrange
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('Test Rule');

        // Act & Assert
        expect(() async => await inheritanceService.createRule(
          name: '',
          description: 'Test description',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
        ), throwsA(isA<ArgumentError>()));

        expect(() async => await inheritanceService.createRule(
          name: 'Test Rule',
          description: '',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
        ), throwsA(isA<ArgumentError>()));

        expect(() async => await inheritanceService.createRule(
          name: 'Test Rule',
          description: 'Test description',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: [],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
        ), throwsA(isA<ArgumentError>()));
      });

      test('should validate time-based condition data', () async {
        // Arrange
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('Test Rule');

        // Act & Assert
        expect(() async => await inheritanceService.createRule(
          name: 'Test Rule',
          description: 'Test description',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'}, // Missing endTime
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
        ), throwsA(isA<ArgumentError>()));

        expect(() async => await inheritanceService.createRule(
          name: 'Test Rule',
          description: 'Test description',
          conditionType: ConditionType.time_based,
          conditionData: {'endTime': '2024-01-01T01:00:00Z'}, // Missing startTime
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
        ), throwsA(isA<ArgumentError>()));
      });

      test('should validate event-based condition data', () async {
        // Arrange
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('Test Rule');

        // Act & Assert
        expect(() async => await inheritanceService.createRule(
          name: 'Test Rule',
          description: 'Test description',
          conditionType: ConditionType.event_based,
          conditionData: {}, // Missing eventType
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
        ), throwsA(isA<ArgumentError>()));
      });

      test('should validate date range', () async {
        // Arrange
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('Test Rule');

        // Act & Assert
        expect(() async => await inheritanceService.createRule(
          name: 'Test Rule',
          description: 'Test description',
          conditionType: ConditionType.time_based,
          conditionData: {
            'startTime': DateTime.now().add(Duration(days: 1)).toIso8601String(),
            'endTime': DateTime.now().subtract(Duration(days: 1)).toIso8601String(),
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
        ), throwsA(isA<ArgumentError>()));
      });

      test('should log rule creation event', () async {
        // Arrange
        when(mockPrefs.getStringList(anyNamed('key')))
            .thenAnswer((_) async => []);
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('Test Rule');

        // Act
        await inheritanceService.createRule(
          name: 'Test Rule',
          description: 'Test description',
          conditionType: ConditionType.time_based,
          conditionData: {
            'startTime': DateTime.now().toIso8601String(),
            'endTime': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
        );

        // Assert
        verify(mockLoggingService.logBusinessEvent(
          userId: 'current_user',
          event: 'inheritance_rule_created',
          businessData: anyNamed('businessData'),
        )).called(1);
      });
    });

    group('Access Evaluation', () {
      test('should evaluate access with no applicable rules', () async {
        // Arrange
        when(mockPrefs.getStringList('inheritance_rules_v3'))
            .thenAnswer((_) async => []);

        // Act
        final result = await inheritanceService.evaluateAccess(
          heirId: 'heir1',
        );

        // Assert
        expect(result.granted, isFalse);
        expect(result.accessLevel, equals(AccessLevel.none));
        expect(result.reason, contains('No applicable inheritance rules found'));
      });

      test('should evaluate access with applicable rules', () async {
        // Arrange
        final rule = InheritanceRule(
          id: 'rule1',
          name: 'Test Rule',
          description: 'Test description',
          conditionType: ConditionType.time_based,
          conditionData: {
            'startTime': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
            'endTime': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
          },
          allowedHeirs: ['heir1', 'heir2'],
          allowedFolders: ['financial', 'legal'],
          allowedDocumentTypes: ['pdf', 'doc'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        );
        
        when(mockPrefs.getStringList('inheritance_rules_v3'))
            .thenAnswer((_) async => [jsonEncode(rule.toJson())]);

        // Act
        final result = await inheritanceService.evaluateAccess(
          heirId: 'heir1',
        );

        // Assert
        expect(result.granted, isTrue);
        expect(result.accessLevel, equals(AccessLevel.read_only));
        expect(result.allowedFolders, contains('financial'));
        expect(result.allowedFolders, contains('legal'));
        expect(result.allowedDocumentTypes, contains('pdf'));
        expect(result.appliedRules.length, equals(1));
      });

      test('should evaluate access with multiple rules and highest access level', () async {
        // Arrange
        final rule1 = InheritanceRule(
          id: 'rule1',
          name: 'Read Only Rule',
          description: 'Read only access',
          conditionType: ConditionType.time_based,
          conditionData: {
            'startTime': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
            'endTime': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          priority: 1,
          createdAt: DateTime.now(),
        );

        final rule2 = InheritanceRule(
          id: 'rule2',
          name: 'Read Write Rule',
          description: 'Read write access',
          conditionType: ConditionType.time_based,
          conditionData: {
            'startTime': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
            'endTime': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['legal'],
          allowedDocumentTypes: ['doc'],
          accessLevel: AccessLevel.read_write,
          priority: 2,
          createdAt: DateTime.now(),
        );
        
        when(mockPrefs.getStringList('inheritance_rules_v3'))
            .thenAnswer((_) async => [
              jsonEncode(rule1.toJson()),
              jsonEncode(rule2.toJson()),
            ]);

        // Act
        final result = await inheritanceService.evaluateAccess(
          heirId: 'heir1',
        );

        // Assert
        expect(result.granted, isTrue);
        expect(result.accessLevel, equals(AccessLevel.read_write)); // Highest access level
        expect(result.allowedFolders, contains('financial'));
        expect(result.allowedFolders, contains('legal'));
        expect(result.appliedRules.length, equals(2));
      });

      test('should respect rule priority ordering', () async {
        // Arrange
        final lowPriorityRule = InheritanceRule(
          id: 'rule1',
          name: 'Low Priority Rule',
          description: 'Low priority',
          conditionType: ConditionType.time_based,
          conditionData: {
            'startTime': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
            'endTime': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          priority: 1,
          createdAt: DateTime.now(),
        );

        final highPriorityRule = InheritanceRule(
          id: 'rule2',
          name: 'High Priority Rule',
          description: 'High priority',
          conditionType: ConditionType.time_based,
          conditionData: {
            'startTime': DateTime.now().subtract(Duration(hours: 1)).toIso8601String(),
            'endTime': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['legal'],
          allowedDocumentTypes: ['doc'],
          accessLevel: AccessLevel.full_access,
          priority: 10,
          createdAt: DateTime.now(),
        );
        
        when(mockPrefs.getStringList('inheritance_rules_v3'))
            .thenAnswer((_) async => [
              jsonEncode(lowPriorityRule.toJson()),
              jsonEncode(highPriorityRule.toJson()),
            ]);

        // Act
        final result = await inheritanceService.evaluateAccess(
          heirId: 'heir1',
        );

        // Assert
        expect(result.granted, isTrue);
        expect(result.accessLevel, equals(AccessLevel.full_access));
        expect(result.appliedRules.first.priority, equals(10)); // High priority rule first
      });
    });

    group('Condition Evaluation', () {
      test('should evaluate time-based condition correctly', () async {
        // Arrange
        final now = DateTime.now();
        final rule = InheritanceRule(
          id: 'rule1',
          name: 'Time Rule',
          description: 'Time-based rule',
          conditionType: ConditionType.time_based,
          conditionData: {
            'startTime': now.subtract(Duration(hours: 1)).toIso8601String(),
            'endTime': now.add(Duration(hours: 1)).toIso8601String(),
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        );

        // Act
        final result = await inheritanceService._evaluateCondition(rule, null);

        // Assert
        expect(result, isTrue);
      });

      test('should reject time-based condition outside time range', () async {
        // Arrange
        final now = DateTime.now();
        final rule = InheritanceRule(
          id: 'rule1',
          name: 'Time Rule',
          description: 'Time-based rule',
          conditionType: ConditionType.time_based,
          conditionData: {
            'startTime': now.add(Duration(hours: 1)).toIso8601String(),
            'endTime': now.add(Duration(hours: 2)).toIso8601String(),
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        );

        // Act
        final result = await inheritanceService._evaluateCondition(rule, null);

        // Assert
        expect(result, isFalse);
      });

      test('should evaluate event-based condition correctly', () async {
        // Arrange
        final rule = InheritanceRule(
          id: 'rule1',
          name: 'Event Rule',
          description: 'Event-based rule',
          conditionType: ConditionType.event_based,
          conditionData: {
            'eventType': 'user_deceased',
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        );

        final context = {
          'events': [
            {'type': 'user_deceased', 'timestamp': DateTime.now().toIso8601String()},
            {'type': 'other_event', 'timestamp': DateTime.now().toIso8601String()},
          ],
        };

        // Act
        final result = await inheritanceService._evaluateCondition(rule, context);

        // Assert
        expect(result, isTrue);
      });

      test('should reject event-based condition when event not present', () async {
        // Arrange
        final rule = InheritanceRule(
          id: 'rule1',
          name: 'Event Rule',
          description: 'Event-based rule',
          conditionType: ConditionType.event_based,
          conditionData: {
            'eventType': 'user_deceased',
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        );

        final context = {
          'events': [
            {'type': 'other_event', 'timestamp': DateTime.now().toIso8601String()},
          ],
        };

        // Act
        final result = await inheritanceService._evaluateCondition(rule, context);

        // Assert
        expect(result, isFalse);
      });

      test('should evaluate location-based condition correctly', () async {
        // Arrange
        final rule = InheritanceRule(
          id: 'rule1',
          name: 'Location Rule',
          description: 'Location-based rule',
          conditionType: ConditionType.location_based,
          conditionData: {
            'allowedLocations': ['US', 'CA', 'UK'],
            'currentLocation': 'US',
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        );

        // Act
        final result = await inheritanceService._evaluateCondition(rule, null);

        // Assert
        expect(result, isTrue);
      });

      test('should reject location-based condition for invalid location', () async {
        // Arrange
        final rule = InheritanceRule(
          id: 'rule1',
          name: 'Location Rule',
          description: 'Location-based rule',
          conditionType: ConditionType.location_based,
          conditionData: {
            'allowedLocations': ['US', 'CA', 'UK'],
            'currentLocation': 'FR',
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        );

        // Act
        final result = await inheritanceService._evaluateCondition(rule, null);

        // Assert
        expect(result, isFalse);
      });

      test('should evaluate approval-based condition correctly', () async {
        // Arrange
        final rule = InheritanceRule(
          id: 'rule1',
          name: 'Approval Rule',
          description: 'Approval-based rule',
          conditionType: ConditionType.approval_based,
          conditionData: {
            'requiredApprovers': ['approver1', 'approver2'],
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        );

        final context = {
          'approvals': [
            {'approver': 'approver1', 'timestamp': DateTime.now().toIso8601String()},
            {'approver': 'approver2', 'timestamp': DateTime.now().toIso8601String()},
            {'approver': 'approver3', 'timestamp': DateTime.now().toIso8601String()},
          ],
        };

        // Act
        final result = await inheritanceService._evaluateCondition(rule, context);

        // Assert
        expect(result, isTrue);
      });

      test('should reject approval-based condition when not all approvers approved', () async {
        // Arrange
        final rule = InheritanceRule(
          id: 'rule1',
          name: 'Approval Rule',
          description: 'Approval-based rule',
          conditionType: ConditionType.approval_based,
          conditionData: {
            'requiredApprovers': ['approver1', 'approver2', 'approver3'],
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        );

        final context = {
          'approvals': [
            {'approver': 'approver1', 'timestamp': DateTime.now().toIso8601String()},
            {'approver': 'approver2', 'timestamp': DateTime.now().toIso8601String()},
          ],
        };

        // Act
        final result = await inheritanceService._evaluateCondition(rule, context);

        // Assert
        expect(result, isFalse);
      });

      test('should evaluate custom condition', () async {
        // Arrange
        final rule = InheritanceRule(
          id: 'rule1',
          name: 'Custom Rule',
          description: 'Custom condition rule',
          conditionType: ConditionType.custom,
          conditionData: {
            'customCondition': 'always_true',
          },
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        );

        // Act
        final result = await inheritanceService._evaluateCondition(rule, null);

        // Assert
        expect(result, isTrue); // Custom condition returns true as placeholder
      });
    });

    group('Request Management', () {
      test('should submit inheritance request successfully', () async {
        // Arrange
        when(mockPrefs.getStringList('inheritance_requests_v3'))
            .thenAnswer((_) async => []);
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async => true);

        // Act
        final request = await inheritanceService.submitRequest(
          heirId: 'heir1',
          ruleIds: ['rule1', 'rule2'],
          requestData: {'requestedFolders': ['financial', 'legal']},
        );

        // Assert
        expect(request.heirId, equals('heir1'));
        expect(request.ruleIds, contains('rule1'));
        expect(request.ruleIds, contains('rule2'));
        expect(request.status, equals(InheritanceStatus.pending));
        verify(mockPrefs.setStringList('inheritance_requests_v3', any)).called(1);
      });

      test('should approve inheritance request successfully', () async {
        // Arrange
        final request = InheritanceRequest(
          id: 'req1',
          heirId: 'heir1',
          ruleIds: ['rule1'],
          requestData: {'requestedFolders': ['financial']},
          status: InheritanceStatus.pending,
          requestedAt: DateTime.now(),
        );
        
        when(mockPrefs.getStringList('inheritance_requests_v3'))
            .thenAnswer((_) async => [jsonEncode(request.toJson())]);
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async = true);

        // Act
        final result = await inheritanceService.approveRequest(
          requestId: 'req1',
          reviewedBy: 'admin1',
        );

        // Assert
        expect(result, isTrue);
        final captured = verify(mockPrefs.setStringList('inheritance_requests_v3', captureAny)).captured;
        final updatedRequests = captured.first as List<String>;
        final updatedRequest = InheritanceRequest.fromJson(jsonDecode(updatedRequests.first));
        expect(updatedRequest.status, equals(InheritanceStatus.approved));
        expect(updatedRequest.reviewedBy, equals('admin1'));
      });

      test('should reject inheritance request successfully', () async {
        // Arrange
        final request = InheritanceRequest(
          id: 'req1',
          heirId: 'heir1',
          ruleIds: ['rule1'],
          requestData: {'requestedFolders': ['financial']},
          status: InheritanceStatus.pending,
          requestedAt: DateTime.now(),
        );
        
        when(mockPrefs.getStringList('inheritance_requests_v3'))
            .thenAnswer((_) async => [jsonEncode(request.toJson())]);
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async = true);

        // Act
        final result = await inheritanceService.rejectRequest(
          requestId: 'req1',
          reviewedBy: 'admin1',
          reason: 'Insufficient documentation',
        );

        // Assert
        expect(result, isTrue);
        final captured = verify(mockPrefs.setStringList('inheritance_requests_v3', captureAny)).captured;
        final updatedRequests = captured.first as List<String>;
        final updatedRequest = InheritanceRequest.fromJson(jsonDecode(updatedRequests.first));
        expect(updatedRequest.status, equals(InheritanceStatus.rejected));
        expect(updatedRequest.rejectionReason, equals('Insufficient documentation'));
      });

      test('should handle approval of non-existent request', () async {
        // Arrange
        when(mockPrefs.getStringList('inheritance_requests_v3'))
            .thenAnswer((_) async => []);

        // Act
        final result = await inheritanceService.approveRequest(
          requestId: 'non_existent',
          reviewedBy: 'admin1',
        );

        // Assert
        expect(result, isFalse);
      });

      test('should handle approval of non-pending request', () async {
        // Arrange
        final request = InheritanceRequest(
          id: 'req1',
          heirId: 'heir1',
          ruleIds: ['rule1'],
          requestData: {'requestedFolders': ['financial']},
          status: InheritanceStatus.approved,
          requestedAt: DateTime.now(),
        );
        
        when(mockPrefs.getStringList('inheritance_requests_v3'))
            .thenAnswer((_) async => [jsonEncode(request.toJson())]);

        // Act
        final result = await inheritanceService.approveRequest(
          requestId: 'req1',
          reviewedBy: 'admin1',
        );

        // Assert
        expect(result, isFalse);
      });
    });

    group('Rule Management', () {
      test('should update inheritance rule successfully', () async {
        // Arrange
        final rule = InheritanceRule(
          id: 'rule1',
          name: 'Original Rule',
          description: 'Original description',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        );
        
        when(mockPrefs.getStringList('inheritance_rules_v3'))
            .thenAnswer((_) async => [jsonEncode(rule.toJson())]);
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async = true);

        final updatedRule = rule.copyWith(
          name: 'Updated Rule',
          description: 'Updated description',
        );

        // Act
        final result = await inheritanceService.updateRule(updatedRule);

        // Assert
        expect(result, isTrue);
        verify(mockLoggingService.logBusinessEvent(
          userId: 'current_user',
          event: 'inheritance_rule_updated',
          businessData: anyNamed('businessData'),
        )).called(1);
      });

      test('should delete inheritance rule successfully', () async {
        // Arrange
        final rule = InheritanceRule(
          id: 'rule1',
          name: 'Test Rule',
          description: 'Test description',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        );
        
        when(mockPrefs.getStringList('inheritance_rules_v3'))
            .thenAnswer((_) async => [jsonEncode(rule.toJson())]);
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async = true);

        // Act
        final result = await inheritanceService.deleteRule('rule1');

        // Assert
        expect(result, isTrue);
        verify(mockLoggingService.logBusinessEvent(
          userId: 'current_user',
          event: 'inheritance_rule_deleted',
          businessData: anyNamed('businessData'),
        )).called(1);
      });

      test('should get all inheritance rules', () async {
        // Arrange
        final rule1 = InheritanceRule(
          id: 'rule1',
          name: 'Rule 1',
          description: 'Description 1',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
          isActive: true,
        );

        final rule2 = InheritanceRule(
          id: 'rule2',
          name: 'Rule 2',
          description: 'Description 2',
          conditionType: ConditionType.event_based,
          conditionData: {'eventType': 'user_deceased'},
          allowedHeirs: ['heir2'],
          allowedFolders: ['legal'],
          allowedDocumentTypes: ['doc'],
          accessLevel: AccessLevel.read_write,
          createdAt: DateTime.now(),
          isActive: false,
        );
        
        when(mockPrefs.getStringList('inheritance_rules_v3'))
            .thenAnswer((_) async => [
              jsonEncode(rule1.toJson()),
              jsonEncode(rule2.toJson()),
            ]);

        // Act
        final rules = await inheritanceService.getRules();

        // Assert
        expect(rules.length, equals(1)); // Only active rules by default
        expect(rules.first.id, equals('rule1'));
        expect(rules.first.isActive, isTrue);
      });

      test('should get all inheritance rules including inactive', () async {
        // Arrange
        final rule1 = InheritanceRule(
          id: 'rule1',
          name: 'Rule 1',
          description: 'Description 1',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
          isActive: true,
        );

        final rule2 = InheritanceRule(
          id: 'rule2',
          name: 'Rule 2',
          description: 'Description 2',
          conditionType: ConditionType.event_based,
          conditionData: {'eventType': 'user_deceased'},
          allowedHeirs: ['heir2'],
          allowedFolders: ['legal'],
          allowedDocumentTypes: ['doc'],
          accessLevel: AccessLevel.read_write,
          createdAt: DateTime.now(),
          isActive: false,
        );
        
        when(mockPrefs.getStringList('inheritance_rules_v3'))
            .thenAnswer((_) async => [
              jsonEncode(rule1.toJson()),
              jsonEncode(rule2.toJson()),
            ]);

        // Act
        final rules = await inheritanceService.getRules(includeInactive: true);

        // Assert
        expect(rules.length, equals(2)); // Both active and inactive
        expect(rules.where((r) => r.id == 'rule1').first.isActive, isTrue);
        expect(rules.where((r) => r.id == 'rule2').first.isActive, isFalse);
      });
    });

    group('Statistics', () {
      test('should calculate inheritance statistics correctly', () async {
        // Arrange
        final rule1 = InheritanceRule(
          id: 'rule1',
          name: 'Rule 1',
          description: 'Description 1',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
          isActive: true,
        );

        final rule2 = InheritanceRule(
          id: 'rule2',
          name: 'Rule 2',
          description: 'Description 2',
          conditionType: ConditionType.event_based,
          conditionData: {'eventType': 'user_deceased'},
          allowedHeirs: ['heir2'],
          allowedFolders: ['legal'],
          allowedDocumentTypes: ['doc'],
          accessLevel: AccessLevel.read_write,
          createdAt: DateTime.now(),
          isActive: false,
        );

        final request1 = InheritanceRequest(
          id: 'req1',
          heirId: 'heir1',
          ruleIds: ['rule1'],
          requestData: {'requestedFolders': ['financial']},
          status: InheritanceStatus.pending,
          requestedAt: DateTime.now(),
        );

        final request2 = InheritanceRequest(
          id: 'req2',
          heirId: 'heir2',
          ruleIds: ['rule2'],
          requestData: {'requestedFolders': ['legal']},
          status: InheritanceStatus.approved,
          requestedAt: DateTime.now(),
        );

        final request3 = InheritanceRequest(
          id: 'req3',
          heirId: 'heir3',
          ruleIds: ['rule1'],
          requestData: {'requestedFolders': ['medical']},
          status: InheritanceStatus.rejected,
          requestedAt: DateTime.now(),
        );
        
        when(mockPrefs.getStringList('inheritance_rules_v3'))
            .thenAnswer((_) async => [
              jsonEncode(rule1.toJson()),
              jsonEncode(rule2.toJson()),
            ]);
        when(mockPrefs.getStringList('inheritance_requests_v3'))
            .thenAnswer((_) async => [
              jsonEncode(request1.toJson()),
              jsonEncode(request2.toJson()),
              jsonEncode(request3.toJson()),
            ]);

        // Act
        final stats = await inheritanceService.getStatistics();

        // Assert
        expect(stats['totalRules'], equals(2));
        expect(stats['activeRules'], equals(1));
        expect(stats['totalRequests'], equals(3));
        expect(stats['pendingRequests'], equals(1));
        expect(stats['approvedRequests'], equals(1));
        expect(stats['rejectedRequests'], equals(1));
        expect(stats['rulesByType']['time_based'], equals(1));
        expect(stats['rulesByType']['event_based'], equals(1));
        expect(stats['rulesByAccessLevel']['read_only'], equals(1));
        expect(stats['rulesByAccessLevel']['read_write'], equals(1));
        expect(stats['approvalRate'], equals(33.33333333333333)); // 1/3 * 100
      });
    });

    group('Rule Applicability', () {
      test('should check rule applicability correctly', () async {
        // Arrange
        final now = DateTime.now();
        final applicableRule = InheritanceRule(
          id: 'rule1',
          name: 'Applicable Rule',
          description: 'Applicable rule',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          startDate: now.subtract(Duration(days: 1)),
          endDate: now.add(Duration(days: 1)),
          createdAt: DateTime.now(),
        );

        final notStartedRule = InheritanceRule(
          id: 'rule2',
          name: 'Not Started Rule',
          description: 'Not started rule',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          startDate: now.add(Duration(days: 1)),
          endDate: now.add(Duration(days: 2)),
          createdAt: DateTime.now(),
        );

        final expiredRule = InheritanceRule(
          id: 'rule3',
          name: 'Expired Rule',
          description: 'Expired rule',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          startDate: now.subtract(Duration(days: 2)),
          endDate: now.subtract(Duration(days: 1)),
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(inheritanceService._isRuleApplicable(applicableRule, null), isTrue);
        expect(inheritanceService._isRuleApplicable(notStartedRule, null), isFalse);
        expect(inheritanceService._isRuleApplicable(expiredRule, null), isFalse);
      });

      test('should handle rules without date constraints', () async {
        // Arrange
        final rule = InheritanceRule(
          id: 'rule1',
          name: 'No Date Rule',
          description: 'Rule without date constraints',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(inheritanceService._isRuleApplicable(rule, null), isTrue);
      });
    });

    group('Error Handling', () {
      test('should handle storage errors during rule creation', () async {
        // Arrange
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenThrow(Exception('Storage error'));
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('Test Rule');

        // Act & Assert
        expect(() async => await inheritanceService.createRule(
          name: 'Test Rule',
          description: 'Test description',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
        ), throwsA(isA<Exception>()));
      });

      test('should handle malformed rule data', () async {
        // Arrange
        when(mockPrefs.getStringList('inheritance_rules_v3'))
            .thenAnswer((_) async => ['invalid json']);

        // Act
        final rules = await inheritanceService.getRules();

        // Assert
        expect(rules, isEmpty);
      });

      test('should handle malformed request data', () async {
        // Arrange
        when(mockPrefs.getStringList('inheritance_requests_v3'))
            .thenAnswer((_) async => ['invalid json']);

        // Act
        final requests = await inheritanceService.getRequests();

        // Assert
        expect(requests, isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle empty rule list during access evaluation', () async {
        // Arrange
        when(mockPrefs.getStringList('inheritance_rules_v3'))
            .thenAnswer((_) async => []);

        // Act
        final result = await inheritanceService.evaluateAccess(
          heirId: 'heir1',
        );

        // Assert
        expect(result.granted, isFalse);
        expect(result.accessLevel, equals(AccessLevel.none));
      });

      test('should handle heir not in any rule', () async {
        // Arrange
        final rule = InheritanceRule(
          id: 'rule1',
          name: 'Test Rule',
          description: 'Test description',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir2', 'heir3'], // Different heir
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        );
        
        when(mockPrefs.getStringList('inheritance_rules_v3'))
            .thenAnswer((_) async => [jsonEncode(rule.toJson())]);

        // Act
        final result = await inheritanceService.evaluateAccess(
          heirId: 'heir1',
        );

        // Assert
        expect(result.granted, isFalse);
      });

      test('should handle very long rule name', () async {
        // Arrange
        final longName = 'a' * 1000;
        when(mockPrefs.getStringList(anyNamed('key')))
            .thenAnswer((_) async => []);
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async = true);
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('sanitized_name');

        // Act
        final rule = await inheritanceService.createRule(
          name: longName,
          description: 'Test description',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
        );

        // Assert
        expect(rule.name, equals('sanitized_name'));
        verify(mockSecurityService.sanitizeInput(longName)).called(1);
      });

      test('should handle maximum rule limit', () async {
        // Arrange
        final existingRules = List.generate(100, (i) => InheritanceRule(
          id: 'rule$i',
          name: 'Rule $i',
          description: 'Description $i',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
          createdAt: DateTime.now(),
        ));
        
        when(mockPrefs.getStringList('inheritance_rules_v3'))
            .thenAnswer((_) async => existingRules.map((r) => jsonEncode(r.toJson())).toList());
        when(mockPrefs.setStringList(anyNamed('key'), anyNamed('value')))
            .thenAnswer((_) async = true);
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('New Rule');

        // Act
        await inheritanceService.createRule(
          name: 'New Rule',
          description: 'New description',
          conditionType: ConditionType.time_based,
          conditionData: {'startTime': '2024-01-01T00:00:00Z'},
          allowedHeirs: ['heir1'],
          allowedFolders: ['financial'],
          allowedDocumentTypes: ['pdf'],
          accessLevel: AccessLevel.read_only,
        );

        // Assert
        verify(mockPrefs.setStringList('inheritance_rules_v3', any)).called(1);
        // Should maintain size limit
        final captured = verify(mockPrefs.setStringList('inheritance_rules_v3', captureAny)).captured;
        final rulesList = captured.first as List<String>;
        expect(rulesList.length, lessThanOrEqualTo(100));
      });
    });
  });
}
