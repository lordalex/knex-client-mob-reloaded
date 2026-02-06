import 'package:flutter/material.dart';

/// A centered circular progress indicator styled with the app's primary color.
///
/// Use this as a standard loading state throughout the app to maintain
/// visual consistency.
class LoadingIndicator extends StatelessWidget {
  /// Optional size constraint for the indicator.
  final double? size;

  /// Optional custom color override. Defaults to the theme's primary color.
  final Color? color;

  const LoadingIndicator({super.key, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      color: color ?? Theme.of(context).colorScheme.primary,
      strokeWidth: 3.0,
    );

    return Center(
      child: size != null
          ? SizedBox(width: size, height: size, child: indicator)
          : indicator,
    );
  }
}
