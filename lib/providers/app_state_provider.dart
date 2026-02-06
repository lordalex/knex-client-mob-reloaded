import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_constants.dart';
import '../models/my_car.dart';

// =============================================================================
// Persisted State Providers
// =============================================================================
// These providers hold values that should be loaded from / saved to
// SharedPreferences. The actual persistence bridge will be wired up when the
// StorageService is integrated in a later phase. For now the providers hold
// sensible defaults and can be updated in-memory.

/// Whether the user has completed profile creation.
final userProfileCreatedProvider = StateProvider<bool>((ref) => false);

/// Whether the user's email address has been validated.
final userEmailValidatedProvider = StateProvider<bool>((ref) => false);

/// IDs of the user's favorite valet sites.
final favoriteSitesProvider =
    StateNotifierProvider<FavoriteSitesNotifier, List<String>>(
  (ref) => FavoriteSitesNotifier(),
);

/// The user's locally-saved vehicle for quick re-use.
final myCarProvider = StateNotifierProvider<MyCarNotifier, MyCar>(
  (ref) => MyCarNotifier(),
);

/// Distance unit preference: 'metric' (km) or 'imperial' (mi).
final distanceUnitProvider = StateProvider<String>((ref) => 'imperial');

/// Whether to sort locations in ascending order.
final sortAscendingProvider = StateProvider<bool>((ref) => false);

/// The field to sort locations by (e.g. 'distance', 'name', 'price').
final sortByProvider = StateProvider<String>((ref) => 'distance');

// =============================================================================
// In-Memory State Providers
// =============================================================================

/// The user's current GPS coordinates as (latitude, longitude).
///
/// Defaults to South Florida coordinates until the device location is obtained.
final userLocationProvider = StateProvider<(double, double)?>(
  (ref) => (AppConstants.defaultLatitude, AppConstants.defaultLongitude),
);

/// Temporary buffer for a base64-encoded profile photo before upload.
final base64PhotoProvider = StateProvider<String>((ref) => '');

/// The user's preferred locale, or null to follow the system locale.
final localeProvider = StateProvider<Locale?>((ref) => null);

// =============================================================================
// Notifiers
// =============================================================================

/// Manages the list of favorite valet site IDs.
class FavoriteSitesNotifier extends StateNotifier<List<String>> {
  FavoriteSitesNotifier() : super([]);

  /// Adds a site ID to favorites.
  void add(String id) {
    if (!state.contains(id)) {
      state = [...state, id];
    }
  }

  /// Removes a site ID from favorites.
  void remove(String id) {
    state = state.where((siteId) => siteId != id).toList();
  }

  /// Toggles a site ID in/out of favorites.
  void toggle(String id) {
    if (isFavorite(id)) {
      remove(id);
    } else {
      add(id);
    }
  }

  /// Whether the given site ID is in the favorites list.
  bool isFavorite(String id) => state.contains(id);

  /// Replaces the entire favorites list (e.g. when loading from storage).
  void setAll(List<String> ids) {
    state = ids;
  }
}

/// Manages the locally-persisted vehicle (MyCar).
class MyCarNotifier extends StateNotifier<MyCar> {
  MyCarNotifier() : super(MyCar.empty());

  /// Sets the saved car to the given [car].
  void setCar(MyCar car) {
    state = car;
  }

  /// Clears the saved car back to an empty state.
  void clear() {
    state = MyCar.empty();
  }
}
