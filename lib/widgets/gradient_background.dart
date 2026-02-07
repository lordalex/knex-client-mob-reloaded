import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/theme/app_colors.dart';

/// Reusable dark gradient background used across ticket/timer/completed screens.
///
/// Gradient flows from dark navy (#1A1A2E) to deep purple (#2D1B69).
/// Sets light status bar icons automatically.
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  /// The deep purple endpoint of the gradient.
  static const Color deepPurple = Color(0xFF2D1B69);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.light.secondary, deepPurple],
          ),
        ),
        child: child,
      ),
    );
  }
}
