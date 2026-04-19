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
- **HTTP**: Dio (`dio` ^5.9.2) — for API requests
- **Navigation**: GoRouter (`go_router` ^17.2.1) — router defined in `lib/app.dart`
- **Platforms**: Android, iOS, Web, Linux, macOS, Windows all enabled
- **Pattern**: MVVM

## Screens & Routes

Screens live flat under `lib/screens/`. Routes are declared in `lib/app.dart`:

| Route | Screen | Notes |
|---|---|---|
| `/login` | `LoginScreen` | Initial route |
| `/register` | `RegisterScreen` | |
| `/search` | `SearchScreen` | |
| `/results` | `ResultsScreen` | |
| `/purchase` | `PurchaseScreen` | |
| `/bookings` | `BookingsScreen` | |
| `/booking/:id` | `BookingScreen` | Detail view for a booking |
| `/account/:id` | `AccountScreen` | User account/profile |

When adding new screens, register a route in `lib/app.dart` and place the screen file under `lib/screens/`. For new feature code (providers, services, models), use `lib/features/<feature>/`.

## Validation

PostToolUse hooks run dart format and flutter analyze automatically after
every file write. Fix any analyze errors before proceeding to the next task.
