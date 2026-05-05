// Test Configuration for Digital Vault Heritage v3.0
// Centralized test configuration and utilities
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([
  // Core Services
  FlutterSecureStorage,
  SharedPreferences,
  http.Client,
  
  // App Services
  SecurityService,
  AdvancedSecurityLoggingService,
  EnhancedDeadMansSwitchService,
  EnhancedSubscriptionService,
  ConditionalInheritanceService,
  UserReportingService,
  ErrorHandlingService,
  
  // Firebase Services (if needed)
  FirebaseMessaging,
  FirebaseFirestore,
])

// Test Constants
class TestConstants {
  // Test Data
  static const String testUserId = 'test_user_123';
  static const String testEmail = 'test@example.com';
  static const String testPhone = '+1234567890';
  static const String testHeirId = 'heir_123';
  static const String testRuleId = 'rule_123';
  static const String testRequestId = 'request_123';
  static const String testSubscriptionId = 'sub_123';
  static const String testPaymentIntentId = 'pi_123';
  static const String testStripeCustomerId = 'cus_123';
  static const String testStripeSubscriptionId = 'sub_stripe_123';

  // Test Keys and Tokens
  static const String testMasterKey = 'dGVzdF9tYXN0ZXJfa2V5XzEyMw=='; // base64 encoded
  static const String testPin = '1234';
  static const String testRecoveryKey = 'ABCD-EFGH-IJKL-MNOP-QRST-UVWX-YZAB-CD';
  static const String testSessionToken = 'session_token_12345';
  static const String testWebhookSignature = 'webhook_signature_123';

  // Test Dates
  static final DateTime testNow = DateTime(2024, 5, 5, 12, 0, 0);
  static final DateTime testPast = DateTime(2024, 1, 1);
  static final DateTime testFuture = DateTime(2024, 12, 31);
  static final Duration testDuration = Duration(days: 30);

  // Test Limits
  static const int maxLoginAttempts = 5;
  static const int maxPinAttempts = 5;
  static const int maxRecoveryAttempts = 3;
  static const int maxDocumentsFree = 10;
  static const int maxDocumentsPremium = 100;
  static const int maxHeirsFree = 1;
  static const int maxHeirsPremium = 5;
}

// Test Utilities
class TestUtilities {
  static Map<String, dynamic> createTestSubscriptionJson({
    String id = TestConstants.testSubscriptionId,
    String userId = TestConstants.testUserId,
    String tier = 'premium',
    String billingCycle = 'monthly',
    String status = 'succeeded',
    String? stripeCustomerId,
    String? stripeSubscriptionId,
    DateTime? currentPeriodStart,
    DateTime? currentPeriodEnd,
    bool autoRenew = true,
  }) {
    return {
      'id': id,
      'userId': userId,
      'tier': tier,
      'billingCycle': billingCycle,
      'status': status,
      'stripeCustomerId': stripeCustomerId ?? TestConstants.testStripeCustomerId,
      'stripeSubscriptionId': stripeSubscriptionId ?? TestConstants.testStripeSubscriptionId,
      'currentPeriodStart': currentPeriodStart?.toIso8601String() ?? TestConstants.testPast.toIso8601String(),
      'currentPeriodEnd': currentPeriodEnd?.toIso8601String() ?? TestConstants.testFuture.toIso8601String(),
      'autoRenew': autoRenew,
      'createdAt': TestConstants.testPast.toIso8601String(),
      'updatedAt': TestConstants.testNow.toIso8601String(),
      'transitionHistory': ['free_to_premium'],
      'lastPaymentDate': TestConstants.testNow.toIso8601String(),
      'failedPaymentAttempts': 0,
    };
  }

  static Map<String, dynamic> createTestInheritanceRuleJson({
    String id = TestConstants.testRuleId,
    String name = 'Test Rule',
    String description = 'Test description',
    String conditionType = 'time_based',
    Map<String, dynamic>? conditionData,
    List<String>? allowedHeirs,
    List<String>? allowedFolders,
    List<String>? allowedDocumentTypes,
    String accessLevel = 'read_only',
    bool isActive = true,
    int priority = 0,
  }) {
    return {
      'id': id,
      'name': name,
      'description': description,
      'conditionType': conditionType,
      'conditionData': conditionData ?? {
        'startTime': TestConstants.testPast.toIso8601String(),
        'endTime': TestConstants.testFuture.toIso8601String(),
      },
      'allowedHeirs': allowedHeirs ?? [TestConstants.testHeirId],
      'allowedFolders': allowedFolders ?? ['financial', 'legal'],
      'allowedDocumentTypes': allowedDocumentTypes ?? ['pdf', 'doc'],
      'accessLevel': accessLevel,
      'startDate': TestConstants.testPast.toIso8601String(),
      'endDate': TestConstants.testFuture.toIso8601String(),
      'isActive': isActive,
      'priority': priority,
      'createdAt': TestConstants.testPast.toIso8601String(),
      'lastModified': TestConstants.testNow.toIso8601String(),
    };
  }

  static Map<String, dynamic> createTestInheritanceRequestJson({
    String id = TestConstants.testRequestId,
    String heirId = TestConstants.testHeirId,
    List<String>? ruleIds,
    Map<String, dynamic>? requestData,
    String status = 'pending',
    String? rejectionReason,
    String? reviewedBy,
  }) {
    return {
      'id': id,
      'heirId': heirId,
      'ruleIds': ruleIds ?? [TestConstants.testRuleId],
      'requestData': requestData ?? {'requestedFolders': ['financial']},
      'status': status,
      'rejectionReason': rejectionReason,
      'requestedAt': TestConstants.testNow.toIso8601String(),
      'reviewedAt': reviewedBy != null ? TestConstants.testNow.toIso8601String() : null,
      'reviewedBy': reviewedBy,
      'reviewData': reviewedBy != null ? {'approved': true} : null,
    };
  }

  static Map<String, dynamic> createTestDeadMansSwitchStateJson({
    String status = 'active',
    Map<String, dynamic>? config,
    List<Map<String, dynamic>>? heirs,
    List<Map<String, dynamic>>? checkInHistory,
    String? lastCheckIn,
    String? gracePeriodStart,
    String? gracePeriodEnd,
    String? triggeredAt,
    Map<String, String>? heirConfirmations,
  }) {
    return {
      'status': status,
      'config': config ?? {
        'channels': ['email', 'in_app'],
        'interval': 5184000000, // 60 days in milliseconds
        'maxMissedCheckIns': 3,
        'gracePeriod': 172800000, // 48 hours in milliseconds
        'requireMultipleChannels': true,
        'requiredChannelConfirmations': 2,
      },
      'heirs': heirs ?? [
        {
          'id': TestConstants.testHeirId,
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '+1234567890',
          'deviceTokens': ['token1', 'token2'],
          'allowedFolders': ['financial', 'legal'],
          'canReceiveAll': true,
          'lastNotified': TestConstants.testNow.toIso8601String(),
          'lastNotificationChannel': 'email',
        }
      ],
      'checkInHistory': checkInHistory ?? [
        {
          'id': 'check_1',
          'channel': 'in_app',
          'timestamp': TestConstants.testNow.toIso8601String(),
          'success': true,
        }
      ],
      'lastCheckIn': lastCheckIn ?? TestConstants.testNow.toIso8601String(),
      'gracePeriodStart': gracePeriodStart,
      'gracePeriodEnd': gracePeriodEnd,
      'triggeredAt': triggeredAt,
      'heirConfirmations': heirConfirmations ?? {},
      'channelLastUsed': {
        'in_app': TestConstants.testNow.toIso8601String(),
      },
    };
  }

  static Map<String, dynamic> createTestSecurityLogEntryJson({
    String id = 'log_123',
    String level = 'info',
    String category = 'authentication',
    String event = 'test_event',
    String? userId,
    String? ipAddress,
    String? userAgent,
    bool success = true,
    String? errorMessage,
    String? stackTrace,
  }) {
    return {
      'id': id,
      'level': level,
      'category': category,
      'event': event,
      'userId': userId ?? TestConstants.testUserId,
      'timestamp': TestConstants.testNow.toIso8601String(),
      'ipAddress': ipAddress ?? '127.0.0.1',
      'userAgent': userAgent ?? 'Test Agent',
      'success': success,
      'errorMessage': errorMessage,
      'stackTrace': stackTrace,
      'sessionId': 'session_123',
    };
  }
}

// Test Fixtures
abstract class TestFixture {
  void setUp();
  void tearDown();
}

class SecurityServiceTestFixture extends TestFixture {
  late MockFlutterSecureStorage mockStorage;
  late MockSharedPreferences mockPrefs;
  late SecurityService securityService;

  @override
  void setUp() {
    mockStorage = MockFlutterSecureStorage();
    mockPrefs = MockSharedPreferences();
    securityService = SecurityService();
  }

  @override
  void tearDown() {
    // Clean up if needed
  }
}

class SubscriptionServiceTestFixture extends TestFixture {
  late MockFlutterSecureStorage mockStorage;
  late MockSharedPreferences mockPrefs;
  late MockSecurityService mockSecurityService;
  late MockAdvancedSecurityLoggingService mockLoggingService;
  late MockHttpClient mockHttpClient;
  late EnhancedSubscriptionService subscriptionService;

  @override
  void setUp() {
    mockStorage = MockFlutterSecureStorage();
    mockPrefs = MockSharedPreferences();
    mockSecurityService = MockSecurityService();
    mockLoggingService = MockAdvancedSecurityLoggingService();
    mockHttpClient = MockHttpClient();
    subscriptionService = EnhancedSubscriptionService();
  }

  @override
  void tearDown() {
    // Clean up if needed
  }
}

// Custom Matchers
class IsValidEmail extends Matcher {
  @override
  bool matches(Object? item, Map matchState) {
    if (item is! String) return false;
    final email = item as String;
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Description describe(Description description) {
    return description.add('is a valid email address');
  }
}

class IsValidPhoneNumber extends Matcher {
  @override
  bool matches(Object? item, Map matchState) {
    if (item is! String) return false;
    final phone = item as String;
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  @override
  Description describe(Description description) {
    return description.add('is a valid phone number');
  }
}

class IsSecureKey extends Matcher {
  @override
  bool matches(Object? item, Map matchState) {
    if (item is! String) return false;
    final key = item as String;
    
    // Check base64url format
    try {
      final decoded = base64Url.decode(key);
      // Check 256-bit length
      return decoded.length == 32;
    } catch (e) {
      return false;
    }
  }

  @override
  Description describe(Description description) {
    return description.add('is a valid 256-bit secure key');
  }
}

// Custom Test Extensions
extension TestExtensions on WidgetTester {
  Future<void> pumpAndSettleWithTimeout([Duration? duration]) {
    return pumpAndSettle(duration ?? Duration(seconds: 5));
  }
}

// Test Data Builders
class TestDataBuilder {
  static Map<String, dynamic> buildUser({
    String id = TestConstants.testUserId,
    String email = TestConstants.testEmail,
    String? phone,
    DateTime? createdAt,
    bool isActive = true,
  }) {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'createdAt': createdAt?.toIso8601String() ?? TestConstants.testPast.toIso8601String(),
      'isActive': isActive,
      'lastLoginAt': TestConstants.testNow.toIso8601String(),
    };
  }

  static Map<String, dynamic> buildVaultDocument({
    String id = 'doc_123',
    String name = 'Test Document',
    String extension = 'pdf',
    int sizeBytes = 1024 * 1024,
    String category = 'financial',
    bool isSharedWithHeirs = false,
  }) {
    return {
      'id': id,
      'name': name,
      'extension': extension,
      'sizeBytes': sizeBytes,
      'category': category,
      'uploadedAt': TestConstants.testNow.toIso8601String(),
      'ciphertextUrl': 'https://example.com/doc_123',
      'encryptedMeta': base64Encode('test metadata'.codeUnits),
      'heirAccessLevel': 'none',
      'isSharedWithHeirs': isSharedWithHeirs,
    };
  }

  static Map<String, dynamic> buildHeir({
    String id = TestConstants.testHeirId,
    String name = 'John Doe',
    String email = 'john@example.com',
    String? phone,
    List<String> deviceTokens = const [],
    List<String> allowedFolders = const [],
    bool canReceiveAll = false,
  }) {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'deviceTokens': deviceTokens,
      'allowedFolders': allowedFolders,
      'canReceiveAll': canReceiveAll,
      'lastNotified': TestConstants.testNow.toIso8601String(),
      'lastNotificationChannel': 'email',
    };
  }
}

// Test Environment Setup
void setupTestEnvironment() {
  // Configure test environment
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Set up any global test configuration
  FlutterError.onError = (FlutterErrorDetails details) {
    // Handle test errors appropriately
    print('Test Error: ${details.exception}');
  };
}

// Global test setup function
void main() {
  setupTestEnvironment();
  // Run all tests
  group('Digital Vault Heritage v3.0 Tests', () {
    // Test groups will be added here
  });
}

// Custom Test Annotations
class IntegrationTest extends TestAnnotation {
  final String description;
  
  const IntegrationTest(this.description);
  
  @override
  String get description => this.description;
}

class SecurityTest extends TestAnnotation {
  final String description;
  
  const SecurityTest(this.description);
  
  @override
  String get description => this.description;
}

class PerformanceTest extends TestAnnotation {
  final String description;
  final Duration? timeout;
  
  const PerformanceTest(this.description, {this.timeout});
  
  @override
  String get description => this.description;
}

class RegressionTest extends TestAnnotation {
  final String description;
  final String? issueNumber;
  
  const RegressionTest(this.description, {this.issueNumber});
  
  @override
  String get description => this.description;
}
