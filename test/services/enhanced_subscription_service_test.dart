// Unit Tests for EnhancedSubscriptionService v3.0
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../lib/core/services/enhanced_subscription_service.dart';
import '../../lib/core/services/security_service.dart';
import '../../lib/core/services/advanced_security_logging_service.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}
class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockSecurityService extends Mock implements SecurityService {}
class MockAdvancedSecurityLoggingService extends Mock implements AdvancedSecurityLoggingService {}
class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('EnhancedSubscriptionService Tests', () {
    late EnhancedSubscriptionService subscriptionService;
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

      subscriptionService = EnhancedSubscriptionService();
    });

    group('Subscription Creation', () {
      test('should create free subscription successfully', () async {
        // Arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('user123');

        // Act
        final result = await subscriptionService.createSubscription(
          userId: 'user123',
          tier: SubscriptionTierV3.free,
          billingCycle: BillingCycle.monthly,
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.status, equals(PaymentStatus.succeeded));
        verify(mockStorage.write('enhanced_subscription_v3', any)).called(1);
      });

      test('should create premium subscription with payment', () async {
        // Arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('user123');
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('{"id": "pi_123", "status": "succeeded", "client_secret": "secret_123"}', 200));

        // Act
        final result = await subscriptionService.createSubscription(
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          paymentMethodId: 'pm_123',
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.status, equals(PaymentStatus.succeeded));
        expect(result.paymentIntentId, equals('pi_123'));
        expect(result.clientSecret, equals('secret_123'));
      });

      test('should handle payment failure', () async {
        // Arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('user123');
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('{"error": "Payment failed"}', 400));

        // Act
        final result = await subscriptionService.createSubscription(
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          paymentMethodId: 'pm_123',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.status, equals(PaymentStatus.failed));
        expect(result.errorMessage, isNotNull);
      });

      test('should log subscription creation event', () async {
        // Arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('user123');

        // Act
        await subscriptionService.createSubscription(
          userId: 'user123',
          tier: SubscriptionTierV3.free,
          billingCycle: BillingCycle.monthly,
        );

        // Assert
        verify(mockLoggingService.logBusinessEvent(
          userId: 'user123',
          event: 'subscription_created',
          businessData: anyNamed('businessData'),
        )).called(1);
      });
    });

    group('Instant Upgrade', () {
      test('should upgrade from free to premium successfully', () async {
        // Arrange
        final existingSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.free,
          billingCycle: BillingCycle.monthly,
          status: PaymentStatus.succeeded,
          createdAt: DateTime.now(),
        );
        
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => jsonEncode(existingSub.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('{"id": "pi_456", "status": "succeeded"}', 200));

        // Act
        final result = await subscriptionService.instantUpgrade(
          userId: 'user123',
          targetTier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          paymentMethodId: 'pm_123',
        );

        // Assert
        expect(result.success, isTrue);
        verify(mockStorage.write('enhanced_subscription_v3', any)).called(1);
      });

      test('should handle upgrade to same tier', () async {
        // Arrange
        final existingSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          status: PaymentStatus.succeeded,
          createdAt: DateTime.now(),
        );
        
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => jsonEncode(existingSub.toJson()));

        // Act
        final result = await subscriptionService.instantUpgrade(
          userId: 'user123',
          targetTier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Already subscribed'));
      });

      test('should create new subscription if none exists', () async {
        // Arrange
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => null);
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('user123');

        // Act
        final result = await subscriptionService.instantUpgrade(
          userId: 'user123',
          targetTier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
        );

        // Assert
        expect(result.success, isTrue);
        verify(mockStorage.write('enhanced_subscription_v3', any)).called(1);
      });
    });

    group('Subscription Cancellation', () {
      test('should cancel subscription immediately', () async {
        // Arrange
        final existingSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          status: PaymentStatus.succeeded,
          stripeSubscriptionId: 'sub_stripe_123',
          createdAt: DateTime.now(),
        );
        
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => jsonEncode(existingSub.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockHttpClient.delete(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('{"id": "sub_stripe_123", "status": "canceled"}', 200));

        // Act
        final result = await subscriptionService.cancelSubscription(
          subscriptionId: 'sub_123',
          immediate: true,
          reason: 'User requested',
        );

        // Assert
        expect(result, isTrue);
        verify(mockHttpClient.delete(any, headers: anyNamed('headers'))).called(1);
      });

      test('should cancel subscription at period end', () async {
        // Arrange
        final existingSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          status: PaymentStatus.succeeded,
          stripeSubscriptionId: 'sub_stripe_123',
          createdAt: DateTime.now(),
        );
        
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => jsonEncode(existingSub.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async = true);
        when(mockHttpClient.delete(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('{"id": "sub_stripe_123", "status": "active", "cancel_at_period_end": true}', 200));

        // Act
        final result = await subscriptionService.cancelSubscription(
          subscriptionId: 'sub_123',
          immediate: false,
        );

        // Assert
        expect(result, isTrue);
        final captured = verify(mockHttpClient.delete(any, headers: captureAnyNamed('headers'))).captured;
        expect(captured.first['cancel_at_period_end'], equals('true'));
      });

      test('should handle cancellation of non-existent subscription', () async {
        // Arrange
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => null);

        // Act
        final result = await subscriptionService.cancelSubscription(
          subscriptionId: 'non_existent',
        );

        // Assert
        expect(result, isFalse);
      });
    });

    group('Refund Processing', () {
      test('should process full refund successfully', () async {
        // Arrange
        final existingSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          status: PaymentStatus.succeeded,
          stripeSubscriptionId: 'sub_stripe_123',
          createdAt: DateTime.now(),
          currentPeriodStart: DateTime.now().subtract(Duration(days: 15)),
          currentPeriodEnd: DateTime.now().add(Duration(days: 15)),
        );
        
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => jsonEncode(existingSub.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async => true);
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('{"id": "ref_123", "status": "succeeded", "amount": 9999}', 200));

        // Act
        final result = await subscriptionService.processRefund(
          subscriptionId: 'sub_123',
          reason: 'Customer requested',
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.refundId, equals('ref_123'));
        expect(result.amountRefunded, equals(9999));
      });

      test('should calculate prorated refund correctly', () async {
        // Arrange
        final existingSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          status: PaymentStatus.succeeded,
          stripeSubscriptionId: 'sub_stripe_123',
          createdAt: DateTime.now(),
          currentPeriodStart: DateTime.now().subtract(Duration(days: 15)),
          currentPeriodEnd: DateTime.now().add(Duration(days: 15)),
        );
        
        // Act
        final refundAmount = subscriptionService._calculateProratedRefund(existingSub);

        // Assert
        expect(refundAmount, equals(4999)); // Half of 9999
      });

      test('should handle refund failure', () async {
        // Arrange
        final existingSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          status: PaymentStatus.succeeded,
          stripeSubscriptionId: 'sub_stripe_123',
          createdAt: DateTime.now(),
        );
        
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => jsonEncode(existingSub.toJson()));
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('{"error": "Refund failed"}', 400));

        // Act
        final result = await subscriptionService.processRefund(
          subscriptionId: 'sub_123',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, isNotNull);
      });
    });

    group('Stripe Webhook Handling', () {
      test('should handle payment succeeded webhook', () async {
        // Arrange
        final webhookPayload = {
          'id': 'evt_123',
          'type': 'invoice.payment_succeeded',
          'data': {
            'object': {
              'id': 'in_123',
              'subscription': 'sub_123',
              'amount_paid': 9999,
            }
          }
        };
        
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => http.Response('{"status": "ok"}', 200));

        // Act
        await subscriptionService.handleStripeWebhook(
          jsonEncode(webhookPayload),
          'signature',
        );

        // Assert
        verify(mockLoggingService.logBusinessEvent(
          userId: 'system',
          event: 'stripe_webhook_processed',
          businessData: anyNamed('businessData'),
        )).called(1);
      });

      test('should handle payment failed webhook', () async {
        // Arrange
        final webhookPayload = {
          'id': 'evt_456',
          'type': 'invoice.payment_failed',
          'data': {
            'object': {
              'id': 'in_456',
              'subscription': 'sub_123',
              'attempt_count': 1,
            }
          }
        };

        // Act
        await subscriptionService.handleStripeWebhook(
          jsonEncode(webhookPayload),
          'signature',
        );

        // Assert
        verify(mockLoggingService.logBusinessEvent(
          userId: 'system',
          event: 'stripe_webhook_processed',
          businessData: anyNamed('businessData'),
        )).called(1);
      });

      test('should handle subscription deleted webhook', () async {
        // Arrange
        final webhookPayload = {
          'id': 'evt_789',
          'type': 'customer.subscription.deleted',
          'data': {
            'object': {
              'id': 'sub_123',
              'status': 'canceled',
            }
          }
        };

        // Act
        await subscriptionService.handleStripeWebhook(
          jsonEncode(webhookPayload),
          'signature',
        );

        // Assert
        verify(mockLoggingService.logBusinessEvent(
          userId: 'system',
          event: 'stripe_webhook_processed',
          businessData: anyNamed('businessData'),
        )).called(1);
      });

      test('should handle invalid webhook signature', () async {
        // Act & Assert
        expect(
          () async => await subscriptionService.handleStripeWebhook('invalid', 'invalid'),
          throwsA(isA<SecurityViolationException>()),
        );
      });
    });

    group('Feature Access Control', () {
      test('should grant access for free tier within limits', () async {
        // Arrange
        final freeSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.free,
          billingCycle: BillingCycle.monthly,
          status: PaymentStatus.succeeded,
          createdAt: DateTime.now(),
        );
        
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => jsonEncode(freeSub.toJson()));

        // Act & Assert
        expect(await subscriptionService.hasFeatureAccess(
          userId: 'user123',
          feature: 'documents',
          documentCount: 5,
        ), isTrue);

        expect(await subscriptionService.hasFeatureAccess(
          userId: 'user123',
          feature: 'documents',
          documentCount: 15,
        ), isFalse);
      });

      test('should grant access for premium tier', () async {
        // Arrange
        final premiumSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          status: PaymentStatus.succeeded,
          createdAt: DateTime.now(),
        );
        
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => jsonEncode(premiumSub.toJson()));

        // Act & Assert
        expect(await subscriptionService.hasFeatureAccess(
          userId: 'user123',
          feature: 'documents',
          documentCount: 50,
        ), isTrue);

        expect(await subscriptionService.hasFeatureAccess(
          userId: 'user123',
          feature: 'dead_mans_switch',
        ), isTrue);
      });

      test('should grant all access for lifetime tier', () async {
        // Arrange
        final lifetimeSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.lifetime,
          billingCycle: BillingCycle.lifetime,
          status: PaymentStatus.succeeded,
          createdAt: DateTime.now(),
        );
        
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => jsonEncode(lifetimeSub.toJson()));

        // Act & Assert
        expect(await subscriptionService.hasFeatureAccess(
          userId: 'user123',
          feature: 'documents',
          documentCount: 1000,
        ), isTrue);

        expect(await subscriptionService.hasFeatureAccess(
          userId: 'user123',
          feature: 'any_feature',
        ), isTrue);
      });

      test('should deny access for inactive subscription', () async {
        // Arrange
        final expiredSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          status: PaymentStatus.succeeded,
          createdAt: DateTime.now(),
          currentPeriodEnd: DateTime.now().subtract(Duration(days: 1)),
        );
        
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => jsonEncode(expiredSub.toJson()));

        // Act & Assert
        expect(await subscriptionService.hasFeatureAccess(
          userId: 'user123',
          feature: 'documents',
        ), isFalse);
      });
    });

    group('Subscription Analytics', () {
      test('should return analytics for active subscription', () async {
        // Arrange
        final activeSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          status: PaymentStatus.succeeded,
          createdAt: DateTime.now(),
          currentPeriodStart: DateTime.now().subtract(Duration(days: 15)),
          currentPeriodEnd: DateTime.now().add(Duration(days: 15)),
          autoRenew: true,
          lastPaymentDate: DateTime.now().subtract(Duration(days: 15)),
        );
        
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => jsonEncode(activeSub.toJson()));

        // Act
        final analytics = await subscriptionService.getSubscriptionAnalytics();

        // Assert
        expect(analytics['currentTier'], equals('premium'));
        expect(analytics['billingCycle'], equals('monthly'));
        expect(analytics['status'], equals('succeeded'));
        expect(analytics['isActive'], isTrue);
        expect(analytics['autoRenew'], isTrue);
        expect(analytics['features']['maxDocuments'], equals(100));
        expect(analytics['features']['hasDeadMansSwitch'], isTrue);
      });

      test('should return empty analytics for no subscription', () async {
        // Arrange
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => null);

        // Act
        final analytics = await subscriptionService.getSubscriptionAnalytics();

        // Assert
        expect(analytics, isEmpty);
      });
    });

    group('Subscription Validation', () {
      test('should validate subscription status with Stripe', () async {
        // Arrange
        final activeSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          status: PaymentStatus.succeeded,
          stripeSubscriptionId: 'sub_stripe_123',
          createdAt: DateTime.now(),
        );
        
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => jsonEncode(activeSub.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async = true);

        // Act
        await subscriptionService._validateSubscriptionStatus(activeSub);

        // Assert
        // Should not update status if still active
        final captured = verify(mockStorage.write('enhanced_subscription_v3', captureAny)).captured;
        final updatedSub = EnhancedSubscription.fromJson(jsonDecode(captured as String));
        expect(updatedSub.status, equals(PaymentStatus.succeeded));
      });

      test('should update expired subscription status', () async {
        // Arrange
        final expiredSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          status: PaymentStatus.succeeded,
          stripeSubscriptionId: 'sub_stripe_123',
          createdAt: DateTime.now(),
          currentPeriodEnd: DateTime.now().subtract(Duration(days: 1)),
        );
        
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => jsonEncode(expiredSub.toJson()));
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async = true);

        // Act
        await subscriptionService._validateSubscriptionStatus(expiredSub);

        // Assert
        final captured = verify(mockStorage.write('enhanced_subscription_v3', captureAny)).captured;
        final updatedSub = EnhancedSubscription.fromJson(jsonDecode(captured as String));
        expect(updatedSub.status, equals(PaymentStatus.failed));
      });
    });

    group('Payment Processing', () {
      test('should map Stripe statuses correctly', () {
        // Act & Assert
        expect(subscriptionService._mapStripeStatus('succeeded'), equals(PaymentStatus.succeeded));
        expect(subscriptionService._mapStripeStatus('processing'), equals(PaymentStatus.processing));
        expect(subscriptionService._mapStripeStatus('requires_payment_method'), equals(PaymentStatus.pending));
        expect(subscriptionService._mapStripeStatus('canceled'), equals(PaymentStatus.canceled));
        expect(subscriptionService._mapStripeStatus('unknown'), equals(PaymentStatus.failed));
      });

      test('should get correct price ID for tier and billing cycle', () {
        // Act & Assert
        expect(subscriptionService._getPriceIdForTier(SubscriptionTierV3.premium, BillingCycle.monthly), equals('price_1premium_monthly'));
        expect(subscriptionService._getPriceIdForTier(SubscriptionTierV3.premium, BillingCycle.yearly), equals('price_1premium_yearly'));
        expect(subscriptionService._getPriceIdForTier(SubscriptionTierV3.lifetime, BillingCycle.lifetime), equals('price_1lifetime'));
        
        expect(() => subscriptionService._getPriceIdForTier(SubscriptionTierV3.free, BillingCycle.monthly), throwsA(isA<ArgumentError>()));
      });

      test('should calculate period end correctly', () {
        // Arrange
        final startDate = DateTime(2024, 1, 15);

        // Act & Assert
        expect(subscriptionService._calculatePeriodEnd(BillingCycle.monthly, startDate), equals(DateTime(2024, 2, 15)));
        expect(subscriptionService._calculatePeriodEnd(BillingCycle.yearly, startDate), equals(DateTime(2025, 1, 15)));
        expect(subscriptionService._calculatePeriodEnd(BillingCycle.lifetime, startDate), equals(DateTime(2100, 12, 31)));
      });
    });

    group('Transition Detection', () {
      test('should detect free to premium transition', () {
        // Act
        final transition = subscriptionService._determineTransition(null, SubscriptionTierV3.premium);

        // Assert
        expect(transition, equals(SubscriptionTransition.free_to_premium));
      });

      test('should detect premium to lifetime transition', () {
        // Act
        final transition = subscriptionService._determineTransition(SubscriptionTierV3.premium, SubscriptionTierV3.lifetime);

        // Assert
        expect(transition, equals(SubscriptionTransition.premium_to_lifetime));
      });

      test('should detect upgrade transition', () {
        // Act
        final transition = subscriptionService._determineTransition(SubscriptionTierV3.free, SubscriptionTierV3.lifetime);

        // Assert
        expect(transition, equals(SubscriptionTransition.upgrade));
      });

      test('should detect downgrade transition', () {
        // Act
        final transition = subscriptionService._determineTransition(SubscriptionTierV3.lifetime, SubscriptionTierV3.premium);

        // Assert
        expect(transition, equals(SubscriptionTransition.downgrade));
      });
    });

    group('Error Handling', () {
      test('should handle storage errors during subscription creation', () async {
        // Arrange
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenThrow(Exception('Storage error'));
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('user123');

        // Act & Assert
        expect(() async => await subscriptionService.createSubscription(
          userId: 'user123',
          tier: SubscriptionTierV3.free,
          billingCycle: BillingCycle.monthly,
        ), throwsA(isA<Exception>()));
      });

      test('should handle network errors during payment processing', () async {
        // Arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('user123');
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await subscriptionService.createSubscription(
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          paymentMethodId: 'pm_123',
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.errorMessage, contains('Network error'));
      });

      test('should handle malformed subscription data', () async {
        // Arrange
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => 'invalid json');

        // Act
        final subscription = await subscriptionService.getCurrentSubscription();

        // Assert
        expect(subscription, isNull);
      });
    });

    group('Edge Cases', () {
      test('should handle very long user ID', () async {
        // Arrange
        final longUserId = 'a' * 1000;
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async = true);
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('sanitized_user');

        // Act
        final result = await subscriptionService.createSubscription(
          userId: longUserId,
          tier: SubscriptionTierV3.free,
          billingCycle: BillingCycle.monthly,
        );

        // Assert
        expect(result.success, isTrue);
        verify(mockSecurityService.sanitizeInput(longUserId)).called(1);
      });

      test('should handle null payment method for free tier', () async {
        // Arrange
        when(mockStorage.read(key: anyNamed('key')))
            .thenAnswer((_) async => null);
        when(mockStorage.write(key: anyNamed('key'), value: anyNamed('value')))
            .thenAnswer((_) async = true);
        when(mockSecurityService.sanitizeInput(anyNamed('input')))
            .thenReturn('user123');

        // Act
        final result = await subscriptionService.createSubscription(
          userId: 'user123',
          tier: SubscriptionTierV3.free,
          billingCycle: BillingCycle.monthly,
          paymentMethodId: null,
        );

        // Assert
        expect(result.success, isTrue);
      });

      test('should handle missing subscription during upgrade', () async {
        // Arrange
        when(mockStorage.read(key: 'enhanced_subscription_v3'))
            .thenAnswer((_) async => null);

        // Act
        final result = await subscriptionService.instantUpgrade(
          userId: 'user123',
          targetTier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
        );

        // Assert
        expect(result.success, isTrue);
      });

      test('should handle refund amount of zero', () async {
        // Arrange
        final existingSub = EnhancedSubscription(
          id: 'sub_123',
          userId: 'user123',
          tier: SubscriptionTierV3.premium,
          billingCycle: BillingCycle.monthly,
          status: PaymentStatus.succeeded,
          stripeSubscriptionId: 'sub_stripe_123',
          createdAt: DateTime.now(),
          currentPeriodStart: DateTime.now().subtract(Duration(days: 30)),
          currentPeriodEnd: DateTime.now().subtract(Duration(days: 1)),
        );
        
        // Act
        final refundAmount = subscriptionService._calculateProratedRefund(existingSub);

        // Assert
        expect(refundAmount, equals(0));
      });
    });
  });
}
