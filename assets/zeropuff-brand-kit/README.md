# ZeroPuff brand kit — "The Snap"

One unlit cigarette, snapped with force; three shards burst from the break. Quitting is effort, and every clean break is a win.

This folder mirrors the repo layout. Copy `assets/`, `android/` and `web/` over the project root; the files land where they belong. `play-store/` and `logo-source/` are not app code (see the end).

---

## Instructions for Claude Code

Implement the new logo, launcher icon, native splash screen and notification icon from this kit. Use the files exactly as provided; do not redraw or rescale them.

### 1. Copy the files

- Copy `assets/branding/**` into the repo (replaces `app_icon.png` and `app_icon_foreground.png`, adds the rest).
- Copy `android/app/src/main/res/drawable-*/ic_stat_zeropuff.png` and `android/app/src/main/res/raw/keep.xml`.
- Copy `web/favicon.png` and `web/icons/*` (overwrite).
- Delete the old splash sources, which are no longer used: `assets/branding/bg.png`, `assets/branding/splash.png`, `assets/branding/splash_mobile.png`.

### 2. Launcher icon (`flutter_launcher_icons`, already a dev dependency)

Replace the `flutter_launcher_icons:` block in `pubspec.yaml` with:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: assets/branding/app_icon.png
  remove_alpha_ios: true
  min_sdk_android: 21
  adaptive_icon_background: "#0F1214"
  adaptive_icon_foreground: assets/branding/app_icon_foreground.png
  adaptive_icon_foreground_inset: 0   # the foreground PNG already contains the safe-zone padding
  adaptive_icon_monochrome: assets/branding/app_icon_monochrome.png   # Android 13+ themed icons
```

Remove the old generated `ic_launcher_background.png` files from `android/app/src/main/res/drawable-*/`; the background is now a colour. Then run:

```bash
dart run flutter_launcher_icons
```

### 3. Native splash (`flutter_native_splash`)

Add `flutter_native_splash: ^2.4.8` to `dev_dependencies`. The config already exists in `pubspec.yaml`, but the package is missing from `dev_dependencies`. Replace the `flutter_native_splash:` block with:

```yaml
flutter_native_splash:
  color: "#EBECE6"            # lightBackground (warm linen)
  color_dark: "#0F1214"       # darkBackground (matte charcoal)
  image: assets/branding/splash_logo.png             # mark + wordmark, 4x density
  image_dark: assets/branding/splash_logo_dark.png
  branding: assets/branding/splash_branding.png      # "One streak at a time"
  branding_dark: assets/branding/splash_branding_dark.png
  branding_bottom_padding: 32
  android_12:
    color: "#EBECE6"
    color_dark: "#0F1214"
    image: assets/branding/splash_android12.png          # 1152 px, mark inside the 768 px circle
    image_dark: assets/branding/splash_android12_dark.png
    branding: assets/branding/splash_branding_android12.png   # 800 x 320 wordmark
    branding_dark: assets/branding/splash_branding_android12_dark.png
```

The old config used `background_image`; it cannot be combined with `color`, so remove it. Regenerate from a clean state:

```bash
flutter pub get
dart run flutter_native_splash:remove
dart run flutter_native_splash:create
```

Confirm that the old `background.png` files under `android/app/src/main/res/drawable*/` are gone, and that `values-v31/styles.xml` and `values-night-v31/styles.xml` now use `#EBECE6` / `#0F1214` rather than `#00C883`.

### 4. Notification icon

Android shows the small notification icon as a white silhouette. The current `@mipmap/ic_launcher` therefore renders as a white square. In `lib/services/notifications/notification_service.dart`:

```dart
const android = AndroidInitializationSettings('ic_stat_zeropuff');
```

Optionally add `color: Color(0xFF2F6B4A)` to each `AndroidNotificationDetails` to tint the icon in brand sage. `res/raw/keep.xml` stops the release build from stripping the icon; it is needed because `isShrinkResources = true`.

### 5. In-app logo (optional, for About / onboarding / share cards)

Register only the logo folder in `pubspec.yaml`. The splash sources are build-time only, so don't bundle them.

```yaml
flutter:
  assets:
    - assets/branding/logo/
```

Flutter picks `2.0x/` and `3.0x/` automatically. Choose the variant from the theme:

```dart
final dark = Theme.of(context).brightness == Brightness.dark;
Image.asset(
  dark ? 'assets/branding/logo/logo_lockup_dark.png' : 'assets/branding/logo/logo_lockup_light.png',
  height: 40, // logical px; the lockup is 40 dp tall at 1x
  semanticLabel: 'ZeroPuff',
);
// Mark only: logo_mark_light.png / logo_mark_dark.png (96 dp wide at 1x)
```

### 6. Web

Set `background_color` and `theme_color` in `web/manifest.json` to `#0F1214`. The icon files are already replaced.

### 7. Verify

```bash
flutter clean && flutter pub get
flutter run --flavor dev
```

Check the following:
- The home-screen icon in both the circle and squircle launcher masks.
- Android 13+ themed icons (wallpaper → themed icons on).
- The splash screen in light and dark mode, on Android 12+ and on an older emulator.
- That a reminder notification shows the snapped-cigarette silhouette.

Both flavors share `src/main/res`, so dev and prod get the same icon.

---

## What's in the kit

| File | Size | Used for |
|---|---|---|
| `assets/branding/app_icon.png` | 1024², opaque | iOS icon + legacy Android icon (`image_path`) |
| `assets/branding/app_icon_foreground.png` | 1024², transparent | Android adaptive icon foreground (safe-zone padded, inset 0) |
| `assets/branding/app_icon_monochrome.png` | 1024², transparent | Android 13+ themed icon |
| `assets/branding/splash_logo(_dark).png` | 4x | Splash centre image (pre-Android 12 + iOS) |
| `assets/branding/splash_branding(_dark).png` | 4x | Splash bottom line, "One streak at a time" |
| `assets/branding/splash_android12(_dark).png` | 1152² | Android 12+ splash icon |
| `assets/branding/splash_branding_android12(_dark).png` | 800×320 | Android 12+ splash branding (wordmark) |
| `assets/branding/logo/…` | 1x / 2x / 3x | In-app mark and horizontal lockup, light and dark |
| `android/…/drawable-*/ic_stat_zeropuff.png` | 24–96 px | Notification small icon (white on transparent) |
| `android/…/raw/keep.xml` | — | Keeps the notification icon under resource shrinking |
| `web/favicon.png`, `web/icons/*` | 32 / 192 / 512 | Web favicon, PWA icons, maskable icons |
| `play-store/app-icon-512.png` | 512², 32-bit PNG | Play Console → Main store listing → App icon |
| `play-store/feature-graphic-1024x500.png` | 1024×500, 24-bit, no alpha | Play Console → Main store listing → Feature graphic |
| `logo-source/*.svg` | vector | Masters: mark (light/dark/mono), wordmark, horizontal + stacked lockups, app icon, feature graphic |

Play Store screenshots are not in the kit. Capture them from the running app: at least 2 phone screenshots, each side 320–3840 px, with the long side no more than twice the short side.

## Brand colours

| Token | Hex | Use |
|---|---|---|
| Charcoal | `#0F1214` | App-icon tile, dark splash, feature graphic |
| Sage deep | `#2F6B4A` | Cigarette paper on light backgrounds |
| Terracotta | `#C28B75` | Filter + shards on light and dark backgrounds |
| Terracotta (icon) | `#D9997C` | Filter + shards on the charcoal icon tile only |
| Paper | `#FAFAF7` | Cigarette paper on the icon tile |
| Linen | `#EBECE6` | Light splash background |
| Mist | `#E6EAE4` | Cigarette paper and wordmark on dark backgrounds |

Wordmark: Geist SemiBold, already converted to outlines in every file. The mark has three cuts: **master** (logo and splash), **icon** (heavier, bigger shards, for the launcher) and **small** (one shard, for notification and favicon).
