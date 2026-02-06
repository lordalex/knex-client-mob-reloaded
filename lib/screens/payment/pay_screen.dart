import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/ticket_provider.dart';
import '../../services/stripe_service.dart';
import '../../widgets/app_button.dart';

/// Payment screen for completing a valet parking payment via Stripe.
///
/// Displays the ticket price and initiates the Stripe payment sheet.
/// On success, navigates to the ticket completed screen.
class PayScreen extends ConsumerStatefulWidget {
  const PayScreen({super.key});

  @override
  ConsumerState<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends ConsumerState<PayScreen> {
  final _stripeService = StripeService();
  bool _isProcessing = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initStripe();
  }

  Future<void> _initStripe() async {
    await _stripeService.initialize();
    if (mounted) setState(() => _initialized = true);
  }

  Future<void> _processPayment() async {
    final ticket = ref.read(activeTicketProvider);
    if (ticket == null) return;

    setState(() => _isProcessing = true);

    try {
      final paymentIntentId = await _stripeService.processPayment(
        amount: 500, // Default $5.00 in cents; real amount from ticket/location
        currency: 'usd',
        ticketId: ticket.id ?? '',
      );

      if (!mounted) return;

      if (paymentIntentId != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful!')),
        );
        context.go('/ticketCompleted');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment cancelled or failed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = ref.watch(activeTicketProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.payment,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Valet Parking Payment',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (ticket != null) ...[
                      if (ticket.ticketNumber != null)
                        Text(
                          'Ticket #${ticket.ticketNumber}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Text(
                        'Location: ${ticket.locationId}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Spacer(),
            AppButton(
              label: 'Pay Now',
              icon: Icons.credit_card,
              isLoading: _isProcessing || !_initialized,
              onPressed: (_isProcessing || !_initialized) ? null : _processPayment,
              width: double.infinity,
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Cancel',
              isOutlined: true,
              onPressed: () => context.pop(),
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
