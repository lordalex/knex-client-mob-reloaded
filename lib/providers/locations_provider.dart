import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location.dart';

/// Holds the list of available valet locations fetched from the backend.
///
/// Populated by the HomeScreen on load via the `getLocations` API endpoint.
/// Empty by default until the first successful fetch.
///
/// TODO: Upgrade to a more robust AsyncNotifierProvider in Phase 3 when
/// location fetching and sorting logic is implemented.
final locationsProvider = StateProvider<List<ValetLocation>>((ref) => []);
