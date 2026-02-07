import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/asset_paths.dart';
import '../../config/theme/app_colors.dart';
import '../../providers/ticket_provider.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/tip_bottom_sheet.dart';

/// Ticket completion screen with gradient background, animated checkmark,
/// ticket summary, tip prompt, and branded footer.
class TicketCompletedScreen extends ConsumerWidget {
  const TicketCompletedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticket = ref.watch(activeTicketProvider);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 32),

              // Animated checkmark
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 72,
                  color: Colors.white,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.4, 0.4),
                    end: const Offset(1.0, 1.0),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms),
              const SizedBox(height: 20),

              // Heading
              const Text(
                'Service Complete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: 8),
              Text(
                'Your valet service is finished',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 28),

              // Info card
              if (ticket != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (ticket.ticketNumber != null)
                        _infoRow('Ticket #', ticket.ticketNumber!),
                      _infoRow('Status', 'Completed'),
                      if (ticket.createdAt != null)
                        _infoRow('Started', _formatDateTime(ticket.createdAt!)),
                      if (ticket.pin != null)
                        _infoRow('PIN', ticket.pin!),
                    ],
                  ),
                ).animate().slideY(
                  begin: 0.15,
                  delay: 400.ms,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                ).fadeIn(delay: 400.ms, duration: 400.ms),

              const Spacer(),

              // Tip button — gold accent
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => TipBottomSheet.show(context),
                    icon: const Icon(Icons.attach_money),
                    label: const Text('Tip Your Valet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      foregroundColor: AppColors.light.secondary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Back to Home button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(activeTicketProvider.notifier).state = null;
                      context.go('/home');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Footer
              Text(
                'Thank you for using KNEX!',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Image.asset(
                AssetPaths.knexLogoWhite,
                height: 28,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
              SizedBox(height: bottomPadding + 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.light.secondaryText,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.light.secondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
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
