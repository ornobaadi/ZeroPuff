# VERSIONS.md — ZeroPuff Rollout Plan
### From Zero to Full Product, Step by Step

**Philosophy:** Ship something real users can install at every version.  
Every version is a complete, usable app — not a prototype.  
Each version adds one meaningful layer on top of the last.

---

## Version Overview

```
v0.1  BETA — "Does the core loop work?"
  ↓   Pure tracking. No AI. Ship to 10–20 close friends.
  
v0.2  BETA — "Does the social hook work?"
  ↓   Add Quit Circle (email SOS). Ship to 50–100 users.

v1.0  LAUNCH — "The real product."
  ↓   AI chat (Spark), monetization, full onboarding. Public launch.

v1.5  GROWTH — "Deepen the experience."
  ↓   Voice mode, advanced analytics, all AI personas, Banglish.

v2.0  FINAL — "Feature-complete."
      Community feed, wearable sync, widget, global expansion.
```

---

## v0.1 — Beta: The Foundation
**Goal:** Validate that users will open the app during cravings and log honestly.  
**Audience:** 10–20 friends and family. Sideload APK.  
**Timeline:** 3–4 weeks to build.  
**No subscriptions. No ads. No AI. No payments.**

---

### What's In v0.1

#### ✅ Authentication
- Google Sign-In only (simplest possible auth)
- No guest mode yet (keep it simple for beta)
- Auto-redirect to onboarding if new user

#### ✅ Onboarding (4 screens, stripped down)
```
Screen 1: Quit date (today / already quit / planning)
Screen 2: Habit (cigarettes/day, pack price, pack size)
Screen 3: Top triggers (chip selection, 6 options)
Screen 4: Quit reason (free text, optional)
→ Done. No account screen (already signed in via Google).
```

#### ✅ Home Dashboard
- Smoke-free counter (days + HH:MM:SS live ticker, Space Mono font)
- Cigarettes not smoked (calculated)
- Money saved (calculated from profile data)
- Big CTA button: **"I'm Craving"**
- Daily check-in card (if not done today)
- Current streak badge

#### ✅ Craving Rescue (No AI — Offline Only)
```
Tap "I'm Craving"
  → Intensity slider (1–10)
  → Trigger chips (stress / bored / social / after food / coffee / other)
  → 2-minute rescue timer starts
  → Micro-actions shown every 30 seconds:
      "Drink a full glass of water."
      "Walk to a different room."
      "Take 3 slow breaths. In 4, hold 4, out 6."
      "Read your quit reason."
  → Timer done → outcome: Resisted / Smoked / Still craving
  → Saved to local DB (Isar) + Supabase
```

#### ✅ Private Smoking Log
- Log cigarettes smoked (count + trigger + optional note)
- Always private by default
- Honesty streak continues even after relapse
- Compassionate language: "Logged. Let's keep going."

#### ✅ Daily Check-in
- Mood (5 emoji: terrible → great)
- Smoke-free today? (toggle)
- If no: how many cigarettes?
- Optional note
- No AI response yet — just a "Logged ✓" confirmation

#### ✅ Health Milestones Timeline
- Full scientific timeline (20 min → 15 years)
- Past milestones: filled, colored
- Next milestone: highlighted with progress bar
- Future milestones: grayed out
- No unlock animation yet (v1.0)

#### ✅ Savings Tracker (screen)
- Total saved (big DM Serif Display number)
- Cigarettes avoided
- "What you could buy" — 3 examples using local prices
- Simple horizontal bar showing progress to next savings goal

#### ✅ Achievements (Basic)
- Time-based only: 1 hour, 6 hours, 12 hours, 1 day, 3 days, 1 week, 2 weeks, 1 month
- Displayed as a simple grid — locked (gray) / unlocked (colored)
- No unlock animation yet
- Checked on app open

#### ✅ Settings & Profile
- Edit name and avatar
- Edit quit date (with confirmation)
- Edit cigarettes/day, pack price
- Edit triggers
- Sign out
- Delete account (hard delete, GDPR)

#### ✅ Notifications (Local Only)
- Daily check-in reminder (user picks time)
- Milestone approach: "2 hours to your 1-day milestone!"
- Streak protection: 11 PM nudge if no log that day

#### ✅ Navigation
- Bottom nav: Home | Progress | You
- 3 tabs only — no Circle tab yet, no Spark tab yet

---

### What's NOT in v0.1
- ❌ AI / Claude API
- ❌ Voice mode
- ❌ Quit Circle
- ❌ Subscriptions / Payments
- ❌ Ads
- ❌ Guest mode
- ❌ Banglish/Bangla
- ❌ Advanced analytics
- ❌ Achievement unlock animations
- ❌ Lottie animations

---

### v0.1 Tech Setup (Do This First, Carry Forward Forever)
```
Supabase project → run full schema from PRD (build it all now, use it gradually)
Flutter project → full folder structure from PRD
Theme → full design system (colors, fonts, shapes) — never change this later
GoRouter → all routes defined (even unused ones return placeholder screens)
Riverpod → all providers scaffolded
Isar → local models for offline-first
```
> **Why set up the full schema now?** Because migrating a live app's database is painful.  
> Build all the tables, even the ones you won't use until v1.0 or v1.5.

---

### v0.1 Codex Build Order

```
Week 1:
  Day 1–2: Theme setup + folder structure + GoRouter + Riverpod scaffold
  Day 3:   Supabase client + Google Auth + auth state provider
  Day 4–5: Onboarding wizard (4 screens, saves to Supabase + Isar)

Week 2:
  Day 1–2: Home Dashboard (live counter, savings, CTA button)
  Day 3:   Craving rescue flow (offline, no AI)
  Day 4:   Private smoking log + honesty streak logic
  Day 5:   Daily check-in screen

Week 3:
  Day 1–2: Health milestone timeline screen
  Day 3:   Savings tracker screen + achievements grid
  Day 4:   Settings / Profile screen
  Day 5:   Local notifications setup + streak protection logic

Week 4:
  Day 1–2: Dark mode QA + accessibility basics (semantic labels, min 48px targets)
  Day 3:   Isar ↔ Supabase sync (background sync, not blocking)
  Day 4:   APK build + sideload to test devices
  Day 5:   Bug fixes from real-device testing
```

---

### v0.1 → v0.2 Gate (Don't Move Forward Until These Pass)
- [ ] 5+ people installed and used it for 3+ days
- [ ] Counter is accurate (correct smoke-free time)
- [ ] Craving rescue flow works offline (airplane mode test)
- [ ] Private log correctly keeps honesty streak alive after relapse
- [ ] Daily check-in saves and reflects correctly on dashboard
- [ ] No crash on startup on Android 10, 12, 14
- [ ] App opens in under 2 seconds on a mid-range device

---
---

## v0.2 — Beta: The Social Hook
**Goal:** Validate Quit Circle. Does having a buddy make users more likely to open the app?  
**Audience:** 50–100 users. Still APK sideload or Play Store Internal Track.  
**Timeline:** 2 weeks on top of v0.1.  
**Still no AI. Still no payments.**

---

### What's New in v0.2

#### ✅ Guest Mode
- Supabase anonymous auth
- All core features work without Google sign-in
- Data stored locally (Isar) + synced to Supabase anonymously
- Prompt to sign in when: opening Quit Circle, hitting craving 3+ times in a day
- Google Sign-In links anonymous account → data preserved

#### ✅ Quit Circle (Email-Based MVP)
```
Circle screen added to bottom nav (👥 tab)

Setup:
  → Enter buddy's name + email
  → Choose what they see: SOS only | Milestones | Nothing (just moral support)
  → Send invite email via Supabase Edge Function + Resend
  → Buddy receives email: "Aadi invited you to their Quit Circle"
    → Accepts via link → redirected to a simple web page confirming acceptance
    → App shows buddy as "Active"

SOS flow:
  → During craving rescue, option appears: "Send SOS to Circle"
  → User taps → optional quick message ("Really struggling with work stress")
  → Buddy gets push notification (if app installed) or email
  → Buddy responds with: 💪 You got this | 📞 Call me | 💙 Thinking of you
  → Response appears in app craving rescue screen
```

#### ✅ Achievement Unlock Animation
- Full-screen celebration when milestone hit
- Badge zooms in with spring physics
- Confetti (Lottie) for major milestones (1 day, 1 week, 1 month)
- Science fact shown: "Your cilia are regrowing. Breathing gets easier every day."
- Share button: generates a simple share card image

#### ✅ Relapse Recovery Flow
```
After logging a relapse:
  1. "Logged. You didn't lose everything."
  2. "What happened?" — trigger quick-select
  3. 3 recovery micro-actions shown
  4. "Start recovery" → recovery streak begins (separate from smoke-free streak)
  5. Dashboard shows: smoke-free streak reset, honesty streak intact, recovery streak started
```

#### ✅ Trigger Intelligence (Basic, No AI)
- Simple insight cards generated from SQL aggregation
- "Your cravings peak between 9–11 PM" (from craving log timestamps)
- "Stress triggers 6 out of your 10 logged cravings"
- "You resisted 70% of cravings this week"
- Shown on Progress screen below milestone timeline

#### ✅ Navigation Expanded
- Bottom nav: Home | Progress | Circle | You (4 tabs)
- Circle tab shows empty state if no buddy invited yet

---

### What's NOT in v0.2
- ❌ AI / Claude API (still)
- ❌ Voice mode
- ❌ Subscriptions / Payments (still)
- ❌ Ads (still)
- ❌ Advanced analytics
- ❌ Banglish/Bangla

---

### v0.2 Supabase Edge Functions to Build
```
quit-circle-invite   → Send invite email via Resend
quit-circle-sos      → Send push/email to buddy on SOS
sos-response         → Handle buddy's one-tap response, notify user
```

---

### v0.2 Codex Build Order
```
Week 1:
  Day 1:   Guest mode (anonymous Supabase auth + account linking)
  Day 2:   Circle screen UI (empty state + member card)
  Day 3:   Invite flow (email input → Edge Function → Resend email)
  Day 4:   Buddy invite acceptance web page (simple HTML, hosted on Supabase)
  Day 5:   SOS flow in craving rescue + Edge Function

Week 2:
  Day 1:   Buddy response (push notification → one-tap → appear in rescue screen)
  Day 2:   Achievement unlock animation (flutter_animate + Lottie confetti)
  Day 3:   Relapse recovery flow (post-smoking-log UI)
  Day 4:   Trigger intelligence cards (SQL aggregation → Riverpod provider)
  Day 5:   QA + APK build + distribute to wider beta group
```

---

### v0.2 → v1.0 Gate
- [ ] At least 10 people have invited a Quit Circle buddy
- [ ] At least 1 complete SOS → response loop tested end-to-end
- [ ] Guest mode → Google Sign-In migration works (data preserved)
- [ ] Achievement animations don't lag on low-end devices
- [ ] Trigger intelligence shows accurate data (not placeholder)
- [ ] No critical crashes in Play Console Internal Track

---
---

## v1.0 — Launch: The Real Product
**Goal:** Public Play Store launch. This is the version that gets marketed.  
**Audience:** Everyone. Play Store open track.  
**Timeline:** 4 weeks on top of v0.2.  
**AI goes live. Payments go live. Ads go live.**

---

### What's New in v1.0

#### ✅ Spark AI Chat — The Core Differentiator
```
New bottom tab: ⚡ Spark (between Home and Progress)

Entry points:
  → "Talk to Spark" button in craving rescue (replaces/supplements offline rescue)
  → Dedicated Spark tab for free conversation
  → "Want Spark's take?" after daily check-in
  → "Let's talk about it" after logging a relapse

Chat experience:
  → Streaming response (token-by-token, like ChatGPT)
  → Typing indicator (3 animated dots) while response loads
  → Bubble layout: AI left (surfaceAI), User right (surfaceUser)
  → DM Sans 15px, 1.6 line height in bubbles
  → Smooth slide-in animation on new messages

First message is immediate:
  → Pre-built from user data, no API call needed for the opener
  → "Hey Aadi. You've been smoke-free for 14 days — 
     I know that streak matters to you. What's going on right now?"

Session types:
  → craving     — during rescue flow, intensity-aware
  → checkin     — after daily check-in, mood-aware
  → recovery    — after relapse, compassion-first
  → freeform    — from Spark tab, open conversation

Rate limits:
  → Free: 10 messages/day, 3 sessions/day
  → Premium: Unlimited
  → When limit hit → gentle bottom sheet (not modal): 
    "You've used your daily Spark messages. Upgrade for unlimited support."
```

#### ✅ Supabase Edge Function: ai-chat (Streaming SSE)
- Claude API called server-side only (key never in Flutter code)
- Dynamic system prompt from user profile + ai_memory table
- Last 6 messages sent as context (not full history)
- Prompt caching on static prefix (saves 70% input token cost)
- After stream: saves messages + increments usage counter
- Offline fallback: if Edge Function fails → show pre-written rescue messages from local JSON

#### ✅ AI Memory System
- ai_memory table populated after each session ends
- Edge Function: update-ai-memory runs async (doesn't block chat)
- Memory includes: total cravings resisted, relapse count, top trigger, peak craving time, mood trend, money saved
- This is what makes Spark feel like it knows you over time

#### ✅ Full Onboarding (Updated from v0.1)
- Screen 5 added: Meet Spark (AI companion intro)
- Screen 6: Sign up / 7-day trial offer
- Guest mode option clearly visible
- Language selection added (English | বাংলা | Banglish)

#### ✅ Monetization — RevenueCat
```
Products in Google Play Console:
  zeropuff_premium_monthly  → ৳299/month  (global: $4.99)
  zeropuff_premium_annual   → ৳1,999/year (global: $34.99)

7-day free trial offered on onboarding completion screen

Paywall screen triggered by:
  → Hitting daily AI message limit
  → Tapping locked feature (voice, persona picker, advanced analytics)
  → Tapping "Upgrade" in profile

Paywall design:
  → Bottom sheet style (not full screen takeover)
  → Annual plan highlighted as default (saves ~60%)
  → "Less than a pack of cigarettes per month"
  → One primary CTA: "Start 7-day free trial"
  → Secondary: "See all features"
```

#### ✅ AdMob Integration
```
Banner ad: Home screen ONLY, bottom (above nav bar)
  → Shows only to free + guest users
  → Removed automatically when premium entitlement detected

Interstitial ad: ONE TIME after first major milestone unlock (1-day badge)
  → Never shown again after first time
  → Never shown during craving rescue
  → Never shown during AI chat

Hard rules baked into code:
  → No ads during rescue flow (rescueActive == true → ads hidden)
  → No ads during Spark chat
  → No ads on achievement unlock screens
```

#### ✅ Premium Features (Gated)
```
Gated behind premium entitlement:
  → Unlimited AI messages
  → AI persona selector (5 options — see below)
  → Quit Circle: up to 5 buddies (free = 1 buddy)
  → Advanced analytics (heatmap, pattern charts)
  → Weekly AI insight narrative
  → No ads

NOT gated (free users keep these):
  → Offline 2-minute rescue (always free, works offline)
  → Health milestones
  → Savings tracker
  → Daily check-in (without AI response)
  → Basic achievements
  → Private smoking log
  → 1 Quit Circle buddy
  → 10 AI messages/day
```

#### ✅ AI Persona Selector (Premium)
All 5 personas active and tested:
```
1. Calm Coach    — warm, steady, grounding
2. Tough Friend  — direct, confident, believes in you
3. Bengali Big Bro — Banglish, emotionally familiar, "bhai" energy
4. Therapist     — reflective, CBT-adjacent, asks good questions
5. Funny         — light humor to break the craving tension
```

#### ✅ Bangla/Banglish Language Support
- Bengali Big Bro persona responds in Banglish naturally
- Language setting in profile (English | Bangla | Banglish)
- Bangla rendering tested on real devices (font support verified)
- UI stays in English (full Bangla UI = v1.5)

#### ✅ RevenueCat Webhook (Edge Function)
```
Events handled:
  INITIAL_PURCHASE  → set subscription_tier = 'premium'
  RENEWAL           → confirm premium stays active
  CANCELLATION      → schedule downgrade to 'free' at period end
  EXPIRATION        → set subscription_tier = 'free'
  BILLING_ISSUE     → send in-app notification
```

#### ✅ FCM Push Notifications (Remote)
- Quit Circle SOS alerts (Edge Function → FCM)
- Milestone reached (server-side cron → FCM)
- Quit Circle buddy response arrives

#### ✅ Crash Reporting + Analytics
- Firebase Crashlytics enabled
- PostHog events wired up:
  - onboarding_completed
  - craving_rescue_started
  - craving_rescue_outcome (resisted/smoked/ongoing)
  - ai_chat_opened
  - ai_limit_hit
  - paywall_shown
  - paywall_converted
  - circle_sos_sent
  - achievement_unlocked

#### ✅ Play Store Ready
- Final app icon (spark motif, clean)
- 5 screenshots (Home, Craving Rescue, Spark Chat, Milestones, Achievements)
- Feature graphic (1024×500)
- Full Play Store listing copy
- Privacy policy URL (required)
- Medical disclaimer in onboarding

---

### v1.0 Codex Build Order

```
Week 1 — AI Core:
  Day 1–2: Supabase Edge Function: ai-chat (streaming SSE, rate limiting, auth)
  Day 3:   Flutter SSE client (stream tokens to chat UI, handle [DONE] event)
  Day 4:   Chat screen UI (bubbles, typing indicator, input row)
  Day 5:   Craving rescue → Spark chat integration (pre-built opener message)

Week 2 — AI Polish + Memory:
  Day 1:   Daily check-in → Spark reflection (post-checkin AI response)
  Day 2:   Relapse → Spark recovery flow
  Day 3:   Edge Function: update-ai-memory (async, post-session)
  Day 4:   Offline fallback (local JSON responses when no internet)
  Day 5:   5 persona system prompts (test each with real conversations)

Week 3 — Monetization:
  Day 1:   RevenueCat Flutter setup (configure products, entitlements)
  Day 2:   Paywall screen (bottom sheet design, annual default)
  Day 3:   Premium feature gating (UnlockableWidget wrapper, check entitlement)
  Day 4:   AdMob banner (home screen only) + interstitial (first milestone only)
  Day 5:   RevenueCat webhook Edge Function

Week 4 — Launch Prep:
  Day 1:   Full onboarding update (Meet Spark screen, trial offer, language picker)
  Day 2:   FCM remote notifications (milestones + Circle SOS)
  Day 3:   PostHog analytics events + Crashlytics
  Day 4:   Play Store listing assets (icon, screenshots, feature graphic)
  Day 5:   Closed beta → 1 week soak → Production release
```

---

### v1.0 → v1.5 Gate
- [ ] AI chat works end-to-end with streaming on real device
- [ ] Rate limiting works correctly (free users hit limit at 10 messages)
- [ ] Premium purchase + restore flow tested
- [ ] Ads hidden during rescue + chat (manual QA)
- [ ] RevenueCat webhook tested with test purchases
- [ ] Bengali Big Bro persona feels natural (real person tested it)
- [ ] No ANR (App Not Responding) during AI streaming on mid-range Android
- [ ] Play Store live, at least 50 organic installs
- [ ] Day 7 retention > 20% (track in PostHog)

---
---

## v1.5 — Growth: Depth & Voice
**Goal:** Deepen the AI experience, add voice, expand analytics.  
**Audience:** Existing users + new users from marketing push.  
**Timeline:** 3–4 weeks on top of v1.0.

---

### What's New in v1.5

#### ✅ Voice Mode (Premium Only)
```
Entry: Microphone icon in Spark chat input row (locks with 🔒 for free users)

Flow:
  → User taps mic
  → Permission requested (microphone)
  → Recording starts: animated waveform while recording
  → User speaks (max 30 seconds)
  → Recording stops automatically or user taps stop
  → Audio → speech_to_text transcription (on-device, no audio uploaded)
  → Transcribed text shown: "You said: [text]" with option to edit before sending
  → Sends to Spark as normal text message
  → Spark responds with text
  → AI response also read aloud via flutter_tts (user can mute)
  → Toggle: "Read responses aloud" in settings

Voice persona:
  → TTS voice matches persona feel (speed, pitch adjusted per persona)
  → Calm Coach: slower, lower pitch
  → Tough Friend: normal speed, confident
  → Bengali Big Bro: slightly faster, warmer pitch
```

**Why transcribe on-device?**  
No audio stored anywhere. Privacy by default. Works offline (speech_to_text uses device model). No extra API cost.

#### ✅ Advanced Analytics (Premium)
```
New section in Progress tab: "Your Patterns"

Charts:
  → Craving heatmap: 7×24 grid (day of week × hour of day), darker = more cravings
     (fl_chart custom widget)
  → Trigger frequency: horizontal bar chart, top 5 triggers ranked
  → Mood vs craving correlation: scatter plot or dual-axis line chart
  → Resistance rate trend: weekly line chart (% of cravings resisted)

Insights panel:
  → "Your riskiest window is Tuesday–Friday, 9–11 PM"
  → "When your mood is 4+, you resist 89% of cravings"
  → "Your resistance rate improved 12% this month"
```

#### ✅ Weekly AI Insight (Premium)
```
Every Monday morning → push notification:
  "Your weekly Spark report is ready"

Opens a generated summary screen:
  → AI narrative (2–3 paragraphs): generated from last 7 days of data
  → Key stats this week vs last week
  → One personalized tip for the coming week
  → Shareable card (optional)

Edge Function: weekly-insight
  → Triggered by Supabase pg_cron every Monday 6 AM per user's timezone
  → Fetches week's craving logs + check-ins + mood data
  → Calls Claude API (not streaming — full response returned)
  → Saves to ai_weekly_insights table
  → Sends push notification
```

#### ✅ Custom Danger-Window Alerts (Premium)
```
In Settings: "Add a danger window"
  → Day of week (multi-select)
  → Time range
  → Label: "Friday night", "After late meetings", "When drinking"

30 minutes before each window:
  → Notification: "Your Friday night craving window starts soon.
     Spark is ready when you need it."
  → Tapping opens Spark chat pre-loaded with: "Your Friday night window is coming up.
     What's your plan tonight?"
```

#### ✅ Craving-Free Streaks (Separate from Smoke-Free)
```
New streak type: "Craving resisted streak"
  → Consecutive cravings resisted (not days, individual events)
  → Shown on achievement screen
  → New achievements: 5 in a row, 10 in a row, 25 in a row
  → Resets only on a logged relapse, not on a logged craving
```

#### ✅ Android Home Screen Widget
```
Simple 2×1 widget:
  → Smoke-free days (large number, Space Mono)
  → Money saved (smaller, below)
  → Tiny "I'm Craving" button (deep links directly to rescue flow)

Built with: home_widget package + AppWidgetProvider
```

#### ✅ Full Bangla UI (Optional)
```
If user selects Bangla in settings:
  → All UI text switches to Bangla
  → flutter_localizations + arb files (en.arb + bn.arb)
  → Bangla numerals option in settings

Note: English is still the default. Bangla is opt-in.
```

#### ✅ Share Cards (Milestones)
```
After achievement unlock, user can generate a shareable image:
  → "21 days. 210 cigarettes not smoked. ৳6,300 saved."
  → Clean design, brand mark
  → Share to WhatsApp, Instagram Stories, etc.

Built with: screenshot package → share_plus
```

---

### v1.5 Codex Build Order

```
Week 1 — Voice:
  Day 1–2: speech_to_text setup + recording UI (waveform animation)
  Day 3:   Transcription → edit → send flow
  Day 4:   flutter_tts integration (AI responses read aloud)
  Day 5:   TTS settings (speed, mute toggle, test across all 5 personas)

Week 2 — Analytics + Weekly Insight:
  Day 1–2: Craving heatmap (custom fl_chart 7×24 grid)
  Day 3:   Trigger frequency + resistance rate charts
  Day 4:   Weekly insight Edge Function + pg_cron schedule
  Day 5:   Weekly insight screen UI + push notification

Week 3 — Widget + Remaining Features:
  Day 1–2: Android home screen widget (home_widget package)
  Day 3:   Custom danger-window alerts (settings UI + local notification scheduling)
  Day 4:   Share cards (screenshot package + share_plus)
  Day 5:   Bangla localization (bn.arb file, flutter_localizations)

Week 4:
  Day 1–2: Craving-free resistance streaks + new achievements
  Day 3–4: QA pass (voice on multiple devices, analytics data accuracy)
  Day 5:   Release v1.5
```

---

### v1.5 → v2.0 Gate
- [ ] Voice mode works on Android 10, 12, 14 without crash
- [ ] TTS reads AI responses naturally in all 5 persona styles
- [ ] Heatmap shows accurate data (tested with 14+ days of logs)
- [ ] Weekly insight email looks good and sends reliably
- [ ] Android widget updates correctly after logging
- [ ] No battery drain from background widget updates
- [ ] Bangla text renders correctly on Samsung, Xiaomi, OnePlus

---
---

## v2.0 — Final: Feature-Complete
**Goal:** The product vision, fully realized.  
**Audience:** Scaled user base.  
**Timeline:** 6–8 weeks on top of v1.5.

---

### What's New in v2.0

#### ✅ Real-Time Voice Conversation with Spark (Premium)
```
The flagship premium feature. Feels like a phone call with a supportive friend.

Flow:
  → Premium user taps "Voice Call Spark" (dedicated button in rescue screen)
  → Full-screen voice UI: Spark avatar with animated audio waveform
  → User speaks → transcribed in real-time (streaming STT)
  → Spark responds in real-time → TTS speaks response while text appears
  → True turn-based conversation (not just voice input for text chat)
  → "End Call" → session saved, outcome logged

Technical approach:
  → streaming speech_to_text (continuous mode)
  → Silence detection to know when user stops speaking (500ms threshold)
  → Send to Edge Function → Claude API → stream back → TTS speaks tokens as they arrive
  → TTS interruption: if user speaks while AI is talking, AI stops (polite)

This is the hardest feature technically. That's why it's v2.0.
```

#### ✅ Anonymous Community Feed
```
New tab: Community (👥 tab replaces Circle — Circle moves under Profile)

Feed shows:
  → Anonymous wins: "Someone just hit 30 days 🎉"
  → Anonymous struggles: "Someone resisted a craving at 2 AM ✊"
  → No usernames. No profile pictures. Just the human moment.
  → React with: 💪 ❤️ 🌿

Users can choose to share their milestone anonymously to the feed
  → Opt-in only. Nothing posted without explicit tap.

AI-moderated: Edge Function screens posts before they appear
  → Remove anything that could shame or trigger others
  → No relapse descriptions with detail that could normalize smoking
```

#### ✅ Group Quit Challenges
```
Under Community tab: "Challenges"

Weekly challenges:
  → "Resist 5 cravings this week"
  → "Check in every day for 7 days"
  → "Go 3 days without smoking"

Private group challenges (Premium):
  → Create a challenge with up to 10 friends
  → Each person's progress visible to the group
  → Friendly leaderboard (opt-in)
  → AI coach sends group tips

No public leaderboards. Challenges are private or anonymous.
```

#### ✅ Long-Term AI Memory (Premium)
```
Currently: AI memory is a structured table updated per session
v2.0: AI can remember free-form notes across months

Memory panel (in Spark tab):
  → "What Spark remembers about you"
  → User can view, edit, or delete any memory
  → Spark can reference memories naturally:
    "Last December you mentioned quitting for your daughter Maya.
    How is she doing?"

Privacy: all memory stored in Supabase (user's own row), user can wipe it
```

#### ✅ Amazfit / WearOS Heart Rate Integration
```
Optional: connect to fitness wearable

When heart rate spikes above baseline:
  → Notification: "Your heart rate jumped. Craving risk is higher right now.
     Spark is here if you need it."
  → User can set sensitivity (off / subtle / proactive)

For Amazfit Bip 6 (your watch):
  → Zepp Health app data access
  → Requires Zepp Health API or Health Connect (Android)

For WearOS:
  → Health Connect integration (Android 14+)
```

#### ✅ Therapist / Coach Referral (Partnerships)
```
In Profile → "Get more support":
  → List of quit-smoking helplines (local + international)
  → Option to connect with a certified quit coach (affiliate model)
  → In Bangladesh: Dhaka Ahsania Mission, NICD hotline
  → Global: NHS Quit Support, CDC Smokers Quitline, etc.

Not a marketplace. Just curated links with context.
This is a trust-building feature, not a revenue feature.
```

#### ✅ iOS Release
```
Flutter codebase is already cross-platform — iOS is largely a configuration task.
Key additions:
  → Apple Sign-In (required by App Store)
  → StoreKit2 / RevenueCat iOS configuration
  → iOS notification permissions handling
  → App Store screenshots (different sizes from Play Store)
  → App Store Connect listing

Test thoroughly on:
  → iPhone SE (small screen)
  → iPhone 14 (standard)
  → iPhone 15 Pro Max (large)
```

#### ✅ Country-Specific Cigarette Prices Database
```
Local cigarette presets per country (loaded from Supabase):
  BD: Benson & Hedges ৳350/pack (20)
  IN: Gold Flake ₹165/pack (20)
  US: Marlboro $9.50/pack (20)
  UK: Lambert & Butler £14/pack (20)
  ...

Shown in onboarding "pack price" step with option to use local preset or enter custom.
Updated periodically (not real-time).
```

---

### v2.0 Codex Build Order

```
Weeks 1–2 — Real-Time Voice:
  Day 1–2:  Streaming STT (continuous mode, silence detection)
  Day 3–4:  Voice UI screen (waveform, Spark avatar, call controls)
  Day 5–6:  Edge Function: real-time voice pipeline (STT → Claude → TTS)
  Day 7–8:  TTS token streaming (speak tokens as they arrive)
  Day 9–10: End-call flow, session save, outcome log

Weeks 3–4 — Community:
  Day 1–2:  Anonymous feed data model + moderation Edge Function
  Day 3–4:  Community feed UI (anonymous cards, reactions)
  Day 5–6:  Milestone → share to community (opt-in flow)
  Day 7–8:  Group challenges (private group creation, leaderboard)
  Day 9–10: AI moderation testing (edge cases)

Weeks 5–6 — Remaining Features:
  Day 1–2:  Long-term AI memory (memory panel UI, edit/delete)
  Day 3–4:  Health Connect integration (heart rate → notification)
  Day 5:    Referral / support resources screen
  Day 6–7:  Country cigarette price database + onboarding preset
  Day 8–10: iOS configuration + App Store submission

Weeks 7–8 — QA & Release:
  Full regression across all features
  Voice testing on 5+ device models
  Community moderation stress test
  iOS device testing (SE, 14, 15 Pro Max)
  v2.0 release 🎉
```

---
---

## Summary Table

| Feature | v0.1 Beta | v0.2 Beta | v1.0 Launch | v1.5 Growth | v2.0 Final |
|---|---|---|---|---|---|
| Core tracker (counter, savings) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Offline craving rescue (2-min) | ✅ | ✅ | ✅ | ✅ | ✅ |
| Health milestones | ✅ | ✅ | ✅ | ✅ | ✅ |
| Daily check-in | ✅ | ✅ | ✅ | ✅ | ✅ |
| Private smoking log | ✅ | ✅ | ✅ | ✅ | ✅ |
| Honesty streak | ✅ | ✅ | ✅ | ✅ | ✅ |
| Basic achievements | ✅ | ✅ | ✅ | ✅ | ✅ |
| Local notifications | ✅ | ✅ | ✅ | ✅ | ✅ |
| Guest mode | ❌ | ✅ | ✅ | ✅ | ✅ |
| Quit Circle (1 buddy, email) | ❌ | ✅ | ✅ | ✅ | ✅ |
| Achievement animations | ❌ | ✅ | ✅ | ✅ | ✅ |
| Relapse recovery flow | ❌ | ✅ | ✅ | ✅ | ✅ |
| Trigger intelligence (basic) | ❌ | ✅ | ✅ | ✅ | ✅ |
| **Spark AI chat (text)** | ❌ | ❌ | **✅** | ✅ | ✅ |
| AI memory system | ❌ | ❌ | ✅ | ✅ | ✅ |
| AI personas (5 options) | ❌ | ❌ | ✅ | ✅ | ✅ |
| Bangla/Banglish AI | ❌ | ❌ | ✅ | ✅ | ✅ |
| Subscriptions (RevenueCat) | ❌ | ❌ | ✅ | ✅ | ✅ |
| AdMob ads | ❌ | ❌ | ✅ | ✅ | ✅ |
| FCM push notifications | ❌ | ❌ | ✅ | ✅ | ✅ |
| Quit Circle (5 buddies) | ❌ | ❌ | ✅ premium | ✅ premium | ✅ premium |
| **Voice input → AI (text response)** | ❌ | ❌ | ❌ | **✅ premium** | ✅ |
| Advanced analytics / heatmap | ❌ | ❌ | ❌ | ✅ premium | ✅ |
| Weekly AI insight report | ❌ | ❌ | ❌ | ✅ premium | ✅ |
| Danger-window alerts | ❌ | ❌ | ❌ | ✅ premium | ✅ |
| Android home screen widget | ❌ | ❌ | ❌ | ✅ | ✅ |
| Bangla full UI | ❌ | ❌ | ❌ | ✅ | ✅ |
| Share cards | ❌ | ❌ | ❌ | ✅ | ✅ |
| **Real-time voice call with Spark** | ❌ | ❌ | ❌ | ❌ | **✅ premium** |
| Anonymous community feed | ❌ | ❌ | ❌ | ❌ | ✅ |
| Group quit challenges | ❌ | ❌ | ❌ | ❌ | ✅ premium |
| Long-term AI memory | ❌ | ❌ | ❌ | ❌ | ✅ premium |
| Heart rate / wearable sync | ❌ | ❌ | ❌ | ❌ | ✅ |
| Country cigarette price DB | ❌ | ❌ | ❌ | ❌ | ✅ |
| iOS release | ❌ | ❌ | ❌ | ❌ | ✅ |

---

## Timeline at a Glance

```
Month 1:   v0.1 Beta  — Build & sideload to friends
Month 2:   v0.2 Beta  — Quit Circle, Play Store Internal Track
Month 3–4: v1.0 Launch — AI goes live, public Play Store launch
Month 5:   v1.5 Growth — Voice input, analytics, widget
Month 6–8: v2.0 Final  — Real-time voice call, community, iOS
```

---

## What to Validate at Each Version

| Version | The One Question You're Answering |
|---|---|
| v0.1 | "Do people open the app when they crave?" |
| v0.2 | "Does having a buddy make them more likely to stay?" |
| v1.0 | "Does AI chat help them get through cravings better?" |
| v1.5 | "Do premium features convert free users to paying?" |
| v2.0 | "Does real-time voice make the hardest cravings survivable?" |

---

## What Never Changes (Carry From v0.1 Forever)

- The design system (colors, fonts, shapes) — set once in v0.1, never rework
- The full database schema — migrate all tables in v0.1, use them gradually
- The folder structure — feature-first from day 1, scales without refactor
- The design anti-patterns (no gradients, no shadows, no neon) — enforced by code review
- The product principle: **craving rescue first, tracker second**

---

*zeropuff VERSIONS.md — Build what matters, ship when it's real.*
