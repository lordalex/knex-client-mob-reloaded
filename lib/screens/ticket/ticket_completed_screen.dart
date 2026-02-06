import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ticket_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/success_ticket.dart';
import '../../widgets/tip_bottom_sheet.dart';

/// Ticket completion screen showing summary and tip prompt.
///
/// Displays a success animation, ticket summary, and offers the user
/// a chance to tip the valet before returning to the home screen.
class TicketCompletedScreen extends ConsumerWidget {
  const TicketCompletedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticket = ref.watch(activeTicketProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Complete'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SuccessTicket(message: 'Valet service completed!'),
            const SizedBox(height: 24),

            if (ticket != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (ticket.ticketNumber != null)
                        _infoRow(context, 'Ticket #', ticket.ticketNumber!),
                      _infoRow(context, 'Status', 'Completed'),
                      if (ticket.createdAt != null)
                        _infoRow(context, 'Started',
                            _formatDateTime(ticket.createdAt!)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Tip button
            AppButton(
              label: 'Tip Your Valet',
              icon: Icons.attach_money,
              onPressed: () => TipBottomSheet.show(context),
            ),
            const SizedBox(height: 12),

            // Go home button
            AppButton(
              label: 'Back to Home',
              isOutlined: true,
              onPressed: () {
                ref.read(activeTicketProvider.notifier).state = null;
                context.go('/home');
              },
            ),
            const SizedBox(height: 16),

            Text(
              'Thank you for using KNEX!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          )),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.month}/${dt.day} ${hour == 0 ? 12 : hour}:${dt.minute.toString().padLeft(2, '0')} $period';
  }
}
