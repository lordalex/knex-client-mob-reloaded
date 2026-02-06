import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/api_provider.dart';
import '../providers/ticket_provider.dart';
import '../services/api/endpoints.dart';
import '../widgets/app_button.dart';

/// Bottom sheet for tipping the valet after service completion.
///
/// Shows preset tip amounts and a custom input option. Submits the tip
/// via the setTicketTip API endpoint.
class TipBottomSheet extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const TipBottomSheet({super.key, this.onClose});

  /// Shows the tip bottom sheet as a modal.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const TipBottomSheet(),
    );
  }

  @override
  ConsumerState<TipBottomSheet> createState() => _TipBottomSheetState();
}

class _TipBottomSheetState extends ConsumerState<TipBottomSheet> {
  double? _selectedTip;
  final _customController = TextEditingController();
  bool _isLoading = false;
  bool _useCustom = false;

  static const _presets = [3.0, 5.0, 10.0, 20.0];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _submitTip() async {
    final amount = _useCustom
        ? double.tryParse(_customController.text) ?? 0
        : _selectedTip ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter a tip amount.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final ticket = ref.read(activeTicketProvider);
    if (ticket == null) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      await ref.read(apiClientProvider).post(
        Endpoints.setTicketTip,
        data: {'id': ticket.id, 'tip': amount},
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tip of \$${amount.toStringAsFixed(2)} sent!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send tip: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Tip Your Valet',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Show your appreciation!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Preset amounts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _presets.map((amount) {
              final isSelected = !_useCustom && _selectedTip == amount;
              return ChoiceChip(
                label: Text('\$${amount.toStringAsFixed(0)}'),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedTip = amount;
                    _useCustom = false;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Custom amount
          Row(
            children: [
              ChoiceChip(
                label: const Text('Custom'),
                selected: _useCustom,
                onSelected: (_) => setState(() => _useCustom = true),
              ),
              if (_useCustom) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _customController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      prefixText: '\$ ',
                      hintText: '0.00',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 24),

          AppButton(
            label: 'Send Tip',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _submitTip,
            width: double.infinity,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onClose ?? () => Navigator.pop(context),
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
