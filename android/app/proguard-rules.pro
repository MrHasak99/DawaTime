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

# Keep all enums (fixes NoSuchMethodException: ...values [])
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}