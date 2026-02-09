import 'dart:developer' as dev;

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
        // The API returns data as a list; unwrap to first element.
        final raw = json is List ? json.first : json;
        print('[FlowManager] RAW PROFILE JSON: $raw');
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
  Ticket? activeTicket;
  try {
    final ticketResponse = await apiClient.post<Ticket>(
      Endpoints.getLatestTicket,
      fromData: (json) {
        final raw = json is List ? (json.isEmpty ? null : json.first) : json;
        if (raw == null) throw Exception('Empty ticket list');
        return Ticket.fromJson(raw as Map<String, dynamic>);
      },
    );

    if (ticketResponse.isSuccess && ticketResponse.data != null) {
      final ticket = ticketResponse.data!;
      print('[FlowManager] Latest ticket: status=${ticket.status}');
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
