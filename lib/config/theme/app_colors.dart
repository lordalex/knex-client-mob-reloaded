import 'package:flutter/material.dart';

/// KNEX brand color tokens for light and dark themes.
///
/// Each theme variant is exposed as a named constant instance with all
/// twelve semantic color slots populated.
///
/// Usage:
/// ```dart
/// AppColors.light.primary   // #E21C3D in light mode
/// AppColors.dark.primary    // #E21C3D in dark mode
/// ```
class AppColors {
  const AppColors._({
    required this.primary,
    required this.secondary,
    required this.tertiary,
    required this.alternate,
    required this.primaryText,
    required this.secondaryText,
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.info,
    required this.success,
    required this.warning,
    required this.error,
  });

  // ---------------------------------------------------------------------------
  // Theme Instances
  // ---------------------------------------------------------------------------

  /// Light theme color palette.
  static const AppColors light = AppColors._(
    primary: Color(0xFFE21C3D),
    secondary: Color(0xFF1A1A2E),
    tertiary: Color(0xFF16213E),
    alternate: Color(0xFFF5F5F5),
    primaryText: Color(0xFF1A1A2E),
    secondaryText: Color(0xFF757575),
    primaryBackground: Color(0xFFFFFFFF),
    secondaryBackground: Color(0xFFF8F9FA),
    info: Color(0xFF2196F3),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    error: Color(0xFFF44336),
  );

  /// Dark theme color palette.
  static const AppColors dark = AppColors._(
    primary: Color(0xFFE21C3D),
    secondary: Color(0xFFE0E0E0),
    tertiary: Color(0xFF90CAF9),
    alternate: Color(0xFF2C2C2C),
    primaryText: Color(0xFFFFFFFF),
    secondaryText: Color(0xFFB0B0B0),
    primaryBackground: Color(0xFF121212),
    secondaryBackground: Color(0xFF1E1E1E),
    info: Color(0xFF2196F3),
    success: Color(0xFF4CAF50),
    warning: Color(0xFFFF9800),
    error: Color(0xFFF44336),
  );

  // ---------------------------------------------------------------------------
  // Token Fields
  // ---------------------------------------------------------------------------

  /// Main KNEX brand color (red).
  final Color primary;

  /// Secondary brand color.
  final Color secondary;

  /// Tertiary accent color.
  final Color tertiary;

  /// Alternative/surface background for cards and sections.
  final Color alternate;

  /// Primary text color.
  final Color primaryText;

  /// Muted / secondary text color.
  final Color secondaryText;

  /// Main scaffold background.
  final Color primaryBackground;

  /// Secondary background for cards and surfaces.
  final Color secondaryBackground;

  /// Informational state color.
  final Color info;

  /// Success state color.
  final Color success;

  /// Warning state color.
  final Color warning;

  /// Error / destructive state color.
  final Color error;
}
