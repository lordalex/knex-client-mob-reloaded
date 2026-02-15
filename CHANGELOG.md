# CHANGELOG

All notable changes to the KNEX Client app are documented here.

---

## [0.1.0] - 2026-02-15

### iOS Configuration
- Tweaked `AppFrameworkInfo.plist`, `Info.plist`, and `AppDelegate.swift` for improved app setup
- Refined iOS permission descriptions and URL schemes

### Tickets Flow
- Improved `Ticket` model with additional helper methods
- Refactored `FlowManager` provider for cleaner active-ticket detection logic
- Updated `AddCarsScreen` flow and UX adjustments
- Enhanced `TicketScreen` with better polling and status handling
- Adjusted `HomeScreen` and `SiteDetailsScreen` routing

### API Client
- Adjusted `ApiClient` envelope parsing
- Added new endpoint entries in `endpoints.dart`

### Dependencies
- Refreshed `pubspec.lock`

---

## [0.0.9] - 2026-02-11

### Ticket Creation Simplified
- `AddCarsScreen`: after `createTicket` returns 200, navigates to `/home` instead of parsing ticket response and calling `generatePINandticket` directly; FlowManager handles active ticket routing
- Removed duplicate ticket creation via `generatePINandticket` call

### API Response Hardening
- `ApiClient`: added support for `{success, data}` envelope format alongside legacy `{status, data}` envelope
- `FlowManager`: unwraps `{data: [...]}` wrapper in `searchUserClient` and `getLatestTicket` responses; added detailed debug logging
- `HomeScreen`: handles `{data: [...]}` wrapper in `getLocations` response
- `TicketScreen`/`TicketTimerScreen`: handle `{data: [...]}` wrapper in `getLatestTicket` polling

### UI
- Replaced `CachedNetworkImage` with `Image.network` in `SiteDetailsScreen` and `LocationCard` to remove `cached_network_image` dependency

---

## [0.0.8] - 2026-02-10

### Ticket Creation Flow Fix
- Separated `createTicket` and `generatePIN` into a two-step flow
- Guarded against empty profile list in FlowManager
- Preserved PIN across poll updates to prevent race conditions
- Added new app screenshot (`01-ticket-screen.png`)

---

## [0.0.7] - 2026-02-08

### getLatestTicket List Response Handling
- Fixed `getLatestTicket` parsing across FlowManager, TicketScreen, and TicketTimerScreen to unwrap `List<dynamic>` responses (API returns a list, not a single map)
- Added `generatePINandticket` polling every 30s on TicketScreen with countdown pie indicator for PIN freshness
- Guarded TicketScreen polling so stale Cancelled tickets from `getLatestTicket` cannot overwrite locally-built active tickets
- Fixed `AddCarsScreen` local ticket status from `'Arrived'` to `Ticket.statusArrival` (`'Arrival'`) to match backend enum values

### API Endpoints & Ticket Model
- Removed unnecessary data payloads from `getLatestTicket` and `getTicketList` calls (backend resolves user from JWT per OpenAPI spec)
- Updated `Ticket` model status constants to real backend values: `Arrival`, `Processing-Arrival`, `Parked`, `Departure`, `Processing-Departure`
- Handle API key variants in `Ticket.fromJson` (`user_client`/`vehicle`/`location`)
- Parse Firestore Timestamp format `{_seconds, _nanoseconds}` in dates
- Switched history screen to `/search` endpoint (`getTicketList` returns all users)
- Added `/search` and `/get-enum` endpoints
- Added debug JWT token printer for API testing
- Added `client_openapi.json` to docs/

---

## [0.0.6] - 2026-02-07

### Branded Visual Polish
- Overhauled ticket flow screens (ticket, timer, completed) with dark navy-to-purple gradient backgrounds
- Added branded ticket card widget with barcode and animated transitions
- Updated add vehicle screen with branded header and consolidated form
- Polished site details with dark navy collapsed AppBar, bio card with watermark, and favorite button
- Restyled tip bottom sheet with USD-prefixed chips, total display, and navy button
- Added reusable `GradientBackground` and `TicketCard` widgets
- Fixed ticket polling to use `userClientId` consistently
- Added `AssetPaths` config and brand logo assets (`knex-logo-white.png`, `knex-logo.png`, `knex_splash.png`, `vallet_one.png`)

### Documentation
- Added comprehensive README with project overview, architecture, and setup guide
- Moved spec files (`KNEX_API_ENDPOINTS.md`, `KNEX_REBUILD_PROMPT.md`) to `docs/`
- Added screenshots and OpenAPI schema to `docs/`
- Reorganized docs assets into `docs/media/` with clean filenames (screenshots, logos, iOS app icons)
- Added screenshots section to README with `docs/media` paths

---

## [0.0.1] - 2026-02-06

### Initial Release - All 6 Phases Complete

**Phase 1 - Foundation**
- Flutter project scaffold with Firebase, Material 3 theming, Riverpod state management
- GoRouter with `StatefulShellRoute.indexedStack` for tab persistence
- Dio HTTP client with `AuthInterceptor` (auto `idToken` envelope wrapping)
- EN/ES/FR localization via `.arb` files
- Florida-themed message system (`FloridaMessages`) for branded UX copy

**Phase 2 - Authentication**
- Firebase Auth: Email/Password, Google Sign-In, Apple Sign-In
- Login screen with Sign In / Sign Up tabs
- Auth token sync via `idTokenChanges()` listener
- Splash screen with GoRouter redirect guards

**Phase 3 - Core Flow**
- `FlowManager` orchestrator: schema fetch, profile search, completeness check, routing
- `HomeScreen` with location cards, GPS distance sorting, filter preferences
- `ProfileCreateScreen` with dynamic schema-driven form, image picker, state/city dropdowns
- `SiteDetailsScreen` with hero image, PhotoView fullscreen, favorite toggle, disclaimer dialog
- `SchemaService`: standalone Dio to fetch OpenAPI schema from Firebase Storage

**Phase 4 - Valet Service**
- `AddCarsScreen`: vehicle creation via `/createVehicle`, ticket via `/generatePINandticket`
- `TicketScreen` with PIN barcode display (`code128`), 5s status polling, departure/cancel actions
- `TicketTimerScreen` with circular progress indicator, 1s UI timer + poll timer
- `TicketCompletedScreen` with summary and tip prompt

**Phase 5 - Payments & Extras**
- Stripe integration via Cloud Functions (`initStripeTestPayment`)
- `TipBottomSheet` with preset amounts ($3/$5/$10/$20) + custom input
- `PayScreen` with Stripe payment sheet
- `FavoritesScreen`, `HistoryScreen`, `ChangeLanguageScreen`, `ProfileScreen`

**Phase 6 - Polish**
- Persistence bridge via `StorageProvider` (SharedPreferences <-> Riverpod)
- Dark mode toggle, distance unit (imperial/metric), sort preferences
- `MyCar` local persistence with make/model/color/plate/state/notes fields

**70 Dart files, 0 analysis issues.**
