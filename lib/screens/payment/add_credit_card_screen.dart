import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_button.dart';

/// Screen for adding a new payment method via Stripe's card form.
///
/// Uses Stripe's built-in CardFormField widget for PCI-compliant card entry.
/// On success, pops back with the payment method token.
class AddCreditCardScreen extends StatefulWidget {
  const AddCreditCardScreen({super.key});

  @override
  State<AddCreditCardScreen> createState() => _AddCreditCardScreenState();
}

class _AddCreditCardScreenState extends State<AddCreditCardScreen> {
  final CardFormEditController _controller = CardFormEditController();
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _saveCard() async {
    if (!(_controller.details.complete)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all card fields.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Card added successfully!')),
      );
      context.pop(paymentMethod.id);
    } on StripeException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.error.localizedMessage ?? 'Card error')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Card')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter your card details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            CardFormField(
              controller: _controller,
              style: CardFormStyle(
                borderColor: theme.colorScheme.outline,
                borderRadius: 8,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            AppButton(
              label: 'Save Card',
              icon: Icons.save,
              isLoading: _isSaving,
              onPressed: _isSaving ? null : _saveCard,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }
}
