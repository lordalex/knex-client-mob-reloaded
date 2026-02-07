# KNEX - Valet Parking Client

A modern **Flutter** app for requesting valet parking services, managing vehicles, tracking tickets in real time, and tipping valets — all wrapped in a playful Florida-themed experience.

Built from scratch as a pure Flutter/Dart project with clean architecture, Riverpod state management, and full i18n support.

---

## Features

- **Multi-provider Authentication** — Email/password, Google Sign-In, and Apple Sign-In via Firebase Auth
- **Dynamic Profile Creation** — Form fields driven by a remote OpenAPI schema so the backend controls what's required
- **Location-aware Home Screen** — Browse valet sites sorted by distance, name, or price with live GPS
- **Vehicle Management** — Add, save, and reuse vehicles across sessions
- **Real-time Ticket Tracking** — Live polling with barcode display, elapsed timer, and status transitions
- **Stripe Payments** — Secure payment flow via Firebase Cloud Functions and Stripe Payment Sheet
- **Tipping** — Preset and custom tip amounts with instant submission
- **Favorites & History** — Save preferred locations and review past valet sessions
- **Trilingual Support** — Full localization in English, Spanish, and French
- **Dark Mode** — System-aware and manually togglable Material 3 theming
- **Florida Messages** — Randomized, Florida-themed copy for errors, validations, and UI feedback

---

## Tech Stack

| Layer | Technology |
|---|---|
| **Framework** | Flutter (Dart SDK ^3.10.7) |
| **State** | Riverpod (manual providers) |
| **Routing** | GoRouter with `StatefulShellRoute` |
| **Networking** | Dio with auth interceptor |
| **Auth** | Firebase Auth |
| **Backend** | Firebase (Core, Crashlytics, Performance, Storage, Cloud Functions) |
| **Payments** | flutter_stripe |
| **Localization** | ARB files (EN / ES / FR) |
| **Theming** | Material 3 + Google Fonts (Inter) |

---

## Architecture

```
lib/
├── main.dart                  # Entry point, Firebase init
├── app.dart                   # MaterialApp.router setup
├── config/                    # Theme, routes, constants
├── l10n/                      # ARB localization files
├── models/                    # Plain Dart models (no codegen)
├── services/                  # API client, auth, location, Stripe, schema
├── providers/                 # Riverpod providers (state layer)
├── screens/                   # 13 feature screens
├── widgets/                   # Reusable components
└── utils/                     # Florida messages, distance calc, validators
```

**70 Dart files** | **0 analysis issues**

### Key Patterns

- **ApiClient** — `post<T>()` never throws; returns `ApiResponse<T>` with `.data` or `.error()`
- **AuthInterceptor** — Transparently wraps every request in `{ "idToken": ..., "data": ... }`
- **FlowManager** — Orchestrates post-login routing: schema fetch, profile check, active ticket detection
- **StorageProvider** — Bridges Riverpod state with SharedPreferences for persistence across sessions
- **Florida Messages** — Branded copy system with 3 randomized variants per category in all 3 languages

---

## Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Xcode (for iOS) / Android Studio (for Android)
- Firebase project configured

### Setup

```bash
# 1. Clone the repo
git clone git@github.com:lordalex/knex-client-mob-reloaded.git
cd knex-client-mob-reloaded

# 2. Install dependencies
flutter pub get

# 3. Configure Firebase (generates platform config files)
flutterfire configure

# 4. Generate localization files
flutter gen-l10n

# 5. Run
flutter run
```

### Environment

The app connects to the KNEX backend at `https://client.knex-app.xyz/api`. All authenticated endpoints use POST with a Firebase JWT envelope. Stripe runs in test mode by default.

---

## Screens

| Screen | Description |
|---|---|
| **Splash** | Animated loading with auth state check |
| **Login** | Tabbed Sign In / Sign Up with social auth |
| **Profile Create** | Schema-driven dynamic form |
| **Home** | Location list with sort/filter and GPS |
| **Site Details** | Hero image, info, favorite toggle, valet request |
| **Add Cars** | Vehicle entry with saved car support |
| **Ticket** | Live status, barcode PIN, auto-routing |
| **Ticket Timer** | Circular progress with elapsed time |
| **Ticket Completed** | Summary, rating, tip prompt |
| **Pay** | Stripe Payment Sheet integration |
| **Favorites** | Saved valet locations |
| **History** | Past ticket records |
| **Profile / Settings** | Edit profile, language, dark mode, sign out |

---

## Localization

Strings are defined in ARB files under `lib/l10n/`:

- `app_en.arb` — English
- `app_es.arb` — Spanish
- `app_fr.arb` — French

Generate after editing:

```bash
flutter gen-l10n
```

---

## License

Proprietary. All rights reserved.
