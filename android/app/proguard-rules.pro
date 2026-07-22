# ── Flutter ────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# ── Firebase / Google Play Services ────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firestore, modelleri yansıma (reflection) ile serileştirir
-keepclassmembers class * {
    @com.google.firebase.firestore.PropertyName <fields>;
}

# ── Kotlin ─────────────────────────────────────────────────
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**

# ── Crash raporlarında satır numaralarını koru ─────────────
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
