// Localization Service for Digital Vault Heritage v3.0
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_en.dart';
import 'app_it.dart';

enum AppLanguage {
  en('English', 'en', '🇺🇸'),
  it('Italiano', 'it', '🇮🇹'),
}

class AppLanguage {
  final String displayName;
  final String code;
  final String flag;

  const AppLanguage(this.displayName, this.code, this.flag);
}

class AppLocalizations {
  final Locale locale;

  const AppLocalizations(this.locale);

  // Helper methods
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('it'),
  ];

  static bool isSupported(Locale locale) {
    return supportedLocales.any((supportedLocale) => 
        supportedLocale.languageCode == locale.languageCode);
  }

  // Get all localized strings based on current locale
  String get(String key) {
    switch (locale.languageCode) {
      case 'it':
        return _getItalianString(key);
      case 'en':
      default:
        return _getEnglishString(key);
    }
  }

  // English strings
  String _getEnglishString(String key) {
    switch (key) {
      case 'appName': return AppLocalizationsEn.appName;
      case 'appTagline': return AppLocalizationsEn.appTagline;
      case 'getStarted': return AppLocalizationsEn.getStarted;
      case 'skipForNow': return AppLocalizationsEn.skipForNow;
      case 'continue': return AppLocalizationsEn.continueText;
      case 'cancel': return AppLocalizationsEn.cancel;
      case 'save': return AppLocalizationsEn.save;
      case 'delete': return AppLocalizationsEn.delete;
      case 'edit': return AppLocalizationsEn.edit;
      case 'add': return AppLocalizationsEn.add;
      case 'remove': return AppLocalizationsEn.remove;
      case 'confirm': return AppLocalizationsEn.confirm;
      case 'retry': return AppLocalizationsEn.retry;
      case 'loading': return AppLocalizationsEn.loading;
      case 'error': return AppLocalizationsEn.error;
      case 'success': return AppLocalizationsEn.success;
      case 'warning': return AppLocalizationsEn.warning;
      case 'info': return AppLocalizationsEn.info;

      // Authentication
      case 'welcomeToDigitalVault': return AppLocalizationsEn.welcomeToDigitalVault;
      case 'createYourPin': return AppLocalizationsEn.createYourPin;
      case 'enterYourPin': return AppLocalizationsEn.enterYourPin;
      case 'confirmPin': return AppLocalizationsEn.confirmPin;
      case 'pinHint': return AppLocalizationsEn.pinHint;
      case 'pinCreated': return AppLocalizationsEn.pinCreated;
      case 'pinMismatch': return AppLocalizationsEn.pinMismatch;
      case 'pinTooShort': return AppLocalizationsEn.pinTooShort;
      case 'pinTooLong': return AppLocalizationsEn.pinTooLong;
      case 'invalidPin': return AppLocalizationsEn.invalidPin;
      case 'pinLocked': return AppLocalizationsEn.pinLocked;
      case 'sessionExpired': return AppLocalizationsEn.sessionExpired;
      case 'pleaseEnterPinAgain': return AppLocalizationsEn.pleaseEnterPinAgain;
      case 'unlock': return AppLocalizationsEn.unlock;
      case 'lock': return AppLocalizationsEn.lock;

      // Biometric Authentication
      case 'enableBiometricAuth': return AppLocalizationsEn.enableBiometricAuth;
      case 'useBiometrics': return AppLocalizationsEn.useBiometrics;
      case 'biometricNotAvailable': return AppLocalizationsEn.biometricNotAvailable;
      case 'biometricAuthFailed': return AppLocalizationsEn.biometricAuthFailed;
      case 'biometricSetupSuccess': return AppLocalizationsEn.biometricSetupSuccess;

      // Vault Management
      case 'yourDigitalVault': return AppLocalizationsEn.yourDigitalVault;
      case 'noDocumentsYet': return AppLocalizationsEn.noDocumentsYet;
      case 'addDocument': return AppLocalizationsEn.addDocument;
      case 'uploadDocument': return AppLocalizationsEn.uploadDocument;
      case 'documentName': return AppLocalizationsEn.documentName;
      case 'selectFile': return AppLocalizationsEn.selectFile;
      case 'documentUploaded': return AppLocalizationsEn.documentUploaded;
      case 'uploadFailed': return AppLocalizationsEn.uploadFailed;
      case 'networkError': return AppLocalizationsEn.networkError;
      case 'unableToUploadFile': return AppLocalizationsEn.unableToUploadFile;
      case 'fileSizeTooLarge': return AppLocalizationsEn.fileSizeTooLarge;
      case 'unsupportedFileType': return AppLocalizationsEn.unsupportedFileType;

      // Document Categories
      case 'identity': return AppLocalizationsEn.identity;
      case 'financial': return AppLocalizationsEn.financial;
      case 'legal': return AppLocalizationsEn.legal;
      case 'personal': return AppLocalizationsEn.personal;
      case 'medical': return AppLocalizationsEn.medical;
      case 'other': return AppLocalizationsEn.other;

      // Document Details
      case 'documentDetails': return AppLocalizationsEn.documentDetails;
      case 'fileName': return AppLocalizationsEn.fileName;
      case 'fileSize': return AppLocalizationsEn.fileSize;
      case 'uploadedOn': return AppLocalizationsEn.uploadedOn;
      case 'lastModified': return AppLocalizationsEn.lastModified;
      case 'category': return AppLocalizationsEn.category;
      case 'shareWithHeirs': return AppLocalizationsEn.shareWithHeirs;
      case 'heirAccessLevel': return AppLocalizationsEn.heirAccessLevel;
      case 'noAccess': return AppLocalizationsEn.noAccess;
      case 'readOnly': return AppLocalizationsEn.readOnly;
      case 'readWrite': return AppLocalizationsEn.readWrite;
      case 'fullAccess': return AppLocalizationsEn.fullAccess;

      // Dead Man's Switch
      case 'deadMansSwitch': return AppLocalizationsEn.deadMansSwitch;
      case 'activateDeadMansSwitch': return AppLocalizationsEn.activateDeadMansSwitch;
      case 'deadMansSwitchActive': return AppLocalizationsEn.deadMansSwitchActive;
      case 'deadMansSwitchInactive': return AppLocalizationsEn.deadMansSwitchInactive;
      case 'checkInInterval': return AppLocalizationsEn.checkInInterval;
      case 'maxMissedCheckIns': return AppLocalizationsEn.maxMissedCheckIns;
      case 'gracePeriod': return AppLocalizationsEn.gracePeriod;
      case 'hours': return AppLocalizationsEn.hours;
      case 'days': return AppLocalizationsEn.days;
      case 'weeks': return AppLocalizationsEn.weeks;
      case 'months': return AppLocalizationsEn.months;
      case 'years': return AppLocalizationsEn.years;

      // Check-in System
      case 'performCheckIn': return AppLocalizationsEn.performCheckIn;
      case 'checkInSuccessful': return AppLocalizationsEn.checkInSuccessful;
      case 'checkInFailed': return AppLocalizationsEn.checkInFailed;
      case 'lastCheckIn': return AppLocalizationsEn.lastCheckIn;
      case 'nextCheckInDue': return AppLocalizationsEn.nextCheckInDue;
      case 'missedCheckIns': return AppLocalizationsEn.missedCheckIns;
      case 'checkInChannels': return AppLocalizationsEn.checkInChannels;
      case 'emailCheckIn': return AppLocalizationsEn.emailCheckIn;
      case 'smsCheckIn': return AppLocalizationsEn.smsCheckIn;
      case 'pushCheckIn': return AppLocalizationsEn.pushCheckIn;
      case 'inAppCheckIn': return AppLocalizationsEn.inAppCheckIn;

      // Grace Period
      case 'gracePeriodActive': return AppLocalizationsEn.gracePeriodActive;
      case 'timeRemaining': return AppLocalizationsEn.timeRemaining;
      case 'cancelGracePeriod': return AppLocalizationsEn.cancelGracePeriod;
      case 'heirsWillBeNotified': return AppLocalizationsEn.heirsWillBeNotified;
      case 'gracePeriodCancelled': return AppLocalizationsEn.gracePeriodCancelled;
      case 'emergencyProtocol': return AppLocalizationsEn.emergencyProtocol;

      // Heir Management
      case 'heirs': return AppLocalizationsEn.heirs;
      case 'addHeir': return AppLocalizationsEn.addHeir;
      case 'heirConfiguration': return AppLocalizationsEn.heirConfiguration;
      case 'heirName': return AppLocalizationsEn.heirName;
      case 'heirEmail': return AppLocalizationsEn.heirEmail;
      case 'heirPhone': return AppLocalizationsEn.heirPhone;
      case 'heirRelationship': return AppLocalizationsEn.heirRelationship;
      case 'saveHeir': return AppLocalizationsEn.saveHeir;
      case 'heirAdded': return AppLocalizationsEn.heirAdded;
      case 'heirUpdated': return AppLocalizationsEn.heirUpdated;
      case 'heirDeleted': return AppLocalizationsEn.heirDeleted;
      case 'noHeirsConfigured': return AppLocalizationsEn.noHeirsConfigured;
      case 'heirsConfigured': return AppLocalizationsEn.heirsConfigured;

      // Settings
      case 'settings': return AppLocalizationsEn.settings;
      case 'generalSettings': return AppLocalizationsEn.generalSettings;
      case 'language': return AppLocalizationsEn.language;
      case 'theme': return AppLocalizationsEn.theme;
      case 'darkTheme': return AppLocalizationsEn.darkTheme;
      case 'lightTheme': return AppLocalizationsEn.lightTheme;
      case 'systemTheme': return AppLocalizationsEn.systemTheme;
      case 'notifications': return AppLocalizationsEn.notifications;
      case 'about': return AppLocalizationsEn.about;
      case 'version': return AppLocalizationsEn.version;
      case 'privacyPolicy': return AppLocalizationsEn.privacyPolicy;
      case 'termsOfService': return AppLocalizationsEn.termsOfService;
      case 'contactSupport': return AppLocalizationsEn.contactSupport;

      // Legal and Compliance
      case 'legalPolicy': return AppLocalizationsEn.legalPolicy;
      case 'termsAndConditions': return AppLocalizationsEn.termsAndConditions;
      case 'dataProtection': return AppLocalizationsEn.dataProtection;
      case 'gdprCompliance': return AppLocalizationsEn.gdprCompliance;
      case 'ccpaCompliance': return AppLocalizationsEn.ccpaCompliance;
      case 'zeroKnowledgeDefense': return AppLocalizationsEn.zeroKnowledgeDefense;
      case 'notLegalAdvice': return AppLocalizationsEn.notLegalAdvice;

      // Placeholders
      case 'ownerDetails': return AppLocalizationsEn.ownerDetails;
      case 'companyName': return AppLocalizationsEn.companyName;
      case 'supportEmail': return AppLocalizationsEn.supportEmail;
      case 'legalAddress': return AppLocalizationsEn.legalAddress;
      case 'privacyContact': return AppLocalizationsEn.privacyContact;

      default:
        return key; // Return key if not found
    }
  }

  // Italian strings
  String _getItalianString(String key) {
    switch (key) {
      case 'appName': return AppLocalizationsIt.appName;
      case 'appTagline': return AppLocalizationsIt.appTagline;
      case 'getStarted': return AppLocalizationsIt.getStarted;
      case 'skipForNow': return AppLocalizationsIt.skipForNow;
      case 'continue': return AppLocalizationsIt.continueText;
      case 'cancel': return AppLocalizationsIt.cancel;
      case 'save': return AppLocalizationsIt.save;
      case 'delete': return AppLocalizationsIt.delete;
      case 'edit': return AppLocalizationsIt.edit;
      case 'add': return AppLocalizationsIt.add;
      case 'remove': return AppLocalizationsIt.remove;
      case 'confirm': return AppLocalizationsIt.confirm;
      case 'retry': return AppLocalizationsIt.retry;
      case 'loading': return AppLocalizationsIt.loading;
      case 'error': return AppLocalizationsIt.error;
      case 'success': return AppLocalizationsIt.success;
      case 'warning': return AppLocalizationsIt.warning;
      case 'info': return AppLocalizationsIt.info;

      // Authentication
      case 'welcomeToDigitalVault': return AppLocalizationsIt.welcomeToDigitalVault;
      case 'createYourPin': return AppLocalizationsIt.createYourPin;
      case 'enterYourPin': return AppLocalizationsIt.enterYourPin;
      case 'confirmPin': return AppLocalizationsIt.confirmPin;
      case 'pinHint': return AppLocalizationsIt.pinHint;
      case 'pinCreated': return AppLocalizationsIt.pinCreated;
      case 'pinMismatch': return AppLocalizationsIt.pinMismatch;
      case 'pinTooShort': return AppLocalizationsIt.pinTooShort;
      case 'pinTooLong': return AppLocalizationsIt.pinTooLong;
      case 'invalidPin': return AppLocalizationsIt.invalidPin;
      case 'pinLocked': return AppLocalizationsIt.pinLocked;
      case 'sessionExpired': return AppLocalizationsIt.sessionExpired;
      case 'pleaseEnterPinAgain': return AppLocalizationsIt.pleaseEnterPinAgain;
      case 'unlock': return AppLocalizationsIt.unlock;
      case 'lock': return AppLocalizationsIt.lock;

      // Biometric Authentication
      case 'enableBiometricAuth': return AppLocalizationsIt.enableBiometricAuth;
      case 'useBiometrics': return AppLocalizationsIt.useBiometrics;
      case 'biometricNotAvailable': return AppLocalizationsIt.biometricNotAvailable;
      case 'biometricAuthFailed': return AppLocalizationsIt.biometricAuthFailed;
      case 'biometricSetupSuccess': return AppLocalizationsIt.biometricSetupSuccess;

      // Vault Management
      case 'yourDigitalVault': return AppLocalizationsIt.yourDigitalVault;
      case 'noDocumentsYet': return AppLocalizationsIt.noDocumentsYet;
      case 'addDocument': return AppLocalizationsIt.addDocument;
      case 'uploadDocument': return AppLocalizationsIt.uploadDocument;
      case 'documentName': return AppLocalizationsIt.documentName;
      case 'selectFile': return AppLocalizationsIt.selectFile;
      case 'documentUploaded': return AppLocalizationsIt.documentUploaded;
      case 'uploadFailed': return AppLocalizationsIt.uploadFailed;
      case 'networkError': return AppLocalizationsIt.networkError;
      case 'unableToUploadFile': return AppLocalizationsIt.unableToUploadFile;
      case 'fileSizeTooLarge': return AppLocalizationsIt.fileSizeTooLarge;
      case 'unsupportedFileType': return AppLocalizationsIt.unsupportedFileType;

      // Document Categories
      case 'identity': return AppLocalizationsIt.identity;
      case 'financial': return AppLocalizationsIt.financial;
      case 'legal': return AppLocalizationsIt.legal;
      case 'personal': return AppLocalizationsIt.personal;
      case 'medical': return AppLocalizationsIt.medical;
      case 'other': return AppLocalizationsIt.other;

      // Document Details
      case 'documentDetails': return AppLocalizationsIt.documentDetails;
      case 'fileName': return AppLocalizationsIt.fileName;
      case 'fileSize': return AppLocalizationsIt.fileSize;
      case 'uploadedOn': return AppLocalizationsIt.uploadedOn;
      case 'lastModified': return AppLocalizationsIt.lastModified;
      case 'category': return AppLocalizationsIt.category;
      case 'shareWithHeirs': return AppLocalizationsIt.shareWithHeirs;
      case 'heirAccessLevel': return AppLocalizationsIt.heirAccessLevel;
      case 'noAccess': return AppLocalizationsIt.noAccess;
      case 'readOnly': return AppLocalizationsIt.readOnly;
      case 'readWrite': return AppLocalizationsIt.readWrite;
      case 'fullAccess': return AppLocalizationsIt.fullAccess;

      // Dead Man's Switch
      case 'deadMansSwitch': return AppLocalizationsIt.deadMansSwitch;
      case 'activateDeadMansSwitch': return AppLocalizationsIt.activateDeadMansSwitch;
      case 'deadMansSwitchActive': return AppLocalizationsIt.deadMansSwitchActive;
      case 'deadMansSwitchInactive': return AppLocalizationsIt.deadMansSwitchInactive;
      case 'checkInInterval': return AppLocalizationsIt.checkInInterval;
      case 'maxMissedCheckIns': return AppLocalizationsIt.maxMissedCheckIns;
      case 'gracePeriod': return AppLocalizationsIt.gracePeriod;
      case 'hours': return AppLocalizationsIt.hours;
      case 'days': return AppLocalizationsIt.days;
      case 'weeks': return AppLocalizationsIt.weeks;
      case 'months': return AppLocalizationsIt.months;
      case 'years': return AppLocalizationsIt.years;

      // Check-in System
      case 'performCheckIn': return AppLocalizationsIt.performCheckIn;
      case 'checkInSuccessful': return AppLocalizationsIt.checkInSuccessful;
      case 'checkInFailed': return AppLocalizationsIt.checkInFailed;
      case 'lastCheckIn': return AppLocalizationsIt.lastCheckIn;
      case 'nextCheckInDue': return AppLocalizationsIt.nextCheckInDue;
      case 'missedCheckIns': return AppLocalizationsIt.missedCheckIns;
      case 'checkInChannels': return AppLocalizationsIt.checkInChannels;
      case 'emailCheckIn': return AppLocalizationsIt.emailCheckIn;
      case 'smsCheckIn': return AppLocalizationsIt.smsCheckIn;
      case 'pushCheckIn': return AppLocalizationsIt.pushCheckIn;
      case 'inAppCheckIn': return AppLocalizationsIt.inAppCheckIn;

      // Grace Period
      case 'gracePeriodActive': return AppLocalizationsIt.gracePeriodActive;
      case 'timeRemaining': return AppLocalizationsIt.timeRemaining;
      case 'cancelGracePeriod': return AppLocalizationsIt.cancelGracePeriod;
      case 'heirsWillBeNotified': return AppLocalizationsIt.heirsWillBeNotified;
      case 'gracePeriodCancelled': return AppLocalizationsIt.gracePeriodCancelled;
      case 'emergencyProtocol': return AppLocalizationsIt.emergencyProtocol;

      // Heir Management
      case 'heirs': return AppLocalizationsIt.heirs;
      case 'addHeir': return AppLocalizationsIt.addHeir;
      case 'heirConfiguration': return AppLocalizationsIt.heirConfiguration;
      case 'heirName': return AppLocalizationsIt.heirName;
      case 'heirEmail': return AppLocalizationsIt.heirEmail;
      case 'heirPhone': return AppLocalizationsIt.heirPhone;
      case 'heirRelationship': return AppLocalizationsIt.heirRelationship;
      case 'saveHeir': return AppLocalizationsIt.saveHeir;
      case 'heirAdded': return AppLocalizationsIt.heirAdded;
      case 'heirUpdated': return AppLocalizationsIt.heirUpdated;
      case 'heirDeleted': return AppLocalizationsIt.heirDeleted;
      case 'noHeirsConfigured': return AppLocalizationsIt.noHeirsConfigured;
      case 'heirsConfigured': return AppLocalizationsIt.heirsConfigured;

      // Settings
      case 'settings': return AppLocalizationsIt.settings;
      case 'generalSettings': return AppLocalizationsIt.generalSettings;
      case 'language': return AppLocalizationsIt.language;
      case 'theme': return AppLocalizationsIt.theme;
      case 'darkTheme': return AppLocalizationsIt.darkTheme;
      case 'lightTheme': return AppLocalizationsIt.lightTheme;
      case 'systemTheme': return AppLocalizationsIt.systemTheme;
      case 'notifications': return AppLocalizationsIt.notifications;
      case 'about': return AppLocalizationsIt.about;
      case 'version': return AppLocalizationsIt.version;
      case 'privacyPolicy': return AppLocalizationsIt.privacyPolicy;
      case 'termsOfService': return AppLocalizationsIt.termsOfService;
      case 'contactSupport': return AppLocalizationsIt.contactSupport;

      // Legal and Compliance
      case 'legalPolicy': return AppLocalizationsIt.legalPolicy;
      case 'termsAndConditions': return AppLocalizationsIt.termsAndConditions;
      case 'dataProtection': return AppLocalizationsIt.dataProtection;
      case 'gdprCompliance': return AppLocalizationsIt.gdprCompliance;
      case 'ccpaCompliance': return AppLocalizationsIt.ccpaCompliance;
      case 'zeroKnowledgeDefense': return AppLocalizationsIt.zeroKnowledgeDefense;
      case 'notLegalAdvice': return AppLocalizationsIt.notLegalAdvice;

      // Placeholders
      case 'ownerDetails': return AppLocalizationsIt.ownerDetails;
      case 'companyName': return AppLocalizationsIt.companyName;
      case 'supportEmail': return AppLocalizationsIt.supportEmail;
      case 'legalAddress': return AppLocalizationsIt.legalAddress;
      case 'privacyContact': return AppLocalizationsIt.privacyContact;

      default:
        return key; // Return key if not found
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.isSupported(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

class LocalizationService {
  static LocalizationService? _instance;
  static LocalizationService get instance => _instance ??= LocalizationService._();

  LocalizationService._();

  final _localeController = StreamController<Locale>.broadcast();
  Stream<Locale> get localeStream => _localeController.stream;

  Locale _currentLocale = const Locale('en');
  Locale get currentLocale => _currentLocale;

  static const String _localeKey = 'app_locale';

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocaleCode = prefs.getString(_localeKey);
      
      if (savedLocaleCode != null) {
        _currentLocale = Locale(savedLocaleCode!);
      } else {
        // Detect system locale
        final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
        if (systemLocale.languageCode == 'it') {
          _currentLocale = const Locale('it');
        } else {
          _currentLocale = const Locale('en');
        }
        await saveLocale(_currentLocale);
      }
    } catch (e) {
      // Fallback to English
      _currentLocale = const Locale('en');
    }
  }

  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      await saveLocale(locale);
      _localeController.add(locale);
    }
  }

  Future<void> saveLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  AppLanguage getLanguageForLocale(Locale locale) {
    for (final language in AppLanguage.values) {
      if (language.code == locale.languageCode) {
        return language;
      }
    }
    return AppLanguage.en; // Default to English
  }

  List<AppLanguage> get supportedLanguages => AppLanguage.values;
}

// Extension method for easy access to localized strings
extension LocalizedString on String {
  String tr(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return localizations?.get(this) ?? this;
  }
}
