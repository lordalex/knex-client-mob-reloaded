import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// KNEX typography scale built on Material 3 type levels.
///
/// - Display, headline, and title styles use **Inter Tight** (a narrower,
///   more impactful variant suited for large headings).
/// - Body and label styles use **Inter** (the standard reading face).
///
/// Each scale level exposes both a light-theme and dark-theme variant that
/// differ only in their default text color. Callers may override the color
/// at the call site when needed.
class AppTypography {
  AppTypography._();

  // ---------------------------------------------------------------------------
  // Light Theme Text Styles
  // ---------------------------------------------------------------------------

  static TextStyle get displayLargeLight => GoogleFonts.interTight(
        fontSize: 57.0,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
        color: AppColors.light.primaryText,
      );

  static TextStyle get displayMediumLight => GoogleFonts.interTight(
        fontSize: 45.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 1.16,
        color: AppColors.light.primaryText,
      );

  static TextStyle get displaySmallLight => GoogleFonts.interTight(
        fontSize: 36.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 1.22,
        color: AppColors.light.primaryText,
      );

  static TextStyle get headlineLargeLight => GoogleFonts.interTight(
        fontSize: 32.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        height: 1.25,
        color: AppColors.light.primaryText,
      );

  static TextStyle get headlineMediumLight => GoogleFonts.interTight(
        fontSize: 28.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        height: 1.29,
        color: AppColors.light.primaryText,
      );

  static TextStyle get headlineSmallLight => GoogleFonts.interTight(
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        height: 1.33,
        color: AppColors.light.primaryText,
      );

  static TextStyle get titleLargeLight => GoogleFonts.interTight(
        fontSize: 22.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.0,
        height: 1.27,
        color: AppColors.light.primaryText,
      );

  static TextStyle get titleMediumLight => GoogleFonts.interTight(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.50,
        color: AppColors.light.primaryText,
      );

  static TextStyle get titleSmallLight => GoogleFonts.interTight(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: AppColors.light.primaryText,
      );

  static TextStyle get bodyLargeLight => GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50,
        color: AppColors.light.primaryText,
      );

  static TextStyle get bodyMediumLight => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: AppColors.light.primaryText,
      );

  static TextStyle get bodySmallLight => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: AppColors.light.secondaryText,
      );

  static TextStyle get labelLargeLight => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: AppColors.light.primaryText,
      );

  static TextStyle get labelMediumLight => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
        color: AppColors.light.primaryText,
      );

  static TextStyle get labelSmallLight => GoogleFonts.inter(
        fontSize: 11.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
        color: AppColors.light.secondaryText,
      );

  // ---------------------------------------------------------------------------
  // Dark Theme Text Styles
  // ---------------------------------------------------------------------------

  static TextStyle get displayLargeDark => GoogleFonts.interTight(
        fontSize: 57.0,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
        color: AppColors.dark.primaryText,
      );

  static TextStyle get displayMediumDark => GoogleFonts.interTight(
        fontSize: 45.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 1.16,
        color: AppColors.dark.primaryText,
      );

  static TextStyle get displaySmallDark => GoogleFonts.interTight(
        fontSize: 36.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        height: 1.22,
        color: AppColors.dark.primaryText,
      );

  static TextStyle get headlineLargeDark => GoogleFonts.interTight(
        fontSize: 32.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        height: 1.25,
        color: AppColors.dark.primaryText,
      );

  static TextStyle get headlineMediumDark => GoogleFonts.interTight(
        fontSize: 28.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        height: 1.29,
        color: AppColors.dark.primaryText,
      );

  static TextStyle get headlineSmallDark => GoogleFonts.interTight(
        fontSize: 24.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
        height: 1.33,
        color: AppColors.dark.primaryText,
      );

  static TextStyle get titleLargeDark => GoogleFonts.interTight(
        fontSize: 22.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.0,
        height: 1.27,
        color: AppColors.dark.primaryText,
      );

  static TextStyle get titleMediumDark => GoogleFonts.interTight(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.15,
        height: 1.50,
        color: AppColors.dark.primaryText,
      );

  static TextStyle get titleSmallDark => GoogleFonts.interTight(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: AppColors.dark.primaryText,
      );

  static TextStyle get bodyLargeDark => GoogleFonts.inter(
        fontSize: 16.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        height: 1.50,
        color: AppColors.dark.primaryText,
      );

  static TextStyle get bodyMediumDark => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
        color: AppColors.dark.primaryText,
      );

  static TextStyle get bodySmallDark => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
        color: AppColors.dark.secondaryText,
      );

  static TextStyle get labelLargeDark => GoogleFonts.inter(
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.43,
        color: AppColors.dark.primaryText,
      );

  static TextStyle get labelMediumDark => GoogleFonts.inter(
        fontSize: 12.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
        color: AppColors.dark.primaryText,
      );

  static TextStyle get labelSmallDark => GoogleFonts.inter(
        fontSize: 11.0,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
        color: AppColors.dark.secondaryText,
      );

  // ---------------------------------------------------------------------------
  // Convenience: Full TextTheme builders
  // ---------------------------------------------------------------------------

  /// Builds a complete [TextTheme] for the light theme.
  static TextTheme get lightTextTheme => TextTheme(
        displayLarge: displayLargeLight,
        displayMedium: displayMediumLight,
        displaySmall: displaySmallLight,
        headlineLarge: headlineLargeLight,
        headlineMedium: headlineMediumLight,
        headlineSmall: headlineSmallLight,
        titleLarge: titleLargeLight,
        titleMedium: titleMediumLight,
        titleSmall: titleSmallLight,
        bodyLarge: bodyLargeLight,
        bodyMedium: bodyMediumLight,
        bodySmall: bodySmallLight,
        labelLarge: labelLargeLight,
        labelMedium: labelMediumLight,
        labelSmall: labelSmallLight,
      );

  /// Builds a complete [TextTheme] for the dark theme.
  static TextTheme get darkTextTheme => TextTheme(
        displayLarge: displayLargeDark,
        displayMedium: displayMediumDark,
        displaySmall: displaySmallDark,
        headlineLarge: headlineLargeDark,
        headlineMedium: headlineMediumDark,
        headlineSmall: headlineSmallDark,
        titleLarge: titleLargeDark,
        titleMedium: titleMediumDark,
        titleSmall: titleSmallDark,
        bodyLarge: bodyLargeDark,
        bodyMedium: bodyMediumDark,
        bodySmall: bodySmallDark,
        labelLarge: labelLargeDark,
        labelMedium: labelMediumDark,
        labelSmall: labelSmallDark,
      );
}
