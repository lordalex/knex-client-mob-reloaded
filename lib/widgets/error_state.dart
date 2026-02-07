import 'package:flutter/material.dart';

import '../config/asset_paths.dart';

/// A standardized error state widget for displaying failures with retry actions.
///
/// Supports a primary retry action and an optional secondary action. The [compact]
/// mode reduces padding for use in smaller containers like list items.
class ErrorStateWidget extends StatelessWidget {
  /// The error title displayed prominently.
  final String title;

  /// A descriptive message explaining what went wrong.
  final String message;

  /// Callback for the primary retry action button.
  final VoidCallback? onRetry;

  /// Optional callback for a secondary action (e.g., "Go Back", "Contact Support").
  final VoidCallback? onSecondaryAction;

  /// Label for the secondary action button.
  final String? secondaryLabel;

  /// When true, uses reduced padding suitable for inline/embedded usage.
  final bool compact;

  const ErrorStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.onRetry,
    this.onSecondaryAction,
    this.secondaryLabel,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = compact
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 12)
        : const EdgeInsets.symmetric(horizontal: 32, vertical: 24);

    return Center(
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!compact)
              Opacity(
                opacity: 0.15,
                child: Image.asset(
                  AssetPaths.knexLogo,
                  width: 80,
                  height: 80,
                ),
              ),
            if (!compact) const SizedBox(height: 16),
            Icon(
              Icons.error_outline,
              size: compact ? 40 : 48,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: compact ? 8 : 16),
            Text(
              title,
              style: compact
                  ? theme.textTheme.titleSmall
                  : theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: compact ? 12 : 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
            if (onSecondaryAction != null && secondaryLabel != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(secondaryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
