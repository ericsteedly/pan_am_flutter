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
- **Navigation**: GoRouter (`go_router` ^17.2.1) — router defined in `lib/app.dart`; includes auth redirect guard
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
| `flight.dart` | `Flight` | Imports `Airport` |
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
| `flight_service.dart` | `FlightService` | `static getFlights({departureAirportId, arrivalAirportId, departureDay}) → Future<List<Flight>>` — GET `/flights` |
| `booking_service.dart` | `BookingService` | `static getBookings() → Future<List<Booking>>` — GET `/bookings` |
| `payment_service.dart` | `PaymentService` | `static getPayments() → Future<List<Payment>>` — GET `/payments` |
| `ticket_service.dart` | `TicketService` | Stub — POST `/tickets` (not yet implemented) |
| `register_service.dart` | `RegisterService` | Stub — POST `/register_user` (not yet implemented) |
| `api_service.dart` | `ApiService` | Placeholder for future shared API logic |

## Providers

Riverpod providers live in `lib/providers/`. ViewModels extend `AsyncNotifier` or `Notifier`.

| File | Provider | Type | Notes |
| --- | --- | --- | --- |
| `auth_provider.dart` | `authProvider` | `AsyncNotifierProvider<AuthNotifier, AuthToken?>` | `build()` restores token from storage; exposes `login()` and `logout()` |

## Auth Flow

1. App startup: `main.dart` calls `WidgetsFlutterBinding.ensureInitialized()`, then runs under `ProviderScope`
2. `AuthNotifier.build()` attempts to restore token from `StorageService`
3. GoRouter redirect guard reads `authProvider` — unauthenticated users are redirected to `/login`; authenticated users on `/login` or `/register` are redirected to `/search`
4. On login: `LoginScreen` calls `authProvider.notifier.login()` → `AuthService` POSTs to `/login` → token saved via `StorageService`
5. On logout: `authProvider.notifier.logout()` deletes token and sets state to `null`, triggering redirect to `/login`

## Screens & Routes

Screens live flat under `lib/screens/`. Routes are declared in `lib/app.dart`:

| Route          | Screen           | Notes                     |
| -------------- | ---------------- | ------------------------- |
| `/login`       | `LoginScreen`    | Initial route             |
| `/register`    | `RegisterScreen` |                           |
| `/search`      | `SearchScreen`   |                           |
| `/results`     | `ResultsScreen`  |                           |
| `/purchase`    | `PurchaseScreen` |                           |
| `/bookings`    | `BookingsScreen` |                           |
| `/booking/:id` | `BookingScreen`  | Detail view for a booking |
| `/account/:id` | `AccountScreen`  | User account/profile      |

## Validation

PostToolUse hooks run dart format and flutter analyze automatically after
every file write. Fix any analyze errors before proceeding to the next task.
