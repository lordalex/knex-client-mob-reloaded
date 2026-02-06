import 'package:flutter/material.dart';

/// Convenience extensions on [String].
extension StringExtension on String {
  /// Capitalizes the first character of the string.
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Returns `true` if this string is a well-formed email address.
  bool get isValidEmail =>
      RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(this);
}

/// Convenience extensions on [BuildContext] for quick access to theme
/// and media query properties without verbose boilerplate.
extension ContextExtension on BuildContext {
  /// Shorthand for `Theme.of(this)`.
  ThemeData get theme => Theme.of(this);

  /// Shorthand for `Theme.of(this).textTheme`.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Shorthand for `Theme.of(this).colorScheme`.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Shorthand for `MediaQuery.of(this).size`.
  Size get screenSize => MediaQuery.of(this).size;

  /// Returns `true` if the shortest side of the screen is >= 600 logical pixels,
  /// which is a common heuristic for tablet-class devices.
  bool get isTablet => MediaQuery.of(this).size.shortestSide >= 600;
}
