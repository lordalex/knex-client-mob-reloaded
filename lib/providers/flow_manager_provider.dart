import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ticket.dart';
import '../models/user_client_profile.dart';
import '../services/api/endpoints.dart';
import '../services/schema_service.dart';
import 'api_provider.dart';
import 'app_state_provider.dart';
import 'profile_provider.dart';
import 'ticket_provider.dart';

/// Determines the user's destination route after authentication.
///
/// Steps:
/// 1. Fetch OpenAPI schema and extract required profile fields
/// 2. Search for existing user profile by email
/// 3. If profile incomplete -> `/profileCreate`
/// 4. If active ticket exists -> `/ticket`
/// 5. Otherwise -> `/home`
final flowManagerProvider = FutureProvider.autoDispose<String>((ref) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) {
    print('[FlowManager] No current user — routing to /login');
    return '/login';
  }

  // DEBUG: Print JWT token for API testing (remove before release)
  final idToken = await currentUser.getIdToken();
  print('');
  print('╔══════════════════════════════════════════════════════════════╗');
  print('║  🔑 JWT TOKEN — copy lines between START and END           ║');
  print('╠══════════════════════════════════════════════════════════════╣');
  print('║  User:  ${currentUser.email}');
  print('║  UID:   ${currentUser.uid}');
  print('╚══════════════════════════════════════════════════════════════╝');
  print('----TOKEN-START----');
  // Split into 800-char chunks so print() doesn't truncate
  final t = idToken ?? '';
  for (var i = 0; i < t.length; i += 800) {
    print(t.substring(i, i + 800 > t.length ? t.length : i + 800));
  }
  print('----TOKEN-END----');
  print('');

  final apiClient = ref.read(apiClientProvider);
  final schemaService = SchemaService();

  // 1. Fetch schema and required fields
  List<String> requiredFields = [];
  try {
    final schema = await schemaService.fetchSchema();
    if (schema != null) {
      requiredFields = schemaService.getRequiredFields(schema);
      print('[FlowManager] Schema fetched. Required fields: $requiredFields');
    } else {
      print('[FlowManager] Schema fetch returned null');
    }
  } catch (e) {
    print('[FlowManager] Schema fetch failed: $e');
  }

  // 2. Search for existing user profile
  print('[FlowManager] ========== PROFILE SEARCH ==========');
  print('[FlowManager] Searching for email: ${currentUser.email}');

  UserClientProfile? profile;
  try {
    final response = await apiClient.post<UserClientProfile>(
      Endpoints.searchUserClient,
      data: {'email': currentUser.email},
      fromData: (json) {
        // The API returns data in various shapes:
        // - List: [{profile}]  (direct list)
        // - Map with inner data list: {data: [{profile}]}
        dynamic payload = json;
        if (payload is Map<String, dynamic> && payload.containsKey('data')) {
          payload = payload['data'];
        }
        final raw = payload is List ? (payload.isEmpty ? null : payload.first) : payload;
        print('[FlowManager] RAW PROFILE JSON: $raw');
        if (raw == null) throw Exception('Empty profile list');
        return UserClientProfile.fromJson(raw as Map<String, dynamic>);
      },
    );

    print('[FlowManager] Response — status: ${response.status}, '
        'isSuccess: ${response.isSuccess}, '
        'hasData: ${response.data != null}, '
        'message: ${response.message}');

    if (response.isSuccess && response.data != null) {
      profile = response.data;
      print('[FlowManager] PARSED PROFILE: '
          'id=${profile!.id}, email=${profile.email}, '
          'firstName=${profile.firstName}, lastName=${profile.lastName}, '
          'phoneNumber=${profile.phoneNumber}, address=${profile.address}');
    }
  } catch (e) {
    // Handle the known 500 "Converting circular structure to JSON" error
    final msg = e.toString();
    if (msg.contains('circular structure')) {
      print('[FlowManager] Known searchUserClient 500 error — treating as new user');
    } else {
      print('[FlowManager] Profile search failed: $e');
    }
  }

  print('[FlowManager] Profile result: ${profile != null ? "FOUND" : "NOT FOUND"}');

  // 3. Check profile completeness
  if (profile == null) {
    print('[FlowManager] => Routing to /profileCreate (no profile)');
    return '/profileCreate';
  }

  if (requiredFields.isNotEmpty) {
    final profileJson = profile.toJson();
    final isComplete = schemaService.isProfileComplete(profileJson, requiredFields);
    print('[FlowManager] Profile JSON for completeness check: $profileJson');
    print('[FlowManager] isProfileComplete: $isComplete');
    if (!isComplete) {
      ref.read(userProfileProvider.notifier).state = profile;
      print('[FlowManager] => Routing to /profileCreate (incomplete)');
      return '/profileCreate';
    }
  }

  // Profile is complete -> store it
  ref.read(userProfileProvider.notifier).state = profile;
  ref.read(userProfileCreatedProvider.notifier).state = true;
  print('[FlowManager] Profile is complete. Stored.');

  // 4. Check for active ticket
  print('[FlowManager] ========== TICKET CHECK ==========');
  print('[FlowManager] User ID: ${profile.id}');
  print('[FlowManager] Email: ${currentUser.email}');
  Ticket? activeTicket;
  try {
    final ticketResponse = await apiClient.post<Ticket>(
      Endpoints.getLatestTicket,
      fromData: (json) {
        print('[FlowManager] RAW TICKET RESPONSE TYPE: ${json.runtimeType}');
        print('[FlowManager] RAW TICKET RESPONSE: $json');
        // Handle {data: [...]} wrapper if present
        dynamic payload = json;
        if (payload is Map<String, dynamic> && payload.containsKey('data')) {
          payload = payload['data'];
        }
        final raw = payload is List ? (payload.isEmpty ? null : payload.first) : payload;
        if (raw == null) throw Exception('Empty ticket list');
        print('[FlowManager] UNWRAPPED TICKET JSON: $raw');
        return Ticket.fromJson(raw as Map<String, dynamic>);
      },
    );

    print('[FlowManager] Ticket response — status: ${ticketResponse.status}, '
        'isSuccess: ${ticketResponse.isSuccess}, '
        'hasData: ${ticketResponse.data != null}, '
        'message: ${ticketResponse.message}');

    if (ticketResponse.isSuccess && ticketResponse.data != null) {
      final ticket = ticketResponse.data!;
      print('[FlowManager] PARSED TICKET:');
      print('[FlowManager]   id=${ticket.id}');
      print('[FlowManager]   ticketNumber=${ticket.ticketNumber}');
      print('[FlowManager]   status="${ticket.status}"');
      print('[FlowManager]   isActive=${ticket.isActive}');
      print('[FlowManager]   locationId=${ticket.locationId}');
      print('[FlowManager]   vehicleId=${ticket.vehicleId}');
      print('[FlowManager]   pin=${ticket.pin}');
      print('[FlowManager]   createdAt=${ticket.createdAt}');
      if (ticket.isActive) activeTicket = ticket;
    } else {
      print('[FlowManager] No active ticket found');
    }
  } catch (e) {
    print('[FlowManager] Ticket check failed: $e');
  }

  if (activeTicket != null) {
    ref.read(activeTicketProvider.notifier).state = activeTicket;
    print('[FlowManager] => Routing to /ticket (active ticket)');
    return '/ticket';
  }

  print('[FlowManager] No active ticket found');

  // 5. No active ticket -> go home
  print('[FlowManager] => Routing to /home');
  return '/home';
});
