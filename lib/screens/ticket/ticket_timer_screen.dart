import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../config/app_constants.dart';
import '../../models/ticket.dart';
import '../../providers/api_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../services/api/endpoints.dart';
import '../../widgets/loading_indicator.dart';

/// Live timer screen showing elapsed parking duration.
///
/// Displays a circular progress indicator and elapsed time. Polls the backend
/// for status changes and navigates to completed screen when done.
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
    final theme = Theme.of(context);

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Valet In Progress'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularPercentIndicator(
                radius: 120,
                lineWidth: 12,
                percent: progress,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 32,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeStr,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      'Elapsed',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                progressColor: theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(height: 32),

              Text(
                'Your car is being parked',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ll notify you when your valet service is complete.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              if (ticket.pin != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('PIN: ', style: theme.textTheme.titleMedium),
                        Text(
                          ticket.pin!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
