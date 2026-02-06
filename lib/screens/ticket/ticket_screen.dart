import 'dart:async';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_constants.dart';
import '../../models/ticket.dart';
import '../../providers/api_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../services/api/endpoints.dart';
import '../../widgets/app_button.dart';
import '../../widgets/loading_indicator.dart';

/// Active ticket screen showing ticket status, barcode, and action buttons.
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
    if (profile?.email == null) return;

    try {
      final response = await ref.read(apiClientProvider).post<Ticket>(
        Endpoints.getLatestTicket,
        data: {'email': profile!.email},
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
      // If poll fails, keep the local ticket data — don't clear it.
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
    final theme = Theme.of(context);

    if (ticket == null) {
      return const Scaffold(body: LoadingIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Ticket'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _statusColor(ticket.status, theme),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel(ticket.status),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Ticket number
            if (ticket.ticketNumber != null) ...[
              Text(
                'Ticket #${ticket.ticketNumber}',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Barcode
            if (ticket.pin != null && ticket.pin!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: ticket.pin!,
                  width: 240,
                  height: 80,
                  drawText: true,
                ),
              ),
            const SizedBox(height: 16),

            // PIN
            if (ticket.pin != null) ...[
              Text('PIN', style: theme.textTheme.labelMedium),
              Text(
                ticket.pin!,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Info card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow('Status', _statusLabel(ticket.status)),
                    if (ticket.ticketNumber != null)
                      _infoRow('Ticket #', ticket.ticketNumber!),
                    _infoRow('Location', ticket.locationId),
                    if (ticket.createdAt != null)
                      _infoRow('Created', _formatTime(ticket.createdAt!)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            if (ticket.status == Ticket.statusPending ||
                ticket.status == Ticket.statusAccepted) ...[
              AppButton(
                label: 'Request My Car',
                isLoading: _isRequestingDeparture,
                onPressed: _isRequestingDeparture ? null : _requestDeparture,
              ),
              const SizedBox(height: 12),
              AppButton(
                label: 'Cancel Request',
                isOutlined: true,
                isLoading: _isCancelling,
                onPressed: _isCancelling ? null : _cancelTicket,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )),
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }

  Color _statusColor(String status, ThemeData theme) {
    return switch (status) {
      Ticket.statusPending => theme.colorScheme.tertiary,
      Ticket.statusAccepted => Colors.blue,
      Ticket.statusInProgress => Colors.orange,
      Ticket.statusCompleted => Colors.green,
      Ticket.statusCancelled => Colors.grey,
      _ => theme.colorScheme.primary,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      Ticket.statusPending => 'Waiting for Valet',
      Ticket.statusAccepted => 'Valet Accepted',
      Ticket.statusInProgress => 'In Progress',
      Ticket.statusCompleted => 'Completed',
      Ticket.statusCancelled => 'Cancelled',
      _ => status,
    };
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour == 0 ? 12 : hour}:${dt.minute.toString().padLeft(2, '0')} $period';
  }
}
