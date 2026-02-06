import 'package:flutter/material.dart';

/// Placeholder success ticket widget.
///
/// Will be replaced in Phase 4 (Valet Service) with the animated
/// success confirmation card shown after a ticket is created or
/// a payment is completed.
class SuccessTicket extends StatelessWidget {
  final String? message;

  const SuccessTicket({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            message ?? 'Success!',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
