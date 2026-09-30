# ── Flutter & Dart ──────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ── Kotlinx Serialization ──────────────────────────────────────
-keepattributes *Annotation*, InnerClasses, EnclosingMethod
-keepclassmembers class kotlinx.serialization.json.** { *** Companion; }
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# ── Google Sign-In ─────────────────────────────────────────────
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.**
-keep class com.google.android.gms.internal.** { *; }

# ── Google API Client ──────────────────────────────────────────
-keep class com.google.api.client.** { *; }
-dontwarn com.google.api.client.**

# ── Isar Database ──────────────────────────────────────────────
-keep class isar.** { *; }
-keep class io.isar.** { *; }
-dontwarn io.isar.**
-keep class * extends io.isar.core.Plugin { *; }
-keepclassmembers class * {
    @io.isar.annotation.* <fields>;
    @io.isar.annotation.* <methods>;
}

# ── SharedPreferences ─────────────────────────────────────────
-keep class androidx.preference.** { *; }

# ── Path Provider ──────────────────────────────────────────────
-dontwarn androidx.core.content.FileProvider

# ── General: keep enums & serializable ─────────────────────────
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}
-keepclassmembers class * extends java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ── Google Play Core (referenced by Flutter engine but not bundled) ──
# These classes are provided at runtime on Play Store devices; R8 must
# not fail when they are missing at compile time.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# ── Core library desugaring ────────────────────────────────────
# Keeps the desugared java.time etc. classes so the L8 step
# (l8DexDesugarLibRelease) always has input after R8 shrinking.
-keep class j$.** { *; }
-dontwarn j$.**
