# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Biometric
-keep class androidx.biometric.** { *; }

# Google Play Core
-dontwarn com.google.android.play.core.**

# Supabase / networking / JSON
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class com.google.gson.** { *; }

# flutter_secure_storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }