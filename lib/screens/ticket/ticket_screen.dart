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
  bool _isCancelling = false;
  bool _isRequestingDeparture = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
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
        data: {'userClientId': profile!.id},
        fromData: (json) {
          final raw = json is List ? json.first : json;
          return Ticket.fromJson(raw as Map<String, dynamic>);
        },
      );

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        final ticket = response.data!;
        ref.read(activeTicketProvider.notifier).state = ticket;

        if (ticket.status == Ticket.statusInProgress) {
          _pollTimer?.cancel();
          context.go('/ticketTimer');
        } else if (ticket.status == Ticket.statusCompleted) {
          _pollTimer?.cancel();
          context.go('/ticketCompleted');
        } else if (ticket.status == Ticket.statusCancelled) {
          _pollTimer?.cancel();
          context.go('/home');
        }
      }
    } catch (e) {
      // Silent — polling errors are non-fatal, local ticket data is preserved.
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
                      const SizedBox(height: 28),

                      // Action buttons
                      if (ticket.status == Ticket.statusPending ||
                          ticket.status == Ticket.statusAccepted ||
                          ticket.status == 'Arrived') ...[
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
