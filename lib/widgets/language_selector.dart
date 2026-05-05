// Language Selector Widget for Digital Vault Heritage v3.0
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/localization_service.dart';

class LanguageSelector extends ConsumerStatefulWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  ConsumerState<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends ConsumerState<LanguageSelector> {
  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService.instance;
    final currentLocale = localizationService.currentLocale;
    
    return PopupMenuButton<Locale>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getLanguageFlag(currentLocale),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
      onSelected: (Locale? newLocale) async {
        if (newLocale != null && newLocale != currentLocale) {
          await localizationService.changeLanguage(newLocale!);
        }
      },
      itemBuilder: (BuildContext context) {
        return localizationService.supportedLanguages.map((language) {
          return PopupMenuItem<Locale>(
            value: Locale(language.code),
            child: Row(
              children: [
                Text(
                  language.flag,
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 12),
                Text(language.displayName),
                const Spacer(),
                if (language.code == currentLocale.languageCode)
                  const Icon(Icons.check, color: Colors.green),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  String _getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'it':
        return '🇮🇹';
      case 'en':
      default:
        return '🇺🇸';
    }
  }
}

class LanguageSettingsPage extends ConsumerStatefulWidget {
  const LanguageSettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends ConsumerState<LanguageSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService.instance;
    final currentLocale = localizationService.currentLocale;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr(context)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'language'.tr(context),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Language selection cards
            ...localizationService.supportedLanguages.map((language) {
              final isSelected = language.code == currentLocale.languageCode;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: isSelected ? 4 : 1,
                color: isSelected 
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : null,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: isSelected 
                      ? Theme.of(context).primaryColor
                      : Colors.grey.shade300,
                    child: Text(
                      language.flag,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  title: Text(
                    language.displayName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected 
                        ? Theme.of(context).primaryColor
                        : null,
                    ),
                  ),
                  subtitle: Text(
                    language.code.toUpperCase(),
                    style: TextStyle(
                      color: isSelected 
                        ? Theme.of(context).primaryColor
                        : Colors.grey.shade600,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: Theme.of(context).primaryColor,
                          size: 24,
                        )
                      : null,
                  onTap: () async {
                    if (!isSelected) {
                      await localizationService.changeLanguage(Locale(language.code));
                    }
                  },
                ),
              );
            }),
            
            const Spacer(),
            
            // Apply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('continue'.tr(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Language selector for settings dropdown
class SettingsLanguageSelector extends StatelessWidget {
  const SettingsLanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizationService = LocalizationService.instance;
    final currentLocale = localizationService.currentLocale;
    
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text('language'.tr(context)),
      subtitle: Text(
        _getLanguageDisplayName(currentLocale),
        style: TextStyle(color: Colors.grey.shade600),
      ),
      trailing: Row(
        children: [
          Text(
            _getLanguageFlag(currentLocale),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LanguageSettingsPage(),
          ),
        );
      },
    );
  }

  String _getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'it':
        return '🇮🇹';
      case 'en':
      default:
        return '🇺🇸';
    }
  }

  String _getLanguageDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'it':
        return 'Italiano';
      case 'en':
      default:
        return 'English';
    }
  }
}
