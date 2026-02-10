import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_constants.dart';
import '../../config/theme/app_colors.dart';
import '../../models/ticket.dart';
import '../../providers/api_provider.dart';
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
          final raw = json is List ? (json.isEmpty ? null : json.first) : json;
          if (raw == null) throw Exception('Empty ticket list');
          return Ticket.fromJson(raw as Map<String, dynamic>);
        },
      );

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        final polled = response.data!;
        final current = ref.read(activeTicketProvider);
        print('[TicketScreen] Poll result: id=${polled.id}, status=${polled.status}');
        print('[TicketScreen] Current ticket: id=${current?.id}, status=${current?.status}');

        // Guard: don't let an old/cancelled polled ticket overwrite a fresh local one.
        // - If current has no ID (locally built), only accept active polled tickets
        // - If current has an ID, only accept polled tickets with the same ID
        if (current?.id == null && !polled.isActive) {
          print('[TicketScreen] Ignoring polled ticket — not active, current is local');
          return;
        }
        if (current?.id != null && polled.id != null && current!.id != polled.id) {
          print('[TicketScreen] Ignoring polled ticket — different ID');
          return;
        }

        // Preserve the PIN from the current ticket if the polled response
        // doesn't include one (getLatestTicket often omits the pin field).
        final preservedPin = (polled.pin == null || polled.pin!.isEmpty)
            ? current?.pin
            : polled.pin;
        ref.read(activeTicketProvider.notifier).state =
            polled.copyWith(pin: preservedPin);

        if (polled.status == Ticket.statusDeparture ||
            polled.status == Ticket.statusProcessingDeparture) {
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

    print('[TicketScreen] ========== POLL generatePINandticket ==========');
    print('[TicketScreen] Sending: email=${profile.email}, vehicle=${ticket.vehicleId}, location=${ticket.locationId}');

    try {
      final response = await ref.read(apiClientProvider).post<Map<String, dynamic>>(
        Endpoints.generatePINandTicket,
        data: {
          'email': profile.email,
          'vehicle': ticket.vehicleId,
          'location': ticket.locationId,
        },
        fromData: (json) {
          print('[TicketScreen] generatePINandticket raw type: ${json.runtimeType}');
          print('[TicketScreen] generatePINandticket raw response: $json');
          if (json is Map<String, dynamic>) return json;
          if (json is Map) return Map<String, dynamic>.from(json);
          return <String, dynamic>{'raw': json};
        },
      );

      if (!mounted) return;

      print('[TicketScreen] generatePINandticket — isSuccess: ${response.isSuccess}, '
          'data: ${response.data}, message: ${response.message}');

      if (response.isSuccess && response.data != null) {
        final pin = response.data!['pin']?.toString();
        print('[TicketScreen] PIN received: $pin');
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
      print('[TicketScreen] generatePINandticket error: $e');
    }
  }

  Future<void> _requestDeparture() async {
    final ticket = ref.read(activeTicketProvider);
    if (ticket == null) return;

    setState(() => _isRequestingDeparture = true);
    try {
      final response = await ref.read(apiClientProvider).post<Ticket>(
        Endpoints.setToDeparture,
        data: {'id': ticket.id},
        fromData: (json) => Ticket.fromJson(json as Map<String, dynamic>),
      );

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        ref.read(activeTicketProvider.notifier).state = response.data;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Failed to request departure.')),
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

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Title bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    const SizedBox(width: 48),
                    const Expanded(
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
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 20),

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
                      ).animate().slideY(
                        begin: 0.15,
                        duration: 500.ms,
                        curve: Curves.easeOutCubic,
                      ).fadeIn(duration: 400.ms),
                      const SizedBox(height: 16),

                      // PIN refresh countdown pie
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
                      const SizedBox(height: 20),

                      // Action buttons
                      if (ticket.status == Ticket.statusArrival ||
                          ticket.status == Ticket.statusProcessingArrival ||
                          ticket.status == Ticket.statusParked) ...[
                        // Request Pick Up button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _isRequestingDeparture
                                  ? null
                                  : _requestDeparture,
                              icon: _isRequestingDeparture
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.chevron_right),
                              label: Text(
                                _isRequestingDeparture
                                    ? 'Requesting...'
                                    : 'Request Pick Up',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.light.secondary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Cancel button
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
