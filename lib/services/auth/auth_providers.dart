import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/api_provider.dart';
import 'auth_service.dart';

/// Provides a singleton [AuthService] instance to the widget tree.
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Stream provider that emits auth state changes (sign-in / sign-out).
///
/// Consumers can watch this to reactively respond to authentication events,
/// e.g. redirecting to the login screen on sign-out.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

/// Stream provider that emits on ID token changes (token refresh events).
final idTokenStreamProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).idTokenChanges;
});

/// Holds the current Firebase JWT token.
///
/// Updated by [authTokenSyncProvider] when the token changes. The token
/// is injected into API requests via [AuthInterceptor].
final authTokenProvider = StateProvider<String?>((ref) => null);

/// Synchronizes the Firebase ID token with [authTokenProvider] and [ApiClient].
///
/// Watch this provider from the root widget to keep the token in sync
/// for the lifetime of the app.
final authTokenSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<User?>>(idTokenStreamProvider, (previous, next) {
    next.when(
      data: (user) async {
        if (user != null) {
          final token = await user.getIdToken();
          ref.read(authTokenProvider.notifier).state = token;
          ref.read(apiClientProvider).setAuthToken(token);
          developer.log('Auth token synced', name: 'AuthProviders');
        } else {
          ref.read(authTokenProvider.notifier).state = null;
          ref.read(apiClientProvider).setAuthToken(null);
          developer.log('Auth token cleared', name: 'AuthProviders');
        }
      },
      loading: () {},
      error: (e, _) {
        developer.log('Token sync error: $e', name: 'AuthProviders');
      },
    );
  });
});

/// The currently authenticated Firebase user, or null.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Whether the user is currently authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
