import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/app_constants.dart';
import '../config/theme/app_colors.dart';
import '../providers/api_provider.dart';
import '../providers/ticket_provider.dart';
import '../services/api/endpoints.dart';

/// Bottom sheet for tipping the valet after service completion.
///
/// Shows preset tip amounts with USD prefix and a custom input option.
/// Submits the tip via the setTicketTip API endpoint.
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

  static const _presets = AppConstants.tipPresets;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  double get _currentAmount {
    if (_useCustom) {
      return double.tryParse(_customController.text) ?? 0;
    }
    return _selectedTip ?? 0;
  }

  Future<void> _submitTip() async {
    final amount = _currentAmount;

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
        Navigator.pop(context); // dismiss bottom sheet
        ref.read(activeTicketProvider.notifier).state = null;
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tip of \$${amount.toStringAsFixed(2)} sent!')),
          );
          context.go('/home');
        }
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
    final amount = _currentAmount;

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
            'Tip Amount',
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

          // Preset amounts with USD prefix
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _presets.map((tipAmount) {
              final isSelected = !_useCustom && _selectedTip == tipAmount;
              return ChoiceChip(
                label: Text('USD ${tipAmount.toStringAsFixed(0)}'),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedTip = tipAmount;
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
                    onChanged: (_) => setState(() {}),
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
          const SizedBox(height: 16),

          // Total Amount row
          if (amount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '\$${amount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // Add Tip button — dark navy
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitTip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.light.secondary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Add Tip'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onClose ?? () {
              Navigator.pop(context);
              ref.read(activeTicketProvider.notifier).state = null;
              context.go('/home');
            },
            child: const Text('Skip'),
          ),
        ],
      ),
    );
  }
}
