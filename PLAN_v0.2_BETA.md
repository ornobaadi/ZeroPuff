# ZeroPuff v0.2 Beta Plan

## Purpose

v0.2 beta answers one question:

> Does ZeroPuff feel rewarding enough to make users return every day and keep logging honestly?

The first beta built the solo quitting loop: onboarding, home dashboard, offline rescue, private logging, daily check-ins, progress, achievements, settings, notifications, and sync. The next version should not chase Social Circle yet. The bigger fish is making the existing app feel complete, motivating, and habit-forming.

v0.2 is the quality-and-retention beta: stronger streaks, milestone celebrations, a quit journal calendar, detailed stats pages, tappable cards, richer progress information, theme/settings polish, and better recovery after relapse.

Target audience: 50-100 beta users through Play Store Internal Track or controlled APK distribution.

Target build window: 2-3 weeks on top of v0.1.

## Product Read

The PRD says the core promise is:

> Before you smoke, open ZeroPuff for 2 minutes.

To make that behavior stick before AI or Social Circle arrives, v0.2 should make every smoke-free day feel visible and every honest log feel useful. The app should become a daily quit journal, not just a rescue tool.

The inspiration screenshots point toward a strong direction:

- A monthly calendar where each day has a status.
- A selected-day detail section with smokes, cravings, entries, and average intensity.
- Streak and success metrics at the top.
- Cards that lead into deeper pages.
- A calm but emotionally rich visual system where progress feels earned.

We should not copy the design exactly. ZeroPuff should keep its own quiet confidence: light and dark themes, warm surfaces, teal/green brand language, smoke-free days as the emotional center, and relapse states that feel compassionate instead of punitive.

## Current Baseline After v0.1 Phase 12

Last updated: May 19, 2026.

### Already Built

- Flutter app shell with Riverpod, GoRouter, Supabase bootstrap, Isar, environment loading, and local notifications.
- Feature-first structure under `lib/features`.
- Bottom navigation with `Home`, `Progress`, and `You`.
- Guest-first onboarding with local draft and completion save.
- Google Sign-In integration path.
- Home dashboard with smoke-free counter, savings, avoided cigarettes, craving CTA, logging shortcut, and daily check-in card.
- Offline 2-minute craving rescue with setup, timer, outcome capture, and persistence.
- Private smoking log with compassionate language.
- Daily check-in with local save, edit-today behavior, dashboard state, and queued sync.
- Progress tab with milestones, savings, achievements, and check-in summary.
- Profile/setup editing, notification preferences, sign out, and local delete.
- Local notification setup for daily check-in, milestone reminder, and streak protection.
- Queue-backed sync retry, startup/manual sync, and quiet sync failure handling.
- Release APK build path exists.

### Still Needs v0.1 Launch Hardening Before Wider v0.2

- Real-device Android QA on Android 10, 12, and 14.
- Airplane-mode walkthrough for rescue, smoking log, check-in, and reconnect sync.
- RLS QA for all v0.1 tables.
- Google OAuth console/package/SHA verification on a real Android device.
- Secure Supabase auth-user deletion Edge Function if full remote account deletion is required before beta expansion.
- App open time sanity check on a mid-range device.

These are not glamorous, but they protect the v0.2 beta from shaky foundations.

## v0.2 Scope

### Included

- v0.1 beta hardening pass.
- Stronger streak system:
  - smoke-free streak
  - daily check-in streak
  - honesty streak
  - craving resistance streak
- Quit Journal calendar screen with day status markers.
- Selected-day details:
  - smokes
  - cravings
  - entries
  - average intensity
  - triggers noticed
  - timeline of logs/check-ins/rescues
- Detailed pages for every major card:
  - smoke-free counter details
  - streak details
  - savings details
  - cigarettes avoided details
  - health milestone details
  - craving analysis details
  - achievement details
- Milestone and achievement celebration system.
- Relapse recovery flow and recovery copy polish.
- Basic craving analysis and trigger intelligence.
- Improved Progress/Stats information architecture.
- Theme and basic app settings:
  - light/dark/system mode
  - notification preferences polish
  - currency/pack settings polish
  - reset quit date flow polish
- Internal event tracking for retention and journal usage.
- v0.2 APK/Internal Track QA checklist.

### Excluded

- Quit Circle, friend invitations, buddy SOS, and email invites.
- Spark AI chat, Claude API, streaming, and AI memory.
- Voice input or TTS.
- RevenueCat, subscriptions, trials, and premium gating.
- AdMob.
- Full remote push notification system.
- Bangla/Banglish UI.
- Community feed.

## v0.2 Success Metrics

### Activation

- 50+ users install the beta.
- 70%+ complete onboarding.
- 60%+ view Progress/Stats at least once.
- 40%+ open the Quit Journal.
- 30%+ tap into at least one detailed stats page.

### Retention

- Day 3 retention improves compared with v0.1.
- At least 35% of users complete 3 daily check-ins in their first week.
- At least 25% of users maintain a 3-day check-in streak.
- At least 20% of users return after a relapse log.

### Behavior

- Users can understand the difference between smoke-free streak, honesty streak, and check-in streak.
- Relapse logging does not make users feel like they failed the app.
- Milestone celebrations feel motivating, not childish.
- Calendar status matches real logged data.

### Reliability

- No critical startup crashes in Internal Track.
- Calendar and stats remain accurate across time zones and app restarts.
- Offline v0.1 features still work exactly as before.
- Streak calculations are deterministic and covered by tests.

## Architecture Rules

- Keep all solo quit features offline-first.
- Every card that looks tappable should be tappable.
- Detailed pages should use shared calculation services, not duplicate math in widgets.
- No feature screen should call Supabase directly; repositories/services own data access.
- Avoid adding vendor dependencies unless they clearly improve this beta.
- Do not add AI/payment/social dependencies in v0.2.
- Calendar should derive from local logs/check-ins/rescue sessions first, then sync quietly.
- Streaks should be explainable in UI and testable in code.

## Data Model Work

Existing tables cover most of v0.2, but a small local/schema expansion will make the calendar and celebrations cleaner.

### New Migration: `0003_retention_quality_beta.sql`

Add or adjust:

- `achievements.seen_at timestamptz`
- `achievements.celebrated_at timestamptz`
- `achievements.metadata jsonb not null default '{}'`
- `daily_checkins.tags text[] not null default '{}'`
- `craving_logs.primary_trigger text`
- `craving_logs.notes text`
- `app_events.properties jsonb` already exists and should be reused.

Optional if we want persisted daily summaries:

- `daily_summaries`
  - `id uuid primary key`
  - `user_id uuid`
  - `local_date date`
  - `smokes integer`
  - `cravings integer`
  - `rescues integer`
  - `resisted_cravings integer`
  - `average_intensity numeric`
  - `status text`
  - `updated_at timestamptz`

Recommendation: start with computed summaries from local data. Add `daily_summaries` only if performance or cross-device sync demands it.

### Day Status Rules

Each calendar day should resolve to one primary status:

- `future`: after today.
- `no_data`: past or today with no log/check-in/rescue.
- `smoke_free`: check-in says smoke-free and no smoking logs.
- `craving`: one or more craving/rescue logs, no smoking logs.
- `relapse`: one or more smoking logs or check-in says not smoke-free.
- `mixed`: both resisted cravings and smoking logs.

The UI can show small dots for secondary signals:

- green: smoke-free.
- amber: craving.
- rose/warm red: relapse.
- teal outline: check-in completed.

## New Flutter Modules

Add:

```text
lib/features/journal/
  screens/
    quit_journal_screen.dart
    day_detail_screen.dart
  widgets/
    journal_month_calendar.dart
    journal_day_cell.dart
    day_status_legend.dart
    selected_day_summary.dart
    day_entry_timeline.dart
  providers/
    journal_providers.dart

lib/features/stats/
  screens/
    streak_details_screen.dart
    savings_details_screen.dart
    smoke_free_details_screen.dart
    craving_analysis_screen.dart
    health_milestone_details_screen.dart
  widgets/
    stat_breakdown_card.dart
    trend_summary_card.dart
    trigger_rank_card.dart
    success_rate_card.dart

lib/features/recovery/
  screens/
    relapse_recovery_screen.dart
  widgets/
    recovery_action_card.dart

lib/features/celebrations/
  widgets/
    achievement_celebration_overlay.dart
    milestone_celebration_sheet.dart
    celebration_badge.dart

lib/features/settings/
  screens/
    appearance_settings_screen.dart
```

Add or extend calculation services:

- `journal_day_summary_service.dart`
- `streak_calculations.dart`
- `progress_calculations.dart`
- `craving_insight_calculations.dart`
- `achievement_unlock_service.dart`

## Navigation Plan

Keep bottom navigation simple, but make the middle tab stronger.

Recommended v0.2 bottom nav:

- `Home`
- `Journal`
- `Progress`
- `You`

Alternative if four tabs feels too heavy:

- Keep `Home | Progress | You`
- Place Quit Journal as the first section inside Progress.

Recommendation: add a dedicated `Journal` tab. Daily logging and streak behavior are central enough to deserve a first-class home, and it matches the habit loop we want.

## Phase 0: v0.1 Release Gate

Goal: Make sure the current beta is actually ready before adding retention features.

Tasks:

- Run `flutter analyze`.
- Run the existing unit/widget tests.
- Build release APK.
- Install on at least one real Android device.
- Test:
  - first launch
  - onboarding
  - rescue offline
  - smoking log offline
  - daily check-in offline
  - reconnect sync
  - notification settings
  - sign out/sign in
- Verify Supabase RLS for v0.1 tables.
- Verify Google Sign-In on real Android using final package/SHA setup.

Exit criteria:

- v0.1 can be handed to 10-20 users without known critical blockers.
- Any remaining issues are documented as known beta limitations.

## Phase 1: Streak System Upgrade

Goal: Make streaks central, clear, and motivating.

Tasks:

- Define streak types:
  - smoke-free streak: consecutive days without smoking.
  - check-in streak: consecutive days with a daily check-in.
  - honesty streak: consecutive days with either check-in or honest smoking log.
  - resistance streak: consecutive cravings resisted.
- Add a `StreakDetailsScreen`.
- Add streak explanation copy so users understand why relapse does not destroy honesty progress.
- Add streak cards on Home and Journal.
- Add streak protection copy for late-day reminders.
- Add streak tests for:
  - relapse day
  - missed day
  - check-in after relapse
  - multiple logs in one day
  - timezone boundary.

Exit criteria:

- Streaks are accurate and deterministic.
- Users can see what streak they are protecting today.
- Relapse resets smoke-free streak but preserves honesty streak when logged.

## Phase 2: Quit Journal Calendar

Goal: Give users a beautiful month-view history of their quit journey.

Tasks:

- Add `Journal` route and optional bottom-nav branch.
- Build monthly calendar inspired by the screenshot, but using ZeroPuff design tokens.
- Month navigation:
  - previous month
  - next month
  - jump to current month.
- Day cells show:
  - date number
  - selected state
  - today state
  - status color/dot
  - completed check-in marker.
- Add legend:
  - smoke-free
  - craving
  - relapse
  - check-in.
- Add top summary:
  - day streak
  - total tracked days
  - smoke-free days
  - success rate.

Exit criteria:

- Calendar renders correctly for different month lengths.
- Selected day is obvious.
- Future dates are muted.
- Status comes from real local data.

## Phase 3: Selected-Day Details

Goal: Make each day feel inspectable and useful.

Tasks:

- Build selected-day summary section below the calendar.
- Show:
  - smokes
  - cravings
  - entries
  - average craving intensity
  - smoke-free/check-in status
  - top trigger or "what you noticed".
- Add day timeline:
  - check-ins
  - craving rescues
  - smoking logs
  - achievement unlocks.
- Add edit/delete actions for smoking log entries if supported safely.
- Add quick actions:
  - add check-in
  - log smoke
  - start rescue.

Exit criteria:

- Selecting a date updates details instantly.
- Empty days have useful, calm empty states.
- Editing an entry refreshes the calendar and stats.

## Phase 4: Tappable Cards and Detail Pages

Goal: Make every major card lead somewhere meaningful.

Tasks:

- Audit Home and Progress cards.
- Add routes/details for:
  - smoke-free counter
  - money saved
  - cigarettes avoided
  - current streak
  - health milestones
  - achievements
  - craving analysis
  - daily check-in summary.
- Each detail page should include:
  - what the metric means
  - current value
  - historical context
  - how it is calculated
  - one motivating next action.
- Add consistent card affordance:
  - trailing chevron or subtle "View" icon.

Exit criteria:

- No major card feels dead.
- Detail pages use real calculations.
- Back navigation feels clean.

## Phase 5: Milestone and Achievement Celebrations

Goal: Make progress feel like a win.

Tasks:

- Add celebration overlay/sheet for newly unlocked achievements.
- Trigger celebrations after:
  - app open recalculation
  - check-in
  - rescue outcome
  - smoking log/recovery update when appropriate.
- Add milestone celebration copy:
  - health improvement
  - cigarettes avoided
  - money saved
  - streak protected.
- Use restrained animation:
  - badge scale
  - soft fade/slide
  - optional subtle particles if performant.
- Track `seen_at` and `celebrated_at` so celebrations do not repeat.
- Add achievement details page with locked/unlocked states.

Exit criteria:

- Every major milestone completion feels acknowledged.
- Celebrations never fire during active rescue.
- Reopening the app does not replay old celebrations.

## Phase 6: Relapse Recovery Upgrade

Goal: Make relapse a guided recovery moment.

Tasks:

- After smoking log save, route to recovery flow.
- Copy:
  - `Logged. You did not lose everything.`
  - `This gives us a clearer map for next time.`
- Ask what happened with quick trigger chips.
- Show 3 recovery micro-actions:
  - drink water
  - reset environment
  - plan next danger window.
- Add `Start recovery` action.
- Show how streaks changed:
  - smoke-free streak reset.
  - honesty streak protected.
  - check-in streak unaffected if completed.
- Add recovery state to selected-day details.

Exit criteria:

- Logging smoking never dead-ends.
- Dashboard and Journal reflect relapse compassionately.
- Users can understand what progress they kept.

## Phase 7: Craving Analysis and Basic Stats

Goal: Turn logs into useful insight without AI.

Tasks:

- Add `CravingAnalysisScreen`.
- Calculate:
  - top triggers
  - peak craving time window
  - average intensity
  - resistance rate
  - cravings this week vs last week
  - smoke-free days this month.
- Add insight cards:
  - "Stress shows up most often."
  - "Your hardest window is 9-11 PM."
  - "You resisted 70% of cravings this week."
- Avoid overclaiming from small samples.
- Empty state if fewer than 3 craving logs.

Exit criteria:

- Insights are based on real data, not placeholders.
- Stats pages are readable and motivating.
- Calculations have unit tests.

## Phase 8: Savings and Health Detail Pages

Goal: Make practical progress feel tangible.

Tasks:

- Add `SavingsDetailsScreen`:
  - total saved
  - daily/weekly/monthly run rate
  - cigarettes not bought
  - simple savings goal progress.
- Add `SmokeFreeDetailsScreen`:
  - total smoke-free time
  - longest smoke-free streak
  - current streak
  - timeline summary.
- Add `HealthMilestoneDetailsScreen`:
  - completed milestones
  - current milestone progress
  - next milestone explanation
  - all milestones list.

Exit criteria:

- Savings and health cards have useful destinations.
- Numbers match Home/Progress exactly.
- Detail pages work offline.

## Phase 9: Theme and Basic Settings Polish

Goal: Make the app feel personal and stable enough for wider beta.

Tasks:

- Add appearance settings:
  - system
  - light
  - dark.
- Persist theme preference locally.
- Add settings polish:
  - notification settings layout
  - setup settings clarity
  - quit date reset warning
  - currency and pack price edit clarity.
- Add app info/legal placeholders:
  - medical disclaimer
  - privacy note
  - version/build number.
- Audit dark mode for Journal, stats, cards, and celebrations.

Exit criteria:

- Theme mode can be changed without restart.
- All v0.2 screens work in light and dark mode.
- Settings feel like a real app, not debug controls.

## Phase 10: Retention Events

Goal: Measure v0.2 without adding PostHog yet.

Tasks:

- Extend internal `app_events` usage with:
  - `journal_opened`
  - `journal_day_selected`
  - `streak_details_opened`
  - `stats_card_opened`
  - `achievement_celebrated`
  - `milestone_celebrated`
  - `relapse_recovery_started`
  - `relapse_recovery_completed`
  - `craving_analysis_opened`
  - `theme_changed`
- Queue events offline where possible.
- Add a simple way to inspect counts in Supabase during beta.

Exit criteria:

- The v0.2 gate can be measured.
- Event logging failures never interrupt user flows.

## Phase 11: QA, Internal Track, and Distribution

Goal: Ship v0.2 to a wider beta group with confidence.

Tasks:

- Run analyzer and tests.
- Add/extend tests for:
  - streak calculations
  - journal day status
  - selected-day summary
  - achievement celebration replay prevention
  - relapse recovery route after smoking log
  - craving analysis calculations
  - theme preference persistence.
- Manual QA:
  - clean install as guest
  - onboarding
  - Journal month navigation
  - day selection
  - log smoke and verify calendar update
  - complete check-in and verify calendar update
  - rescue outcome and verify calendar update
  - achievement unlock celebration
  - card detail routes
  - theme switching
  - offline use and reconnect sync.
- Build release APK or Internal Track bundle.
- Prepare beta tester instructions.

Exit criteria:

- v0.2 build is ready for 50-100 users.
- Journal/stats/streaks are accurate in manual QA.
- Known limitations are documented.

## Chronological Build Order

### Week 0: Launch Hardening

1. v0.1 real-device QA.
2. RLS verification.
3. Google Sign-In verification.
4. Release APK sanity pass.

### Week 1: Daily Retention Core

1. Streak system upgrade.
2. Journal route and calendar UI.
3. Day status calculations.
4. Selected-day detail section.
5. Journal tests.

### Week 2: Wins and Detail Depth

1. Tappable Home/Progress cards.
2. Streak, savings, smoke-free, and health detail pages.
3. Achievement/milestone celebration system.
4. Relapse recovery upgrade.
5. Achievement replay prevention tests.

### Week 3: Polish and Beta Release

1. Craving analysis and basic stats pages.
2. Theme/basic settings polish.
3. Retention event tracking.
4. Full QA pass.
5. APK/Internal Track build.
6. Distribute to 50-100 users.

## v0.2 Beta Validation Checklist

- [ ] v0.1 solo flows still pass.
- [ ] Streak types are accurate and understandable.
- [ ] Journal calendar displays the current month correctly.
- [ ] Day status markers match logs/check-ins/rescues.
- [ ] Selected-day details update after new logs.
- [ ] Every major card routes to a detailed page.
- [ ] Achievement celebration appears once per unlock.
- [ ] Milestone completion feels rewarding.
- [ ] Relapse recovery flow appears after smoking log.
- [ ] Honesty streak remains intact after relapse.
- [ ] Craving analysis uses real logged data.
- [ ] Theme mode switching works.
- [ ] Dark mode QA passes on all new screens.
- [ ] No ads, AI, payments, premium prompts, or social prompts appear.

## v0.2 -> v1.0 Gate

- [ ] 50+ beta users installed v0.2.
- [ ] 40%+ opened Journal.
- [ ] 30%+ opened at least one detail page.
- [ ] 25%+ completed a 3-day check-in streak.
- [ ] 10+ users saw an achievement/milestone celebration.
- [ ] 3+ relapse loggers returned after recovery flow.
- [ ] No critical crashes in Internal Track.
- [ ] Calendar/streak data matches manual inspection.
- [ ] Product decision made: proceed to AI v1.0, or spend one more beta on retention polish.

## Credentials Needed

### Needed for v0.2

- Final Android package name and Google OAuth setup.
- Play Store Internal Track access if distributing beyond APK sideloading.

### Possibly Needed

- Supabase service role key stored only as Edge Function secret if full remote auth-user deletion is required.

### Not Needed Until Later

- Resend API key: delayed until Quit Circle.
- Anthropic API key: v1.0.
- RevenueCat products and API keys: v1.0.
- AdMob app ID and ad units: v1.0.
- PostHog key: v1.0 or later.
- Crashlytics production setup: v1.0 or late beta.

## Risk Notes

- Streak pressure can become shame. Counterbalance smoke-free streak with honesty streak and recovery copy.
- Calendar status must be truthful, not flattering. Trust matters more than perfect-looking months.
- Celebrations should feel earned and calm, not childish.
- Detail pages must add insight, not just repeat the same number in a bigger font.
- Avoid turning v0.2 into advanced analytics. Keep it clear, useful, and beta-shippable.
- Social Circle is still valuable, but it belongs after the solo app has stronger daily retention.

## Immediate Next Step

Before writing v0.2 feature code:

1. Run the v0.1 release gate checklist on a real Android device.
2. Create or update streak calculation tests for all streak types.
3. Add `Journal` route and decide whether it becomes a bottom-nav tab.
4. Build the month calendar with real local day summaries.
5. Add selected-day details, then wire Home/Progress cards to detail pages.
