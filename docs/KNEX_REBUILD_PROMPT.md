
# KNEX Client App - Complete Rebuild Specification (Pure Flutter)

## Mission

Rebuild the KNEX valet parking client app as a **pure Flutter project** — no FlutterFlow framework or dependencies. The app allows users to request valet parking services, manage vehicles, view real-time ticket status, and pay tips via Stripe.

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (latest stable) |
| Language | Dart |
| State Management | Riverpod (flutter_riverpod + riverpod_annotation) |
| Routing | go_router |
| Networking | dio (with interceptors) |
| Auth | Firebase Auth (firebase_auth, google_sign_in, sign_in_with_apple) |
| Backend Services | Firebase (Core, Crashlytics, Performance, Storage, Cloud Functions) |
| Payments | flutter_stripe |
| Localization | flutter_localizations + .arb files (EN, ES, FR) |
| Theming | Material 3 with custom ThemeExtension |
| Forms | reactive_forms or standard Form + TextFormField |
| Local Storage | shared_preferences |
| Image Handling | image_picker, flutter_image_compress, cached_network_image |

---

## Project Structure

```
lib/
├── main.dart                     # App entry, Firebase init, providers
├── app.dart                      # MaterialApp.router setup
├── config/
│   ├── app_constants.dart        # API base URLs, keys
│   ├── theme/
│   │   ├── app_theme.dart        # ThemeData (light + dark)
│   │   ├── app_colors.dart       # Color tokens
│   │   └── app_typography.dart   # Text styles
│   └── routes/
│       ├── app_router.dart       # GoRouter config
│       └── route_names.dart      # Route name constants
├── l10n/
│   ├── app_en.arb                # English strings
│   ├── app_es.arb                # Spanish strings
│   ├── app_fr.arb                # French strings
│   └── florida_messages.dart     # Fun randomized messages (keep existing)
├── models/
│   ├── user_client_profile.dart
│   ├── vehicle.dart
│   ├── ticket.dart
│   ├── location.dart
│   ├── my_car.dart               # Local persisted vehicle
│   └── api_response.dart         # Generic API result wrapper
├── services/
│   ├── api/
│   │   ├── api_client.dart       # Dio-based HTTP client
│   │   ├── api_interceptors.dart # Auth token, error handling, logging
│   │   └── endpoints.dart        # All endpoint constants
│   ├── auth/
│   │   ├── auth_service.dart     # Firebase auth wrapper
│   │   └── auth_providers.dart   # Riverpod providers for auth state
│   ├── location_service.dart     # GPS + geocoding
│   ├── storage_service.dart      # SharedPreferences wrapper
│   ├── stripe_service.dart       # Stripe payment processing
│   ├── notification_service.dart # Toast notifications
│   └── schema_service.dart       # OpenAPI schema fetching + validation
├── providers/
│   ├── app_state_provider.dart   # Global app state (favorites, car, prefs)
│   ├── profile_provider.dart     # User profile state
│   ├── locations_provider.dart   # Valet locations
│   ├── ticket_provider.dart      # Active ticket + polling
│   └── theme_provider.dart       # Dark/light mode
├── screens/
│   ├── login/
│   │   └── login_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   ├── profile_create/
│   │   └── profile_create_screen.dart
│   ├── site_details/
│   │   └── site_details_screen.dart
│   ├── add_cars/
│   │   └── add_cars_screen.dart
│   ├── ticket/
│   │   ├── ticket_screen.dart
│   │   ├── ticket_timer_screen.dart
│   │   └── ticket_completed_screen.dart
│   ├── payment/
│   │   ├── pay_screen.dart
│   │   └── add_credit_card_screen.dart
│   ├── favorites/
│   │   └── favorites_screen.dart
│   ├── history/
│   │   └── history_screen.dart
│   ├── settings/
│   │   ├── change_language_screen.dart
│   │   └── list_config_screen.dart
│   └── shell/
│       └── nav_shell.dart        # Bottom nav bar wrapper
├── widgets/
│   ├── error_state.dart
│   ├── tip_bottom_sheet.dart
│   ├── success_ticket.dart
│   ├── card_item.dart
│   ├── card_list.dart
│   ├── city_dropdown.dart
│   ├── loading_indicator.dart
│   └── app_button.dart           # Reusable styled button
└── utils/
    ├── florida_messages.dart     # Keep existing fun messages
    ├── distance.dart             # Haversine calculation
    ├── image_utils.dart          # Base64 encode/decode, compression
    ├── json_utils.dart           # JSON parsing helpers
    ├── validators.dart           # Form validation
    └── extensions.dart           # String, context extensions
```

---

## Firebase Configuration

```
Project ID:           knex-client24
Auth Domain:          knex-client24.firebaseapp.com
Storage Bucket:       knex-client24.appspot.com
Messaging Sender ID:  1045566810040
App ID (web):         1:1045566810040:web:5e2c46c1cec3256028514d
```

Firebase services to initialize:
- Firebase Core
- Firebase Auth
- Firebase Crashlytics (set user ID, record Flutter errors)
- Firebase Performance
- Firebase Storage (for schema file access)
- Cloud Functions (for Stripe payment intents)

Use `flutterfire configure` to generate platform-specific config files.

---

## API Specification

**Base URL**: `https://client.knex-app.xyz/api`

**Authentication Pattern**: Every authenticated request sends:
```json
POST /endpoint
Content-Type: application/json

{
  "idToken": "<Firebase JWT token>",
  "data": { ... payload ... }
}
```

### User Client Endpoints

| Method | Endpoint | Data Payload | Response |
|--------|----------|-------------|----------|
| POST | `/createUserClient` | `UserClientProfile.toMap()` | `{ status: { status, result, message }, data }` |
| POST | `/getUserClient` | `{ "id": "<id>" }` | `UserClientProfile` |
| POST | `/updateUserClient` | `UserClientProfile.toMap()` | CrudResult |
| POST | `/searchUserClient` | `{ "email": "<email>" }` | `List<UserClientProfile>` |
| POST | `/deleteUserClient` | `{ "id": "<id>" }` | CrudResult |
| POST | `/listUserClients` | `{}` | `List<UserClientProfile>` |

### Vehicle Endpoints

| Method | Endpoint | Data Payload | Response |
|--------|----------|-------------|----------|
| POST | `/createVehicle` | `{ vehicle_make, vehicle_model, license_plate, color }` | CrudResult |
| POST | `/listVehicles` | `{}` | `List<Vehicle>` |
| POST | `/getVehicle` | `{ "id": "<id>" }` | Vehicle |
| POST | `/updateVehicle` | Vehicle.toMap() | CrudResult |
| POST | `/deleteVehicle` | `{ "id": "<id>" }` | CrudResult |

### Ticket Endpoints

| Method | Endpoint | Data Payload | Response |
|--------|----------|-------------|----------|
| POST | `/createTicket` | `{ user_client_id, vehicle_id, status, location_id, notes }` | CrudResult |
| POST | `/getLatestTicket` | `{}` | Ticket or null |
| POST | `/getTicketList` | `{}` | `List<Ticket>` |
| POST | `/getTicketByPIN` | `{ "pin": "<pin>" }` | Ticket |
| POST | `/setToDeparture` | `{ "ticketId": "<id>" }` | CrudResult |
| POST | `/setToCancelForClient` | `{ "ticketId": "<id>" }` | CrudResult |
| POST | `/setTicketTip` | `{ "ticketId": "<id>", "tip": <amount> }` | CrudResult |
| POST | `/setTicketStatus` | `{ "ticketId": "<id>", "status": "<status>" }` | CrudResult |

### Location Endpoints

| Method | Endpoint | Data Payload | Response |
|--------|----------|-------------|----------|
| POST | `/getLocations` | `{}` | `List<Location>` |

### Provisional Ticket Endpoints (No Auth Required)

| Method | Endpoint | Data Payload | Response |
|--------|----------|-------------|----------|
| POST | `/createProvisionalTicket` | `{ locationId, vehicle: {...} }` | ProvisionalTicket |
| POST | `/linkUserClientToTicketByProvisionalPIN` | `{ "pin": "<pin>" }` | CrudResult |
| POST | `/setToDepartureCasual` | `{ "pin": "<pin>" }` | CrudResult |

### Stripe Payment

| Method | Endpoint | Data Payload | Response |
|--------|----------|-------------|----------|
| POST | `/confirmPayment` | payment confirmation data | CrudResult |

### External API

**Google Places Autocomplete** (for address field):
```
GET https://maps.googleapis.com/maps/api/place/autocomplete/json
  ?input=<query>
  &key=AIzaSyABQuvxlOjBSQpg3sAfXKttOZJlNsMrmjE
```

---

## Data Models

### UserClientProfile
```dart
class UserClientProfile {
  final String? id;
  final String? uid;
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? photo;       // base64 encoded image
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```
Note: API returns keys in both camelCase and lowercase variants (e.g., `firstName` or `firstname`, `phoneNumber` or `phone`). The model must handle both.

### Vehicle
```dart
class Vehicle {
  final String? id;
  final String? userClientId;  // JSON key: "user_client_id"
  final String vehicleMake;    // JSON key: "vehicle_make"
  final String vehicleModel;   // JSON key: "vehicle_model"
  final String? vehicleYear;   // JSON key: "vehicle_year"
  final String licensePlate;   // JSON key: "license_plate"
  final String color;
  final String? vin;
}
```

### Ticket
```dart
class Ticket {
  final String? id;
  final String? ticketNumber;   // JSON key: "ticket_number"
  final String userClientId;    // JSON key: "user_client_id"
  final String vehicleId;       // JSON key: "vehicle_id"
  final String status;          // Pending, Accepted, InProgress, Completed, Cancelled
  final String locationId;      // JSON key: "location_id"
  final String? notes;
  final String? pin;
}
```

### Location
```dart
class Location {
  final String id;
  final String name;
  final String? address;
  final Map<String, dynamic> rawData;
  // rawData contains: coordinates (lat/lng), company, photos, bio,
  // notes, currency, value (price), phone, etc.
}
```

### MyCar (Local persistence)
```dart
class MyCar {
  final String? model;
  final String? color;
  final String? plate;
  // Persisted to SharedPreferences as JSON
}
```

---

## App State (Riverpod)

Replace FlutterFlow's `FFAppState` with Riverpod providers:

### Persisted State (SharedPreferences)
```dart
// User profile completion flag
final userProfileCreatedProvider = StateNotifierProvider<BoolNotifier, bool>(...);

// User email validated flag
final userEmailValidatedProvider = StateNotifierProvider<BoolNotifier, bool>(...);

// Favorite site IDs
final favoriteSitesProvider = StateNotifierProvider<ListNotifier<String>, List<String>>(...);

// Persisted vehicle
final myCarProvider = StateNotifierProvider<MyCarNotifier, MyCar>(...);

// List preferences
final distanceUnitProvider = StateProvider<String>((ref) => 'metric');
final sortAscendingProvider = StateProvider<bool>((ref) => false);
final sortByProvider = StateProvider<String>((ref) => 'distance');
```

### In-Memory State
```dart
// User's current GPS location
final userLocationProvider = StateProvider<LatLng?>((ref) => LatLng(26.132895, -80.104208));

// Temporary base64 photo storage
final base64PhotoProvider = StateProvider<String>((ref) => '');
```

---

## Authentication Flow

### Supported Auth Methods
1. **Email/Password** - sign up + sign in
2. **Google Sign-In** - via `google_sign_in` package
3. **Apple Sign-In** - via `sign_in_with_apple` package

(Phone, Anonymous, JWT, and GitHub auth exist in the old code but only Email, Google, and Apple are actively used in the UI)

### Auth Flow
```
1. App starts → Firebase.initializeApp()
2. Listen to FirebaseAuth.instance.authStateChanges()
3. If user == null → show LoginScreen
4. If user != null → show NavShell (HomePage)
5. On HomePage load:
   a. Fetch user profile from API (searchUserClient by email)
   b. If profile incomplete → redirect to ProfileCreateScreen
   c. Check for active ticket → if found, redirect to TicketScreen
   d. Otherwise show locations list
```

### JWT Token Management
- Listen to `FirebaseAuth.instance.idTokenChanges()` for token refresh
- Store current JWT in a Riverpod provider
- Attach to every API request via Dio interceptor

### Error Messages
All auth errors should display fun, Florida-themed messages (see Florida Messages section below).

---

## Screen Specifications

### 1. LoginScreen (`/login`)

**Layout**: Full-screen with gradient/image background

**Components**:
- App logo at top
- TabBar with two tabs: **Sign In** | **Sign Up**
- **Sign In tab**:
  - Email text field
  - Password field with visibility toggle
  - "Sign In" button
  - "Forgot Password?" link (sends password reset email)
- **Sign Up tab**:
  - Email text field
  - Password field with visibility toggle
  - Confirm password field with visibility toggle
  - "Create Account" button
- Social auth buttons:
  - "Sign in with Google" button
  - "Sign in with Apple" button

**Behavior**:
- Validates password match on sign up
- Shows Florida-themed error messages on failure
- Navigates to NavShell (HomePage) on success
- Lock screen orientation to portrait on load

---

### 2. NavShell (Bottom Navigation)

**Layout**: Scaffold with body = selected tab, BottomNavigationBar at bottom

**Tabs**:
1. **Home** (home icon) → HomeScreen
2. **Profile** (person icon) → ProfileScreen

**Behavior**: Hide bottom nav on tablet/desktop (responsive check)

---

### 3. HomeScreen (`/home`) - Main Dashboard

**Layout** (top to bottom):
1. **Promotional Carousel** - 4 banner slides with KNEX branding, fade/move animations
2. **Section header**: "Valet location available near you" with filter icon button (→ ListConfigScreen)
3. **Locations ListView** - Scrollable list of valet site cards

**Each site card shows**:
- Site image (network image with error fallback)
- Location name
- Distance from user (Haversine calculation in selected unit)
- Address
- Company name
- Price value
- Chevron icon → tapping navigates to SiteDetailsScreen with site `id`

**On Page Load** (sequential steps):
1. Lock orientation to portrait
2. Fetch user profile via API → if incomplete, redirect to ProfileCreate
3. Fetch locations via `getLocations` API
4. Get user GPS coordinates
5. Sort locations by distance from user
6. Check for active ticket → if found, redirect to TicketScreen

**States**: Loading (spinner), Error (ErrorState widget with retry + sign out), Loaded (list)

---

### 4. ProfileScreen (`/profile`) - Tab 2

**Layout**:
- Circular profile photo with KNEX badge overlay
- User's full name
- User's email
- Menu list:
  - "My favorite sites" → FavoritesScreen
  - "Profile Settings" → ProfileCreateScreen
  - "Language" → ChangeLanguageScreen
  - "Help Center" (placeholder, no action)
  - "Dark mode" toggle switch
  - "Notification Settings" (placeholder, no action)
  - "Log out" → sign out + navigate to LoginScreen
- App version: "v1.0"

**On Load**: Fetch user profile, decode base64 photo to display

---

### 5. ProfileCreateScreen (`/profileCreate`)

**Layout**: Scrollable form

**Components**:
- KNEX logo header
- Profile photo upload area (tap to pick from camera/gallery)
  - Shows Lottie animation placeholder when no photo
  - Shows circular image preview when photo selected
- Form fields:
  - First Name (text)
  - Last Name (text)
  - Phone (with mask: `(###) ###-####`)
  - Address (with Google Places autocomplete suggestions)
  - Zip Code (numeric)
  - State (dropdown of all US states)
  - City (dropdown, dynamically populated based on selected state)
- "Save Info" button

**Dynamic Fields**: The app fetches an OpenAPI schema from Firebase Storage (`https://storage.googleapis.com/knex-attendant-25.firebasestorage.app/client_openapi.json`) to determine which fields are required. Parse the schema and only show/require fields that the schema marks as required.

**On Submit**:
1. Validate all required fields
2. Compress photo (flutter_image_compress)
3. Convert photo to base64
4. Send profile to API (createUserClient or searchUserClient+updateUserClient)
5. Set `userProfileCreated = true`
6. Navigate to HomeScreen

---

### 6. SiteDetailsScreen (`/siteDetails?id=<siteId>`)

**Layout**:
- Hero image (tappable for fullscreen view with photo_view)
- "Primary Site" badge
- Location name
- Address
- Star rating bar (flutter_rating_bar)
- Two action buttons side by side:
  - "Request Valet" → shows disclaimer dialog, then navigates to AddCarsScreen
  - "Call" → launches phone dialer with site phone number
- Description/bio text
- Favorite/unfavorite toggle button (heart icon, persists to favorites list)

**On Load**: Fetch locations, find matching location by ID

---

### 7. AddCarsScreen (`/addCars?id=<siteId>&notesJson=<optional>`)

**Layout**: Form for vehicle info

**Components**:
- KNEX logo + instructions
- Form fields (pre-populated from saved car if available):
  - Make and Model (with car icon prefix)
  - Color (with palette icon prefix)
  - License Plate (with document icon prefix)
- Checklist of valet notes/instructions (from `notesJson` parameter)
  - Each note is a checkbox item
  - "Custom notes" checkbox with text field that appears when checked
- "Save Info" button

**On Submit**:
1. Validate license plate is not empty
2. Create vehicle via `createVehicle` API
3. Persist vehicle locally to `myCar` state
4. Navigate to HomeScreen

---

### 8. TicketScreen (`/ticket`) - Active Valet Ticket

**Layout**:
- Carousel header with ticket info
- Barcode display (Code128 of ticket PIN, using barcode_widget)
- Ticket status with percentage progress indicator
- Lottie animations for different ticket states
- Action buttons:
  - "Cancel Request" → calls `setToCancelForClient` API
  - "Retrieve My Car" → calls `setToDeparture` API
- Tip button → opens TipBottomSheet
- Attendant info display (when assigned)
- "Go Home" button (when ticket completed)

**Real-Time Polling**: Use `Timer.periodic` (3 separate timers) to poll for:
1. Latest ticket data
2. Attendant info
3. Ticket status updates

**Ticket Statuses**: Pending → Accepted → InProgress → Completed/Cancelled

---

### 9. TicketTimerScreen (`/ticketTimer`)
Dedicated timer view for active valet session. Shows elapsed time with stop_watch_timer.

### 10. TicketCompletedScreen (`/ticketCompleted`)
Post-valet completion screen showing summary and tip prompt.

### 11. PayScreen (`/pay`)
Standalone payment screen with card details layout.

### 12. AddCreditCardScreen (`/addCreditCard`)
Credit card management screen for saving/viewing cards.

### 13. FavoritesScreen (`/favorites`)
Shows user's favorited valet locations from persisted favorites list. Shows empty state with Florida-themed message when no favorites.

### 14. HistoryScreen (`/history`)
Shows past valet service history from `getTicketList` API.

### 15. ListConfigScreen (`/listConfig`)
Filter/sort configuration:
- Distance unit toggle: metric / imperial
- Sort order: ascending / descending
- Sort by: distance / name / price

### 16. ChangeLanguageScreen (`/changeLanguage`)
Language selection: English, Spanish, French. Persists to SharedPreferences.

---

## Reusable Components

### ErrorStateWidget
```
Props:
  - title: String
  - message: String
  - onRetry: VoidCallback?
  - onSecondaryAction: VoidCallback? (label + callback)
  - compact: bool (for inline errors vs full-page)

Displays: animated error icon, title, message, retry button, optional secondary button
```

### TipBottomSheet
```
Props:
  - ticketNumber: String
  - baseValue: double (service price)
  - tipProposals: List<int> (e.g., [15, 20, 25])
  - currencyType: String

Displays: tip percentage buttons, custom amount field, "Pay" button
Triggers Stripe payment on submit
```

### AppButton
Standard styled button replacing FlutterFlow's FFButtonWidget:
- Primary/secondary variants
- Loading state with spinner
- Icon support
- Full-width option

### LoadingIndicator
Centered circular progress indicator (red/theme-colored)

---

## Stripe Integration

### Configuration
```
Test Publishable Key: pk_test_51HZhaXKSurfj8r0pw0ssMC4fKSkVVPaP773HO4sHi8G8u1enXvEL7sCUp7kSMBxSrbtNPXRvjQbgEJWftjDKN35S00VQ43BHRt
Merchant Country Code: CA
Merchant Display Name: KNEX
```

### Payment Flow
1. UI calls `processPayment(amount, currency, customerEmail, customerName)`
2. Call Firebase Cloud Function `initStripeTestPayment` (test) or `initStripePayment` (prod) with:
   ```json
   { "amount": <cents>, "currency": "<code>", "email": "<email>", "name": "<name>" }
   ```
3. Cloud Function returns: `{ paymentId, paymentIntent (client_secret), ephemeralKey, customer }`
4. Initialize Stripe PaymentSheet:
   ```dart
   Stripe.instance.initPaymentSheet(
     paymentIntentClientSecret: clientSecret,
     customerEphemeralKeySecret: ephemeralKey,
     customerId: customerId,
     merchantDisplayName: 'KNEX',
     style: ThemeMode.system,
     testEnv: true,
   )
   ```
5. Present payment sheet: `Stripe.instance.presentPaymentSheet()`
6. Return payment ID on success

### Tip Payment
Amount conversion: `(baseValue * tipPercentage / 100 * 100).round()` → Stripe expects cents

---

## Localization

### Languages
- English (en) - default
- Spanish (es)
- French (fr)

### Implementation
Use Flutter's built-in `flutter_localizations` with `.arb` files. All user-facing strings must have translations in all 3 languages.

### Florida Messages System (KEEP THIS SYSTEM)

The app uses a unique system of fun, Florida-themed messages for errors, validation, and feedback. These randomly vary to keep the UX fresh.

**File**: `lib/utils/florida_messages.dart` (port directly from existing code)

**Key methods** (all localized for EN/ES/FR):
- `errorTitle(context)` - Error dialog titles
- `genericError(context)` - Generic error messages
- `serverError(context)` - 500 errors
- `timeout(context)` - Request timeouts
- `noInternet(context)` - Connection issues
- `sessionExpired(context)` - Auth token expired
- `notFound(context)` - 404 errors
- `forbidden(context)` - 403 errors
- `badRequest(context)` - 400 errors
- `retryButton(context)` / `okButton(context)` / `cancelButton(context)` - Button labels
- `loadingDefault(context)` - Loading text
- `successGeneric(context)` - Success messages
- `plateRequired(context)` - License plate validation
- `emailRequired(context)` - Email validation
- `passwordsDontMatch(context)` - Password confirmation
- `photoRequired(context)` - Profile photo validation
- `stateRequired(context)` - State selection validation
- `invalidFileFormat(context, format)` - File upload validation
- `noFavoritesYet(context)` - Empty favorites
- `tipEmpty(context)` - Empty tip validation
- `paymentError(context, details)` - Payment failures
- `signInRequired(context)` - Re-auth needed
- `passwordResetSent(context)` - Reset confirmation
- `emailAlreadyInUse(context)` - Duplicate email
- `invalidCredentials(context)` - Wrong login
- `getMessageForStatusCode(context, code)` - HTTP status code messages
- `getMessageForError(context, error)` - Exception-based messages

Each method returns a randomly selected message from a pool of Florida-themed variants. Example:
```dart
static String genericError(BuildContext context) => _randomFromLocalized(context, [
  {
    'en': "Well, that went south faster than a snowbird in October!",
    'es': "Bueno, eso se fue al sur mas rapido que un turista en octubre!",
    'fr': "Eh bien, ca a tourne au vinaigre plus vite qu'un snowbird en octobre!",
  },
  {
    'en': "Looks like we hit a Florida pothole! Let's try again.",
    'es': "Parece que caimos en un bache de Florida! Intentemos de nuevo.",
    'fr': "On dirait qu'on a touche un nid-de-poule de Floride! Reessayons.",
  },
]);
```

---

## Theming

### Color Tokens
Define these in `AppColors`:
- `primary` - Main brand color
- `secondary` - Secondary brand color
- `tertiary` - Accent color
- `alternate` - Alternative background
- `primaryText` - Main text color
- `secondaryText` - Muted text color
- `primaryBackground` - Main background
- `secondaryBackground` - Card/surface background
- `info` - Info state color
- `success` - Success state color
- `warning` - Warning state color
- `error` - Error state color (use red as in current app)

### Typography
Use Google Fonts `Inter` and `Inter Tight` font families:
- `displaySmall`, `displayMedium`, `displayLarge`
- `headlineSmall`, `headlineMedium`, `headlineLarge`
- `titleSmall`, `titleMedium`, `titleLarge`
- `bodySmall`, `bodyMedium`, `bodyLarge`
- `labelSmall`, `labelMedium`, `labelLarge`

### Dark Mode
Support light and dark themes. Persist user preference to SharedPreferences.

---

## Utility Functions to Implement

### Distance Calculation (Haversine)
```dart
/// Calculate distance between two coordinates
/// Returns formatted string like "2.3 mi" or "3.7 km"
String calculateDistance(double lat1, double lon1, double lat2, double lon2, String unit)
```

### Image Utilities
```dart
/// Compress image bytes (quality ~70%)
Future<Uint8List> compressImage(Uint8List bytes)

/// Convert bytes to base64 string
String bytesToBase64(Uint8List bytes)

/// Convert base64 string to bytes
Uint8List base64ToBytes(String base64String)
```

### JSON Utilities
```dart
/// Extract a value from a JSON string by key
dynamic getKeyFromJsonString(String jsonString, String key)

/// Convert JSON array string to List<String>
List<String> jsonToArray(String jsonString)
```

### US States & Cities
```dart
/// Returns list of all US state names
List<String> statesList()

/// Returns list of city names for a given US state
List<String> citiesList(String state)
```

### Time Formatting
```dart
/// Parse ISO datetime, return human-readable relative time
String extractTime(String isoDateTimeString)
```

---

## Flow Manager Logic

The FlowManager is a central orchestrator for determining where the user should be routed. Implement this as a service or set of Riverpod providers:

### Profile Completeness Check
1. Fetch OpenAPI schema from Firebase Storage
2. Parse schema to determine required fields for `UserClient`
3. Fetch user profile from API by email
4. Compare profile fields against schema requirements
5. If any required field is empty/null → redirect to ProfileCreate
6. Otherwise mark profile as complete

### Active Ticket Check
1. Call `getLatestTicket` API
2. If ticket exists and status is NOT "Cancelled" or "Completed" → redirect to TicketScreen
3. Otherwise continue to HomeScreen

### Initial Route Decision
```
fetchProfile()
  → incomplete? → ProfileCreateScreen
  → complete? → checkActiveTicket()
    → active ticket? → TicketScreen
    → no ticket? → HomeScreen
```

---

## Key Behavioral Requirements

1. **Orientation Lock**: Lock to portrait mode on LoginScreen and HomeScreen load
2. **Splash Screen**: Show `knex_splash.png` during Firebase initialization and initial auth check (~1 second)
3. **Navigation Guards**: Prevent back-navigation from HomeScreen to LoginScreen after auth
4. **Auto-populate**: AddCars form should pre-fill from locally saved vehicle data
5. **Favorites**: Persist to SharedPreferences, show in FavoritesScreen, toggle from SiteDetails
6. **Ticket Polling**: When on TicketScreen, poll every few seconds for status updates
7. **Tip Flow**: After ticket completion, prompt for tip via bottom sheet → process via Stripe
8. **Google Places**: Address field in ProfileCreate should show autocomplete suggestions
9. **Photo Handling**: Profile photos are stored as base64 strings in the API, compressed before upload
10. **Error Resilience**: All API calls should handle errors gracefully with Florida-themed messages, never leave user stuck in loading state

---

## Assets to Include

### Images
- `app_launcher_icon.png` - App icon
- `knex-logo.png` - Standard logo
- `knex-logo-white.png` - White logo (dark backgrounds)
- `knex_splash.png` - Splash screen
- `defaultuser_turquesa.png` - Default avatar
- `error_image.png` - Error state image
- `bannerJames.png` - Carousel banner
- `masterCard@2x.png` - Card brand image

### Lottie Animations
- `loading.json` - Loading animation
- `loading2.json` - Alternative loading animation

### Fonts
- Inter (Variable weight)
- Inter Tight (Variable weight)

---

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # Routing
  go_router: ^14.0.0

  # Networking
  dio: ^5.4.0

  # Firebase
  firebase_core: ^3.14.0
  firebase_auth: ^5.6.0
  firebase_crashlytics: ^4.3.7
  firebase_performance: ^0.10.1
  firebase_storage: ^12.4.7
  cloud_functions: ^5.5.2

  # Auth
  google_sign_in: ^6.3.0
  sign_in_with_apple: ^7.0.1

  # Payments
  flutter_stripe: ^11.5.0

  # UI
  carousel_slider: ^5.0.0
  auto_size_text: ^3.0.0
  flutter_rating_bar: ^4.0.1
  percent_indicator: ^4.2.2
  barcode_widget: ^2.0.3
  flutter_animate: ^4.5.0
  lottie: ^3.1.2
  flutter_spinkit: ^5.2.0
  cached_network_image: ^3.4.1
  photo_view: ^0.15.0
  badges: ^2.0.2
  dropdown_button2: ^2.3.9
  font_awesome_flutter: ^10.7.0
  toastification: ^3.0.2

  # Media
  image_picker: ^1.1.2
  flutter_image_compress: ^2.4.0

  # Forms
  mask_text_input_formatter: ^2.9.0

  # Location
  location: ^7.0.1
  permission_handler: ^11.3.1

  # Storage
  shared_preferences: ^2.5.3
  path_provider: ^2.1.4

  # Utilities
  google_fonts: ^6.1.0
  intl: ^0.20.2
  url_launcher: ^6.3.1
  stop_watch_timer: ^3.0.2
  page_transition: ^2.1.0
  rxdart: ^0.27.7
  equatable: ^2.0.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  riverpod_generator: ^2.4.0
  flutter_lints: ^4.0.0
```

---

## Implementation Order (Recommended)

### Phase 1: Foundation
1. Create Flutter project with `flutter create --org com.knex knex_client`
2. Set up project structure (folders as specified above)
3. Configure Firebase (`flutterfire configure`)
4. Set up theming (AppColors, AppTypography, ThemeData)
5. Set up Riverpod providers (app state, storage service)
6. Set up go_router with all routes (placeholder screens)
7. Set up Dio-based API client with auth interceptor
8. Set up localization (.arb files)

### Phase 2: Authentication
1. Implement AuthService (email, Google, Apple sign-in)
2. Build LoginScreen with full UI
3. Implement auth state listening and routing guards
4. Implement splash screen

### Phase 3: Core Flow
1. Implement SchemaService (fetch + parse OpenAPI schema)
2. Build ProfileCreateScreen with dynamic field validation
3. Build HomeScreen with locations list + carousel
4. Implement FlowManager logic (profile check → ticket check → route)
5. Build SiteDetailsScreen

### Phase 4: Valet Service
1. Build AddCarsScreen with vehicle form
2. Implement vehicle creation API integration
3. Build TicketScreen with polling
4. Build TicketTimerScreen
5. Build TicketCompletedScreen

### Phase 5: Payments & Extras
1. Implement Stripe service
2. Build TipBottomSheet
3. Build PayScreen and AddCreditCardScreen
4. Build FavoritesScreen
5. Build HistoryScreen
6. Build ChangeLanguageScreen
7. Build ListConfigScreen

### Phase 6: Polish
1. Port FloridaMessages system
2. Add Lottie and flutter_animate animations
3. Implement NotificationService (toast notifications)
4. Add Crashlytics error reporting
5. Dark mode support
6. Responsive design (tablet/desktop bottom nav hiding)
7. Testing

---

## Important Notes

- The backend API has a known bug with `searchUserClient` returning "Converting circular structure to JSON" (500 error). Handle this gracefully on the client side.
- All API endpoints use POST method, even for reads — this is by design.
- The `idToken` field in API requests is the Firebase JWT, not a custom token.
- Profile photos can be large as base64 strings. Always compress before upload.
- The app is primarily used in South Florida (default coordinates: 26.132895, -80.104208).
- Keep the Florida-themed messaging system — it's a core part of the brand identity.
- The OpenAPI schema URL is from a DIFFERENT Firebase project (`knex-attendant-25`), not the client project.
