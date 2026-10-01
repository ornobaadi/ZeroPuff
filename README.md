# ZeroPuff

A calm, private habit and streak tracker for quitting smoking, built with Flutter. Pause through cravings, check in daily, track cigarettes avoided and money won back, and celebrate milestones.

ZeroPuff is not a medical app and does not provide medical advice.

**Current version:** 1.1.1 (build 5). See [CHANGELOG.md](CHANGELOG.md).

## Features

- **Craving rescue:** a guided two-minute pause with breathing that respects reduced-motion settings.
- **Live smoke-free clock:** counts up on open, with digits that roll like an odometer.
- **Daily check-ins and journal:** a month-by-month calendar of smoke-free days, cravings and honest logs.
- **Progress:** streaks, milestones, achievement badges, craving analysis and money won back.
- **Private by default:** works in guest mode with data on the device; Google sign-in is optional, for backup and sync.
- **Reminders** at your local time, all optional.

## Design

- **Palette:** sage green and terracotta on warm linen (light) or deep charcoal (dark). Tokens live in `lib/core/theme/` (`app_colors.dart`, `app_theme.dart`, `app_accents.dart`).
- **Type:** Playfair Display for headlines and numbers, with lining figures and italic emphasis; Geist for body text. Both are bundled variable fonts in `assets/fonts/`, so nothing is downloaded at runtime.
- **Icons:** Material Symbols Rounded (`material_symbols_icons`). Outlined by default, filled when selected.
- **Navigation:** a Material 3 Expressive floating toolbar on phones with spring animations; a navigation rail on tablets and foldables.
- Screens read colors from the theme or `AppAccents`, not hard-coded values.

## Tech stack

Flutter, Riverpod, go_router, Isar (local database), Supabase (auth and sync), Google Sign-In, and flutter_local_notifications.

## Setup

1. Copy `.env.example` to `.env` and fill in the Supabase and Google values.
2. Apply the SQL files in `supabase/migrations/` to your Supabase project, in order.
3. Install packages:

```bash
flutter pub get
```

## Run

```bash
flutter run --flavor dev
```

## Test

```bash
flutter analyze
```
```bash
flutter test
```

## Release (Android)

Requires `android/key.properties` and the upload keystore (both gitignored). The release build fails without them.

Before a release, bump `version` in `pubspec.yaml` **and** `appVersionLabel` / `appBuildLabel` in `lib/core/constants/app_constants.dart`, then add a `CHANGELOG.md` entry.

Play Store bundle (`build/app/outputs/bundle/prodRelease/app-prod-release.aab`):

```bash
flutter build appbundle --release --flavor prod --android-skip-build-dependency-validation
```

Prod APKs for GitHub releases (`build/app/outputs/flutter-apk/`):

```bash
flutter build apk --release --split-per-abi --flavor prod --android-skip-build-dependency-validation
```

Test build that installs next to the store app (package `com.zeropuff.app.dev`):

```bash
flutter build apk --split-per-abi --flavor dev
```

See `PRD_Zeropuff.md` for product scope, including the guardrails that keep the app out of Google Play's Health category.
