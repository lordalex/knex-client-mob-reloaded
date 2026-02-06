/// Centralized application constants for the KNEX client app.
///
/// Contains API endpoints, Firebase configuration, Stripe keys,
/// default location coordinates, and external service keys.
class AppConstants {
  AppConstants._();

  // ---------------------------------------------------------------------------
  // API
  // ---------------------------------------------------------------------------

  /// Base URL for all KNEX client API calls (all endpoints use POST).
  static const String apiBaseUrl = 'https://client.knex-app.xyz/api';

  /// OpenAPI schema URL hosted on the *attendant* Firebase project.
  /// Used by FlowManager to determine required profile fields.
  static const String schemaUrl =
      'https://storage.googleapis.com/knex-attendant-25.firebasestorage.app/openapi.json';

  // ---------------------------------------------------------------------------
  // Firebase
  // ---------------------------------------------------------------------------

  /// Firebase project identifier for the client app.
  static const String firebaseProjectId = 'knex-client24';

  /// Firebase Auth domain.
  static const String firebaseAuthDomain = 'knex-client24.firebaseapp.com';

  /// Firebase Storage bucket.
  static const String firebaseStorageBucket = 'knex-client24.appspot.com';

  /// Firebase Cloud Messaging sender ID.
  static const String firebaseMessagingSenderId = '1045566810040';

  /// Firebase App ID (web configuration).
  static const String firebaseAppId =
      '1:1045566810040:web:5e2c46c1cec3256028514d';

  // ---------------------------------------------------------------------------
  // Stripe
  // ---------------------------------------------------------------------------

  /// Stripe publishable key (test environment).
  static const String stripePublishableKey =
      'pk_test_51HZhaXKSurfj8r0pw0ssMC4fKSkVVPaP773HO4sHi8G8u1enXvEL7sCUp7kSMBxSrbtNPXRvjQbgEJWftjDKN35S00VQ43BHRt';

  /// ISO 3166-1 alpha-2 country code for the Stripe merchant.
  static const String merchantCountryCode = 'CA';

  /// Display name shown on the Stripe payment sheet.
  static const String merchantDisplayName = 'KNEX';

  // ---------------------------------------------------------------------------
  // Default Location (South Florida)
  // ---------------------------------------------------------------------------

  /// Default latitude when GPS is unavailable.
  static const double defaultLatitude = 26.132895;

  /// Default longitude when GPS is unavailable.
  static const double defaultLongitude = -80.104208;

  // ---------------------------------------------------------------------------
  // Google Places
  // ---------------------------------------------------------------------------

  /// API key for Google Places Autocomplete (address fields).
  static const String googlePlacesApiKey =
      'AIzaSyABQuvxlOjBSQpg3sAfXKttOZJlNsMrmjE';

  // ---------------------------------------------------------------------------
  // HTTP Timeouts
  // ---------------------------------------------------------------------------

  /// Connection timeout in milliseconds.
  static const int connectTimeoutMs = 30000;

  /// Receive timeout in milliseconds.
  static const int receiveTimeoutMs = 30000;

  // ---------------------------------------------------------------------------
  // Misc
  // ---------------------------------------------------------------------------

  /// Duration between ticket-polling requests (in seconds).
  static const int ticketPollIntervalSeconds = 5;

  /// Maximum photo compression quality (0-100).
  static const int photoCompressionQuality = 70;

  /// Application version label shown in the Profile screen.
  static const String appVersion = 'v1.0';
}
