import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the current [ThemeMode] (light, dark, or system).
///
/// Used by `MaterialApp.router` to switch between light and dark themes.
/// The user's preference can be toggled from the Profile screen.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

/// Notifier that manages the app's theme mode.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light);

  /// Toggles between light and dark mode.
  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  /// Sets the theme mode to a specific value.
  void setMode(ThemeMode mode) {
    state = mode;
  }

  /// Whether the current mode is dark.
  bool get isDark => state == ThemeMode.dark;
}
