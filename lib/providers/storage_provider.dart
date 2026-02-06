import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/my_car.dart';
import '../services/storage_service.dart';
import 'app_state_provider.dart';
import 'theme_provider.dart';

/// Provides the singleton [StorageService] instance.
///
/// Overridden at app startup in main.dart with the pre-initialized instance.
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

/// Storage key constants for SharedPreferences.
class StorageKeys {
  StorageKeys._();

  static const String profileCreated = 'profile_created';
  static const String emailValidated = 'email_validated';
  static const String favoriteSites = 'favorite_sites';
  static const String myCar = 'my_car';
  static const String distanceUnit = 'distance_unit';
  static const String sortAscending = 'sort_ascending';
  static const String sortBy = 'sort_by';
  static const String locale = 'locale';
  static const String themeMode = 'theme_mode';
}

/// Loads persisted state from SharedPreferences into Riverpod providers.
///
/// Call this once during app startup after [StorageService.init] completes.
void loadPersistedState(WidgetRef ref, StorageService storage) {
  ref.read(userProfileCreatedProvider.notifier).state =
      storage.getBool(StorageKeys.profileCreated);

  ref.read(userEmailValidatedProvider.notifier).state =
      storage.getBool(StorageKeys.emailValidated);

  ref.read(favoriteSitesProvider.notifier).setAll(
    storage.getStringList(StorageKeys.favoriteSites),
  );

  final carJson = storage.getJson(StorageKeys.myCar);
  if (carJson != null) {
    ref.read(myCarProvider.notifier).setCar(MyCar.fromJson(carJson));
  }

  final distUnit = storage.getString(StorageKeys.distanceUnit);
  if (distUnit.isNotEmpty) {
    ref.read(distanceUnitProvider.notifier).state = distUnit;
  }

  ref.read(sortAscendingProvider.notifier).state =
      storage.getBool(StorageKeys.sortAscending);

  final sortByVal = storage.getString(StorageKeys.sortBy);
  if (sortByVal.isNotEmpty) {
    ref.read(sortByProvider.notifier).state = sortByVal;
  }

  final localeCode = storage.getString(StorageKeys.locale);
  if (localeCode.isNotEmpty) {
    ref.read(localeProvider.notifier).state = Locale(localeCode);
  }

  final themeModeStr = storage.getString(StorageKeys.themeMode);
  if (themeModeStr == 'dark') {
    ref.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
  } else if (themeModeStr == 'system') {
    ref.read(themeModeProvider.notifier).setMode(ThemeMode.system);
  }
}

/// Sets up listeners to persist provider state changes to SharedPreferences.
///
/// Should be called once from a root widget that has access to [WidgetRef].
void setupPersistenceListeners(WidgetRef ref) {
  final storage = ref.read(storageServiceProvider);

  ref.listen<bool>(userProfileCreatedProvider, (_, next) {
    storage.setBool(StorageKeys.profileCreated, next);
  });

  ref.listen<bool>(userEmailValidatedProvider, (_, next) {
    storage.setBool(StorageKeys.emailValidated, next);
  });

  ref.listen<List<String>>(favoriteSitesProvider, (_, next) {
    storage.setStringList(StorageKeys.favoriteSites, next);
  });

  ref.listen<MyCar>(myCarProvider, (_, next) {
    storage.setJson(StorageKeys.myCar, next.toJson());
  });

  ref.listen<String>(distanceUnitProvider, (_, next) {
    storage.setString(StorageKeys.distanceUnit, next);
  });

  ref.listen<bool>(sortAscendingProvider, (_, next) {
    storage.setBool(StorageKeys.sortAscending, next);
  });

  ref.listen<String>(sortByProvider, (_, next) {
    storage.setString(StorageKeys.sortBy, next);
  });

  ref.listen<Locale?>(localeProvider, (_, next) {
    storage.setString(StorageKeys.locale, next?.languageCode ?? '');
  });

  ref.listen<ThemeMode>(themeModeProvider, (_, next) {
    final value = switch (next) {
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
      _ => 'light',
    };
    storage.setString(StorageKeys.themeMode, value);
  });
}
