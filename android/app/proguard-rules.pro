## Flutter wrapper
-keep class io.flutter.**  { *; }

## Android
-keep class androidx.lifecycle.** { *; }
-keep class com.google.android.** { *; }

## Other
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

-keep class androidx.media3.exoplayer.** { *; }
-keep class com.google.zxing.**{*;}