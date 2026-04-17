# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run the app (debug)
flutter run

# Run on a specific device
flutter run -d <device-id>          # list devices: flutter devices

# Analyze (lint)
flutter analyze

# Run all tests
flutter test

# Run a single test file
flutter test test/widget_test.dart
```

## Architecture

**POSI** is a Flutter POS (Punto de Venta e Inventario) app targeting mobile. It follows an offline-first approach using Drift (SQLite) as local DB, syncing with the .NET backend over Dio.

**State management:** Riverpod — wrap the app root in `ProviderScope` (already done in `main.dart`). Prefer `ConsumerWidget` / `ConsumerStatefulWidget` over `StatelessWidget` when accessing providers.

**Routing:** `go_router`. All route path constants live in `lib/core/constants/app_routes.dart`. Routes are currently declared inline in `POSIApp.build`; as the app grows they should be extracted to a dedicated router file.

**Current screen flow:**
`/` (Splash) → `/login` → `/home` (Dashboard) → `/products`, `/pos`, `/sales`, `/cash-register`, `/settings`

**lib layout:**
```
lib/
  core/
    constants/   # AppColors, AppRoutes
    theme/       # AppTheme (Material 3, light + dark)
    utils/       # CurrencyFormatter, etc.
  main.dart      # Entry point — screens still inline here, pending extraction
```

Features (Login, Products CRUD, POS/cart, Sales history, Cash register) are all pending implementation; screens currently show placeholder text.

## Key packages

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `drift` + `sqlite3_flutter_libs` | Local offline-first database |
| `go_router` | Declarative routing |
| `dio` + `flutter_secure_storage` | HTTP client + secure token storage |
| `mobile_scanner` | Barcode scanner |
| `flutter_form_builder` + `form_builder_validators` | Forms & validation |
| `connectivity_plus` | Online/offline detection |
