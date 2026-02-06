import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/shell/nav_shell.dart';
import '../../screens/login/login_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile_create/profile_create_screen.dart';
import '../../screens/site_details/site_details_screen.dart';
import '../../screens/add_cars/add_cars_screen.dart';
import '../../screens/ticket/ticket_screen.dart';
import '../../screens/ticket/ticket_timer_screen.dart';
import '../../screens/ticket/ticket_completed_screen.dart';
import '../../screens/payment/pay_screen.dart';
import '../../screens/payment/add_credit_card_screen.dart';
import '../../screens/favorites/favorites_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/settings/list_config_screen.dart';
import '../../screens/settings/change_language_screen.dart';

/// Global navigator key for accessing the navigator from outside the widget tree.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// A [ChangeNotifier] that triggers GoRouter redirect evaluation whenever
/// the provided [stream] emits a new value.
///
/// Used to refresh the router when Firebase auth state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Creates the app-wide [GoRouter] instance.
///
/// The router uses a [StatefulShellRoute.indexedStack] to maintain the state
/// of the Home and Profile tab branches independently. All other screens are
/// top-level routes that push over the shell (using the root navigator).
///
/// Initial location is `/splash`. Auth redirects handle navigation:
/// - `/splash` -> `/home` (authenticated) or `/login` (not authenticated)
/// - Unauthenticated + not on `/login` -> redirect to `/login`
/// - Authenticated + on `/login` -> redirect to `/home`
/// Whether Firebase has been successfully initialized.
bool get _firebaseInitialized {
  try {
    Firebase.app();
    return true;
  } catch (_) {
    return false;
  }
}

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    refreshListenable: _firebaseInitialized
        ? GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges())
        : null,
    redirect: (context, state) {
      final isLoggedIn = _firebaseInitialized &&
          FirebaseAuth.instance.currentUser != null;
      final location = state.matchedLocation;
      final isOnSplash = location == '/splash';
      final isOnLogin = location == '/login';

      // Splash screen: decide where to go based on auth state.
      if (isOnSplash) {
        return isLoggedIn ? '/home' : '/login';
      }

      // Not authenticated and not on login -> go to login.
      if (!isLoggedIn && !isOnLogin) return '/login';

      // Authenticated and still on login -> go to home.
      if (isLoggedIn && isOnLogin) return '/home';

      // No redirect needed.
      return null;
    },
    routes: [
      // Splash (shown during auth check)
      GoRoute(
        path: '/splash',
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login (outside the shell -- no bottom nav)
      GoRoute(
        path: '/login',
        name: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // Main shell with bottom navigation (Home + Profile tabs)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            NavShell(navigationShell: navigationShell),
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 1: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Profile creation (outside the shell -- fullscreen flow)
      GoRoute(
        path: '/profileCreate',
        name: RouteNames.profileCreate,
        builder: (context, state) => const ProfileCreateScreen(),
      ),

      // Site details
      GoRoute(
        path: '/siteDetails',
        name: RouteNames.siteDetails,
        builder: (context, state) {
          final siteId = state.uri.queryParameters['id'] ?? '';
          return SiteDetailsScreen(siteId: siteId);
        },
      ),

      // Add cars
      GoRoute(
        path: '/addCars',
        name: RouteNames.addCars,
        builder: (context, state) {
          final siteId = state.uri.queryParameters['id'] ?? '';
          return AddCarsScreen(siteId: siteId);
        },
      ),

      // Ticket flow
      GoRoute(
        path: '/ticket',
        name: RouteNames.ticket,
        builder: (context, state) => const TicketScreen(),
      ),
      GoRoute(
        path: '/ticketTimer',
        name: RouteNames.ticketTimer,
        builder: (context, state) => const TicketTimerScreen(),
      ),
      GoRoute(
        path: '/ticketCompleted',
        name: RouteNames.ticketCompleted,
        builder: (context, state) => const TicketCompletedScreen(),
      ),

      // Payment
      GoRoute(
        path: '/pay',
        name: RouteNames.pay,
        builder: (context, state) => const PayScreen(),
      ),
      GoRoute(
        path: '/addCreditCard',
        name: RouteNames.addCreditCard,
        builder: (context, state) => const AddCreditCardScreen(),
      ),

      // Favorites & History
      GoRoute(
        path: '/favorites',
        name: RouteNames.favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/history',
        name: RouteNames.history,
        builder: (context, state) => const HistoryScreen(),
      ),

      // Settings
      GoRoute(
        path: '/listConfig',
        name: RouteNames.listConfig,
        builder: (context, state) => const ListConfigScreen(),
      ),
      GoRoute(
        path: '/changeLanguage',
        name: RouteNames.changeLanguage,
        builder: (context, state) => const ChangeLanguageScreen(),
      ),
    ],
  );
}
