# Changelog

## 1.2.0 (build 6)

A new rescue you can feel, and reasons to open the app every day.

### New
- Rescue rebuilt: tapping "I'm craving" opens straight into breathing. Hold the orb to breathe in, let go to breathe out, with vibration that rises and fades with each breath.
- Pocket mode: breathing paced by vibration alone on a dark screen.
- If the urge is still strong, pick a different tool: grounding, a ten-minute delay with a check-back, water, moving, or your reason.
- A win screen after each craving you get through, showing how far the urge dropped and what you kept.
- Smoking moments: name the times you used to smoke (coffee, breaks, the drive home) and get a heads-up ten minutes before each.
- Tapping a notification opens the screen it is about.
- A Today card on Home that changes with the day, including a one-tap daily promise.
- Savings goal: name what the money is for and watch a jar fill towards it.
- Home-screen widget and a quick-settings tile, both one tap from the rescue.
- Share a milestone or a beaten craving as an image.
- Onboarding lets you try one breath before anything else is asked.

### Changed
- Daily check-in ends on a short summary instead of a brief message.
- The app records how strong each urge was before and after a rescue.

### Requires
- Supabase migration `0007_craving_rescue_fields.sql`.

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
