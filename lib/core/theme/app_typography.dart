import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const _fontFamily = 'PlusJakartaSans';

  // ── Headings ──
  static const headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.3,
  );

  static const headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  // ── Titles ──
  static const titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ── Body ──
  static const bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── Labels ──
  static const labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  static TextTheme textTheme({required Color color}) => TextTheme(
        headlineLarge: headlineLarge.copyWith(color: color),
        headlineMedium: headlineMedium.copyWith(color: color),
        headlineSmall: headlineSmall.copyWith(color: color),
        titleLarge: titleLarge.copyWith(color: color),
        titleMedium: titleMedium.copyWith(color: color),
        titleSmall: titleSmall.copyWith(color: color),
        bodyLarge: bodyLarge.copyWith(color: color),
        bodyMedium: bodyMedium.copyWith(color: color),
        bodySmall: bodySmall.copyWith(color: color.withValues(alpha: 0.7)),
        labelLarge: labelLarge.copyWith(color: color),
        labelMedium: labelMedium.copyWith(color: color.withValues(alpha: 0.7)),
        labelSmall: labelSmall.copyWith(color: color.withValues(alpha: 0.5)),
      );
}
