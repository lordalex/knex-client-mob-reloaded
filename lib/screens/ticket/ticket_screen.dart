import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_constants.dart';
import '../../config/theme/app_colors.dart';
import '../../models/ticket.dart';
import '../../providers/api_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/locations_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../services/api/endpoints.dart';
import '../../widgets/gradient_background.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/ticket_card.dart';

/// Active ticket screen showing branded ticket card with barcode and actions.
///
/// Polls the backend every [AppConstants.ticketPollIntervalSeconds] to update
/// the ticket status. Routes to timer/completed screens based on status changes.
class TicketScreen extends ConsumerStatefulWidget {
  const TicketScreen({super.key});

  @override
  ConsumerState<TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends ConsumerState<TicketScreen> {
  Timer? _pollTimer;
  Timer? _pinTimer;
  Timer? _pinCountdownTimer;
  bool _isCancelling = false;
  bool _isRequestingDeparture = false;
  int _pinSecondsLeft = 30;
  static const int _pinIntervalSeconds = 30;

  @override
  void initState() {
    super.initState();
    _startPolling();
    // Fetch the full ticket immediately so we have ID / ticket number
    _pollTicket();
    // Call immediately, then every 30s
    _pollPIN();
    _pinTimer = Timer.periodic(
      const Duration(seconds: _pinIntervalSeconds),
      (_) => _pollPIN(),
    );
    // 1s countdown for the pie
    _pinCountdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) {
          setState(() {
            _pinSecondsLeft = (_pinSecondsLeft - 1).clamp(0, _pinIntervalSeconds);
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _pinTimer?.cancel();
    _pinCountdownTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(
      const Duration(seconds: AppConstants.ticketPollIntervalSeconds),
      (_) => _pollTicket(),
    );
  }

  Future<void> _pollTicket() async {
    final profile = ref.read(userProfileProvider);
    if (profile?.id == null) return;

    try {
      final response = await ref.read(apiClientProvider).post<Ticket>(
        Endpoints.getLatestTicket,
        fromData: (json) {
          dynamic payload = json;
          if (payload is Map<String, dynamic> && payload.containsKey('data')) {
            payload = payload['data'];
          }
          final raw = payload is List ? (payload.isEmpty ? null : payload.first) : payload;
          if (raw == null) throw Exception('Empty ticket list');
          return Ticket.fromJson(raw as Map<String, dynamic>);
        },
      );

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        final polled = response.data!;
        final current = ref.read(activeTicketProvider);
        debugPrint('[TicketScreen] Poll result: id=${polled.id}, status=${polled.status}');
        debugPrint('[TicketScreen] Current ticket: id=${current?.id}, status=${current?.status}');

        // Guard: don't let an old/cancelled polled ticket overwrite a fresh local one.
        // - If current has no ID (locally built), only accept active polled tickets
        // - If current has an ID, only accept polled tickets with the same ID
        if (current?.id == null && !polled.isActive) {
          debugPrint('[TicketScreen] Ignoring polled ticket — not active, current is local');
          return;
        }
        if (current?.id != null && polled.id != null && current!.id != polled.id) {
          debugPrint('[TicketScreen] Ignoring polled ticket — different ID');
          return;
        }

        // Preserve the PIN from the current ticket if the polled response
        // doesn't include one (getLatestTicket often omits the pin field).
        final preservedPin = (polled.pin == null || polled.pin!.isEmpty)
            ? current?.pin
            : polled.pin;
        ref.read(activeTicketProvider.notifier).state =
            polled.copyWith(pin: preservedPin);

        // Once the attendant has accepted the ticket (status moves past
        // Arrival), stop regenerating PINs — otherwise generatePINandTicket
        // would create a brand-new ticket and reset the flow.
        if (polled.status != Ticket.statusArrival &&
            polled.status != Ticket.statusProcessingArrival) {
          _pinTimer?.cancel();
          _pinCountdownTimer?.cancel();
        }

        if (polled.status == Ticket.statusProcessing ||
            polled.status == Ticket.statusProcessingDeparture ||
            polled.status == Ticket.statusDeparted) {
          _pollTimer?.cancel();
          _pinTimer?.cancel();
          context.go('/ticketTimer');
        } else if (polled.status == Ticket.statusCompleted) {
          _pollTimer?.cancel();
          _pinTimer?.cancel();
          context.go('/ticketCompleted');
        } else if (polled.status == Ticket.statusCancelled) {
          _pollTimer?.cancel();
          _pinTimer?.cancel();
          context.go('/home');
        }
      }
    } catch (_) {
      // Silent — polling errors are non-fatal
    }
  }

  Future<void> _pollPIN() async {
    final ticket = ref.read(activeTicketProvider);
    final profile = ref.read(userProfileProvider);
    if (ticket == null || profile == null) return;

    // Only regenerate PIN while the ticket is still waiting for the attendant.
    // Once the attendant enters the PIN, status advances past 'Arrival' and
    // calling generatePINandTicket again would create a NEW ticket, resetting
    // the flow.
    if (ticket.status != Ticket.statusArrival &&
        ticket.status != Ticket.statusProcessingArrival) {
      debugPrint('[TicketScreen] Skipping PIN poll — status is ${ticket.status}');
      _pinTimer?.cancel();
      _pinCountdownTimer?.cancel();
      return;
    }

    debugPrint('[TicketScreen] ========== POLL generatePINandticket ==========');
    debugPrint('[TicketScreen] Sending: email=${profile.email}, vehicle=${ticket.vehicleId}, location=${ticket.locationId}');

    try {
      final response = await ref.read(apiClientProvider).post<Map<String, dynamic>>(
        Endpoints.generatePINandTicket,
        data: {
          'email': profile.email,
          'vehicle': ticket.vehicleId,
          'location': ticket.locationId,
        },
        fromData: (json) {
          debugPrint('[TicketScreen] generatePINandticket raw type: ${json.runtimeType}');
          debugPrint('[TicketScreen] generatePINandticket raw response: $json');
          if (json is Map<String, dynamic>) return json;
          if (json is Map) return Map<String, dynamic>.from(json);
          return <String, dynamic>{'raw': json};
        },
      );

      if (!mounted) return;

      debugPrint('[TicketScreen] generatePINandticket — isSuccess: ${response.isSuccess}, '
          'data: ${response.data}, message: ${response.message}');

      if (response.isSuccess && response.data != null) {
        final pin = response.data!['pin']?.toString();
        debugPrint('[TicketScreen] PIN received: $pin');
        if (pin != null && pin.isNotEmpty) {
          // Re-read the latest ticket so we don't overwrite status/id
          // changes that _pollTicket may have written while this was in-flight.
          final latest = ref.read(activeTicketProvider) ?? ticket;
          ref.read(activeTicketProvider.notifier).state =
              latest.copyWith(pin: pin);
          if (mounted) setState(() => _pinSecondsLeft = _pinIntervalSeconds);
        }
      }
    } catch (e) {
      debugPrint('[TicketScreen] generatePINandticket error: $e');
    }
  }

  Future<void> _requestDeparture() async {
    final ticket = ref.read(activeTicketProvider);
    if (ticket == null) return;

    setState(() => _isRequestingDeparture = true);
    try {
      final response = await ref.read(apiClientProvider).post<Map<String, dynamic>>(
        Endpoints.setTicketStatus,
        data: {'id': ticket.id, 'status': Ticket.statusDeparture},
        fromData: (json) {
          if (json is Map<String, dynamic>) return json;
          if (json is Map) return Map<String, dynamic>.from(json);
          return <String, dynamic>{'raw': json};
        },
      );

      if (!mounted) return;

      if (response.isSuccess) {
        // Update local ticket status immediately, poll will confirm
        ref.read(activeTicketProvider.notifier).state =
            ticket.copyWith(status: Ticket.statusDeparture);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Failed to request pick up.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isRequestingDeparture = false);
    }
  }

  Future<void> _cancelTicket() async {
    final ticket = ref.read(activeTicketProvider);
    if (ticket == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ticket'),
        content: const Text('Are you sure you want to cancel this valet request?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, Cancel')),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCancelling = true);
    try {
      await ref.read(apiClientProvider).post(
        Endpoints.setToCancelForClient,
        data: {'id': ticket.id},
      );

      if (!mounted) return;

      _pollTimer?.cancel();
      _pinTimer?.cancel();
      ref.read(activeTicketProvider.notifier).state = null;
      context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = ref.watch(activeTicketProvider);

    if (ticket == null) {
      return const Scaffold(body: LoadingIndicator());
    }

    // Resolve location name/address from cache
    final locations = ref.watch(locationsProvider);
    final location = locations.where((l) => l.id == ticket.locationId).firstOrNull;

    // Get saved vehicle info
    final myCar = ref.watch(myCarProvider);

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Title bar
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        'Your Ticket',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Status stepper
              _StatusStepper(currentStatus: ticket.status),
              const SizedBox(height: 16),

              // Ticket card with slide-up animation
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: bottomPadding + 16),
                  child: Column(
                    children: [
                      TicketCard(
                        ticket: ticket,
                        locationName: location?.name,
                        locationAddress: location?.address,
                        showPin: ticket.status == Ticket.statusProcessingArrival,
                        vehicle: myCar.isNotEmpty ? myCar : null,
                      ).animate().slideY(
                        begin: 0.15,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ).fadeIn(duration: 400.ms),
                      const SizedBox(height: 16),

                      // PIN refresh countdown — during Arrival and Processing-Arrival
                      if (ticket.status == Ticket.statusArrival ||
                          ticket.status == Ticket.statusProcessingArrival) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                value: 1.0 - (_pinSecondsLeft / _pinIntervalSeconds),
                                strokeWidth: 2.5,
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PIN refreshes in ${_pinSecondsLeft}s',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],

                      // Cancel button — only during Arrival
                      if (ticket.status == Ticket.statusArrival) ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed:
                                  _isCancelling ? null : _cancelTicket,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white70,
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isCancelling
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white70,
                                      ),
                                    )
                                  : const Text('Cancel Ticket'),
                            ),
                          ),
                        ),
                      ],

                      // Processing Arrival — valet is parking the car
                      if (ticket.status == Ticket.statusProcessingArrival) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Your valet is parking your car...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],

                      // Request Pick Up — only when Parked (long press to confirm)
                      if (ticket.status == Ticket.statusParked) ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: _isRequestingDeparture
                                ? ElevatedButton.icon(
                                    onPressed: null,
                                    icon: const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    label: const Text('Requesting...'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.light.secondary,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onLongPress: () {
                                      HapticFeedback.heavyImpact();
                                      _requestDeparture();
                                    },
                                    child: Container(
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: AppColors.light.secondary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.chevron_right, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            'Hold to Request Pick Up',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],

                      // Departure — waiting for attendant to confirm
                      if (ticket.status == Ticket.statusDeparture) ...[
                        const SizedBox(height: 20),
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Waiting for your valet...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your pick up request has been sent',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                      ],
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

/// Horizontal status stepper showing the ticket's progress through the flow.
///
/// Steps: Arrive → Process → Parked → Pick Up → Done
class _StatusStepper extends StatelessWidget {
  final String currentStatus;

  const _StatusStepper({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Arrive', Ticket.statusArrival),
      ('Process', Ticket.statusProcessingArrival),
      ('Parked', Ticket.statusParked),
      ('Pick Up', Ticket.statusDeparture),
      ('Done', Ticket.statusCompleted),
    ];

    final currentIndex = _statusIndex(currentStatus);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          // Even indices = step circles, odd indices = connecting lines
          if (i.isOdd) {
            final stepIndex = i ~/ 2;
            final isCompleted = stepIndex < currentIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: isCompleted
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.white.withValues(alpha: 0.15),
              ),
            );
          }

          final stepIndex = i ~/ 2;
          final step = steps[stepIndex];
          final isActive = stepIndex == currentIndex;
          final isCompleted = stepIndex < currentIndex;

          return _StepDot(
            label: step.$1,
            isActive: isActive,
            isCompleted: isCompleted,
          );
        }),
      ),
    );
  }

  int _statusIndex(String status) {
    return switch (status) {
      Ticket.statusArrival => 0,
      Ticket.statusProcessingArrival => 1,
      Ticket.statusParked => 2,
      Ticket.statusDeparture || Ticket.statusDeparted ||
      Ticket.statusProcessingDeparture || Ticket.statusProcessing => 3,
      Ticket.statusCompleted => 4,
      _ => 0,
    };
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepDot({
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isActive ? 24 : 16,
          height: isActive ? 24 : 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? Colors.white
                : isCompleted
                    ? Colors.white.withValues(alpha: 0.8)
                    : Colors.transparent,
            border: Border.all(
              color: isActive || isCompleted
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              width: isActive ? 2 : 1.5,
            ),
          ),
          child: isCompleted
              ? const Icon(Icons.check, size: 10, color: Color(0xFF2D1B69))
              : isActive
                  ? Icon(Icons.circle, size: 8, color: AppColors.light.secondary)
                  : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? Colors.white
                : isCompleted
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.3),
            fontSize: 9,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
