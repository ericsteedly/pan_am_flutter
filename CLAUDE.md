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

This is an early-stage Flutter app. The intended stack based on installed dependencies:

- **State management**: Riverpod (`flutter_riverpod` ^3.3.1) — wrap `main()` with `ProviderScope` before adding providers
- **HTTP**: Dio (`dio` ^5.9.2) — for API requests
- **Platforms**: Android, iOS, Web, Linux, macOS, Windows all enabled
- **Patterns** MVVM

No feature structure, navigation, or layering has been established yet. When adding features, place code under `lib/` with a feature-based folder structure (e.g., `lib/features/<feature>/`).

## Validation

PostToolUse hooks run dart format and flutter analyze automatically after
every file write. Fix any analyze errors before proceeding to the next task.
