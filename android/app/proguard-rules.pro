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

# Keep DawaTime app classes
-keep class com.mrhasak99.dawatime.** { *; }

# Keep WorkManager classes
-keep class androidx.work.** { *; }
-dontwarn androidx.work.**

# Keep permission handler classes
-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# Keep Geolocator classes
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# Keep all native methods and JNI
-keepclasseswithmembernames class * {
    native <methods>;
}

# Critical: Keep Flutter engine and initialization classes
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-keep class io.flutter.embedding.android.** { *; }
-keep class io.flutter.plugin.** { *; }
-dontwarn io.flutter.**

# Keep main application class and methods
-keep class **.MainActivity { *; }
-keep class **.MainApp { *; }
-keep class **.** { 
    public static void main(java.lang.String[]); 
}

# Keep system services that might be accessed via reflection
-keep class android.app.** { *; }
-keep class android.content.** { *; }
-keep class android.os.** { *; }

# Keep all classes that extend Application
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver

# Keep serialization classes
-keepnames class * implements java.io.Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    !static !transient <fields>;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Samsung-specific fixes
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.lifecycle.** { *; }
-dontwarn androidx.lifecycle.**

# Flutter local notifications (critical for Samsung devices)
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# HTTP and networking (Firebase dependencies)
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Package info plus
-keep class io.flutter.plugins.packageinfo.** { *; }
-dontwarn io.flutter.plugins.packageinfo.**

# URL launcher
-keep class io.flutter.plugins.urllauncher.** { *; }
-dontwarn io.flutter.plugins.urllauncher.**

# Shared preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }
-dontwarn io.flutter.plugins.sharedpreferences.**

# Keep all plugin registrants
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class * extends io.flutter.plugin.common.PluginRegistry$Registrar { *; }

# Samsung One UI compatibility
-keep class com.samsung.** { *; }
-dontwarn com.samsung.**

# Additional Flutter engine classes  
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Critical Firebase initialization classes
-keep class com.google.firebase.FirebaseApp { *; }
-keep class com.google.firebase.FirebaseOptions { *; }
-keep class com.google.firebase.FirebaseOptions$Builder { *; }
-keep class com.google.firebase.provider.FirebaseInitProvider { *; }
-keep class com.google.firebase.components.** { *; }

# Flutter Firebase plugin specific classes
-keep class io.flutter.plugins.firebase.** { *; }
-keep class io.flutter.plugins.firebaseauth.** { *; }
-keep class io.flutter.plugins.cloud_firestore.** { *; }

# WorkManager critical classes
-keep class androidx.work.impl.** { *; }
-keep class androidx.work.WorkManager { *; }
-keep class androidx.work.Configuration** { *; }

# Keep all reflection-based Flutter plugin registrations
-keep class **.GeneratedPluginRegistrant { *; }
-keep class * implements io.flutter.plugin.common.PluginRegistry$Registrar { *; }

# System Chrome and Flutter services
-keep class android.view.WindowManager** { *; }
-keep class android.app.Activity** { *; }

# Keep notification icon drawables (prevent R8 from removing them)
-keep class **.R$drawable { *; }
-keepclassmembers class **.R { public static <fields>; }
-keepclassmembers class **.R$* { public static <fields>; }
-keep class com.mrhasak99.dawatime.R$drawable { *; }