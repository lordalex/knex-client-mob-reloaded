import 'package:flutter/material.dart';

/// A versatile button widget used throughout the KNEX app.
///
/// Supports primary (elevated) and outlined variants, loading state with
/// a spinner, and an optional leading icon. Disables interaction while loading.
class AppButton extends StatelessWidget {
  /// The button label text.
  final String label;

  /// Callback when the button is pressed. Ignored while [isLoading] is true.
  final VoidCallback? onPressed;

  /// Whether to show a loading spinner instead of the label.
  final bool isLoading;

  /// Optional leading icon displayed before the label.
  final IconData? icon;

  /// When true, renders as an [OutlinedButton] instead of [ElevatedButton].
  final bool isOutlined;

  /// Optional explicit width. If null, the button sizes to its content.
  final double? width;

  /// Optional explicit height. Defaults to 48.
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isOutlined = false,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              color: isOutlined
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onPrimary,
            ),
          )
        : _buildLabelWithIcon();

    final style = _buttonStyle(context);

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: style,
            child: child,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: style,
            child: child,
          );

    if (width != null) {
      return SizedBox(width: width, height: height, child: button);
    }
    return SizedBox(height: height, child: button);
  }

  Widget _buildLabelWithIcon() {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }
    return Text(label);
  }

  ButtonStyle _buttonStyle(BuildContext context) {
    return ButtonStyle(
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
