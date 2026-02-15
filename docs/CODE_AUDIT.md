# KNEX Client - Code Quality Audit

**Date:** 2026-02-15
**Branch:** `dev` @ `d1a7246`
**Files Audited:** 70 Dart files + config/assets
**Flutter Analysis Issues:** 0

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [File Ratings](#file-ratings)
3. [Models Audit](#models-audit)
4. [Services Audit](#services-audit)
5. [Providers Audit](#providers-audit)
6. [Screens Audit](#screens-audit)
7. [Widgets Audit](#widgets-audit)
8. [Config & Theme Audit](#config--theme-audit)
9. [Utils Audit](#utils-audit)
10. [Localization Audit](#localization-audit)
11. [Dependencies Audit](#dependencies-audit)
12. [Cross-Cutting Issues](#cross-cutting-issues)
13. [Critical Findings Table](#critical-findings-table)
14. [API Endpoints Inventory](#api-endpoints-inventory)
15. [Recommendations](#recommendations)

---

## Executive Summary

**Overall Grade: B+ (84/100)**

The KNEX Flutter codebase is a professionally structured valet parking client with zero analysis issues, comprehensive localization (108 keys x 3 languages), a complete Material 3 design system, and robust API handling. The app covers all 6 implementation phases from foundation to polish.

**Strengths:**
- Zero Flutter analysis issues across 70 Dart files
- Solid Material 3 design system (colors, typography, theme extensions)
- Comprehensive Florida-branded messaging system (EN/ES/FR)
- Robust API response parsing with multiple envelope format handling
- Proper resource cleanup (timers, controllers, listeners disposed)
- Clean architecture with separation of concerns

**Weaknesses:**
- ~60+ hardcoded UI strings not routed through localization
- FlowManager provider does too much (4 responsibilities in one provider)
- Unsafe force casts in flow_manager_provider (crash risk)
- Image compression stub unimplemented
- Linting rules not enabled beyond defaults

---

## File Ratings

### Models
| File | Grade |
|------|-------|
| api_response.dart | A |
| location.dart | A- |
| my_car.dart | A |
| ticket.dart | A |
| user_client_profile.dart | A- |
| vehicle.dart | A |

### Services
| File | Grade |
|------|-------|
| api/api_client.dart | A- |
| api/api_interceptors.dart | A |
| api/endpoints.dart | A |
| auth/auth_service.dart | A |
| auth/auth_providers.dart | A- |
| location_service.dart | A |
| schema_service.dart | A- |
| storage_service.dart | A |
| stripe_service.dart | A- |
| notification_service.dart | C (stub) |

### Providers
| File | Grade |
|------|-------|
| api_provider.dart | A |
| app_state_provider.dart | A |
| flow_manager_provider.dart | B+ |
| locations_provider.dart | A |
| profile_provider.dart | A |
| storage_provider.dart | A- |
| theme_provider.dart | A |
| ticket_provider.dart | A |

### Screens
| File | Grade |
|------|-------|
| splash/splash_screen.dart | A |
| login/login_screen.dart | B+ |
| home/home_screen.dart | B |
| profile_create/profile_create_screen.dart | B+ |
| site_details/site_details_screen.dart | B |
| add_cars/add_cars_screen.dart | B |
| ticket/ticket_screen.dart | B+ |
| ticket/ticket_timer_screen.dart | A- |
| ticket/ticket_completed_screen.dart | A |
| payment/pay_screen.dart | B+ |
| payment/add_credit_card_screen.dart | B |
| profile/profile_screen.dart | B |
| settings/change_language_screen.dart | A- |
| settings/list_config_screen.dart | B+ |
| favorites/favorites_screen.dart | B+ |
| history/history_screen.dart | B |
| shell/nav_shell.dart | A |

### Widgets
| File | Grade |
|------|-------|
| app_button.dart | A |
| error_state.dart | A |
| loading_indicator.dart | A |
| gradient_background.dart | A |
| location_card.dart | B+ |
| ticket_card.dart | B+ |
| tip_bottom_sheet.dart | B |
| card_item.dart | A- |
| card_list.dart | A |
| city_dropdown.dart | A- |
| success_ticket.dart | A |

### Config & Utils
| File | Grade |
|------|-------|
| config/app_constants.dart | A+ |
| config/asset_paths.dart | A |
| config/theme/app_colors.dart | A+ |
| config/theme/app_typography.dart | A |
| config/theme/app_theme.dart | A+ |
| config/routes/route_names.dart | A |
| config/routes/app_router.dart | A- |
| utils/florida_messages.dart | A+ |
| utils/distance.dart | A+ |
| utils/validators.dart | A- |
| utils/extensions.dart | A |
| utils/image_utils.dart | B+ |
| utils/json_utils.dart | A |
| utils/us_states.dart | A |
| main.dart | A- |
| app.dart | A |

---

## Models Audit

### api_response.dart - A
Robust generic response wrapper. Catches all exceptions during data parsing. Gracefully handles multiple API response formats (legacy `{status, data}` envelope and modern `{success, data}` format). No dynamic usage without proper checks.

### location.dart - A-
Smart handling of inconsistent API response shapes (coordinates as Map or flat keys, company as String or Map). Helper method `_toDouble` handles type conversions safely. Minor: `photos` getter uses `whereType<String>()` which is safe but could log unexpected types.

### my_car.dart - A
Clean immutable data model. Proper nullable fields, well-structured `copyWith`, equality operators implemented correctly.

### ticket.dart - A
Robust parsing helpers `_parseDouble()` and `_parseDateTime()` handle multiple input formats including Firestore timestamps `{_seconds, _nanoseconds}`. Good coverage for snake_case API key variants.

### user_client_profile.dart - A-
Handles backend's inconsistent casing (camelCase vs lowercase) well. `_parseDateTime` helper handles multiple formats. Minor: redundant `as String?` cast after null coalescing is harmless but unclear.

### vehicle.dart - A
Clean snake_case to camelCase mapping. Default empty strings for required fields ensure safety.

---

## Services Audit

### api/api_client.dart - A-
Comprehensive try-catch blocks. Handles 3 different envelope formats (legacy, modern `{success, data}`, and non-envelope maps). `post` method is 115 lines and could be broken down. Extensive debugPrint statements useful for development.

### api/api_interceptors.dart - A
Well-structured with single responsibility per interceptor. AuthInterceptor gracefully handles missing/null tokens. ErrorInterceptor provides fallback messages for all error types. Token handling is clean.

### api/endpoints.dart - A
Simple, well-organized constant collection with comments.

### auth/auth_service.dart - A
Proper credential delegation to Firebase. Google sign-in returns null on cancel, properly handled. Email trimmed before use. Password not logged.

### auth/auth_providers.dart - A-
Good separation with AuthService as singleton. Minor: `getIdToken()` on line 42 can throw but lacks explicit try-catch wrapper.

### location_service.dart - A
Comprehensive permission handling covering denied, deniedForever, and granted states. Returns null on any failure. Uses clean record type `(double, double)?`.

### schema_service.dart - A-
Issue: `required.cast<String>()` on line 62 could fail if list contains non-strings. Should use `whereType<String>().toList()` instead. Nested null checks create a pyramid structure.

### storage_service.dart - A
Clean wrapper around SharedPreferences. JSON parsing wrapped in try-catch with safe defaults.

### stripe_service.dart - A-
Issue: `result.data` assumed to be `Map<String, dynamic>` without type check. If Cloud Function returns unexpected format, this crashes. Returns null on failure which is good.

### notification_service.dart - C
Stub with TODO comments. Not implemented. Should be removed or properly implemented.

---

## Providers Audit

### flow_manager_provider.dart - B+
**Highest-risk file in the codebase.** Combines 4 responsibilities (schema fetch, profile search, ticket check, routing decision) in a single 194-line provider.

Issues:
- **Unsafe force casts** on lines 84 and 154: `(raw as Map<String, dynamic>)` without prior type verification
- **Code duplication**: Lines 73-85 and 143-155 have nearly identical unwrapping logic
- Creates new SchemaService instance on each evaluation
- Extensive debugPrint statements should be conditional

### storage_provider.dart - A-
Well-structured persistence bridge between SharedPreferences and Riverpod. Good use of `ref.listen` for persistence. Safe default handling.

### Other providers - A
Simple, clean state holders. No issues.

---

## Screens Audit

### login_screen.dart - B+
Good: Proper disposal of TabController and all TextEditingControllers. Florida messages for errors. Social login with platform detection.
Issues: Hardcoded strings ("Valet Parking", "Sign In", "Sign Up", "or"). Visibility toggle logic repeated for multiple fields.

### home_screen.dart - B
Good: FlowManager integration, error/loading states, CustomScrollView.
Issues: Hardcoded strings ("Request valet?", "No locations found nearby"). Banner building (lines 338-415) should extract sub-widget. Multiple `ref.watch()` calls could trigger unnecessary rebuilds.

### profile_create_screen.dart - B+
Good: Dynamic schema-driven form, proper controller disposal, phone mask formatter.
Issues: Hardcoded labels ("Create Profile", "First Name", "Required"). Photo picker logic should be extracted to sub-widget.

### site_details_screen.dart - B
Good: Error handling for missing location, hero image with states.
Issues: Hardcoded strings ("Primary Site", "Service:", "USD", "Request Valet", "Call"). Disclaimer dialog text not localized. Missing semantic labels on favorite toggle.

### add_cars_screen.dart - B
Good: Clean API integration with vehicle-then-ticket flow, optional fields collapsing.
Issues: All field labels hardcoded, not localized.

### ticket_screen.dart - B+
Good: Excellent cleanup in `dispose()` (cancels 3 timers). Smart polling guards. PIN refresh countdown.
Issues: debugPrint statements should be removed for production. Action button section (lines 373-444) could extract sub-widget.

### ticket_timer_screen.dart - A-
Good: Proper timer management with cleanup, beautiful circular progress, gradient background.
Issues: Minor hardcoded strings ("Pick your car", "ELAPSED", "Powered by KNEX").

### ticket_completed_screen.dart - A
Clean ConsumerWidget, good animations via flutter_animate. Minor hardcoded text.

### pay_screen.dart - B+
Good Stripe integration. Issues: Hardcoded $5.00 amount, `_initialized` flag should be a provider.

### history_screen.dart - B
Good: RefreshIndicator, error/loading/empty states. Issues: Hardcoded labels in `_TicketHistoryCard`.

### profile_screen.dart - B
Clean settings hub. Issues: All ListTile labels hardcoded (8+ strings).

### change_language_screen.dart - A-
Good language selection with flag emojis. Minor hardcoded "Language" title.

### nav_shell.dart - A
Clean StatefulShellRoute integration. Minor hardcoded nav labels.

---

## Widgets Audit

### app_button.dart - A
Excellent reusable component supporting loading, icon, and outlined variants.

### error_state.dart - A
Well-designed with compact mode and optional secondary action.

### gradient_background.dart - A
Clean gradient wrapper with proper system UI overlay style.

### location_card.dart - B+
Good card design with image loading/error handling. Missing semantic label on InkWell.

### ticket_card.dart - B+
Beautiful branded ticket design with barcode. Issue: Magic number `0xFF2D1B69` should be in AppColors. Hardcoded "YOUR PIN" and "VALET ONE" text.

### tip_bottom_sheet.dart - B
Good preset + custom amount pattern. Issues: Multiple hardcoded strings ("Tip Amount", "USD", "Custom", "Total Amount", "Skip"). No semantic labels on ChoiceChips.

---

## Config & Theme Audit

### app_constants.dart - A+
Excellent organization with clear sections. All keys documented. Good separation of API URLs, Firebase config, Stripe keys, defaults, timeouts.

### app_colors.dart - A+
Excellent Material 3 color token design with 12 semantic colors, both light and dark variants. KNEX brand red (0xFFE21C3D) consistently applied.

### app_typography.dart - A
Complete Material 3 typography scale (14 levels). Inter Tight for display/headline, Inter for body/label. Correct font weights and spacing.

### app_theme.dart - A+
Complete ThemeData for light + dark modes. All standard components themed. KnexThemeExtension with info/success/warning tokens. Proper `lerp()` and `copyWith()`.

### app_router.dart - A-
Proper StatefulShellRoute, GoRouterRefreshStream, redirect logic. Issue: If Firebase fails to init, router won't react to auth changes (edge case).

---

## Utils Audit

### florida_messages.dart - A+
Exceptional brand personality with 15+ message categories. Complete trilinguality (EN/ES/FR, 108 keys). Smart pattern matching for error detection. Random selection prevents message fatigue.

### distance.dart - A+
Correct Haversine formula. Handles both metric and imperial. Verified: `a = sin^2(dphi/2) + cos(phi1)*cos(phi2)*sin^2(dlambda/2)`.

### validators.dart - A-
Composable validators following standard Flutter pattern. Issue: Email regex `r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$'` rejects valid emails with deep subdomains or TLDs like `.co.uk`. Recommendation: change last part to `{2,}`.

### image_utils.dart - B+
Issue: `compressImage()` is a stub (returns bytes unchanged). `flutter_image_compress` is in pubspec but never used. Uncompressed profile photos waste bandwidth.

### extensions.dart - A
Concise single-responsibility extensions for String and BuildContext. Tablet detection at 600px is standard.

---

## Localization Audit

**Key Count:** EN=108, ES=108, FR=108 (all aligned)

**Categories covered:** App metadata, navigation, buttons (17), screen titles (14), form labels (14), messages (16), content (7), configuration (6), language names (3), ticket statuses (5).

**Spanish quality:** Proper accents, cultural adaptation ("Iniciar Sesion").
**French quality:** Proper accents and gender agreement. One bug: `app_fr.arb` line 23 — "Retour a l'accueil" should be "Retour **a** l'accueil" (missing accent on a).

**Gap:** ~60+ hardcoded strings in screens/widgets are NOT using these l10n keys. The .arb files have the keys defined, but many screens use inline English strings instead.

---

## Dependencies Audit

### pubspec.yaml - A
Clean dependencies, appropriate version constraints, dev dependencies properly separated.

**Potential unused:**
- `rxdart` (^0.27.7) — not observed in codebase
- `equatable` (^2.0.7) — not observed in codebase
- `riverpod_generator` in dev_dependencies but no `@riverpod` annotations used (manual Riverpod throughout)

### analysis_options.yaml - C+
Only default Flutter lints enabled. All custom rules commented out. Missing important rules like `prefer_single_quotes`, `avoid_empty_else`, `prefer_final_fields`, `unnecessary_await_in_return`.

---

## Cross-Cutting Issues

### 1. Hardcoded Strings (HIGH PRIORITY)
~60+ user-facing strings across screens and widgets that bypass the localization system. The .arb keys exist for many of these but aren't wired up.

**Worst offenders:** profile_screen.dart (8+ strings), site_details_screen.dart (5+), add_cars_screen.dart (6+), list_config_screen.dart (8+), tip_bottom_sheet.dart (6+).

### 2. Widget Extraction Opportunities (MEDIUM)
| Screen | Section | Suggestion |
|--------|---------|-----------|
| HomeScreen | Banner carousel (338-415) | Extract `_BannerCard` widget |
| LoginScreen | Error banner (131-169) | Extract `AuthErrorBanner` |
| ProfileCreateScreen | Photo picker (257-277) | Extract `_PhotoPickerSection` |
| TicketScreen | Action buttons (373-444) | Extract `_TicketActions` |

### 3. Magic Numbers & Colors (MEDIUM)
- `ticket_card.dart:169` — `0xFF2D1B69` should be in `AppColors`
- `home_screen.dart:344-363` — Hardcoded `0xFF0A2647`, `0xFF144272`
- Various hardcoded SizedBox dimensions

### 4. Accessibility (MEDIUM)
- Missing semantic labels on icon buttons (favorite toggles, action icons)
- No Tooltip widgets for ambiguous icons
- No semantic labels on ChoiceChips and RadioListTiles

### 5. Performance (LOW)
- Multiple `ref.watch()` in HomeScreen build could cause excess rebuilds
- Some `setState()` in polling functions (could use Stream/Provider)
- Missing const constructors on some frequently-rebuilt widgets

---

## Critical Findings Table

| Severity | File | Line(s) | Issue | Fix |
|----------|------|---------|-------|-----|
| HIGH | flow_manager_provider | 84, 154 | Unsafe force cast `as Map<String, dynamic>` without type check | Add `if (raw is Map<String, dynamic>)` guard |
| HIGH | stripe_service | 38 | Cloud Function result assumed to be Map | Add explicit type check before accessing |
| HIGH | analysis_options.yaml | 23-25 | No linting rules enabled beyond defaults | Enable strict rules |
| MEDIUM | image_utils.dart | 23 | `compressImage()` stub — uncompressed uploads | Implement with flutter_image_compress |
| MEDIUM | schema_service | 62 | `cast<String>()` crashes on mixed-type list | Use `whereType<String>().toList()` |
| MEDIUM | flow_manager_provider | 73-85, 143-155 | Duplicated response unwrapping logic | Extract helper function |
| MEDIUM | flow_manager_provider | all | 194 lines, 4 responsibilities | Split into separate providers |
| MEDIUM | validators.dart | 29 | Email regex rejects valid emails (.co.uk) | Change `{2,4}` to `{2,}` |
| MEDIUM | app_fr.arb | 23 | Missing accent: "a" should be "a" | Fix accent |
| MEDIUM | ~15 screens | various | ~60+ hardcoded strings bypass l10n | Wire to AppLocalizations |
| LOW | auth_providers | 42 | `getIdToken()` can throw without try-catch | Add explicit try-catch |
| LOW | notification_service | all | Stub file, not implemented | Remove or implement |
| LOW | pubspec.yaml | 16-17 | Possibly unused: rxdart, equatable | Verify and remove if unused |
| LOW | asset_paths.dart | 15, 18 | Typo: "vallet" should be "valet" | Rename assets |

---

## API Endpoints Inventory

### Base Configuration

| Key | Value |
|-----|-------|
| **Base URL** | `https://client.knex-app.xyz/api` |
| **HTTP Method** | All endpoints use POST |
| **Auth Envelope** | `{ "idToken": "<JWT>", "data": { ...payload } }` |
| **Auth Injection** | Automatic via `AuthInterceptor` |

### Response Formats

The backend uses two envelope formats. `ApiClient` normalizes both:

**Legacy:** `{ "status": { "status": "success", "result": "READ", "message": "..." }, "data": <T> }`

**Modern:** `{ "success": true, "data": <T>, "endpoint": "..." }`

---

### User Client Endpoints

#### 1. `/searchUserClient` — Find user profile
| Field | Value |
|-------|-------|
| **Payload** | `{ email }` |
| **Response** | `UserClientProfile` (as List or `{data: [...]}`) |
| **Called by** | `flow_manager_provider.dart` |
| **Purpose** | Check if user profile exists and is complete |
| **Quirks** | Known 500 error ("Converting circular structure to JSON") — treated as "new user". Returns List even for single result. May wrap in `{data: [...]}` or return bare List. |

#### 2. `/createUserClient` — Create new profile
| Field | Value |
|-------|-------|
| **Payload** | `{ firstName, lastName, phoneNumber, photo, address, city, state, zipCode, email, uid }` |
| **Response** | `UserClientProfile` |
| **Called by** | `profile_create_screen.dart` |
| **Purpose** | Create new user profile with required fields |

#### 3. `/updateUserClient` — Update existing profile
| Field | Value |
|-------|-------|
| **Payload** | `{ id, firstName, lastName, phoneNumber, photo, address, city, state, zipCode, email, uid }` |
| **Response** | `UserClientProfile` |
| **Called by** | `profile_create_screen.dart` |
| **Purpose** | Update incomplete profile |

#### 4-6. `/getUserClient`, `/deleteUserClient`, `/listUserClients`
Defined in `endpoints.dart` but **not currently called** by any screen.

---

### Vehicle Endpoints

#### 7. `/createVehicle` — Create/upsert vehicle
| Field | Value |
|-------|-------|
| **Payload** | `{ user_client_id, vehicle_make, vehicle_model, license_plate, color }` |
| **Response** | `Vehicle` with `id` |
| **Called by** | `add_cars_screen.dart` (Step 1 before ticket creation) |
| **Purpose** | Create vehicle record for valet service |

#### 8-11. `/listVehicles`, `/getVehicle`, `/updateVehicle`, `/deleteVehicle`
Defined in `endpoints.dart` but **not currently called**.

---

### Ticket Endpoints

#### 12. `/createTicket` — Create valet ticket
| Field | Value |
|-------|-------|
| **Payload** | `{ user_client, email, vehicle, location, notes? }` |
| **Response** | `Ticket` |
| **Called by** | `add_cars_screen.dart` (Step 2 after createVehicle) |
| **Purpose** | Create a new valet parking ticket |

#### 13. `/generatePINandticket` — Generate/refresh PIN
| Field | Value |
|-------|-------|
| **Payload** | `{ email, vehicle, location }` |
| **Response** | `{ pin: "XXXX", ... }` |
| **Called by** | `ticket_screen.dart` (every 30s while status is "Arrival") |
| **Purpose** | Generate fresh PIN for valet attendant |
| **Quirks** | Only called while `status == "Arrival"`. Calling after status change creates a NEW ticket. Polling stops once attendant accepts. |

#### 14. `/getLatestTicket` — Poll active ticket
| Field | Value |
|-------|-------|
| **Payload** | Empty (backend resolves user from JWT) |
| **Response** | `Ticket` (as List or `{data: [...]}`) |
| **Called by** | `flow_manager_provider.dart` (on load), `ticket_screen.dart` (every 5s), `ticket_timer_screen.dart` (every 5s) |
| **Purpose** | Check for active ticket and poll status changes |
| **Quirks** | PIN field often omitted in polls — client preserves existing PIN. Returns List or wrapped `{data: [...]}`. |

#### 15. `/setToDeparture` — Request car pickup
| Field | Value |
|-------|-------|
| **Payload** | `{ id }` (ticket ID) |
| **Response** | Updated `Ticket` |
| **Called by** | `ticket_screen.dart` (user taps "Request Pick Up") |
| **Purpose** | Transition ticket to Departure status |

#### 16. `/setToCancelForClient` — Cancel ticket
| Field | Value |
|-------|-------|
| **Payload** | `{ id }` (ticket ID) |
| **Response** | Confirmation |
| **Called by** | `ticket_screen.dart` (user confirms cancel) |
| **Purpose** | User-initiated ticket cancellation |

#### 17. `/setTicketTip` — Submit tip
| Field | Value |
|-------|-------|
| **Payload** | `{ id, tip }` (ticket ID, amount in dollars) |
| **Response** | Confirmation |
| **Called by** | `tip_bottom_sheet.dart` |
| **Purpose** | Set tip amount for completed service |

#### 18-22. `/getTicketList`, `/getTicketByPIN`, `/setTicketStatus`, `/updateTicket`, `/updateTicketPhotos`
Defined in `endpoints.dart` but **not currently called**.

---

### Location Endpoints

#### 23. `/getLocations` — Fetch valet locations
| Field | Value |
|-------|-------|
| **Payload** | `{ userClientId }` (optional) |
| **Response** | `List<ValetLocation>` (as List or `{data: [...]}`) |
| **Called by** | `home_screen.dart` |
| **Purpose** | Load all available valet service locations |
| **Quirks** | Returns either bare List or wrapped `{data: [...]}`. Includes metadata: name, address, company, photos, bio, price, currency, rating. |

---

### Search & Enum Endpoints

#### 24. `/search` — Generic search
| Field | Value |
|-------|-------|
| **Payload** | `{ modelName: "Ticket", searchCriteria: { user_client: <id> } }` |
| **Response** | `{ results: [Ticket] }` |
| **Called by** | `history_screen.dart` |
| **Purpose** | Fetch ticket history for user |
| **Quirks** | Response wraps results in `results` key (not standard `data` envelope). |

#### 25. `/get-enum`
Defined but **not currently called**.

---

### Payment Endpoints

#### 26. `/confirmPayment`
Defined but **not currently called** (payment flow uses Stripe Cloud Functions instead).

---

### Provisional Ticket Endpoints (No Auth Required)

#### 27-29. `/createProvisionalTicket`, `/linkUserClientToTicketByProvisionalPIN`, `/setToDepartureCasual`
Defined but **not currently called**. Intended for walk-up valet service without authentication.

---

### Firebase Cloud Functions

#### 30. `initStripeTestPayment`
| Field | Value |
|-------|-------|
| **Type** | Firebase `httpsCallable` |
| **Payload** | `{ amount (cents), currency, ticketId }` |
| **Response** | `{ clientSecret, paymentIntentId }` |
| **Called by** | `stripe_service.dart` |
| **Purpose** | Create Stripe payment intent server-side |
| **Flow** | Call function -> receive clientSecret -> init payment sheet -> present to user |

---

### External Services

#### 31. OpenAPI Schema (Firebase Storage)
| Field | Value |
|-------|-------|
| **URL** | `https://storage.googleapis.com/knex-attendant-25.firebasestorage.app/openapi.json` |
| **Method** | GET (no auth) |
| **Called by** | `schema_service.dart` via `flow_manager_provider.dart` |
| **Purpose** | Determine required profile fields |
| **Note** | Hosted on the **attendant** Firebase project, not the client project |

---

### Endpoints by Screen

| Screen | Endpoints Used |
|--------|---------------|
| SplashScreen | (none) |
| LoginScreen | (Firebase Auth only) |
| HomeScreen | `getLocations` |
| ProfileCreateScreen | `createUserClient`, `updateUserClient` |
| SiteDetailsScreen | (none — receives data from HomeScreen) |
| AddCarsScreen | `createVehicle`, `createTicket` |
| TicketScreen | `getLatestTicket` (5s poll), `generatePINandticket` (30s poll), `setToDeparture`, `setToCancelForClient` |
| TicketTimerScreen | `getLatestTicket` (5s poll) |
| TicketCompletedScreen | (none) |
| PayScreen | Cloud Function `initStripeTestPayment` |
| TipBottomSheet | `setTicketTip` |
| HistoryScreen | `search` |
| FavoritesScreen | (local storage only) |
| ProfileScreen | (local storage + sign out) |
| FlowManager | `searchUserClient`, `getLatestTicket`, OpenAPI schema (GET) |

### Defined but Unused Endpoints (12)

| Endpoint | Likely Purpose |
|----------|---------------|
| `/getUserClient` | Fetch single profile by ID |
| `/deleteUserClient` | Delete user account |
| `/listUserClients` | Admin: list all users |
| `/listVehicles` | List user's vehicles |
| `/getVehicle` | Get single vehicle |
| `/updateVehicle` | Update vehicle details |
| `/deleteVehicle` | Delete vehicle |
| `/getTicketList` | List tickets (replaced by `/search`) |
| `/getTicketByPIN` | Lookup ticket by PIN (attendant app) |
| `/setTicketStatus` | Manual status change |
| `/updateTicket` | Generic ticket update |
| `/updateTicketPhotos` | Vehicle inspection photos |

### Ticket Status Flow

```
Arrival -> Processing-Arrival -> Parked -> Departure -> Processing-Departure -> Completed
                                                                              -> Cancelled (at any point)
```

### Polling Strategy

| Poll | Interval | Screen | Condition |
|------|----------|--------|-----------|
| `getLatestTicket` | 5 seconds | TicketScreen, TicketTimerScreen | While ticket is active |
| `generatePINandticket` | 30 seconds | TicketScreen | Only while status == "Arrival" |

---

## Recommendations

### Before Release (HIGH)
1. **Fix unsafe casts** in `flow_manager_provider.dart` lines 84 and 154 — add type guards
2. **Enable linting rules** in `analysis_options.yaml`
3. **Wire hardcoded strings** to `AppLocalizations` (60+ strings across 15 screens)
4. **Implement image compression** in `image_utils.dart` or remove the stub
5. **Fix French accent** in `app_fr.arb` line 23

### Before Beta (MEDIUM)
6. **Refactor FlowManager** — split into separate providers for schema, profile, and ticket
7. **Extract sub-widgets** from large build methods (HomeScreen banner, TicketScreen actions)
8. **Centralize magic colors** (`0xFF2D1B69`, `0xFF0A2647`) into AppColors
9. **Add semantic accessibility** labels to icon buttons, chips, and interactive elements
10. **Fix email validator** regex to support `.co.uk` and deep subdomains
11. **Add type guard** to `stripe_service.dart` Cloud Function result

### Future (LOW)
12. Clean up unused dependencies (rxdart, equatable, riverpod_generator)
13. Remove or implement `notification_service.dart` stub
14. Fix asset filename typo ("vallet" -> "valet")
15. Add unit tests for validators, distance calculation, FloridaMessages, and API parsing
16. Consider dark mode WCAG contrast compliance audit
