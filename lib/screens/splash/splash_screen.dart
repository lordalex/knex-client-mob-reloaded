import 'package:flutter/material.dart';

import '../../config/asset_paths.dart';
import '../../config/theme/app_colors.dart';
import '../../widgets/loading_indicator.dart';

/// Full-screen splash displayed on app startup while Firebase initializes
/// and the [FlowManager] determines the user's destination route.
///
/// Navigation is handled entirely by GoRouter redirects -- this widget
/// contains no navigation logic itself.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light.secondary, // dark navy (#1A1A2E)
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AssetPaths.knexLogoWhite,
              width: 120,
              height: 120,
            ),
            const SizedBox(height: 32),
            const LoadingIndicator(size: 40, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
