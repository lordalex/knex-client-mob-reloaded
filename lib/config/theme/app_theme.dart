import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Custom [ThemeExtension] that exposes KNEX-specific design tokens
/// not covered by the standard Material [ThemeData].
///
/// Access via `Theme.of(context).extension<KnexThemeExtension>()`.
class KnexThemeExtension extends ThemeExtension<KnexThemeExtension> {
  const KnexThemeExtension({
    required this.info,
    required this.success,
    required this.warning,
    required this.tertiary,
    required this.alternate,
    required this.secondaryBackground,
    required this.primaryText,
    required this.secondaryText,
  });

  final Color info;
  final Color success;
  final Color warning;
  final Color tertiary;
  final Color alternate;
  final Color secondaryBackground;
  final Color primaryText;
  final Color secondaryText;

  @override
  KnexThemeExtension copyWith({
    Color? info,
    Color? success,
    Color? warning,
    Color? tertiary,
    Color? alternate,
    Color? secondaryBackground,
    Color? primaryText,
    Color? secondaryText,
  }) {
    return KnexThemeExtension(
      info: info ?? this.info,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      tertiary: tertiary ?? this.tertiary,
      alternate: alternate ?? this.alternate,
      secondaryBackground: secondaryBackground ?? this.secondaryBackground,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
    );
  }

  @override
  KnexThemeExtension lerp(
    covariant ThemeExtension<KnexThemeExtension>? other,
    double t,
  ) {
    if (other is! KnexThemeExtension) return this;
    return KnexThemeExtension(
      info: Color.lerp(info, other.info, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      tertiary: Color.lerp(tertiary, other.tertiary, t)!,
      alternate: Color.lerp(alternate, other.alternate, t)!,
      secondaryBackground:
          Color.lerp(secondaryBackground, other.secondaryBackground, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
    );
  }
}

/// Central theme configuration for the KNEX app.
///
/// Provides fully configured [ThemeData] instances for both light and dark
/// modes, built on Material 3 with the KNEX brand color palette and typography.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Light Theme
  // ---------------------------------------------------------------------------

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color scheme
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.light.primary,
      onPrimary: Colors.white,
      secondary: AppColors.light.secondary,
      onSecondary: Colors.white,
      tertiary: AppColors.light.tertiary,
      onTertiary: Colors.white,
      error: AppColors.light.error,
      onError: Colors.white,
      surface: AppColors.light.primaryBackground,
      onSurface: AppColors.light.primaryText,
      surfaceContainerHighest: AppColors.light.secondaryBackground,
      outline: AppColors.light.secondaryText,
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.light.primaryBackground,

    // Typography
    textTheme: AppTypography.lightTextTheme,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.light.primaryBackground,
      foregroundColor: AppColors.light.primaryText,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.titleLargeLight,
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.light.primaryBackground,
      selectedItemColor: AppColors.light.primary,
      unselectedItemColor: AppColors.light.secondaryText,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: AppTypography.labelSmallLight.copyWith(
        color: AppColors.light.primary,
      ),
      unselectedLabelStyle: AppTypography.labelSmallLight,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.light.primary,
        foregroundColor: Colors.white,
        textStyle: AppTypography.labelLargeLight.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 2,
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.light.primary,
        side: BorderSide(color: AppColors.light.primary),
        textStyle: AppTypography.labelLargeLight.copyWith(
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.light.primary,
        textStyle: AppTypography.labelLargeLight.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.light.secondaryBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.light.alternate),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.light.alternate),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.light.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.light.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.light.error, width: 2),
      ),
      labelStyle: AppTypography.bodyMediumLight.copyWith(
        color: AppColors.light.secondaryText,
      ),
      hintStyle: AppTypography.bodyMediumLight.copyWith(
        color: AppColors.light.secondaryText,
      ),
      errorStyle: AppTypography.bodySmallLight.copyWith(
        color: AppColors.light.error,
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.light.primaryBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: AppColors.light.alternate,
      thickness: 1,
      space: 1,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.light.primary;
        }
        return AppColors.light.secondaryText;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.light.primary.withValues(alpha: 0.4);
        }
        return AppColors.light.alternate;
      }),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.light.primaryBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: AppTypography.headlineSmallLight,
      contentTextStyle: AppTypography.bodyMediumLight,
    ),

    // Bottom Sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.light.primaryBackground,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
      dragHandleColor: AppColors.light.secondaryText.withValues(alpha: 0.3),
    ),

    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.light.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.light.secondaryBackground,
      selectedColor: AppColors.light.primary.withValues(alpha: 0.15),
      labelStyle: AppTypography.labelMediumLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.light.secondary,
      contentTextStyle: AppTypography.bodyMediumLight.copyWith(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Extensions
    extensions: const <ThemeExtension<dynamic>>[
      KnexThemeExtension(
        info: Color(0xFF2196F3),
        success: Color(0xFF4CAF50),
        warning: Color(0xFFFF9800),
        tertiary: Color(0xFF16213E),
        alternate: Color(0xFFF5F5F5),
        secondaryBackground: Color(0xFFF8F9FA),
        primaryText: Color(0xFF1A1A2E),
        secondaryText: Color(0xFF757575),
      ),
    ],
  );

  // ---------------------------------------------------------------------------
  // Dark Theme
  // ---------------------------------------------------------------------------

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color scheme
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.dark.primary,
      onPrimary: Colors.white,
      secondary: AppColors.dark.secondary,
      onSecondary: Colors.black,
      tertiary: AppColors.dark.tertiary,
      onTertiary: Colors.black,
      error: AppColors.dark.error,
      onError: Colors.white,
      surface: AppColors.dark.primaryBackground,
      onSurface: AppColors.dark.primaryText,
      surfaceContainerHighest: AppColors.dark.secondaryBackground,
      outline: AppColors.dark.secondaryText,
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.dark.primaryBackground,

    // Typography
    textTheme: AppTypography.darkTextTheme,

    // AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.dark.primaryBackground,
      foregroundColor: AppColors.dark.primaryText,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTypography.titleLargeDark,
    ),

    // Bottom Navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.dark.primaryBackground,
      selectedItemColor: AppColors.dark.primary,
      unselectedItemColor: AppColors.dark.secondaryText,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: AppTypography.labelSmallDark.copyWith(
        color: AppColors.dark.primary,
      ),
      unselectedLabelStyle: AppTypography.labelSmallDark,
    ),

    // Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.dark.primary,
        foregroundColor: Colors.white,
        textStyle: AppTypography.labelLargeDark.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 2,
      ),
    ),

    // Outlined Button
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.dark.primary,
        side: BorderSide(color: AppColors.dark.primary),
        textStyle: AppTypography.labelLargeDark.copyWith(
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),

    // Text Button
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.dark.primary,
        textStyle: AppTypography.labelLargeDark.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.dark.secondaryBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.dark.alternate),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.dark.alternate),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.dark.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.dark.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.dark.error, width: 2),
      ),
      labelStyle: AppTypography.bodyMediumDark.copyWith(
        color: AppColors.dark.secondaryText,
      ),
      hintStyle: AppTypography.bodyMediumDark.copyWith(
        color: AppColors.dark.secondaryText,
      ),
      errorStyle: AppTypography.bodySmallDark.copyWith(
        color: AppColors.dark.error,
      ),
    ),

    // Card
    cardTheme: CardThemeData(
      color: AppColors.dark.secondaryBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Divider
    dividerTheme: DividerThemeData(
      color: AppColors.dark.alternate,
      thickness: 1,
      space: 1,
    ),

    // Switch
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.dark.primary;
        }
        return AppColors.dark.secondaryText;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.dark.primary.withValues(alpha: 0.4);
        }
        return AppColors.dark.alternate;
      }),
    ),

    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.dark.secondaryBackground,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      titleTextStyle: AppTypography.headlineSmallDark,
      contentTextStyle: AppTypography.bodyMediumDark,
    ),

    // Bottom Sheet
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.dark.secondaryBackground,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
      dragHandleColor: AppColors.dark.secondaryText.withValues(alpha: 0.3),
    ),

    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.dark.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    // Chip
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.dark.alternate,
      selectedColor: AppColors.dark.primary.withValues(alpha: 0.25),
      labelStyle: AppTypography.labelMediumDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.dark.secondary,
      contentTextStyle: AppTypography.bodyMediumDark.copyWith(
        color: Colors.black,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    // Extensions
    extensions: const <ThemeExtension<dynamic>>[
      KnexThemeExtension(
        info: Color(0xFF2196F3),
        success: Color(0xFF4CAF50),
        warning: Color(0xFFFF9800),
        tertiary: Color(0xFF90CAF9),
        alternate: Color(0xFF2C2C2C),
        secondaryBackground: Color(0xFF1E1E1E),
        primaryText: Color(0xFFFFFFFF),
        secondaryText: Color(0xFFB0B0B0),
      ),
    ],
  );
}
