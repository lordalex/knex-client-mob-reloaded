import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'config/routes/app_router.dart';
import 'config/theme/app_theme.dart';
import 'providers/app_state_provider.dart';
import 'providers/storage_provider.dart';
import 'providers/theme_provider.dart';
import 'services/auth/auth_providers.dart';

/// The singleton [GoRouter] instance for the app.
///
/// Created once at the top level so it is not rebuilt on every widget rebuild.
/// The [createRouter] function is defined in `config/routes/app_router.dart`.
final GoRouter _router = createRouter();

/// Whether Firebase has been initialized (safe to use Firebase services).
bool get _firebaseReady {
  try {
    Firebase.app();
    return true;
  } catch (_) {
    return false;
  }
}

/// Root widget for the KNEX valet parking client app.
///
/// Sets up Material 3 theming (light + dark), GoRouter navigation,
/// locale-aware localizations (EN/ES/FR), and Riverpod state management.
/// Loads persisted state from SharedPreferences on first build.
class KnexApp extends ConsumerStatefulWidget {
  const KnexApp({super.key});

  @override
  ConsumerState<KnexApp> createState() => _KnexAppState();
}

class _KnexAppState extends ConsumerState<KnexApp> {
  bool _loaded = false;

  @override
  Widget build(BuildContext context) {
    // Activate token sync only if Firebase is available.
    if (_firebaseReady) {
      ref.watch(authTokenSyncProvider);
    }

    // Set up persistence once, inside build where ref.listen is allowed.
    if (!_loaded) {
      _loaded = true;
      // Listeners use ref.listen — must be in build.
      setupPersistenceListeners(ref);
      // State mutations must be deferred past the current build frame.
      Future(() {
        final storage = ref.read(storageServiceProvider);
        loadPersistedState(ref, storage);
      });
    }

    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'KNEX',
      debugShowCheckedModeBanner: false,

      // Routing
      routerConfig: _router,

      // Theming
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Localization
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
    );
  }
}
