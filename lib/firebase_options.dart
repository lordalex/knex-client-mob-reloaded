import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

/// Firebase configuration for the KNEX client app (project: knex-client24).
class DefaultFirebaseOptions {
  /// Returns the [FirebaseOptions] appropriate for the current platform.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for '
          '${defaultTargetPlatform.name}. '
          'Run `flutterfire configure` to generate platform-specific options.',
        );
    }
  }

  // ---------------------------------------------------------------------------
  // iOS
  // ---------------------------------------------------------------------------

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB1ZBWOw3nYzUSLXYdIegP6r3JRrGo2cwk',
    appId: '1:1045566810040:ios:4b3a4cd901fd282b28514d',
    messagingSenderId: '1045566810040',
    projectId: 'knex-client24',
    storageBucket: 'knex-client24.appspot.com',
    iosBundleId: 'co.lordalexand.knex',
  );

  // ---------------------------------------------------------------------------
  // Android
  // ---------------------------------------------------------------------------

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAOvqV-PPTzZTGvJq8ZBJn1QNmJdFg4Wa4',
    appId: '1:1045566810040:android:e122d66a3854838628514d',
    messagingSenderId: '1045566810040',
    projectId: 'knex-client24',
    storageBucket: 'knex-client24.appspot.com',
  );

  // ---------------------------------------------------------------------------
  // Web (placeholder — run `flutterfire configure` for real web credentials)
  // ---------------------------------------------------------------------------

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyPlaceholder',
    appId: '1:1045566810040:web:5e2c46c1cec3256028514d',
    messagingSenderId: '1045566810040',
    projectId: 'knex-client24',
    authDomain: 'knex-client24.firebaseapp.com',
    storageBucket: 'knex-client24.appspot.com',
  );

  // ---------------------------------------------------------------------------
  // macOS (shares iOS config)
  // ---------------------------------------------------------------------------

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB1ZBWOw3nYzUSLXYdIegP6r3JRrGo2cwk',
    appId: '1:1045566810040:ios:4b3a4cd901fd282b28514d',
    messagingSenderId: '1045566810040',
    projectId: 'knex-client24',
    storageBucket: 'knex-client24.appspot.com',
    iosBundleId: 'co.lordalexand.knex',
  );
}
