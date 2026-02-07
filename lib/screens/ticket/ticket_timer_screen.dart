import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../config/app_constants.dart';
import '../../config/asset_paths.dart';
import '../../models/ticket.dart';
import '../../providers/api_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../services/api/endpoints.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/loading_indicator.dart';

/// Live timer screen showing elapsed parking duration.
///
/// Full-screen gradient background, glowing circular timer, branded footer.
/// Polls the backend for status changes and navigates to completed screen.
class TicketTimerScreen extends ConsumerStatefulWidget {
  const TicketTimerScreen({super.key});

  @override
  ConsumerState<TicketTimerScreen> createState() => _TicketTimerScreenState();
}

class _TicketTimerScreenState extends ConsumerState<TicketTimerScreen> {
  Timer? _uiTimer;
  Timer? _pollTimer;
  Duration _elapsed = Duration.zero;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    final ticket = ref.read(activeTicketProvider);
    _startTime = ticket?.createdAt ?? DateTime.now();

    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(_startTime!);
        });
      }
    });

    _pollTimer = Timer.periodic(
      const Duration(seconds: AppConstants.ticketPollIntervalSeconds),
      (_) => _pollTicket(),
    );
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _pollTicket() async {
    final profile = ref.read(userProfileProvider);
    if (profile?.id == null) return;

    try {
      final response = await ref.read(apiClientProvider).post<Ticket>(
        Endpoints.getLatestTicket,
        data: {'userClientId': profile!.id},
        fromData: (json) => Ticket.fromJson(json as Map<String, dynamic>),
      );

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        final ticket = response.data!;
        ref.read(activeTicketProvider.notifier).state = ticket;

        if (ticket.status == Ticket.statusCompleted) {
          _pollTimer?.cancel();
          _uiTimer?.cancel();
          context.go('/ticketCompleted');
        } else if (ticket.status == Ticket.statusCancelled) {
          _pollTimer?.cancel();
          _uiTimer?.cancel();
          context.go('/home');
        }
      }
    } catch (e) {
      developer.log('Timer poll error: $e', name: 'TicketTimerScreen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = ref.watch(activeTicketProvider);

    if (ticket == null) {
      return const Scaffold(body: LoadingIndicator());
    }

    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes.remainder(60);
    final seconds = _elapsed.inSeconds.remainder(60);
    final timeStr = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    // Cap progress at 1.0 for visual (2 hours = full circle)
    final progress = (_elapsed.inMinutes / 120).clamp(0.0, 1.0);

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 24),

              // Title
              const Text(
                'Pick your car',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your car is being parked',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),

              // Timer — centered in remaining space
              Expanded(
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.08),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: CircularPercentIndicator(
                      radius: 140,
                      lineWidth: 10,
                      percent: progress,
                      center: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 28,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            timeStr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ELAPSED',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      progressColor: Colors.white.withValues(alpha: 0.9),
                      backgroundColor: Colors.white.withValues(alpha: 0.12),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ),
                ),
              ),

              // Pay button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to pay/completed when ready
                      context.go('/ticketCompleted');
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Pay valet parking'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Footer — Powered by KNEX + Valet One logo
              Padding(
                padding: EdgeInsets.only(bottom: bottomPadding + 16),
                child: Column(
                  children: [
                    Image.asset(
                      AssetPaths.valetOneLogo,
                      height: 24,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Powered by KNEX',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
