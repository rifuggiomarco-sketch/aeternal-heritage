// Core Providers for Digital Vault Heritage v3.0
// Copyright © 2026 Aeternal Heritage. All rights reserved.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core Services
import 'services/encryption_service.dart';
import 'services/secure_key_service.dart';
import 'services/secure_crypto_storage.dart';
import 'services/pin_service.dart';
import 'services/shamir_service.dart';
import 'services/recovery_key_service.dart';
import 'services/migration_service.dart';
import 'services/security_service.dart';
import 'services/error_handling_service.dart';
import 'services/screenshot_protection.dart';

// Enhanced Services v3.0
import 'services/advanced_security_logging_service.dart';
import 'services/enhanced_dead_mans_switch_service.dart';
import 'services/enhanced_subscription_service.dart';
import 'services/user_reporting_service.dart';
import 'services/conditional_inheritance_service.dart';

// New Integration Services
import 'services/supabase_service.dart';
import 'services/stripe_service.dart';
import 'services/dead_mans_switch_enhanced_service.dart';

// Localization
import '../l10n/localization_service.dart';

// Core
import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'state/lock_state.dart';
import 'logger.dart';

// Features
import '../features/vault/vault_provider.dart';
import '../features/kill_switch/kill_switch_provider.dart';
import '../features/auth/auth_provider.dart';

// Core Security Services
final encryptionServiceProvider = Provider((ref) => EncryptionService());
final secureKeyServiceProvider = Provider((ref) => SecureKeyService());
final secureCryptoStorageProvider = Provider((ref) => SecureCryptoStorage());

// Enhanced Security Services
final securityServiceProvider = Provider((ref) => SecurityService());
final errorHandlingServiceProvider = Provider((ref) => ErrorHandlingService());

// Authentication & Recovery Services
final authServiceProvider = Provider((ref) => AuthService());
final pinServiceProvider = Provider((ref) => PinService());
final recoveryKeyServiceProvider = Provider((ref) => RecoveryKeyService());

// Cryptographic Services
final shamirServiceProvider = Provider((ref) => ShamirService());
final sealedEnvelopeServiceProvider = Provider(
  (ref) => SealedEnvelopeService(shamir: ref.read(shamirServiceProvider)),
);

// Enhanced Services v3.0
final advancedSecurityLoggingServiceProvider = Provider<AdvancedSecurityLoggingService>((ref) {
  return AdvancedSecurityLoggingService();
});

final enhancedDeadMansSwitchServiceProvider = Provider<EnhancedDeadMansSwitchService>((ref) {
  return EnhancedDeadMansSwitchService();
});

final enhancedSubscriptionServiceProvider = Provider<EnhancedSubscriptionService>((ref) {
  return EnhancedSubscriptionService();
});

final userReportingServiceProvider = Provider<UserReportingService>((ref) {
  return UserReportingService();
});

final conditionalInheritanceServiceProvider = Provider<ConditionalInheritanceService>((ref) {
  return ConditionalInheritanceService();
});

// New Integration Service Providers
final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService.instance;
});

final stripeServiceProvider = Provider<StripeService>((ref) {
  return StripeService.instance;
});

final deadMansSwitchEnhancedServiceProvider = Provider<DeadMansSwitchEnhancedService>((ref) {
  return DeadMansSwitchEnhancedService.instance;
});

// Localization Provider
final localizationsServiceProvider = Provider<LocalizationService>((ref) {
  return LocalizationService.instance;
});

// Core Providers
final appRouterProvider = Provider<AppRouter>((ref) {
  return AppRouter();
});

final appThemeProvider = Provider<AppTheme>((ref) {
  return AppTheme();
});

final lockProvider = StateNotifierProvider<LockStateNotifier, LockState>((ref) {
  return LockStateNotifier();
});

final loggerProvider = Provider<AppLogger>((ref) {
  return AppLogger();
});

// Feature Providers
final vaultProvider = AsyncNotifierProvider<VaultNotifier, List<VaultDoc>>((ref) {
  return VaultNotifier(ref);
});

final killSwitchProvider = AsyncNotifierProvider<KillSwitchNotifier, KillSwitchState>((ref) {
  return KillSwitchNotifier(ref);
});

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

// Utility Providers for initialization
Future<void> initializeProviders(ProviderContainer container) async {
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  container.read(sharedPreferencesProvider.notifier).state = prefs;

  // Note: FlutterSecureStorage and other services are initialized in main.dart
  // This function can be used for any additional provider setup needed
}
final securityEventsProvider = StreamProvider<List<SecurityEvent>>((ref) async* {
  final securityService = ref.read(securityServiceProvider);
  yield* Stream.periodic(const Duration(minutes: 1), (_) async {
    return await securityService.getSecurityEvents();
  }).asyncMap((event) => event);
});

final errorEventsProvider = StreamProvider<List<AppError>>((ref) async* {
  final errorService = ref.read(errorHandlingServiceProvider);
  yield* errorService.errorStream.map((error) => [error]);
});

// Subscription State Providers
final subscriptionProvider = FutureProvider<Subscription?>((ref) async {
  final subscriptionService = ref.read(subscriptionServiceProvider);
  return await subscriptionService.getCurrentSubscription();
});

final premiumAccessProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final subscriptionService = ref.read(subscriptionServiceProvider);
  return await subscriptionService.hasPremiumAccess(userId);
});

// Dead Man's Switch State Providers
final deadMansSwitchStateProvider = FutureProvider<DeadMansSwitchState>((ref) async {
  final dmsService = ref.read(deadMansSwitchServiceProvider);
  return await dmsService.getState();
});

// Session Management Provider
final sessionValidProvider = FutureProvider<bool>((ref) async {
  final securityService = ref.read(securityServiceProvider);
  return await securityService.isSessionValid();
});

// Pricing Information Provider
final pricingInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final subscriptionService = ref.read(subscriptionServiceProvider);
  return subscriptionService.getPricingInfo();
});

// Available Tiers Provider
final availableTiersProvider = Provider<List<SubscriptionTier>>((ref) {
  final subscriptionService = ref.read(subscriptionServiceProvider);
  return subscriptionService.getAvailableTiers();
});

// Error Log Provider
final errorLogProvider = FutureProvider.family<List<AppError>, int>((ref, limit) async {
  final errorService = ref.read(errorHandlingServiceProvider);
  return await errorService.getRecentErrors(limit: limit);
});

// Initialization Providers
final appInitializationProvider = FutureProvider<void>((ref) async {
  // Initialize all services
  final securityService = ref.read(securityServiceProvider);
  final errorService = ref.read(errorHandlingServiceProvider);
  final subscriptionService = ref.read(subscriptionServiceProvider);
  final dmsService = ref.read(deadMansSwitchServiceProvider);
  
  // Initialize services in order
  await securityService.createSession('default_user'); // Will be replaced with actual user ID
  await subscriptionService.initialize();
  await dmsService.initialize();
  
  // Error service doesn't need explicit initialization
});

// Health Check Provider
final healthCheckProvider = FutureProvider<Map<String, bool>>((ref) async {
  final results = <String, bool>{};
  
  try {
    // Test security service
    final securityService = ref.read(securityServiceProvider);
    results['security'] = await securityService.isSessionValid();
  } catch (e) {
    results['security'] = false;
  }
  
  try {
    // Test error service
    final errorService = ref.read(errorHandlingServiceProvider);
    results['errorHandling'] = true; // Basic health check
  } catch (e) {
    results['errorHandling'] = false;
  }
  
  try {
    // Test subscription service
    final subscriptionService = ref.read(subscriptionServiceProvider);
    await subscriptionService.getCurrentSubscription();
    results['subscription'] = true;
  } catch (e) {
    results['subscription'] = false;
  }
  
  try {
    // Test dead man's switch
    final dmsService = ref.read(deadMansSwitchServiceProvider);
    await dmsService.getState();
    results['deadMansSwitch'] = true;
  } catch (e) {
    results['deadMansSwitch'] = false;
  }
  
  return results;
});
