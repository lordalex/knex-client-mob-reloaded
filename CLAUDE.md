# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

KNEX is a valet parking client app rebuilt as a **pure Flutter/Dart project** (no FlutterFlow). Users request valet parking services, manage vehicles, view real-time ticket status, and tip valets via Stripe. The full specification lives in `KNEX_REBUILD_PROMPT.md`.

## Build & Run Commands

```bash
# Create the project (first time only)
flutter create --org com.knex knex_client

# Get dependencies
flutter pub get

# Generate Riverpod code (after modifying providers with annotations)
dart run build_runner build --delete-conflicting-outputs

# Generate localization files (after editing .arb files)
flutter gen-l10n

# Configure Firebase
flutterfire configure

# Run the app
flutter run

# Run tests
flutter test
flutter test test/path/to/specific_test.dart

# Analyze code
flutter analyze
```

## Tech Stack

- **State Management**: Riverpod (`flutter_riverpod` + `riverpod_annotation` + code generation via `build_runner`)
- **Routing**: `go_router` with `NavShell` bottom navigation wrapper
- **Networking**: `dio` with interceptors for auth token injection and error handling
- **Auth**: Firebase Auth (Email/Password, Google Sign-In, Apple Sign-In)
- **Backend**: Firebase (Core, Crashlytics, Performance, Storage, Cloud Functions)
- **Payments**: `flutter_stripe` with Firebase Cloud Functions for payment intents
- **Localization**: `.arb` files for EN/ES/FR via `flutter_localizations`
- **Theming**: Material 3 with custom `ThemeExtension`, Google Fonts (Inter, Inter Tight)

## Architecture

### API Pattern
All backend endpoints use **POST** (even reads). Every authenticated request wraps the payload:
```json
{ "idToken": "<Firebase JWT>", "data": { ...payload } }
```
Base URL: `https://client.knex-app.xyz/api`

### Flow Manager (Routing Orchestrator)
On app load, the FlowManager determines the user's destination:
1. Fetch OpenAPI schema from Firebase Storage (`knex-attendant-25` project, not the client project) to determine required profile fields
2. Fetch user profile via `searchUserClient` by email
3. If profile incomplete → `ProfileCreateScreen`
4. If active ticket exists (not Cancelled/Completed) → `TicketScreen`
5. Otherwise → `HomeScreen`

### State Architecture
- **Persisted state** (SharedPreferences): profile completion flag, email validation, favorite site IDs, saved vehicle (`MyCar`), distance unit, sort preferences, language
- **In-memory state** (Riverpod providers): user GPS location, base64 photo buffer, auth token
- JWT token refreshes via `FirebaseAuth.instance.idTokenChanges()` listener, stored in a Riverpod provider, attached to requests via Dio interceptor

### Data Model Quirks
- `UserClientProfile`: API returns keys in both camelCase and lowercase variants (e.g., `firstName` or `firstname`). Models must handle both.
- `Vehicle`: JSON keys use snake_case (`vehicle_make`, `license_plate`, etc.)
- `Location.rawData`: contains coordinates, company, photos, bio, currency, price, phone as a dynamic map

### Florida Messages System
A core brand feature — all error messages, validation feedback, and UI copy use randomized Florida-themed messages. Each message has EN/ES/FR variants. Located in `lib/utils/florida_messages.dart`. This system must be preserved.

## Key Backend Quirks

- `searchUserClient` has a known 500 error ("Converting circular structure to JSON") — handle gracefully client-side
- The OpenAPI schema URL is from a **different** Firebase project (`knex-attendant-25.firebasestorage.app`), not the client project (`knex-client24`)
- Stripe test keys are used; payment intents are created via Firebase Cloud Functions (`initStripeTestPayment` / `initStripePayment`)
- Default GPS coordinates (South Florida): `26.132895, -80.104208`

## Project Structure

```
lib/
├── main.dart              # Entry point, Firebase init
├── app.dart               # MaterialApp.router setup
├── config/                # Theme (colors, typography), routes (go_router), constants
├── l10n/                  # .arb localization files (EN/ES/FR)
├── models/                # Data models (UserClientProfile, Vehicle, Ticket, Location, MyCar)
├── services/              # API client (Dio), auth, location, storage, Stripe, schema
├── providers/             # Riverpod providers (app state, profile, locations, tickets, theme)
├── screens/               # Feature screens organized by domain
├── widgets/               # Reusable components (ErrorState, TipBottomSheet, AppButton, etc.)
└── utils/                 # Florida messages, Haversine distance, image/JSON utils, validators
```

## Implementation Phases

The recommended build order is in `KNEX_REBUILD_PROMPT.md` under "Implementation Order":
1. **Foundation** — project scaffold, Firebase, theming, Riverpod, go_router, Dio client, l10n
2. **Authentication** — AuthService, LoginScreen, auth guards, splash
3. **Core Flow** — SchemaService, ProfileCreate, HomeScreen, FlowManager, SiteDetails
4. **Valet Service** — AddCars, vehicle API, TicketScreen with polling, timer, completion
5. **Payments & Extras** — Stripe, tips, favorites, history, settings screens
6. **Polish** — Florida messages, animations, Crashlytics, dark mode, responsive, tests
