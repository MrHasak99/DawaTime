# Keep rules for androidx.window and related classes
-keep class androidx.window.** { *; }
-dontwarn androidx.window.**

# Keep all Firebase and Google Play classes
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.protobuf.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.protobuf.**
-dontwarn io.flutter.plugins.**

# Preserve generic type signatures for Gson, Firebase, and plugins using TypeToken
-keepattributes Signature
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Keep all enums (fixes NoSuchMethodException: ...values [])
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}