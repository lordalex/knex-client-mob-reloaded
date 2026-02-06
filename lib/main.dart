import 'dart:developer' as developer;
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/storage_provider.dart';
import 'services/storage_service.dart';

/// Global StorageService instance, initialized before runApp.
final StorageService storageService = StorageService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize SharedPreferences.
  await storageService.init();

  // Initialize Firebase (skip if credentials are still placeholders).
  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  final isPlaceholder = firebaseOptions.apiKey.contains('Placeholder');

  if (isPlaceholder) {
    developer.log(
      'Firebase credentials are placeholders — skipping initialization. '
      'Run `flutterfire configure` to set up real credentials.',
      name: 'main',
    );
  } else {
    try {
      await Firebase.initializeApp(options: firebaseOptions);

      // Forward Flutter framework errors to Crashlytics (non-fatal in debug).
      FlutterError.onError = (details) {
        print('[Crashlytics] Flutter error: ${details.exceptionAsString()}');
        FirebaseCrashlytics.instance.recordFlutterError(details);
      };

      // Forward asynchronous errors to Crashlytics (non-fatal in debug).
      PlatformDispatcher.instance.onError = (error, stack) {
        print('[Crashlytics] Platform error: $error');
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
        return true;
      };
    } catch (e) {
      developer.log(
        'Firebase initialization failed: $e',
        name: 'main',
        error: e,
      );
    }
  }

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const KnexApp(),
    ),
  );
}
