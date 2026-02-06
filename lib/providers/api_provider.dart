import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/api/api_client.dart';

/// Provides a singleton [ApiClient] instance to the widget tree.
///
/// Used by [authTokenSyncProvider] to push token updates to the HTTP client,
/// and by all service/repository layers that need to make backend requests.
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
