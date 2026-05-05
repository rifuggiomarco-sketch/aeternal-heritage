# v2.4 — Hardening anti reverse-engineering.
# Mantiene API pubbliche di Flutter/Firebase/crypto e offusca il resto.

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Encrypt / PointyCastle / BouncyCastle
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**
-keep class org.pointycastle.** { *; }
-dontwarn org.pointycastle.**

# Cryptography (cryptography.dart usa platform channels)
-keep class com.google.crypto.tink.** { *; }
-dontwarn com.google.crypto.tink.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# App entrypoints (MainActivity con MethodChannel anti-screenshot)
-keep class com.aeterna.protocol.MainActivity { *; }

# Rimuovi log in release (rinforza la regola di non-leak)
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
