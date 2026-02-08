import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/ticket.dart';
import '../../providers/api_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../services/api/endpoints.dart';
import '../../widgets/loading_indicator.dart';

/// Screen displaying the user's past valet ticket history.
///
/// Fetches all tickets via [Endpoints.getTicketList] and shows them
/// in reverse chronological order. Completed tickets show in green,
/// cancelled in grey.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final profile = ref.read(userProfileProvider);
    if (profile?.id == null) {
      setState(() {
        _isLoading = false;
        _error = 'No profile found.';
      });
      return;
    }

    try {
      final response = await ref.read(apiClientProvider).post<List<Ticket>>(
        Endpoints.search,
        data: {
          'modelName': 'Ticket',
          'searchCriteria': {'user_client': profile!.id},
        },
        fromData: (json) {
          // /search returns { results: [...] }
          final list = json is Map
              ? (json['results'] as List?) ?? []
              : json is List
                  ? json
                  : [];
          return list
              .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

      if (!mounted) return;

      if (response.isSuccess && response.data != null) {
        ref.read(ticketHistoryProvider.notifier).state = response.data!;
      } else {
        _error = response.message ?? 'Failed to load history.';
      }
    } catch (e) {
      developer.log('History fetch error: $e', name: 'HistoryScreen');
      if (mounted) _error = 'Failed to load history.';
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch(ticketHistoryProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: _isLoading
          ? const LoadingIndicator()
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(_error!, style: theme.textTheme.bodyLarge),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _fetchHistory,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : tickets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No ticket history yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchHistory,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = tickets[index];
                          return _TicketHistoryCard(ticket: ticket);
                        },
                      ),
                    ),
    );
  }
}

class _TicketHistoryCard extends StatelessWidget {
  final Ticket ticket;

  const _TicketHistoryCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = ticket.status == Ticket.statusCompleted;
    final statusColor = isCompleted ? Colors.green : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (ticket.ticketNumber != null)
                  Text(
                    'Ticket #${ticket.ticketNumber}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ticket.status,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  ticket.locationId,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (ticket.createdAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(ticket.createdAt!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            if (ticket.tip != null && ticket.tip! > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Tip: \$${ticket.tip!.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '${dt.month}/${dt.day}/${dt.year} ${hour == 0 ? 12 : hour}:${dt.minute.toString().padLeft(2, '0')} $period';
  }
}
