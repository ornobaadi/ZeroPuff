# Changelog

## 1.1.1 (build 5)

A calmer, more polished look.

### New
- New visual style: soft sage and terracotta colors on warm linen (light) and deep charcoal (dark), with elegant serif headlines.
- Floating navigation bar: the active tab expands with a smooth, springy animation.
- The smoke-free clock counts up when you open the app, and its digits roll like an odometer.
- Cleaner, more consistent icons throughout the app.

### Fixed
- Numbers are now full height everywhere instead of looking shrunken next to text.
- Money amounts show thousands separators ($2,190) and keep cents for small amounts ($5.50).
- "Packs skipped" no longer shows a trailing ".0".
- Removed a stray dot at the end of progress bars, and made all progress bars the same height.
- Stat tiles now share one consistent style across Home, Progress, Journal and Savings.
- Better text contrast in dark mode.
- The version shown in the app is now correct.

## 1.1.0 (build 4)

A full redesign in Material 3 Expressive, plus reliability and privacy fixes.

### New
- Redesigned onboarding: five short steps, your progress is saved if you leave, and reminders are optional.
- New Home screen with a live smoke-free clock, one-tap craving rescue and a daily check-in card.
- Redesigned rescue flow with breathing guidance that respects reduced-motion settings.
- Journal calendar with icons and words, not just colors.
- Progress, milestones and achievements rebuilt with clearer badges and stats.
- Light and dark themes, a bottom navigation bar with labels, and a side rail on tablets and foldables.
- Privacy policy link in the app.

### Fixed
- Reminders now fire at your local time.
- Signing out no longer leaves one account's data on the device for the next person.
- Streak counts are correct across daylight-saving changes.
- Error messages no longer show technical details.
- Delete account and delete data now remove everything they should.
- Smoke-free clock no longer rebuilds the whole screen every second, which saves battery.

### Under the hood
- Bundled fonts (no runtime downloads), backups disabled for the local database, and stricter database rules.
