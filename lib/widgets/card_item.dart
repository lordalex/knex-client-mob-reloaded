import 'package:flutter/material.dart';

/// Placeholder card item widget.
///
/// Will be replaced in Phase 3 with the styled location/site card
/// displaying photo, name, distance, and pricing information.
class CardItem extends StatelessWidget {
  final String? title;
  final VoidCallback? onTap;

  const CardItem({super.key, this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Text(
          title ?? 'Card Item',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
