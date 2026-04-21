# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Description

This is a frontend mock flight-booking application that retrieves available flights from an api based on user input query from this front end. Users authenticate and have an account where they can edit there personal information and store payment methods as well as flight bookings.

## Commands

```bash
flutter pub get          # Install dependencies
flutter analyze          # Lint (flutter_lints + riverpod_lint)
flutter test             # Run all tests
flutter test <path>      # Run a single test file
flutter run              # Run on connected device/emulator
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
```

## Architecture

- **State management**: Riverpod (`flutter_riverpod` ^3.3.1) — `ProviderScope` wraps `main()` in `main.dart`
- **HTTP**: Dio (`dio` ^5.9.2) — global instance configured in `lib/services/dio_client.dart` (base URL: `https://panamapi.dev`)
- **Navigation**: GoRouter (`go_router` ^17.2.1) — `routerProvider` in `lib/app.dart`; reactive auth redirect via `_RouterNotifier` + `refreshListenable`
- **Secure storage**: `flutter_secure_storage` ^10.0.0 — token persistence via `StorageService`
- **Platforms**: Android, iOS, Web, Linux, macOS, Windows all enabled
- **Pattern**: MVVM

## Architecture Rules

- All HTTP calls live in services/ only
- ViewModels expose state via Riverpod providers, never call HTTP directly
- Screens are dumb — they only read from providers and call ViewModel methods
- No business logic in widget build() methods

## Project Structure

This project uses layer-first organization. Do NOT use lib/features/.
All models go in lib/models/, providers in lib/providers/,
services in lib/services/, screens in lib/screens/.

## Models

Data models live in `lib/models/`. Each is a pure data class with a `fromJson` factory and `toJson` method — no business logic.

| File | Class(es) | Notes |
| --- | --- | --- |
| `airport.dart` | `Airport` | |
| `payment.dart` | `Payment` | `cardNumber` nullable — absent in nested Account responses |
| `flight.dart` | `Flight`, `FlightResult`, `DirectFlight`, `ConnectedFlight` | `FlightResult` is a sealed class — `DirectFlight` wraps a single `Flight`; `ConnectedFlight` holds `flight1`/`flight2` with `totalDuration`, `totalPrice`, `totalPoints`; discriminated by presence of `flight1` key in JSON |
| `account.dart` | `Account` | Imports `Payment`; flattens nested `customer` object |
| `booking.dart` | `Booking`, `Ticket` | `Ticket` is an inline deserialization helper; `paymentId` and `rewardsPayment` are nullable |
| `auth_token.dart` | `AuthToken` | Parsed from `/login` response; holds `token` string |
| `login_request.dart` | `LoginRequest` | Write-only request body; `toJson()` only, no `fromJson` |

## Services

HTTP calls live exclusively in `lib/services/`. Never call services directly from providers or screens.

Services are classes with `static` methods. Token auth is handled automatically by a Dio interceptor in `dio_client.dart` — no token parameter needed in individual service methods.

| File | Function / Class | Responsibility |
| --- | --- | --- |
| `dio_client.dart` | — | Global `dio` instance; base URL `https://panamapi.dev`, JSON header, LogInterceptor, token auth interceptor |
| `auth_service.dart` | `AuthService` | `login(LoginRequest) → Future<AuthToken>` — POST `/login` |
| `storage_service.dart` | `StorageService` | Static; `writeToken`, `readToken`, `deleteToken` via `FlutterSecureStorage` |
| `account_service.dart` | `AccountService` | `static getAccount() → Future<Account>` — GET `/account` |
| `airport_service.dart` | `AirportService` | `static getAirports() → Future<List<Airport>>` — GET `/airports` |
| `flight_service.dart` | `FlightService` | `static getFlights({departureAirportId, arrivalAirportId, departureDay}) → Future<List<FlightResult>>` — GET `/flights`; response mixes direct and connected flight shapes |
| `booking_service.dart` | `BookingService` | `static getBookings() → Future<List<Booking>>` — GET `/bookings`; `static createBooking(List<int> flightIds) → Future<int>` — POST `/bookings` with body `[{"flight_id": N}]`, returns new booking `id` |
| `payment_service.dart` | `PaymentService` | `static getPayments() → Future<List<Payment>>` — GET `/payments` |
| `ticket_service.dart` | `TicketService` | Stub — POST `/tickets` (not yet implemented) |
| `register_service.dart` | `RegisterService` | Stub — POST `/register_user` (not yet implemented) |
| `api_service.dart` | `ApiService` | Placeholder for future shared API logic |

## Providers

Riverpod providers live in `lib/providers/`. ViewModels extend `AsyncNotifier` or `Notifier`.

| File | Provider | Type | Notes |
| --- | --- | --- | --- |
| `auth_provider.dart` | `authProvider` | `AsyncNotifierProvider<AuthNotifier, AuthToken?>` | `build()` restores token from storage; exposes `login()` and `logout()` |
| `airports_provider.dart` | `airportsProvider` | `AsyncNotifierProvider<AirportsNotifier, List<Airport>>` | Load-once; `build()` calls `AirportService.getAirports()` |
| `search_form_provider.dart` | `searchFormProvider` | `NotifierProvider<SearchFormNotifier, SearchFormState>` | Manages trip type, airport selection (mutual exclusion), date constraints, and validation; exposes `availableDepartAirports()` / `availableArriveAirports()` helpers |
| `flights_provider.dart` | `flightsProvider` | `AsyncNotifierProvider<FlightsNotifier, FlightsState?>` | `search()` fetches depart (and return for roundtrip) legs in parallel; `selectDepartFlight()` creates depart booking and transitions `leg` to `returnLeg`; `confirmReturnFlight()` creates return booking; `resetToDepart()` / `reset()` for back navigation; `FlightsState` holds `departBookingId` and `returnBookingId` separately for use by `PurchaseScreen` |

## Widgets

Reusable widgets live in `lib/widgets/`. All screens use `PanAmAppBar` as their `Scaffold` appBar.

| File | Class | Notes |
| --- | --- | --- |
| `pan_am_app_bar.dart` | `PanAmAppBar` | Implements `PreferredSizeWidget`; blue bar (`0xFF1565C0`), bold title, italic tagline, `MainMenu` in actions |
| `main_menu.dart` | `MainMenu` | `ConsumerWidget`; `PopupMenuButton` with Book Flight / Account / Bookings navigation and Logout wired to `authProvider.notifier.logout()` |
| `airport_select.dart` | `AirportSelect` | `Autocomplete<Airport>` with depart/arrive icons; `onChanged` callback; tap-to-reopen clears field; `GestureDetector` on screen body dismisses via `FocusScope.of(context).unfocus()` |
| `flight_card.dart` | `FlightCard` | Renders `FlightResult` — uses `switch` on sealed type: `DirectFlight` shows single flight #, nonstop badge; `ConnectedFlight` shows flight1#/flight2#, layover code badge, total duration/price. Times formatted to 12h; duration formatted as `Xh YYm`. Amber border + filled price button when selected. |

## Auth Flow

1. App startup: `main.dart` calls `WidgetsFlutterBinding.ensureInitialized()`, then runs under `ProviderScope`
2. `AuthNotifier.build()` attempts to restore token from `StorageService`
3. GoRouter redirect guard reads `authProvider` — unauthenticated users are redirected to `/login`; authenticated users on `/login` or `/register` are redirected to `/search`
4. On login: `LoginScreen` calls `authProvider.notifier.login()` → `AuthService` POSTs to `/login` → token saved via `StorageService`
5. On logout: `authProvider.notifier.logout()` deletes token and sets state to `null`, triggering redirect to `/login`

## Screens & Routes

Screens live flat under `lib/screens/`. Routes are declared in `lib/app.dart`.
The router is a Riverpod `routerProvider` (not a global) — `MainApp` watches it as a `ConsumerWidget`.

| Route          | Screen           | Status | Notes |
| -------------- | ---------------- | ------ | ----- |
| `/login`       | `LoginScreen`    | Implemented | Initial route; wired to `authProvider` |
| `/register`    | `RegisterScreen` | Stub | `PanAmAppBar` only |
| `/search`      | `SearchScreen`   | Implemented | Full form; watches `airportsProvider`, `searchFormProvider`, `flightsProvider`; navigates to `/results` on search success |
| `/results`     | `ResultsScreen`  | Implemented | `ConsumerStatefulWidget`; reads `flightsProvider` + `searchFormProvider`; handles depart and return legs via `FlightLeg` enum; back navigation via `PopScope`; navigates to `/purchase` when `selectedReturnFlight` is set |
| `/purchase`    | `PurchaseScreen` | Stub | Next to build; `departBookingId` + `returnBookingId` available in `flightsProvider` state |
| `/bookings`    | `BookingsScreen` | Stub | |
| `/booking/:id` | `BookingScreen`  | Stub | Detail view for a booking |
| `/account/:id` | `AccountScreen`  | Stub | Uses placeholder id `'me'` in `MainMenu` until account provider is wired |

## Flight Search & Booking Flow

The multi-screen booking flow is tracked in `flightsProvider` (`FlightsState`):

1. **SearchScreen** — builds query, calls `flightsProvider.notifier.search()`, navigates to `/results`
2. **ResultsScreen (depart leg)** — reads `flightsProvider.state.departFlights`; button is "CONTINUE" (oneway) or "NEXT FLIGHT" (roundtrip); tapping calls `selectDepartFlight()` → POST `/bookings` → stores `departBookingId`, transitions `leg` to `FlightLeg.returnLeg`
3. **ResultsScreen (return leg, roundtrip only)** — same screen, reads `returnFlights`; `leg == FlightLeg.returnLeg`; "CONTINUE" calls `confirmReturnFlight()` → POST `/bookings` → stores `returnBookingId`, sets `selectedReturnFlight`, triggers navigation to `/purchase`
4. **ResultsScreen (oneway)** — depart leg only; "CONTINUE" calls `confirmReturnFlight()` directly, same navigation outcome
5. **PurchaseScreen** — stub; both `departBookingId` and `returnBookingId` are available in `FlightsState`

`FlightLeg` enum (`depart` / `returnLeg`) in `FlightsState` drives which list and button the Results screen renders. Back navigation: return leg → `resetToDepart()`; depart leg → `reset()` + go to `/search`.

## Validation

PostToolUse hooks run dart format and flutter analyze automatically after
every file write. Fix any analyze errors before proceeding to the next task.
