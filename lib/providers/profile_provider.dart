import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_client_profile.dart';

/// Holds the currently signed-in user's profile data.
///
/// Set to null when no profile has been fetched (e.g. before sign-in or if the
/// API call to fetch the profile has not yet completed).
///
/// TODO: Upgrade to a more robust AsyncNotifierProvider in Phase 3 when
/// profile fetching logic is implemented.
final userProfileProvider = StateProvider<UserClientProfile?>((ref) => null);
