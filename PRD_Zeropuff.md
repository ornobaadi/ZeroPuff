# PRD: ZeroPuff v2.0
### AI-Powered Quit Smoking Companion — Android (Flutter)

**Version:** 2.0 — Definitive  
**Platform:** Android first → iOS post-launch  
**Build Method:** Vibe-coding with Codex / Claude Code  
**Status:** Ready for Development  

---

## Table of Contents

1. [Product Summary & Vision](#1-product-summary--vision)  
2. [Product Principles](#2-product-principles)  
3. [Target Users & Personas](#3-target-users--personas)  
4. [Success Metrics](#4-success-metrics)  
5. [Market & Launch Strategy](#5-market--launch-strategy)  
6. [Tech Stack & Architecture](#6-tech-stack--architecture)  
7. [Design System](#7-design-system)  
8. [Database Schema](#8-database-schema)  
9. [Feature Specification — MVP](#9-feature-specification--mvp)  
10. [AI Architecture Deep Dive](#10-ai-architecture-deep-dive)  
11. [Monetization](#11-monetization)  
12. [App Navigation & Screen Map](#12-app-navigation--screen-map)  
13. [Onboarding Flow](#13-onboarding-flow)  
14. [Backend Architecture](#14-backend-architecture)  
15. [Scalability Plan](#15-scalability-plan)  
16. [Development Phases](#16-development-phases)  
17. [Codex Prompting Strategy](#17-codex-prompting-strategy)  
18. [Risk Analysis](#18-risk-analysis)  
19. [Launch Checklist](#19-launch-checklist)  
20. [Future Roadmap](#20-future-roadmap)  
21. [Appendix](#21-appendix)

---

## 1. Product Summary & Vision

### One-Line Summary

ZeroPuff is an AI-powered quit-smoking companion that helps users survive cravings in real time — with a conversational AI that knows them personally, a trusted support circle, and the most beautifully designed quit app on the Play Store.

### Core Promise

> **Before you smoke, open ZeroPuff for 2 minutes.**

### What This App Actually Is

Most quit apps are trackers dressed up as companions. ZeroPuff is an **emergency support system** for the exact moment a craving hits. The tracker, the stats, the savings — those are secondary. The primary experience is: *you feel the urge, you open the app, you talk to something that actually helps*.

### The Main User Loop

```
Craving hits
    ↓
Open ZeroPuff → tap "I'm Craving"
    ↓
Intensity + trigger (2 taps, 5 seconds)
    ↓
Spark AI responds immediately (knows your history, your name, your reason)
    ↓
2-minute rescue: AI conversation + breathing + distraction
    ↓
User logs outcome: Resisted / Smoked / Still craving
    ↓
Celebration or compassionate recovery (zero shame)
    ↓
Data improves next session → AI gets more personal
```

### The Retention Loop

```
Honest logging → AI learns patterns → 
Responses feel personal → User trusts app → 
Opens during next craving → Better outcomes → 
Streak + Quit Circle reinforce → User stays
```

---

## 2. Product Principles

These are non-negotiable. Every design and feature decision should pass through them.

1. **Support before shame.** Relapse is part of quitting. We celebrate honesty.
2. **Useful in under 60 seconds.** If it takes longer, we've failed.
3. **Privacy by default.** Nothing shared with the Quit Circle without explicit permission.
4. **The AI should feel personal, not generic.** It knows your name, your why, your streak.
5. **Recovery over perfection.** An "honesty streak" matters as much as a smoke-free streak.
6. **No friction at craving time.** One tap to start rescue. No login wall, no loading screen.
7. **Design with intention.** Clean, calm, human — not corporate, not gradient-heavy, not gamified trash.
8. **Free users get real help.** The paywall is around depth, not survival.
9. **Social accountability is consent-first.** Your Quit Circle sees only what you share.
10. **Voice is premium, text always works.** Never make silence the only option.

---

## 3. Target Users & Personas

### Persona 1: The Struggling Quitter (Primary)
- Age 22–40, male or female
- Has tried quitting 2–5 times before
- Breaks during stress, after meals, or in social situations
- Knows they should quit, just can't get past cravings
- Comfortable with AI chat (uses ChatGPT regularly)
- **They need:** Immediate emotional support during cravings, zero judgment after relapse

### Persona 2: The Reduce-First Smoker
- Not ready to quit cold turkey
- Wants to go from 15/day → 5/day gradually
- **They need:** Daily limits, reduction plan, gentle accountability

### Persona 3: The Social Smoker
- Only smokes at parties, with friends, after drinks
- Doesn't see themselves as "a smoker"
- **They need:** Trigger awareness, social pressure scripts, quick anti-craving tools

### Persona 4: The Support Buddy (Secondary App User)
- Friend, partner, or sibling invited by the smoker
- Doesn't want to monitor everything — just be there when needed
- **They need:** One-tap SOS response, clear instructions, no burden

---

## 4. Success Metrics

### Acquisition
- App installs / week
- Onboarding completion rate (target: >75%)
- Guest-to-account conversion (target: >50%)
- Referral installs from Quit Circle shares

### Activation
- % users who complete first craving rescue
- % users who complete first daily check-in
- % users who invite 1 Quit Circle buddy
- Time from install to first AI message

### Engagement
- DAU / MAU ratio (target: >25%)
- Craving rescues per active user / week
- Daily check-in streak average
- AI messages per active user / day
- Session length during craving rescue

### Retention
- Day 1 / Day 7 / Day 30 retention
- Relapse recovery retention (% who return after logging a relapse)
- Comeback rate after 7+ day inactivity

### Monetization
- Free-to-paid conversion (target: 3–7%)
- Trial-to-paid conversion (target: >40%)
- Monthly MRR
- AI cost per MAU (target: <$0.08 for free, <$0.20 for premium)
- Churn rate (target: <5%/month for premium)

### Safety
- Private log usage rate
- Relapse logging rate (if high, means users trust us)
- Crisis response trigger rate
- Account deletion rate

---

## 5. Market & Launch Strategy

### Bangladesh-First, Global-Ready

**Why Bangladesh-first:**
- Local founder understands cultural context deeply
- Bangla/Banglish AI creates emotional resonance that Western apps can't replicate
- "Bengali Big Brother" persona is a unique product moat
- Local word-of-mouth through universities, workplaces, and families
- Affordable pricing drives early paid adoption

**Global-ready requirements from Day 1:**
- i18n architecture in Flutter (flutter_localizations)
- Multi-currency support in the database
- No hardcoded local references in core logic
- Country-specific cigarette price presets
- Pricing via RevenueCat (supports region-based pricing)

### Supported Languages (Phase 1)
- English (primary)
- Bangla (বাংলা)
- Banglish (mixed — the most emotionally natural mode for Bangladeshi users)

---

## 6. Tech Stack & Architecture

### Frontend

| Layer | Choice | Why |
|---|---|---|
| Framework | Flutter 3.x | Single codebase, best performance on Android, great M3 support |
| State Management | Riverpod (flutter_riverpod) | Less boilerplate than Bloc, async-native, testable |
| Navigation | GoRouter | Declarative, deep linking, handles auth guards cleanly |
| Local DB | Isar | Fastest Flutter local DB — offline-first critical for craving moment |
| Animations | flutter_animate + Lottie | Spring physics, composable, Lottie for achievement unlocks |
| Charts | fl_chart | Customizable, M3-styleable |
| Audio | flutter_tts + speech_to_text | TTS for AI voice response, STT for premium voice input |
| Notifications | flutter_local_notifications + FCM | Local for scheduled, FCM for Quit Circle SOS alerts |
| Permissions | permission_handler | Standardized permission requests |

### Backend

| Layer | Choice | Why |
|---|---|---|
| Database | Supabase (PostgreSQL) | RLS for privacy, Edge Functions for AI, realtime for Quit Circle |
| Auth | Supabase Auth | Google OAuth + Magic Link, guest mode via anonymous auth |
| Edge Functions | Supabase (Deno runtime) | Secure server-side AI calls, never expose API keys to client |
| AI | Claude API (Anthropic) | Best conversational quality, streaming, prompt caching |
| Push | Firebase Cloud Messaging | Free, reliable, Quit Circle SOS delivery |
| Storage | Supabase Storage | Profile avatars |

### Payments & Ads

| Layer | Choice | Why |
|---|---|---|
| Subscriptions | RevenueCat | Handles Play Billing, receipt validation, entitlement management |
| Ads (free tier) | Google AdMob | Banner only on dashboard, never in craving rescue |

### Observability

| Layer | Choice |
|---|---|
| Analytics | PostHog (GDPR-friendly, generous free tier) |
| Crash Reporting | Firebase Crashlytics |
| Error Monitoring | Sentry (optional, add post-MVP) |

---

## 7. Design System

> **Design Direction: Quiet Confidence**
>
> ZeroPuff should feel like taking a deep breath of clean air in a calm room.
> Not a hospital. Not a game. Not a Silicon Valley productivity app.
> Warm, unhurried, intentional. The kind of app that makes you feel safe opening it at 2 AM when you're about to relapse.

---

### 7.1 Typography

The entire type system is built on the **DM type family** — cohesive, humanist, and intentionally un-trendy.

```
Display / Large Numbers:  DM Serif Display
Body / UI Text:           DM Sans
Live Counter Digits:      Space Mono
```

**Why this pairing:**
- DM Serif Display has weight and gravitas — used for big milestone numbers ("14 days") and achievement unlocks. It feels earned.
- DM Sans is clean and neutral without being cold — identical DNA to the serif, perfect pairing.
- Space Mono for the live timer makes numbers feel precise and mechanical, adding contrast to the warmth of the rest of the UI.

```dart
// lib/core/theme/app_typography.dart

import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme get textTheme => TextTheme(
    // Used for: smoke-free day count, milestone numbers, savings total
    displayLarge: GoogleFonts.dmSerifDisplay(
      fontSize: 64,
      fontWeight: FontWeight.w400, // Serif = weight already feels bold at 400
      letterSpacing: -1.5,
      height: 1.1,
    ),
    displayMedium: GoogleFonts.dmSerifDisplay(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.5,
      height: 1.15,
    ),
    displaySmall: GoogleFonts.dmSerifDisplay(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      height: 1.2,
    ),

    // Used for: screen titles, section headers
    headlineLarge: GoogleFonts.dmSans(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      height: 1.25,
    ),
    headlineMedium: GoogleFonts.dmSans(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      height: 1.3,
    ),
    headlineSmall: GoogleFonts.dmSans(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      height: 1.35,
    ),

    // Used for: card titles, tab labels
    titleLarge: GoogleFonts.dmSans(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
    ),
    titleMedium: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    titleSmall: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),

    // Used for: body text, AI chat messages, descriptions
    bodyLarge: GoogleFonts.dmSans(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.6,
      letterSpacing: 0.15,
    ),
    bodyMedium: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.55,
      letterSpacing: 0.2,
    ),
    bodySmall: GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0.3,
    ),

    // Used for: buttons, chips, labels
    labelLarge: GoogleFonts.dmSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
    labelMedium: GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.4,
    ),
    labelSmall: GoogleFonts.dmSans(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
    ),
  );

  // Special: live counter uses Space Mono for precise mechanical feel
  static TextStyle get liveCounter => GoogleFonts.spaceMono(
    fontSize: 52,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.0,
  );

  static TextStyle get liveCounterLabel => GoogleFonts.dmSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    // ALL CAPS applied in widget
  );
}
```

---

### 7.2 Color System

**Seed Color:** `#2A9D7C` — a muted, sophisticated teal-green. Not neon. Not lime. The color of healthy lungs and fresh air.

**Scheme Variant:** `DynamicSchemeVariant.expressive` — gives us a richer, more vibrant tonal palette than the default, while still being harmonious.

```dart
// lib/core/theme/app_colors.dart

class AppColors {
  // === SEED ===
  static const Color seed = Color(0xFF2A9D7C);

  // === BRAND PRIMARIES (generated from seed, manually tuned) ===
  static const Color primary = Color(0xFF2A9D7C);       // Teal green — main actions
  static const Color primaryDark = Color(0xFF1A7A5E);   // Pressed / active
  static const Color primaryLight = Color(0xFFB7EDE1);  // Tonal container

  // === SEMANTIC ACCENTS ===
  static const Color accentAI = Color(0xFF7C6AF4);      // Spark AI elements (purple-indigo)
  static const Color accentMoney = Color(0xFFE07B39);   // Savings / money elements (warm amber)
  static const Color accentStreak = Color(0xFFE85D75);  // Streak fire (warm rose)
  static const Color accentCraving = Color(0xFFF0A500); // Warning / high craving (amber)

  // === SURFACES (light mode) ===
  static const Color surface = Color(0xFFF7F8F6);       // Off-white with a hint of green
  static const Color surfaceCard = Color(0xFFFFFFFF);   // Pure white cards on off-white bg
  static const Color surfaceElevated = Color(0xFFF0F4F2); // Slightly tinted elevated surfaces
  static const Color surfaceAI = Color(0xFFF0EFFE);     // AI bubble background (light purple tint)
  static const Color surfaceUser = Color(0xFFE8F7F2);   // User bubble background (light green tint)

  // === TEXT ===
  static const Color textPrimary = Color(0xFF111B17);   // Almost black with green undertone
  static const Color textSecondary = Color(0xFF4A6358); // Muted green-gray
  static const Color textTertiary = Color(0xFF8CA99C);  // Disabled / placeholder

  // === FUNCTIONAL ===
  static const Color success = Color(0xFF2A9D7C);       // Same as primary
  static const Color warning = Color(0xFFF0A500);
  static const Color error = Color(0xFFDC3545);
  static const Color relapse = Color(0xFFE07B39);       // Warm, not red — relapse isn't failure

  // === DARK MODE OVERRIDES ===
  // Note: M3 auto-generates dark mode — these are only needed for semantic overrides
  static const Color surfaceDark = Color(0xFF0F1C18);
  static const Color surfaceCardDark = Color(0xFF1A2D26);
  static const Color surfaceAIDark = Color(0xFF1F1A3D);
  static const Color surfaceUserDark = Color(0xFF112820);
  static const Color textPrimaryDark = Color(0xFFE2EDE9);
  static const Color textSecondaryDark = Color(0xFF8DB5A5);
}
```

```dart
// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      dynamicSchemeVariant: DynamicSchemeVariant.expressive,
      brightness: Brightness.light,
      // Manual overrides for semantic precision:
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
    ),
    textTheme: AppTypography.textTheme,
    
    // Shape system — M3 Expressive uses more rounded shapes
    // We add subtle shape variety to express hierarchy
    cardTheme: const CardThemeData(
      elevation: 0,             // Flat cards — no shadow, use color for elevation
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      color: AppColors.surfaceCard,
    ),
    
    // Navigation bar — minimal, not loud
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceCard,
      elevation: 0,
      indicatorColor: AppColors.primaryLight,
      labelTextStyle: WidgetStatePropertyAll(
        AppTypography.textTheme.labelSmall,
      ),
    ),
    
    // Buttons — filled = primary action, no gradients
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: AppTypography.textTheme.labelLarge?.copyWith(
          fontSize: 16,
          letterSpacing: 0.2,
        ),
      ),
    ),

    // Input fields — minimal, no border by default, subtle filled style
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceElevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Chips — used heavily in onboarding + trigger selection
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceElevated,
      selectedColor: AppColors.primaryLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide.none,
      ),
      labelStyle: AppTypography.textTheme.labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Dividers — very subtle
    dividerTheme: DividerThemeData(
      color: AppColors.textTertiary.withOpacity(0.2),
      thickness: 1,
      space: 1,
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      dynamicSchemeVariant: DynamicSchemeVariant.expressive,
      brightness: Brightness.dark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      error: AppColors.error,
    ),
    textTheme: AppTypography.textTheme,
    // ... mirror light theme with dark overrides
  );
}
```

---

### 7.3 Spacing & Layout System

A consistent 8px base grid. All spacing is a multiple of 4.

```dart
// lib/core/theme/app_spacing.dart

class AppSpacing {
  // Base unit: 4px
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Page padding (horizontal)
  static const double pagePadding = 20;

  // Card internal padding
  static const double cardPadding = 20;

  // Section gap (between major sections on a page)
  static const double sectionGap = 28;

  // Component gap (between related elements)
  static const double componentGap = 12;
}
```

---

### 7.4 Shape System

```dart
// lib/core/theme/app_shapes.dart

// Shape tokens — vary by component type to create visual hierarchy
class AppShapes {
  // Cards — slightly more rounded than default
  static const BorderRadius card       = BorderRadius.all(Radius.circular(20));
  
  // Buttons — rounded but not pill
  static const BorderRadius button     = BorderRadius.all(Radius.circular(16));
  
  // Chips — squarer feel, grouped tightly
  static const BorderRadius chip       = BorderRadius.all(Radius.circular(10));
  
  // Input fields
  static const BorderRadius input      = BorderRadius.all(Radius.circular(14));
  
  // Bottom sheets
  static const BorderRadius sheet      = BorderRadius.vertical(top: Radius.circular(28));
  
  // AI chat bubbles — expressive, slightly irregular
  static const BorderRadius bubbleAI   = BorderRadius.only(
    topLeft: Radius.circular(4),     // Sharp corner on the "voice" side
    topRight: Radius.circular(18),
    bottomLeft: Radius.circular(18),
    bottomRight: Radius.circular(18),
  );
  static const BorderRadius bubbleUser = BorderRadius.only(
    topLeft: Radius.circular(18),
    topRight: Radius.circular(4),    // Sharp corner on the "voice" side
    bottomLeft: Radius.circular(18),
    bottomRight: Radius.circular(18),
  );
  
  // Achievement badge — circular
  static const BorderRadius badge      = BorderRadius.all(Radius.circular(100));
  
  // Progress ring — circular
  static const BorderRadius ring       = BorderRadius.all(Radius.circular(100));
  
  // FAB / CTA button — more expressive rounding
  static const BorderRadius cta        = BorderRadius.all(Radius.circular(24));
}
```

---

### 7.5 Motion System

**Principle:** Purposeful motion only. No animation for animation's sake. Every motion communicates something.

```
Duration tokens:
  Instant:     0ms   — state changes that should feel immediate (toggle)
  Fast:       150ms  — micro-interactions (button press, chip select)
  Standard:   300ms  — page transitions, card expansion
  Deliberate: 500ms  — milestone reveals, achievement unlocks
  Cinematic:  800ms+ — onboarding sequences, first-time moments

Curve tokens:
  Default:    Curves.easeInOutCubicEmphasized  — M3 standard
  Spring:     SpringDescription.withDampingRatio(mass: 1, stiffness: 600, ratio: 0.8)
  Overshoot:  Curves.elasticOut (dampened) — badge pop, celebration
  Linear:     Curves.linear — looping pulse animations only
```

**Key animation patterns:**

```dart
// 1. CRAVING BUTTON — breathing pulse (draws attention without being annoying)
// Scale: 1.0 → 1.025 → 1.0, Duration: 2000ms, Curve: Curves.easeInOut, loop
widget.animate(onPlay: (c) => c.repeat(reverse: true))
  .scaleXY(end: 1.025, duration: 2000.ms, curve: Curves.easeInOut);

// 2. AI CHAT BUBBLE — slides in from bottom with spring
widget.animate()
  .slideY(begin: 0.3, end: 0, duration: 350.ms, curve: Curves.easeOutCubic)
  .fadeIn(duration: 250.ms);

// 3. COUNTER DIGITS — vertical scroll on change (like an odometer)
// Use AnimatedSwitcher with custom SlideTransition
AnimatedSwitcher(
  duration: 300.ms,
  transitionBuilder: (child, animation) => SlideTransition(
    position: Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero)
      .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: FadeTransition(opacity: animation, child: child),
  ),
  child: Text(key: ValueKey(currentValue), currentValue, style: AppTypography.liveCounter),
)

// 4. ACHIEVEMENT UNLOCK — Lottie confetti + badge zoom
// Badge: scale 0 → 1.15 → 1.0 with elasticOut curve
widget.animate()
  .scale(begin: Offset(0, 0), end: Offset(1.15, 1.15), duration: 400.ms, curve: Curves.easeOut)
  .then()
  .scale(begin: Offset(1.15, 1.15), end: Offset(1.0, 1.0), duration: 150.ms);

// 5. PAGE TRANSITIONS — M3 shared axis (horizontal for sibling, vertical for parent→child)
// Use GoRouter with CustomTransitionPage:
CustomTransitionPage(
  transitionsBuilder: (context, animation, secondary, child) =>
    SharedAxisTransition(
      animation: animation,
      secondaryAnimation: secondary,
      transitionType: SharedAxisTransitionType.horizontal,
      child: child,
    ),
)

// 6. MILESTONE RING — expanding ring animation when milestone hit
// Outer ring scale 0.8 → 1.0, opacity 1 → 0, repeated 2x (pulse effect)
// Then: ring fills with color, tick icon fades in
```

---

### 7.6 Iconography

Use **Material Symbols** (Rounded variant, weight 400, grade 0, optical size 24).

```dart
// In pubspec.yaml:
// material_symbols_icons: ^4.x.x

// Key icons used:
Icons.bolt_rounded           // Spark / AI (NOT the default bolt — use rounded)
Icons.favorite_rounded       // Health milestones
Icons.trending_up_rounded    // Progress / savings
Icons.people_rounded         // Quit Circle
Icons.mic_rounded            // Voice mode
Icons.chat_bubble_rounded    // AI chat
Icons.local_fire_department  // Streak
Icons.check_circle_rounded   // Resisted
Icons.refresh_rounded        // Recovery / restart
Icons.notifications_rounded  // Alerts
Icons.lock_rounded           // Private log
Icons.workspace_premium      // Premium features
```

---

### 7.7 Key Screen Mockups (ASCII)

**Home Dashboard:**
```
┌─────────────────────────────────────────┐
│  Good morning, Aadi ☁️               ⚙️ │  ← DM Sans, secondary color, no heavy header
│─────────────────────────────────────────│
│                                         │
│  ╭─────────────────────────────────╮    │
│  │                                 │    │  ← Primary card, white, radius 20
│  │   14                            │    │  ← "14" in DM Serif Display, 64px
│  │   days smoke-free               │    │  ← DM Sans 14px, secondary text
│  │                                 │    │
│  │   09 : 43 : 12                  │    │  ← Space Mono, HH:MM:SS
│  │   HRS  MIN  SEC                 │    │  ← Spaced caps, 11px
│  │                                 │    │
│  │  ●●●●●●●●●●●●●░░░░  78%        │    │  ← Progress to next milestone
│  │  Next: 3 months (lung function) │    │  ← Subtle, understated
│  ╰─────────────────────────────────╯    │
│                                         │
│  ╭─────────────╮  ╭─────────────╮       │
│  │ ৳ 4,200     │  │  23         │       │  ← 2-col mini cards
│  │ saved       │  │  cigarettes │       │     Money = accentMoney color
│  ╰─────────────╯  │ not smoked  │       │     Count = textPrimary
│                   ╰─────────────╯       │
│                                         │
│  ╭─────────────────────────────────╮    │
│  │  ⚡ I'm craving right now       │    │  ← Big CTA, full width
│  │  Talk to Spark for 2 minutes   │    │     primary color bg, white text
│  ╰─────────────────────────────────╯    │     gentle breathing pulse
│                                         │
│  ─── Today ──────────────────────────  │
│                                         │
│  ╭─────────────────────────────────╮    │
│  │ Daily check-in            →     │    │  ← Check-in card (if not done)
│  │ How are you feeling today?      │    │
│  ╰─────────────────────────────────╯    │
│                                         │
│  [🏠]  [⚡]  [📊]  [👤]               │  ← Navigation bar, flat
└─────────────────────────────────────────┘
```

**AI Chat Screen (Spark):**
```
┌─────────────────────────────────────────┐
│  ← Spark                          🔊   │  ← Simple title, no heavy appbar
│─────────────────────────────────────────│
│                                         │
│  ╭──────────────────────────────╮       │
│  │ Hey Aadi. You've got this.   │       │  ← AI bubble, surfaceAI bg
│  │ 23 cravings resisted — this  │       │     DM Sans 15px, lineheight 1.6
│  │ is just another one. What's  │       │     bubbleAI border radius
│  │ triggering you right now?    │       │
│  ╰──────────────────────────────╯       │
│  Spark  •  just now                     │  ← Tiny label, textTertiary
│                                         │
│                    ╭──────────────────╮ │
│                    │ Work stress. Can't│ │  ← User bubble, surfaceUser bg
│                    │ focus and just   │ │     Right-aligned
│                    │ want one drag    │ │     bubbleUser border radius
│                    ╰──────────────────╯ │
│                         You  •  now     │
│                                         │
│  ╭──────────────────────────────╮       │
│  │ That pull when your brain is │       │
│  │ overwhelmed is real. Here's  │       │  ← typing indicator shows first
│  │ what helps in 60 seconds:    │       │     (3 animated dots in bubble)
│  │                              │       │
│  │ Breathe in 4, hold 4, out 4. │       │
│  │ Do it twice. Then tell me if │       │
│  │ it shifted anything.         │       │
│  ╰──────────────────────────────╯       │
│                                         │
│─────────────────────────────────────────│
│  ╭─────────────────────────────────╮    │
│  │  Type a message...         🎤  │    │  ← Input, surfaceElevated fill
│  ╰─────────────────────────────────╯    │     Mic icon = premium (locked if free)
└─────────────────────────────────────────┘
```

**Achievement Unlock Screen:**
```
┌─────────────────────────────────────────┐
│                                         │
│        [confetti falls from top]        │
│                                         │
│              ╭──────╮                   │
│              │  🌙  │                   │  ← Badge, 96px, circular
│              ╰──────╯                   │     accentStreak color ring
│                                         │
│          One Week Free                  │  ← DM Serif Display 36px
│                                         │
│     7 days. 70 cigarettes not           │
│     smoked. ৳ 2,100 saved.             │  ← DM Sans 16px, secondary
│                                         │
│     Your taste buds are fully           │
│     restored. Your lungs cleared        │  ← Science fact, adds meaning
│     their first layer of residue.       │
│                                         │
│  ╭───────────────────────────────╮      │
│  │         Share this win        │      │  ← Optional share
│  ╰───────────────────────────────╯      │
│                                         │
│              Keep going →               │  ← Text button, not filled
└─────────────────────────────────────────┘
```

---

### 7.8 Design Anti-Patterns (NEVER Do)

- ❌ Gradient backgrounds — use flat color or very subtle mesh (max 3% opacity)
- ❌ Drop shadows on cards — use color contrast (off-white bg, white cards)
- ❌ Purple/blue/pink gradients — they signal "AI slop" instantly
- ❌ Neon green or lime — too aggressive, kills the calm feeling
- ❌ Multiple font families — stick to DM Serif + DM Sans + Space Mono only
- ❌ Animated background blobs — distracting, cheap
- ❌ Heavy illustrations on every screen — one per milestone unlock, that's it
- ❌ Cramped spacing — breathe, leave whitespace, trust emptiness
- ❌ All-caps everywhere — only for counter labels (HRS MIN SEC) and labels
- ❌ More than 3 interactive elements in one card — split it

---

## 8. Database Schema

### Full SQL (Supabase / PostgreSQL)

```sql
-- ============================================================
-- PROFILES (extends auth.users)
-- ============================================================
create table public.profiles (
  id               uuid references auth.users(id) on delete cascade primary key,
  display_name     text,
  avatar_url       text,
  is_guest         boolean default false,
  created_at       timestamptz default now(),

  -- Quit configuration
  quit_date             timestamptz not null,
  quit_goal             text default 'quit' check (quit_goal in ('quit', 'reduce', 'explore')),
  cigarettes_per_day    int not null default 10,
  target_per_day        int, -- for reduce-first users
  cigarettes_per_pack   int not null default 20,
  price_per_pack        numeric(8,2) not null default 10.00,
  currency_code         text default 'BDT',

  -- Motivation (AI context)
  quit_reason            text, -- 'health' | 'family' | 'money' | 'sports' | 'self' | 'other'
  quit_reason_detail     text, -- free text ≤ 300 chars
  primary_triggers       text[],
  previous_attempts      int default 0,
  preferred_language     text default 'en', -- 'en' | 'bn' | 'banglish'

  -- AI companion
  ai_persona             text default 'friend',
  -- 'calm_coach' | 'tough_friend' | 'bengali_big_bro' | 'therapist' | 'funny'

  -- Subscription
  subscription_tier      text default 'free',
  revenuecat_id          text unique,
  trial_used             boolean default false,

  -- Onboarding
  onboarding_completed   boolean default false,
  onboarding_step        int default 0,

  -- Notification preferences
  notif_milestones       boolean default true,
  notif_checkin          boolean default true,
  notif_craving_tips     boolean default false,
  notif_quit_circle      boolean default true,
  checkin_time           time default '09:00:00',

  -- Streak tracking (denormalized for speed)
  smoke_free_streak_days   int default 0,
  honesty_streak_days      int default 0, -- even relapses logged = honesty streak maintained
  best_streak_days         int default 0,
  last_log_date            date
);

alter table public.profiles enable row level security;
create policy "Own profile full access" on public.profiles
  for all using (auth.uid() = id);


-- ============================================================
-- CRAVING LOGS
-- ============================================================
create table public.craving_logs (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references public.profiles(id) on delete cascade not null,
  created_at      timestamptz default now(),

  intensity       int check (intensity between 1 and 10),
  trigger_type    text,
  trigger_note    text,
  mood            text, -- 'anxious' | 'stressed' | 'bored' | 'sad' | 'neutral' | 'social'
  outcome         text check (outcome in ('resisted', 'smoked', 'ongoing', 'unknown')),
  is_private      boolean default false,
  duration_seconds int,
  rescue_used     boolean default false, -- did they use the 2min rescue?
  chat_session_id uuid -- links to ai_chat_sessions if AI was used
);

alter table public.craving_logs enable row level security;
create policy "Own craving logs" on public.craving_logs
  for all using (auth.uid() = user_id);


-- ============================================================
-- SMOKING LOGS (separate from craving — for honest tracking)
-- ============================================================
create table public.smoking_logs (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid references public.profiles(id) on delete cascade not null,
  logged_at        timestamptz default now(),

  cigarettes_count  int not null default 1,
  trigger_type      text,
  mood              text,
  note              text,
  is_private        boolean default true,  -- default private!
  notified_circle   boolean default false,
  recovery_started  boolean default false
);

alter table public.smoking_logs enable row level security;
create policy "Own smoking logs" on public.smoking_logs
  for all using (auth.uid() = user_id);


-- ============================================================
-- DAILY CHECK-INS
-- ============================================================
create table public.daily_checkins (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references public.profiles(id) on delete cascade not null,
  checkin_date    date not null,
  created_at      timestamptz default now(),

  mood            int check (mood between 1 and 5), -- 1=terrible 5=great
  smoke_free      boolean default true,
  cigarettes      int default 0,
  strongest_trigger text,
  note            text,
  ai_reflection   text, -- AI response text, stored to avoid re-fetching

  unique(user_id, checkin_date)
);

alter table public.daily_checkins enable row level security;
create policy "Own check-ins" on public.daily_checkins
  for all using (auth.uid() = user_id);


-- ============================================================
-- AI CHAT SESSIONS
-- ============================================================
create table public.ai_chat_sessions (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references public.profiles(id) on delete cascade not null,
  created_at      timestamptz default now(),
  ended_at        timestamptz,

  session_type    text default 'craving',
  -- 'craving' | 'checkin_reflection' | 'recovery' | 'freeform'

  message_count   int default 0,
  outcome         text, -- 'resisted' | 'smoked' | 'ongoing' | null
  session_summary text  -- AI-generated summary for memory (generated on session end)
);

alter table public.ai_chat_sessions enable row level security;
create policy "Own chat sessions" on public.ai_chat_sessions
  for all using (auth.uid() = user_id);


-- ============================================================
-- AI CHAT MESSAGES
-- ============================================================
create table public.ai_chat_messages (
  id              uuid primary key default gen_random_uuid(),
  session_id      uuid references public.ai_chat_sessions(id) on delete cascade not null,
  user_id         uuid references public.profiles(id) on delete cascade not null,
  created_at      timestamptz default now(),

  role            text not null check (role in ('user', 'assistant')),
  content         text not null,
  tokens_used     int
);

alter table public.ai_chat_messages enable row level security;
create policy "Own messages" on public.ai_chat_messages
  for all using (auth.uid() = user_id);


-- ============================================================
-- AI MEMORY (persistent personalization context)
-- ============================================================
create table public.ai_memory (
  user_id               uuid references public.profiles(id) on delete cascade primary key,
  updated_at            timestamptz default now(),

  -- Computed stats (updated by edge function after each session)
  total_smoke_free_days   int default 0,
  total_cravings_resisted int default 0,
  total_relapses          int default 0,
  best_streak_days        int default 0,
  money_saved             numeric(10,2) default 0,
  cigarettes_avoided      int default 0,

  -- Pattern intelligence
  top_trigger             text,
  peak_craving_time       text, -- e.g. "after 10 PM"
  avg_craving_intensity   numeric(3,1),
  recent_mood_trend       text, -- 'improving' | 'declining' | 'stable'
  last_relapse_trigger    text,

  -- Free-form notes AI builds over time (premium only)
  personal_notes          text -- e.g. "Quitting for daughter Maya. Stressed at work in Nov."
);

alter table public.ai_memory enable row level security;
create policy "Read own memory" on public.ai_memory
  for select using (auth.uid() = user_id);
-- Only service_role (edge functions) can write


-- ============================================================
-- ACHIEVEMENTS
-- ============================================================
create table public.user_achievements (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references public.profiles(id) on delete cascade not null,
  achievement_key text not null,
  unlocked_at     timestamptz default now(),
  notified        boolean default false,

  unique(user_id, achievement_key)
);

alter table public.user_achievements enable row level security;
create policy "Own achievements" on public.user_achievements
  for all using (auth.uid() = user_id);


-- ============================================================
-- QUIT CIRCLE (social accountability)
-- ============================================================
create table public.quit_circles (
  id              uuid primary key default gen_random_uuid(),
  owner_id        uuid references public.profiles(id) on delete cascade not null,
  created_at      timestamptz default now(),
  name            text default 'My Quit Circle'
);

create table public.circle_members (
  id              uuid primary key default gen_random_uuid(),
  circle_id       uuid references public.quit_circles(id) on delete cascade not null,
  user_id         uuid references public.profiles(id) on delete cascade,
  email           text not null,
  display_name    text,
  invite_token    text unique default gen_random_uuid()::text,
  status          text default 'pending' check (status in ('pending', 'accepted', 'declined', 'removed')),
  notification_level text default 'sos_only',
  -- 'sos_only' | 'milestones' | 'all' | 'none'
  joined_at       timestamptz,
  created_at      timestamptz default now()
);

create table public.sos_events (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid references public.profiles(id) on delete cascade not null,
  circle_id       uuid references public.quit_circles(id) on delete cascade not null,
  created_at      timestamptz default now(),
  message         text,
  trigger_type    text,
  resolved        boolean default false,
  resolved_at     timestamptz
);

create table public.sos_responses (
  id              uuid primary key default gen_random_uuid(),
  sos_id          uuid references public.sos_events(id) on delete cascade not null,
  responder_email text,
  response_type   text, -- 'encouragement' | 'call_me' | 'thinking_of_you' | 'custom'
  custom_message  text,
  responded_at    timestamptz default now()
);

-- RLS for circle tables
alter table public.quit_circles enable row level security;
create policy "Owner access" on public.quit_circles for all using (auth.uid() = owner_id);

alter table public.circle_members enable row level security;
create policy "Owner sees members" on public.circle_members for select
  using (exists (
    select 1 from public.quit_circles
    where id = circle_id and owner_id = auth.uid()
  ));


-- ============================================================
-- USAGE TRACKING (rate limiting)
-- ============================================================
create table public.usage_tracking (
  user_id             uuid references public.profiles(id) on delete cascade primary key,
  tracking_date       date default current_date,
  ai_messages_today   int default 0,
  ai_sessions_today   int default 0,
  sos_sent_today      int default 0,
  updated_at          timestamptz default now()
);

alter table public.usage_tracking enable row level security;
create policy "Own usage" on public.usage_tracking for select using (auth.uid() = user_id);


-- ============================================================
-- INDEXES
-- ============================================================
create index idx_craving_logs_user_date on public.craving_logs(user_id, created_at desc);
create index idx_smoking_logs_user_date on public.smoking_logs(user_id, logged_at desc);
create index idx_chat_messages_session  on public.ai_chat_messages(session_id, created_at asc);
create index idx_checkins_user_date     on public.daily_checkins(user_id, checkin_date desc);
create index idx_achievements_user      on public.user_achievements(user_id);
create index idx_circle_members_token   on public.circle_members(invite_token);
```

---

## 9. Feature Specification — MVP

### F1: Guest Mode

- User can install and use core features without creating an account
- Supabase anonymous auth — creates a real UUID but no credentials
- Data stored locally (Isar) + synced to Supabase anonymously
- When user signs in with Google → anonymous account is linked, data preserved
- Guest limitations: no Quit Circle, no subscription, no cross-device sync

### F2: Onboarding (See Section 13 for full flow)

5 screens, under 2 minutes, no account required until the end.

### F3: Home Dashboard

**State awareness — dashboard changes based on user state:**

```
New user (day 0):
  → Encouraging first-day message, no stats yet, big CTA

Active user (day 1+):
  → Full dashboard: counter, savings, craving button, check-in card

Post-relapse:
  → Compassionate tone, recovery-focused CTA ("Restart your journey")
  → Honesty streak shown prominently (smoke-free streak shows 0, honesty streak continues)

Inactive user (7+ days since last log):
  → Comeback card: "Still here when you're ready."
```

### F4: Craving Rescue (2-minute flow)

```
Step 1: Intensity (1–10 slider, takes 3 seconds)
Step 2: Trigger (chip selection, 6 common + custom)
Step 3: Mode selection:
  - Talk to Spark (AI chat)
  - 2-min guided rescue (breathing + distraction prompts)
  - Send SOS to circle
  - Log privately only

[AI Chat path]
  → AI responds immediately (pre-built context)
  → Conversation until user is ready to log outcome
  → Outcome: Resisted / Smoked / Still craving / Talk more

[2-min Rescue path — no AI cost, works offline]
  → Timer starts
  → Micro-actions shown every 30s:
    - "Take 3 slow breaths. In 4, hold 4, out 6."
    - "Walk to another room or outside."
    - "Read your quit reason."
    - "Drink a full glass of water."
  → Timer completes → outcome log
```

**Critical rule:** No ad is ever shown during craving rescue. Not before, not after.

### F5: AI Text Chat (Spark)

See Section 10 for full architecture. Feature notes:

- Streaming response (token-by-token display, ChatGPT style)
- Typing indicator (3 animated dots in bubble) while streaming starts
- Free tier: 10 AI messages/day, 3 sessions/day
- Premium: unlimited
- Language: English by default, Bangla/Banglish if persona is "Bengali Big Bro" or user language set

### F6: Private Smoking Log

- Log cigarettes smoked — always private by default
- "Private" badge visible on log entry
- User can choose to notify circle after logging (not before)
- Smoke-free streak resets, but **honesty streak never resets as long as they log**
- AI recovery flow offered (not forced) after logging

### F7: Relapse Recovery

After logging a relapse:
```
1. App confirms private or shared
2. Short compassionate message (never "failure" language)
3. AI asks: "What happened? One word is fine."
4. AI generates 3 next micro-actions
5. User picks one → starts recovery streak
6. "One choice is all it takes to start over."
```

### F8: Daily Check-in

- 30 seconds maximum
- Mood (5 emoji) + smoke-free toggle + optional note
- If smoked: how many? (links to smoking log)
- Optional: "Want Spark's take?" → AI reflection (uses 1 daily message)
- Skipping check-in does NOT break honesty streak

### F9: Health Milestones Timeline

| Time | What Happens | Icon |
|---|---|---|
| 20 min | Heart rate and blood pressure drop | ❤️ |
| 12 hrs | Blood oxygen normalizes | 🫁 |
| 24 hrs | Heart attack risk starts dropping | 💛 |
| 48 hrs | Taste & smell nerve endings regrow | 👃 |
| 72 hrs | Breathing noticeably easier | 🌬️ |
| 1 week | Circulation improves significantly | 🩸 |
| 2 weeks | Lung function improves | 🫁 |
| 1 month | Cough and fatigue reduce | ⚡ |
| 3 months | Lung capacity up 30% | 💨 |
| 6 months | Cravings rare and weak | 🌿 |
| 1 year | Heart disease risk halved | ❤️‍🔥 |
| 5 years | Stroke risk = non-smoker | 🧠 |
| 10 years | Lung cancer risk halved | 🎯 |
| 15 years | Heart disease risk = non-smoker | 🏆 |

Each milestone: animated unlock screen + AI congratulation + science explanation.

### F10: Savings Tracker

- Total money saved (primary, large DM Serif Display number)
- "What could you buy?" — converts to real items with local price context
  - BDT: Rice bag, Eid outfit, smartphone, concert ticket
  - USD: Coffee, pizza, Netflix month, AirPods
- Monthly bar chart (fl_chart, minimal, no clutter)
- Projection: 1 year / 5 years savings

### F11: Quit Circle

- Invite up to 1 buddy (free) or 5 (premium) via email
- Buddy receives email with invite link (opens app or web page)
- Notification level set by user: SOS only / Milestones / All
- SOS flow:
  - User taps "Send SOS to Circle" during craving rescue
  - Buddy gets push notification + email
  - Buddy can respond with: 💪 "You've got this!" / 📞 "Call me" / 💙 "Thinking of you"
  - Response shows in app within the rescue session
- Privacy: Quit Circle sees milestones and SOS only. They **never** see smoking logs unless user explicitly shares.

### F12: Achievements

**Time-based:**
1 hour, 6 hours, 12 hours, 1 day, 3 days, 1 week, 2 weeks, 1 month, 3 months, 6 months, 1 year

**Resistance-based:**
Resisted 1st craving, 5, 10, 25, 50, 100

**Money-based:**
Saved ৳500, ৳1000, ৳5000, ৳10,000

**Honesty-based:**
Logged 3 days in a row, 7 days, 30 days (regardless of smoking)

**Recovery-based:**
Came back after relapse, Restarted 3 times (resilience badge)

### F13: Trigger Intelligence

Auto-generated insights (no AI cost, pure SQL aggregation):
- "Your cravings peak between 9–11 PM."
- "Stress triggers 60% of your cravings."
- "You resist 74% of cravings when you use the rescue flow."
- "Your best days happen after morning check-ins."

Premium: AI-generated weekly insight narrative.

### F14: Notifications

| Type | Trigger | Content style |
|---|---|---|
| Milestone approach | 2 hours before milestone | "You're almost there." |
| Milestone reached | When achieved | "You did it. Here's what changed in your body." |
| Daily check-in | User-configured time | "30 seconds. How are you?" |
| Quit Circle SOS | Buddy sends SOS | "Aadi needs your support right now." |
| Comeback | 5 days since last log | "Still here. No judgment." |
| Streak protection | 23:00 if no log that day | "Keep your streak alive — 5 minutes." |

**No** motivational quote spam. No "Did you know?" facts. Quality over frequency.

---

## 10. AI Architecture Deep Dive

### 10.1 Request Flow

```
Flutter client
    │
    │  POST /functions/v1/ai-chat
    │  Authorization: Bearer <supabase_jwt>
    │  Body: { session_id, message, session_type, craving_context? }
    │
    ▼
Supabase Edge Function (Deno)
    │
    ├── 1. Verify JWT → get user_id
    ├── 2. Check usage_tracking → rate limit if free tier exceeded
    ├── 3. Fetch profile + ai_memory → build system prompt
    ├── 4. Fetch last 6 messages from session → conversation history
    ├── 5. Call Anthropic API (streaming)
    ├── 6. Stream response back to client (SSE)
    └── 7. After stream ends: save message + increment usage counter
    
Anthropic API (claude-sonnet-4-20250514)
    │
    └── Stream tokens → Edge Function → Flutter client
```

### 10.2 System Prompt Template

```typescript
function buildSystemPrompt(profile: Profile, memory: AiMemory, sessionType: string): string {
  const smokeFreeTime = calculateSmokeFreeTime(profile.quit_date);
  
  return `You are Spark, a compassionate AI companion inside ZeroPuff — a quit-smoking app.

## Who You're Talking To
Name: ${profile.display_name}
Smoke-free: ${smokeFreeTime.days} days, ${smokeFreeTime.hours} hours
Quit date: ${profile.quit_date}
Goal: ${profile.quit_goal === 'reduce' ? 'Reducing from ' + profile.cigarettes_per_day + ' to ' + profile.target_per_day + '/day' : 'Quitting completely'}
Reason for quitting: ${profile.quit_reason_detail || profile.quit_reason}
Known triggers: ${profile.primary_triggers?.join(', ') || 'not specified yet'}
Previous attempts: ${profile.previous_attempts}
Preferred language: ${profile.preferred_language}

## Their Journey So Far
Total cravings resisted: ${memory.total_cravings_resisted}
Total relapses: ${memory.total_relapses}
Best streak: ${memory.best_streak_days} days
Money saved: ${profile.currency_code} ${memory.money_saved}
Top trigger: ${memory.top_trigger || 'unknown'}
Peak craving time: ${memory.peak_craving_time || 'varies'}
Mood trend: ${memory.recent_mood_trend || 'unknown'}
${memory.personal_notes ? '## Personal Notes\n' + memory.personal_notes : ''}

## This Session
Type: ${sessionType}
${sessionType === 'craving' ? `Craving intensity: ${cravingContext?.intensity}/10\nTrigger: ${cravingContext?.trigger}` : ''}

## Your Persona
${getPersonaInstructions(profile.ai_persona, profile.preferred_language)}

## Response Rules
- Keep responses SHORT: 2-4 sentences during cravings, up to 6 for reflection sessions
- Ask only ONE question per response
- During cravings: acknowledge → validate → redirect → one action
- Never use shame, failure language, or judgment
- If relapse happened: lead with compassion, zero blame, immediately pivot to recovery
- Never recommend medications or medical treatments
- If user mentions self-harm or crisis → gently suggest professional help, provide hotline
- Max 150 words per response unless user explicitly asks for more
- No excessive emojis: max 1 per message, only when it adds warmth not decoration`;
}

function getPersonaInstructions(persona: string, language: string): string {
  const personas = {
    calm_coach: `Be warm but focused. You're a supportive coach who believes in them. Measured, calm, grounding. Use simple breathing techniques. Speak like a steady hand on a shoulder.`,
    
    tough_friend: `Be direct and confident. You don't baby them — you believe in them enough to be real. "You've gotten through harder things. Don't let a craving win right now." Still kind, never cruel.`,
    
    bengali_big_bro: `Mix Bangla and English naturally (Banglish). Be emotionally warm and culturally familiar. Use phrases like "bhai" or "vai", reference family and duty naturally when relevant. Example: "Bhai, tui parbi — tui আগেও korechi." Be like an older sibling who genuinely cares. ${language === 'bn' ? 'Respond primarily in Bangla.' : 'Mix naturally.'}`,
    
    therapist: `Use grounding and cognitive reframing techniques. Ask reflective questions. Help them observe thoughts without being controlled by them. "What is the craving telling you right now?" CBT-adjacent, never clinical.`,
    
    funny: `Use light humor to defuse the craving. A well-timed joke breaks the tension. Never make fun of them — only make fun of the cigarette. "Your brain thinks a 3mm paper tube is worth throwing away all your progress. It's wrong." Keep it real underneath the humor.`,
  };
  return personas[persona] || personas.calm_coach;
}
```

### 10.3 Rate Limits

| Tier | AI messages/day | Sessions/day | Voice |
|---|---|---|---|
| Guest | 5 | 1 | ❌ |
| Free | 10 | 3 | ❌ |
| Premium | Unlimited | Unlimited | ✅ |

When free limit is hit → show compassionate upsell bottom sheet (not a modal interrupt during rescue).

### 10.4 Cost Optimization

```
Prompt caching: Cache static system prompt prefix with Anthropic's cache_control
  → Saves ~70% of input token cost on system prompt

Context window: Send only last 6 messages (not full history)
  → Avg session: 8 messages × 150 tokens = 1,200 tokens output

Per-session cost estimate (Sonnet):
  Input:  ~800 tokens × $3/M  = $0.0024
  Output: ~1,200 tokens × $15/M = $0.018
  Total per session: ~$0.02

At 50k MAU, 20% daily active, avg 1 session/day:
  10,000 sessions/day × $0.02 = $200/day = ~$6,000/month
  Revenue at 5% premium conversion: ~$12,000/month
  → AI cost is ~50% of revenue at this scale (acceptable, improves as scale grows)
```

### 10.5 Offline Fallback

When AI is unavailable (no internet, API down):
- 2-minute guided rescue still works (pure local, no API)
- Show pre-written rescue messages from a local JSON file (20 responses by trigger type)
- "Spark will catch up when you're back online" — no error message

---

## 11. Monetization

### Tiers

| Feature | Guest | Free | Premium Monthly | Premium Annual |
|---|---|---|---|---|
| Core dashboard | ✅ | ✅ | ✅ | ✅ |
| Health milestones | ✅ | ✅ | ✅ | ✅ |
| Savings tracker | ✅ | ✅ | ✅ | ✅ |
| 2-min guided rescue | ✅ | ✅ | ✅ | ✅ |
| Daily check-in | ✅ | ✅ | ✅ | ✅ |
| Basic achievements | ✅ | ✅ | ✅ | ✅ |
| Private smoking log | ✅ | ✅ | ✅ | ✅ |
| AI chat (craving) | 5 msgs | 10 msgs/day | Unlimited | Unlimited |
| Quit Circle | ❌ | 1 buddy | 5 buddies | 5 buddies |
| AI persona choice | ❌ | ❌ | ✅ | ✅ |
| Voice mode | ❌ | ❌ | ✅ | ✅ |
| AI memory | ❌ | Basic | Full | Full |
| Advanced analytics | ❌ | ❌ | ✅ | ✅ |
| Weekly AI insight | ❌ | ❌ | ✅ | ✅ |
| Custom danger alerts | ❌ | ❌ | ✅ | ✅ |
| Ad-free | ❌ | ❌ | ✅ | ✅ |
| **Price** | Free | Free | ~$4.99/mo | ~$34.99/yr |

**Bangladesh pricing** (via RevenueCat regional pricing):
- Premium Monthly: ৳299/mo
- Premium Annual: ৳1,999/yr

### Ad Policy
- Free & Guest: Banner ad on home screen **bottom** only (NavigationBar sits above it)
- **NEVER** ads during craving rescue, chat, or achievement unlock
- Interstitial: One time only, after first milestone unlock (tasteful, not jarring)
- Premium: No ads anywhere, ever

### Trial
- 7-day free Premium trial on first-time onboarding completion
- Offered before sign-in screen to maximize conversion
- RevenueCat handles grace periods and receipt validation

---

## 12. App Navigation & Screen Map

```
App Entry
    │
    ├── Splash (auth state check)
    │
    ├── [No session] → Welcome → Auth
    │
    ├── [Session, onboarding incomplete] → Onboarding Wizard
    │
    └── [Session + onboarded] → Main Shell
            │
            ├── Bottom Nav: Home | Spark | Progress | Circle | Profile
            │
            ├── HOME
            │   ├── → Craving Rescue Sheet (I'm Craving CTA)
            │   ├── → Daily Check-in Sheet
            │   ├── → Achievement Detail
            │   └── → Milestone Detail
            │
            ├── SPARK (AI Hub)
            │   ├── → New Craving Session
            │   ├── → Daily Reflection Session
            │   ├── → Free Chat
            │   ├── → Session History
            │   └── [Premium] → Voice Mode
            │
            ├── PROGRESS
            │   ├── Health Timeline
            │   ├── Savings Detail
            │   ├── Craving Log History
            │   ├── Smoking Log History
            │   ├── Achievements Gallery
            │   └── [Premium] → Analytics (heatmap, patterns)
            │
            ├── CIRCLE (Quit Circle)
            │   ├── My Circle (member list)
            │   ├── → Invite Buddy
            │   ├── → SOS History
            │   └── → Circle Settings
            │
            └── PROFILE
                ├── Edit Profile
                ├── Quit Settings
                ├── AI Persona Picker
                ├── Notification Settings
                ├── Language Settings
                ├── Subscription
                ├── Privacy & Data
                └── About / Help
```

**Bottom Navigation Labels:**
- Home (🏠)
- Spark (⚡)
- Progress (📊)
- Circle (👥)
- You (👤)

---

## 13. Onboarding Flow

### Design: Minimal, Warm, Fast

No heavy illustrations. Clean typography. One question per screen. Progress dots visible.

```
Screen 1: Welcome
──────────────────
[Small brand mark — spark icon + "ZeroPuff" wordmark]

"You decided to quit.
That's already the hardest part."

Subtext: "Set up in 90 seconds. No account needed yet."

[Get started →]
[Already have an account? Sign in]


Screen 2: Your Goal
──────────────────
"What brings you here?"

○  Quit completely
○  Cut down first
○  I already quit — just tracking
○  Just exploring for now

[Continue →]  [Skip]


Screen 3: Your Habit
──────────────────
"Tell us about your habit"
(so we can calculate your savings accurately)

Cigarettes per day:      [slider 1–60, default 10]
Price per pack:          [number input + currency]  
Cigarettes per pack:     [10 | 20 | 25 selector]

Est. monthly savings: ৳ 2,400 ✨

[Continue →]


Screen 4: Your Quit Date
──────────────────
"When did you last smoke?"

◉  Today — I'm quitting right now
○  I quit on:  [Date picker]
○  I plan to quit:  [Date picker]

[Continue →]


Screen 5: Your Triggers
──────────────────
"When do cravings usually hit you?"
(Spark will remember this to help you better)

[Stress] [After eating] [Boredom] [Friends]
[Tea/coffee] [Night time] [Driving] [Drinking]

+ Add your own: [text field]

Optionally, tell Spark your #1 reason for quitting:
[text area, 200 chars, placeholder: "For my daughter. For my lungs. For myself."]

[Continue →]  [Skip]


Screen 6: Meet Spark + Sign Up
──────────────────
[Spark avatar — simple bolt icon in a soft circle, animated gentle pulse]

"Hi. I'm Spark.

I'm available 24/7 — especially at 2 AM
when the craving feels impossible."

[Sign in with Google]   ← primary button
[Continue without account]  ← secondary, smaller

──── OR start a 7-day free Premium trial ────
[Try Premium free for 7 days →]

Legal: By continuing you agree to our Terms and Privacy Policy.
```

---

## 14. Backend Architecture

### Supabase Edge Functions

```
/supabase/functions/
├── ai-chat/              # AI conversation (SSE streaming)
├── update-ai-memory/     # Post-session memory update (async)  
├── check-achievements/   # Check for newly unlocked achievements
├── daily-checkin-ai/     # Process check-in, return AI response
├── quit-circle-invite/   # Send invite email to buddy
├── quit-circle-sos/      # Send SOS push to circle members
├── sos-response/         # Handle buddy's one-tap response
├── revenuecat-webhook/   # Subscription lifecycle events
└── streak-calculator/    # Cron: update streaks + honesty streak daily
```

### Key Edge Function: ai-chat

```typescript
// supabase/functions/ai-chat/index.ts
import Anthropic from 'npm:@anthropic-ai/sdk';

const RATE_LIMITS = { guest: 5, free: 10, premium: Infinity };

Deno.serve(async (req) => {
  // 1. Auth
  const token = req.headers.get('Authorization')?.replace('Bearer ', '');
  const { data: { user }, error } = await supabase.auth.getUser(token);
  if (error || !user) return new Response('Unauthorized', { status: 401 });

  const { session_id, message, session_type, craving_context } = await req.json();

  // 2. Rate limit check
  const { data: profile } = await supabase.from('profiles').select('*').eq('id', user.id).single();
  const { data: usage } = await supabase.from('usage_tracking').select('*').eq('user_id', user.id).single();
  
  const limit = RATE_LIMITS[profile.subscription_tier] ?? RATE_LIMITS.free;
  if ((usage?.ai_messages_today ?? 0) >= limit) {
    return Response.json({ error: 'limit_reached', tier: profile.subscription_tier }, { status: 429 });
  }

  // 3. Build context
  const [{ data: memory }, { data: history }] = await Promise.all([
    supabase.from('ai_memory').select('*').eq('user_id', user.id).single(),
    supabase.from('ai_chat_messages')
      .select('role, content')
      .eq('session_id', session_id)
      .order('created_at', { ascending: true })
      .limit(6),
  ]);

  const systemPrompt = buildSystemPrompt(profile, memory, session_type, craving_context);

  // 4. Stream from Claude
  const anthropic = new Anthropic({ apiKey: Deno.env.get('ANTHROPIC_API_KEY') });
  
  const stream = anthropic.messages.stream({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 300,
    system: [
      {
        type: 'text',
        text: STATIC_SYSTEM_PREFIX, // cached — saves 70% input token cost
        cache_control: { type: 'ephemeral' },
      },
      { type: 'text', text: systemPrompt },
    ],
    messages: [
      ...(history ?? []),
      { role: 'user', content: message },
    ],
  });

  // 5. Stream SSE to Flutter
  const encoder = new TextEncoder();
  let fullResponse = '';

  const readable = new ReadableStream({
    async start(controller) {
      for await (const chunk of stream) {
        if (chunk.type === 'content_block_delta' && chunk.delta.type === 'text_delta') {
          fullResponse += chunk.delta.text;
          controller.enqueue(encoder.encode(`data: ${JSON.stringify({ delta: chunk.delta.text })}\n\n`));
        }
      }
      
      // 6. Persist after stream completes
      await Promise.all([
        supabase.from('ai_chat_messages').insert([
          { session_id, user_id: user.id, role: 'user', content: message },
          { session_id, user_id: user.id, role: 'assistant', content: fullResponse },
        ]),
        supabase.from('usage_tracking').upsert({
          user_id: user.id,
          tracking_date: new Date().toISOString().split('T')[0],
          ai_messages_today: (usage?.ai_messages_today ?? 0) + 1,
        }),
      ]);
      
      controller.enqueue(encoder.encode('data: [DONE]\n\n'));
      controller.close();
    },
  });

  return new Response(readable, {
    headers: {
      'Content-Type': 'text/event-stream',
      'Cache-Control': 'no-cache',
      'Connection': 'keep-alive',
    },
  });
});
```

### Edge Function: quit-circle-sos

```typescript
// Sends push notification to all circle members when user triggers SOS
Deno.serve(async (req) => {
  const { user_id, message, trigger_type } = await req.json();
  
  // Get circle members who want SOS notifications
  const { data: members } = await supabase
    .from('circle_members')
    .select('*, profiles(*)')
    .eq('status', 'accepted')
    .in('notification_level', ['sos_only', 'all'])
    .eq('quit_circles.owner_id', user_id);

  // Create SOS event
  const { data: sosEvent } = await supabase
    .from('sos_events')
    .insert({ user_id, circle_id: members[0].circle_id, message, trigger_type })
    .select().single();

  // Send FCM push to each member who has the app
  // Send email via Resend to members without app
  const { data: profile } = await supabase.from('profiles').select('display_name').eq('id', user_id).single();
  
  for (const member of members) {
    await sendSOSNotification(member, profile.display_name, sosEvent.id);
  }
  
  return Response.json({ success: true, sos_id: sosEvent.id });
});
```

---

## 15. Scalability Plan

### Database (Supabase)

| MAU Range | Plan | Monthly Cost | Notes |
|---|---|---|---|
| 0–10k | Free | $0 | 500MB DB, 2GB bandwidth |
| 10k–100k | Pro | $25 | 8GB DB, 250GB bandwidth |
| 100k–500k | Team | $599 | 100GB DB, 2TB bandwidth, SLA |
| 500k+ | Enterprise | Custom | Self-hosted Supabase or migrate to RDS |

### AI Costs (Claude API)

```
Assumptions at 50k MAU:
  Daily active rate: 20% = 10,000 DAU
  Sessions per active user: 1.2/day
  Messages per session: 8
  Tokens per message: ~200 in + 150 out

Daily:
  Input:  10,000 × 1.2 × 8 × 200 = 19.2M tokens × $3/M = $57.6
  Output: 10,000 × 1.2 × 8 × 150 = 14.4M tokens × $15/M = $216
  Daily AI cost: ~$274 = ~$8,200/month

With prompt caching (static prefix cached):
  Input cost reduced ~70% → Daily AI cost: ~$160 = ~$4,800/month

Premium revenue at 5% conversion:
  2,500 users × $4.99 avg = $12,475/month
  
AI cost ratio: ~38% of revenue at 50k MAU → healthy, improves with scale
```

### Cost Controls Applied
1. Prompt caching for static system prompt prefix
2. Max 6 message history per request (no full history)
3. max_tokens: 300 (strict cap)
4. Server-side rate limiting (not just client-side)
5. Pre-built offline fallback messages (no API call needed)
6. Cache daily check-in AI responses (don't re-fetch on screen re-enter)

---

## 16. Development Phases

### Phase 0 — Foundation (Week 1)
- [ ] Flutter project init, folder structure, pubspec.yaml
- [ ] Supabase project + full schema migration
- [ ] GoRouter scaffold (all routes, auth guard)
- [ ] Riverpod providers scaffold
- [ ] M3 Expressive theme (colors, typography, shapes)
- [ ] Google Fonts package + font preloading
- [ ] RevenueCat account + Play Console subscription products
- [ ] AdMob account + ad unit IDs
- [ ] FCM + firebase_core setup
- [ ] Isar schema (local models)
- [ ] `.env` secrets management

### Phase 1 — MVP Core (Weeks 2–5)
- [ ] Supabase Anonymous Auth + Guest mode
- [ ] Google Sign-In + account linking
- [ ] Onboarding wizard (6 screens)
- [ ] Home dashboard (counter, savings, CTA)
- [ ] Health milestone timeline
- [ ] 2-minute guided rescue (offline, no AI)
- [ ] Private smoking log
- [ ] Daily check-in
- [ ] Basic achievements (time-based)
- [ ] Savings tracker
- [ ] Streak logic (smoke-free + honesty)
- [ ] Settings + profile edit
- [ ] Notifications (local)
- [ ] Dashboard state awareness (new / active / relapsed / inactive)

### Phase 2 — AI Integration (Weeks 6–8)
- [ ] Edge Function: `ai-chat` with SSE streaming
- [ ] Chat UI with streaming tokens + typing indicator
- [ ] Craving rescue → AI chat flow
- [ ] AI memory system (edge function: `update-ai-memory`)
- [ ] Rate limiting (free vs premium)
- [ ] Daily check-in AI reflection
- [ ] Offline fallback (local rescue messages)
- [ ] Relapse recovery AI flow

### Phase 3 — Quit Circle (Weeks 9–10)
- [ ] Circle creation + invite flow
- [ ] Edge Function: `quit-circle-invite` (email via Resend)
- [ ] SOS flow from craving rescue
- [ ] Edge Function: `quit-circle-sos` + FCM delivery
- [ ] Buddy one-tap response
- [ ] Circle screen in app
- [ ] Invite acceptance web page (simple, links to app)

### Phase 4 — Monetization (Weeks 11–12)
- [ ] RevenueCat integration
- [ ] Paywall screen (beautiful, not aggressive)
- [ ] 7-day trial flow
- [ ] Premium feature gating
- [ ] AdMob banner on home screen
- [ ] RevenueCat webhook edge function
- [ ] Subscription management screen

### Phase 5 — Premium Features (Weeks 13–14)
- [ ] Voice mode (speech_to_text + flutter_tts)
- [ ] AI persona selector (5 personas)
- [ ] Bangla/Banglish language toggle
- [ ] Advanced analytics (heatmap, pattern charts)
- [ ] Weekly AI insight narrative
- [ ] Custom danger-window reminders
- [ ] Trigger intelligence cards

### Phase 6 — Polish & Launch (Weeks 15–16)
- [ ] Lottie animations for achievement unlocks
- [ ] Full dark mode QA
- [ ] Accessibility audit (semantic labels, min touch target 48px, text scaling)
- [ ] Performance profiling (60fps on Snapdragon 665 target device)
- [ ] PostHog + Crashlytics integration
- [ ] Privacy policy, terms, medical disclaimer
- [ ] Account deletion flow (GDPR)
- [ ] Play Store listing (icon, screenshots, feature graphic, description)
- [ ] Internal test track → Closed beta → Production

---

## 17. Codex Prompting Strategy

### Master Context Prompt (paste at start of every session)

```
I'm building ZeroPuff — an AI-powered quit-smoking Flutter app for Android.

## Stack
- Flutter 3.x with Dart
- State: Riverpod (flutter_riverpod + riverpod_annotation)
- Navigation: GoRouter
- Backend: Supabase (auth, DB, Edge Functions)
- Local DB: Isar (offline-first)
- UI: Material 3 Expressive (DynamicSchemeVariant.expressive)
- Animations: flutter_animate
- Payments: RevenueCat (purchases_flutter)
- Ads: Google AdMob

## Architecture Rules
- Feature-first folder structure under lib/features/
- All Supabase queries go through a repository class under lib/repositories/
- All state is Riverpod providers — no setState anywhere
- Isar for local storage, sync to Supabase in background
- Never call Anthropic API from Flutter client — always via Supabase Edge Function
- Max 150 lines per widget file — split if larger
- Use Material 3 components only — no custom reinventions of buttons/cards/chips

## Folder Structure
lib/
├── core/
│   ├── constants/        # app_constants.dart, achievement_keys.dart
│   ├── theme/            # app_theme.dart, app_colors.dart, app_typography.dart, app_shapes.dart, app_spacing.dart
│   ├── router/           # router.dart (GoRouter config)
│   └── utils/            # date_utils.dart, format_utils.dart
├── features/
│   ├── auth/             # screens/, providers/
│   ├── onboarding/       # screens/, providers/, models/
│   ├── home/             # screens/, widgets/, providers/
│   ├── rescue/           # screens/, widgets/, providers/   ← craving rescue
│   ├── chat/             # screens/, widgets/, providers/   ← AI chat
│   ├── progress/         # screens/, widgets/, providers/
│   ├── circle/           # screens/, widgets/, providers/   ← Quit Circle
│   └── profile/          # screens/, providers/
├── repositories/
│   ├── auth_repository.dart
│   ├── profile_repository.dart
│   ├── chat_repository.dart
│   ├── craving_repository.dart
│   ├── smoking_repository.dart
│   ├── achievement_repository.dart
│   └── circle_repository.dart
├── models/
│   └── [Isar models + plain Dart models]
└── main.dart

## Design System (NON-NEGOTIABLE)
- Font: DM Serif Display (display) + DM Sans (body) + Space Mono (live counter)
- Seed color: Color(0xFF2A9D7C)
- Scheme: DynamicSchemeVariant.expressive
- Cards: elevation 0, radius 20, white on off-white background
- NO gradients. NO drop shadows (use color contrast instead).
- NO neon. NO heavy animations.
- Breathing pulse on craving CTA only.

Now: [SPECIFIC TASK]
```

### Session-Specific Prompts (use after master context)

**Phase 1 Prompt Order:**
1. "Build the M3 Expressive theme setup: app_colors.dart, app_typography.dart, app_shapes.dart, app_spacing.dart, and app_theme.dart using DM fonts and seed color #2A9D7C"
2. "Set up Supabase client singleton, anonymous auth, Google Sign-In, and Riverpod auth provider with user state"
3. "Build the onboarding wizard: 6 screens with GoRouter navigation, Riverpod state, and progress dots"
4. "Build the Home Dashboard screen with live smoke-free counter using Space Mono, money saved card, and animated craving CTA button"
5. "Build the 2-minute offline craving rescue flow with intensity slider, trigger chip selection, and micro-action prompts"

---

## 18. Risk Analysis

| Risk | Impact | Likelihood | Mitigation |
|---|---|---|---|
| Users don't trust AI | High | Medium | Short responses, persona choice, Bengali Big Bro feel |
| Free limit feels too stingy | High | Medium | 10 msgs/day is enough for real craving moments |
| Quit Circle causes shame | High | Low | Privacy-first defaults, no auto-exposure |
| Voice costs spiral | High | Medium | Voice is premium only, transcription not stored |
| App feels like generic tracker | High | Low | Craving rescue is the main screen, tracker is secondary |
| Claude API downtime | Medium | Low | Offline fallback, local rescue flow |
| Subscription sync bugs | Medium | Low | RevenueCat handles validation |
| RLS policy mistakes | High | Medium | Test every policy with Supabase dashboard RLS tester |
| User logs relapse and leaves | High | High | "Honesty streak" concept + comeback notifications |
| Bangladesh-only perception | Medium | Low | English-first with Bangla as a persona option |

---

## 19. Launch Checklist

### Product
- [ ] Onboarding < 2 minutes (test with 5 real people)
- [ ] Dashboard all 4 states tested (new/active/relapsed/inactive)
- [ ] Craving rescue works offline
- [ ] AI chat works with streaming
- [ ] Quit Circle invite + SOS flow end-to-end
- [ ] Relapse logging: no shame language anywhere
- [ ] Private log: circle is NOT notified
- [ ] Achievement unlocks with animation
- [ ] Premium gating correct on all features
- [ ] Ads: not shown during rescue or chat

### Backend
- [ ] All RLS policies tested
- [ ] Rate limiting tested (free tier, guest, premium)
- [ ] Edge functions deployed + tested
- [ ] AI API key never exposed to client
- [ ] RevenueCat webhook live
- [ ] FCM push notifications working
- [ ] Streak cron job running

### Safety & Legal
- [ ] Medical disclaimer in onboarding
- [ ] Privacy policy (GDPR-compliant)
- [ ] Terms of service
- [ ] Crisis response prompt (self-harm → hotline message)
- [ ] Account deletion (data export + delete)
- [ ] Supporter unsubscribe link in every email
- [ ] No AI medical diagnosis language

### App Store
- [ ] App name + icon (spark motif, clean)
- [ ] Screenshots (3–8, no generic template screenshots)
- [ ] Feature graphic (1024×500)
- [ ] Short description (≤80 chars)
- [ ] Full description (no keyword stuffing)
- [ ] Content rating: Everyone
- [ ] Internal → Closed beta → Production

---

## 20. Future Roadmap

### v2 — Community (3–6 months post-launch)
- Anonymous wins feed ("47 days. Still here.")
- Group quit challenges
- Anonymous peer support rooms
- AI-moderated to prevent shame

### v2 — Advanced AI
- Longer AI memory (premium) — remembers across months
- Pattern prediction ("Your risk window is tonight 10–11 PM")
- AI-generated weekly quit report card
- Quit plan builder (personalized step-by-step)

### v3 — Integrations
- Android widget (streak + savings on home screen)
- Amazfit / WearOS heart rate correlation with cravings
- Calendar integration for danger-window alerts
- WhatsApp SOS (link buddy by WhatsApp number)

### v3 — Global
- Country-specific cigarette price database
- Full Bangla UI (not just Banglish persona)
- Regional health resource links
- iOS release

---

## 21. Appendix

### A: App Name Decision

**ZeroPuff** — recommended.

Reasoning: "Spark" works on 3 levels — the AI companion's name, the spark of motivation, and the metaphorical opposite of lighting a cigarette. Short, memorable, works globally.

Alternatives if ZeroPuff is taken: **AirSpark**, **Sparq**, **CraveZero**, **BreatheSpark**

### B: Key Copy

```
Home CTA:
  "I'm craving right now"

Rescue start:
  "Give me 2 minutes before you decide."

Private log:
  "Log honestly. Your circle won't see this."

Relapse recovery:
  "You didn't lose everything. You logged honestly,
  and that's how we learn."

SOS prompt:
  "Want your circle before you decide?"

Comeback notification:
  "Still here. No judgment. Ready when you are."

Paywall hook:
  "Less than a pack. Always there when the craving hits."

Share card (premium):
  "21 days. 210 cigarettes not smoked. ৳ 6,300 saved."

Honesty streak:
  "Honesty: 14 days — every log, even the hard ones."
```

### C: Third-Party Accounts Needed

| Service | Purpose | Cost | Link |
|---|---|---|---|
| Supabase | Database + Auth + Edge Functions | Free → $25/mo | supabase.com |
| Anthropic | Claude API | Pay-per-use | console.anthropic.com |
| RevenueCat | Subscription management | Free <$2.5k MRR | revenuecat.com |
| Google Play Console | Android distribution | $25 one-time | play.google.com/console |
| Google AdMob | Ads (free tier) | Free | admob.google.com |
| Firebase | FCM + Crashlytics | Free | console.firebase.google.com |
| PostHog | Analytics | Free <1M events | posthog.com |
| Resend | Quit Circle emails | Free 3k/mo | resend.com |

### D: Full pubspec.yaml

```yaml
name: quit_spark
description: AI-powered quit smoking companion
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"
  flutter: ">=3.13.0"

dependencies:
  flutter:
    sdk: flutter

  # Supabase
  supabase_flutter: ^2.5.0

  # State + Navigation  
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.2.0

  # Local DB (offline-first)
  isar: ^3.1.8
  isar_flutter_libs: ^3.1.8
  path_provider: ^2.1.3

  # Animations
  flutter_animate: ^4.5.0
  lottie: ^3.1.2

  # UI / Fonts
  google_fonts: ^6.2.1
  material_symbols_icons: ^4.2729.1

  # Charts
  fl_chart: ^0.68.0

  # Voice (Premium)
  flutter_tts: ^4.0.2
  speech_to_text: ^6.6.2

  # Payments
  purchases_flutter: ^7.3.0

  # Ads
  google_mobile_ads: ^5.1.0

  # Push Notifications
  flutter_local_notifications: ^17.2.2
  firebase_messaging: ^15.1.3
  firebase_core: ^3.5.0
  firebase_crashlytics: ^4.1.3

  # Auth
  google_sign_in: ^6.2.1

  # Utils
  intl: ^0.19.0
  flutter_dotenv: ^5.1.0
  shared_preferences: ^2.3.2
  url_launcher: ^6.3.0
  image_picker: ^1.1.2
  permission_handler: ^11.3.1
  connectivity_plus: ^6.0.3

  # Analytics
  posthog_flutter: ^4.0.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.12
  riverpod_generator: ^2.4.3
  isar_generator: ^3.1.8
  custom_lint: ^0.6.4
  riverpod_lint: ^2.3.13
  flutter_lints: ^4.0.0
```

---

*ZeroPuff PRD v2.0 — Built for the craving moment.*  
*"One conversation at a time."*
