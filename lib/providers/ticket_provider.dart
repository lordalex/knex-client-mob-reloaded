import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ticket.dart';

/// Holds the user's currently active valet ticket, if any.
///
/// A ticket is considered "active" when its status is not Completed or
/// Cancelled. The FlowManager checks this on app load to redirect users to
/// the TicketScreen if they have an in-progress ticket.
///
/// TODO: Upgrade to an AsyncNotifierProvider in Phase 4 when ticket polling
/// is implemented.
final activeTicketProvider = StateProvider<Ticket?>((ref) => null);

/// Holds the user's historical (completed/cancelled) tickets.
///
/// Populated by the History screen via the `getTicketList` API endpoint.
///
/// TODO: Upgrade to an AsyncNotifierProvider in Phase 5 when history
/// fetching is implemented.
final ticketHistoryProvider = StateProvider<List<Ticket>>((ref) => []);
