# ZeroPuff

A simple smoke-free habit and streak tracker built with Flutter. Log cravings, check in daily, track cigarettes avoided and money saved, and celebrate milestones. ZeroPuff is not a medical app and does not provide medical advice.

## Setup

1. Copy `.env.example` to `.env` and fill in the Supabase and Google values.
2. Apply the SQL files in `supabase/migrations/` to your Supabase project, in order.
3. `flutter pub get`

## Run

```
flutter run
```

## Release (Android)

Requires `android/key.properties` and the upload keystore (both gitignored). The release build fails without them.

```
flutter build appbundle --release
```

See `PRD_Zeropuff.md` for product scope, including the guardrails that keep the app out of Google Play's Health category.
