# ZeroPuff v0.1 Beta Build Plan

## Purpose

v0.1 beta answers one question:

> Do users open ZeroPuff during cravings and log honestly afterward?

This release is not the AI product yet. It is the behavioral foundation: Google sign-in, onboarding, smoke-free tracking, offline craving rescue, private logging, daily check-ins, milestones, savings, basic achievements, local reminders, and a calm design system that can carry every later version.

Target audience: 10-20 trusted friends and family via sideloaded APK.

Target build window: 3-4 weeks.

## v0.1 Scope

### Included

- Guest-first onboarding.
- Google Sign-In for sync and account features.
- New-user onboarding with 4 screens.
- Home dashboard with live smoke-free counter.
- Offline 2-minute craving rescue.
- Private smoking log.
- Daily check-in.
- Health milestone timeline.
- Savings tracker.
- Basic time-based achievements.
- Settings and profile management.
- Local notifications.
- Bottom navigation: Home, Progress, You.
- Supabase schema and sync foundation.
- Isar offline-first local storage.
- Full Material 3 Expressive design system.

### Excluded

- AI chat, Claude, Spark, AI memory, and streaming.
- Voice mode.
- Quit Circle.
- Forced sign-in before exploring.
- Payments, subscriptions, RevenueCat, and AdMob.
- Bangla or Banglish UI.
- Advanced analytics.
- Achievement celebration animations.
- Lottie.
- Public Play Store release.

## Product Principles for v0.1

- Craving rescue first, tracker second.
- No shame language anywhere.
- Every core action must still work offline after sign-in and setup.
- The user should reach the rescue flow in one obvious tap from Home.
- Logging a cigarette must not feel like failure.
- Honesty streak and smoke-free streak are separate concepts.
- Design should feel quiet, grounded, and personal: no gradients, no neon, no fake wellness gloss.

## Design Direction

### Visual Mood

ZeroPuff should feel like a clean room at night: calm, legible, soft, and steady. It should not look like a generic AI app, crypto app, habit tracker clone, or gradient-heavy wellness template.

### Material 3 Expressive Rules

- Use `ThemeData(useMaterial3: true)`.
- Generate the app scheme from seed color `#2A9D7C`.
- Use `DynamicSchemeVariant.expressive` where supported by the current Flutter SDK.
- Prefer tonal surfaces and shape hierarchy over shadows.
- Cards use zero elevation.
- Buttons are clear and tactile, not glossy.
- Motion is restrained: only the craving CTA gets a subtle breathing pulse.

### Typography

- Headings and expressive milestone moments: `Playfair Display`.
- Body and UI: `Geist` preferred, with `Inter` as fallback if Geist support becomes awkward in Flutter.
- Live timer digits: `Space Mono`.
- Use dual font styling intentionally: serif for emotional weight, clean sans for usability.
- No negative letter spacing in compact UI.
- Use large serif numbers sparingly so they feel earned.

### Color Tokens

- Primary: `#2A9D7C`.
- Primary dark: `#1A7A5E`.
- Primary light: `#B7EDE1`.
- AI accent reserved for future versions: `#7C6AF4`.
- Money accent: `#E07B39`.
- Streak accent: `#E85D75`.
- Craving/warning accent: `#F0A500`.
- Light surface: `#F7F8F6`.
- Card surface: `#FFFFFF`.
- Elevated surface: `#F0F4F2`.
- Primary text: `#111B17`.
- Secondary text: `#4A6358`.

### Shape and Spacing

- 4px base grid.
- Page horizontal padding: 20px.
- Card padding: 20px.
- Section gap: 28px.
- Card radius: 20px.
- Button radius: 16px.
- Chips: 10-12px radius.
- Minimum tap target: 48px.

## Target Architecture

```text
lib/
  core/
    constants/
    env/
    router/
    sync/
    theme/
    utils/
  features/
    auth/
    onboarding/
    home/
    rescue/
    logging/
    checkin/
    progress/
    achievements/
    profile/
    settings/
  models/
  repositories/
  services/
    notifications/
    supabase/
    local_database/
```

Rules:

- Feature-first UI under `lib/features`.
- Shared app infrastructure under `lib/core`.
- Supabase calls go through repositories.
- Isar access goes through local database services/repositories.
- Riverpod owns app state.
- Avoid `setState` except inside tiny private UI widgets where local animation/input state is simpler and isolated.
- Keep widget files focused and split large screens into local widgets.
- Navigation must support Android predictive back cleanly: no broken previews, no double pops, no confusing back destinations, and no accidental app exits from primary tabs.

## Phase 0: Project Foundation

Goal: Replace the starter app with the real ZeroPuff foundation.

Tasks:

- Update `pubspec.yaml` with v0.1 dependencies:
  - `flutter_riverpod`
  - `riverpod_annotation`
  - `go_router`
  - `supabase_flutter`
  - `google_sign_in`
  - `isar`
  - `isar_flutter_libs`
  - `path_provider`
  - `flutter_dotenv`
  - `google_fonts`
  - `intl`
  - `shared_preferences`
  - `flutter_local_notifications`
  - `timezone`
  - `permission_handler`
  - `connectivity_plus`
  - `uuid`
- Add dev dependencies:
  - `build_runner`
  - `riverpod_generator`
  - `isar_generator`
  - `riverpod_lint`
  - `custom_lint`
- Create the folder structure.
- Replace `MaterialApp` with `MaterialApp.router`.
- Add app bootstrap initialization:
  - dotenv
  - Supabase
  - Isar
  - notifications
  - Riverpod `ProviderScope`
- Create placeholder routes for future features, but expose only v0.1 tabs.

Exit criteria:

- App launches to an auth gate.
- Theme loads.
- Router works.
- Analyzer passes.

Credentials needed:

- None yet if we use placeholder env values locally.

## Phase 1: Design System

Goal: Lock the visual language before feature screens begin.

Files:

- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_typography.dart`
- `lib/core/theme/app_spacing.dart`
- `lib/core/theme/app_shapes.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/theme/app_motion.dart`

Tasks:

- Implement light and dark Material 3 themes.
- Add semantic colors for relapse, warning, success, savings, and streaks.
- Add reusable spacing and shape tokens.
- Add text styles for live counter and milestone numbers.
- Define component themes for buttons, chips, cards, navigation bar, input fields, snackbars, dialogs, and bottom sheets.
- Create a small internal design preview screen in debug mode to inspect typography, color, controls, and spacing.
- Add navigation transition standards for Android:
  - primary bottom tabs keep state with a shell route.
  - detail flows use platform-friendly transitions.
  - critical flows like active rescue confirm before leaving.
  - predictive back previews should always reveal the real previous destination.

Exit criteria:

- The app has no Flutter starter purple.
- The interface uses tonal surfaces, not gradients or shadows.
- Text remains readable in light and dark mode.
- Android gesture back behavior feels smooth across onboarding, tabs, rescue, and settings.

## Phase 2: Backend and Local Data Foundation

Goal: Build the data layer once so v0.2 and v1.0 do not require painful rewrites.

Tasks:

- Create Supabase project.
- Add `.env` keys:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
- Run the full PRD schema in Supabase, even for later features.
- Enable Row Level Security.
- Add v0.1 RLS policies first:
  - profiles are user-owned.
  - onboarding responses are user-owned.
  - craving logs are user-owned.
  - smoking logs are user-owned.
  - check-ins are user-owned.
  - achievements are user-owned.
  - notification preferences are user-owned.
- Create Isar models for:
  - user profile cache
  - onboarding data
  - craving rescue session
  - smoking log
  - daily check-in
  - achievement state
  - notification preferences
  - sync queue item
- Add repositories with offline-first writes:
  - write locally first.
  - queue Supabase sync if offline.
  - mark synced when remote write succeeds.

Exit criteria:

- Local writes work without network.
- Supabase sync works when online.
- No feature screen directly calls Supabase.

Credentials needed:

- Supabase project URL and anon key.
- Supabase SQL editor access to run migrations.

How to acquire:

- Create a project at `https://supabase.com`.
- Copy URL and anon public key from Project Settings > API.
- Keep the service role key private; do not put it in Flutter.

## Phase 3: Authentication

Goal: Guest-first entry with Google Sign-In for sync/account features.

Tasks:

- Configure Android package name.
- Add Google Sign-In dependency setup.
- Configure Supabase Google OAuth provider.
- Preserve local guest baseline and link it to Google account on sign-in.
- Add auth repository.
- Add Riverpod auth state provider.
- Add routes:
  - `/sign-in`
  - `/onboarding`
  - `/home`
- Redirect rules:
  - signed out -> sign-in.
  - signed in but onboarding incomplete -> onboarding.
  - signed in and onboarded -> home shell.
- Create initial profile row after first sign-in.

Exit criteria:

- User can sign in with Google on Android.
- Returning users skip onboarding.
- New users are sent to onboarding.
- Sign out returns to sign-in.

Credentials needed:

- Google OAuth client details.
- Android SHA-1 and SHA-256 fingerprints.
- Supabase Google provider client ID and secret.

How to acquire:

- Create or use a Firebase project.
- Register the Android app with the final package name.
- Add SHA-1 and SHA-256 from `./gradlew signingReport`.
- Download `google-services.json` if Firebase is used for configuration.
- In Google Cloud Console, create OAuth credentials if Supabase needs a web client.
- Paste client ID and secret into Supabase Auth > Providers > Google.

## Phase 4: Onboarding

Goal: Four screens, under two minutes, no account friction.

Screens:

- Quit date:
  - today
  - already quit
  - planning date
- Habit:
  - cigarettes per day
  - currency
  - pack price
  - pack size
- Top triggers:
  - stress
  - bored
  - social
  - after food
  - coffee
  - other
- Quit reason:
  - optional free text

Tasks:

- Build onboarding state provider.
- Save every step locally as draft.
- On completion, save to Isar and Supabase.
- Create initial achievement state.
- Schedule default daily check-in reminder after permission prompt.

Exit criteria:

- Onboarding can be completed quickly.
- Partial state survives app restart.
- Home calculations have enough data to work.

## Phase 5: Home Dashboard

Goal: Make the main loop obvious and emotionally calm.

Home sections:

- Smoke-free counter:
  - days
  - live `HH:MM:SS`
- Money saved.
- Cigarettes not smoked.
- Current smoke-free streak.
- Honesty streak.
- Primary CTA: `I'm Craving`.
- Daily check-in card if incomplete today.

Tasks:

- Implement live ticker provider.
- Implement savings and avoided-cigarette calculations.
- Add state-aware dashboard copy:
  - new user
  - active streak
  - logged smoking today
  - inactive/no log
- Add subtle breathing animation only to the craving CTA.

Exit criteria:

- User can start rescue in one tap.
- Calculations update correctly as time passes.
- Dashboard does not look like a generic stats grid.

## Phase 6: Offline Craving Rescue

Goal: The core v0.1 loop.

Flow:

- Tap `I'm Craving`.
- Select intensity from 1-10.
- Select trigger chips.
- Start 2-minute rescue timer.
- Show one micro-action every 30 seconds:
  - Drink a full glass of water.
  - Walk to a different room.
  - Take 3 slow breaths. In 4, hold 4, out 6.
  - Read your quit reason.
- On timer completion, choose outcome:
  - Resisted.
  - Smoked.
  - Still craving.
- Save session locally and sync to Supabase.

Tasks:

- Build rescue session model.
- Build timer provider that survives app backgrounding.
- Add compassionate result screen.
- If outcome is smoked, offer to create smoking log.
- If still craving, allow restart rescue without extra friction.

Exit criteria:

- Full flow works in airplane mode.
- Outcome persists after restart.
- Rescue language is immediate and supportive.

## Phase 7: Private Smoking Log and Streaks

Goal: Encourage honesty without shame.

Tasks:

- Add private smoking log screen.
- Fields:
  - cigarette count
  - trigger
  - optional note
  - timestamp
- Add streak calculator:
  - smoke-free streak resets after smoking.
  - honesty streak continues if the user logs truthfully.
- Add confirmation copy:
  - `Logged. Let's keep going.`
  - `You did not lose everything. This helps us learn.`

Exit criteria:

- Smoking logs affect dashboard.
- Honesty streak does not reset on relapse.
- Smoke-free streak calculation is deterministic and tested.

## Phase 8: Daily Check-In

Goal: Build daily retention without making the user feel monitored.

Fields:

- Mood: 5 simple options.
- Smoke-free today toggle.
- Cigarette count if not smoke-free.
- Optional note.

Tasks:

- Add check-in card on Home.
- Add check-in screen or bottom sheet.
- Save locally and sync.
- Reflect today's status on dashboard.
- Maintain honesty streak based on daily completion.

Exit criteria:

- Only one check-in per day unless user edits it.
- Home card hides after completion.
- Data survives offline use.

## Phase 9: Progress, Milestones, Savings, Achievements

Goal: Give users visible progress without turning the app into a game.

Progress tab sections:

- Health milestone timeline.
- Savings tracker.
- Basic achievements grid.

Health milestones:

- 20 minutes.
- 8 hours.
- 24 hours.
- 48 hours.
- 72 hours.
- 1 week.
- 2 weeks.
- 1 month.
- 3 months.
- 6 months.
- 1 year.
- 5 years.
- 10 years.
- 15 years.

Achievements:

- 1 hour.
- 6 hours.
- 12 hours.
- 1 day.
- 3 days.
- 1 week.
- 2 weeks.
- 1 month.

Tasks:

- Build milestone calculation service.
- Build timeline UI:
  - past filled.
  - current highlighted.
  - future muted.
- Build savings screen:
  - total saved.
  - cigarettes avoided.
  - three local examples.
  - progress to next savings goal.
- Build achievement unlock check on app open and after logs/check-ins.

Exit criteria:

- Milestones are accurate from quit date.
- Achievements are stable and not duplicated.
- Progress feels encouraging, not noisy.

## Phase 10: Profile, Settings, and Account Controls

Goal: Let beta users correct bad setup data without reinstalling.

Tasks:

- Profile screen:
  - name
  - avatar placeholder/edit path
  - quit date
  - cigarettes per day
  - pack price
  - pack size
  - triggers
- Notification settings:
  - daily check-in time
  - milestone reminder toggle
  - streak protection toggle
- Auth controls:
  - sign out
  - delete account
- Add confirmation when quit date changes because it recalculates streaks.

Exit criteria:

- Editing profile recalculates dashboard and progress.
- Sign out works.
- Delete account removes local data and remote user-owned rows.

Credentials possibly needed:

- If Supabase client-side delete is insufficient for auth user deletion, we will need a small Supabase Edge Function using the service role key stored only in Supabase secrets.

How to acquire:

- Supabase service role key is in Project Settings > API.
- Add it only to Supabase Edge Function secrets, never to `.env` used by Flutter.

## Phase 11: Local Notifications

Goal: Add useful reminders without remote push infrastructure.

Notifications:

- Daily check-in reminder at user-selected time.
- Milestone approach reminder.
- 11 PM streak protection nudge if no log/check-in today.

Tasks:

- Configure `flutter_local_notifications`.
- Configure Android notification channel.
- Request notification permission at the right moment.
- Store notification preferences locally and remotely.
- Reschedule notifications after profile or settings changes.

Exit criteria:

- Notifications fire on Android test devices.
- User can disable or change reminder time.
- No notification is sent during an active rescue session.

Credentials needed:

- None for local notifications.

## Phase 12: Sync, QA, and Beta APK

Goal: Make the app reliable enough for real beta users.

Tasks:

- Implement background/manual sync retry.
- Add visible but quiet sync failure handling.
- Add unit tests for:
  - streak calculations
  - savings calculations
  - milestone status
  - achievement unlocks
- Add widget tests for:
  - auth redirect shell
  - onboarding completion
  - rescue outcome save
- Test offline scenarios:
  - open app offline after sign-in
  - complete rescue offline
  - log smoking offline
  - complete check-in offline
  - reconnect and sync
- Test Android 10, 12, and 14 if devices/emulators are available.
- Build release APK.

Exit criteria:

- `flutter analyze` passes.
- Tests pass.
- APK installs on target devices.
- App opens under 2 seconds on a mid-range Android device.
- No crash on startup.

## Chronological Build Order

### Week 1: Foundation and Onboarding

1. Project dependencies and folder structure.
2. Theme and design system.
3. Router and Riverpod app shell.
4. Supabase and Isar initialization.
5. Google Sign-In.
6. Onboarding flow.

### Week 2: Core Loop

1. Home dashboard.
2. Live counter and savings calculations.
3. Craving rescue setup screen.
4. 2-minute offline rescue timer.
5. Rescue outcome logging.
6. Private smoking log.
7. Streak and honesty logic.

### Week 3: Retention and Progress

1. Daily check-in.
2. Health milestone timeline.
3. Savings tracker.
4. Achievements grid.
5. Profile and settings.
6. Local notifications.

### Week 4: Reliability and Beta Release

1. Offline sync hardening.
2. Dark mode QA.
3. Accessibility pass.
4. Real-device Android QA.
5. Bug fixes.
6. Release APK build.
7. Install with 10-20 beta users.

## v0.1 Beta Validation Checklist

- 5+ people install and use it for at least 3 days.
- At least 3 users start a craving rescue during a real craving.
- At least 1 user logs a cigarette without abandoning the app.
- Counter remains accurate after app restart.
- Rescue works in airplane mode.
- Daily check-in saves and updates Home.
- Honesty streak survives relapse logging.
- No startup crash on Android 10, 12, or 14.
- App opens in under 2 seconds on a mid-range Android phone.

## Analytics Without Analytics SDK

v0.1 does not need PostHog yet. For beta, use a simple internal event table and local queue:

- `onboarding_completed`
- `craving_rescue_started`
- `craving_rescue_completed`
- `craving_outcome_resisted`
- `craving_outcome_smoked`
- `daily_checkin_completed`
- `smoking_log_created`
- `achievement_unlocked`

This gives enough signal for the v0.1 gate without adding another vendor.

## Credentials I Will Ask For

### Needed Early

- Supabase project URL.
- Supabase anon key.
- Google OAuth client information.
- Android package name decision.
- Android SHA-1 and SHA-256 fingerprints.

### Possibly Needed for Account Deletion

- Supabase service role key, stored only as an Edge Function secret.

### Not Needed Until Later Versions

- Anthropic API key: v1.0.
- RevenueCat API keys and products: v1.0.
- AdMob app ID and ad units: v1.0.
- Firebase Cloud Messaging server setup: v1.0.
- Resend API key: v0.2.
- PostHog key: v1.0.
- Crashlytics setup: v1.0.

## Immediate Next Step

Start Phase 0 by converting the starter Flutter app into the ZeroPuff app shell:

1. Update dependencies.
2. Add folder structure.
3. Add design system files.
4. Replace `main.dart` with `ProviderScope`, bootstrap initialization, and `MaterialApp.router`.
5. Add placeholder auth/onboarding/home routes.

After that, request Supabase and Google Sign-In credentials before implementing real authentication.
