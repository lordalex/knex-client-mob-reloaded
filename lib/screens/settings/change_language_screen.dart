import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_state_provider.dart';

/// Screen for selecting the app's display language.
///
/// Supports English, Spanish, and French. The selected locale is stored
/// in [localeProvider] and applied to MaterialApp.router.
class ChangeLanguageScreen extends ConsumerWidget {
  const ChangeLanguageScreen({super.key});

  static const _languages = [
    _LanguageOption(label: 'English', locale: Locale('en')),
    _LanguageOption(label: 'Español', locale: Locale('es')),
    _LanguageOption(label: 'Français', locale: Locale('fr')),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Language')),
      body: ListView(
        children: [
          // System default option
          ListTile(
            leading: const Icon(Icons.phone_android),
            title: const Text('System Default'),
            trailing: currentLocale == null
                ? Icon(Icons.check, color: theme.colorScheme.primary)
                : null,
            onTap: () {
              ref.read(localeProvider.notifier).state = null;
            },
          ),
          const Divider(),
          ..._languages.map((lang) {
            final isSelected = currentLocale?.languageCode ==
                lang.locale.languageCode;
            return ListTile(
              leading: Text(
                _flagEmoji(lang.locale.languageCode),
                style: const TextStyle(fontSize: 24),
              ),
              title: Text(lang.label),
              subtitle: Text(lang.locale.languageCode.toUpperCase()),
              trailing: isSelected
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                ref.read(localeProvider.notifier).state = lang.locale;
              },
            );
          }),
        ],
      ),
    );
  }

  String _flagEmoji(String languageCode) {
    return switch (languageCode) {
      'en' => '🇺🇸',
      'es' => '🇪🇸',
      'fr' => '🇫🇷',
      _ => '🌐',
    };
  }
}

class _LanguageOption {
  final String label;
  final Locale locale;

  const _LanguageOption({required this.label, required this.locale});
}
