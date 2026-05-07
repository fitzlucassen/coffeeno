# Google ML Kit — Text Recognition
#
# The google_mlkit_text_recognition plugin references optional language
# packs (Chinese, Devanagari, Japanese, Korean) that we don't bundle.
# R8 fails the release build trying to resolve them — tell R8 to ignore
# the missing symbols so the Latin-script recognizer still links.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
-keep class com.google.mlkit.vision.text.** { *; }

# Firebase / Play services occasionally reference missing classes during
# R8's walk. Suppress those non-fatal warnings.
-dontwarn com.google.android.play.core.**
