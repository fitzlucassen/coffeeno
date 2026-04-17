import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  static const _cardRadius = 16.0;
  static const _buttonRadius = 12.0;
  static const _inputRadius = 12.0;

  // ── Light Theme ──
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: const ColorScheme.light(
          primary: AppColors.terracotta,
          onPrimary: Colors.white,
          primaryContainer: AppColors.terracottaMuted,
          onPrimaryContainer: AppColors.espresso,
          secondary: AppColors.sage,
          onSecondary: Colors.white,
          secondaryContainer: AppColors.sageLight,
          onSecondaryContainer: AppColors.espresso,
          surface: AppColors.warmWhite,
          onSurface: AppColors.espresso,
          onSurfaceVariant: AppColors.espressoLight,
          error: AppColors.error,
          onError: Colors.white,
          outline: AppColors.espressoMuted,
          outlineVariant: Color(0xFFE8DDD0),
        ),
        textTheme: AppTypography.textTheme(color: AppColors.espresso),
        fontFamily: 'PlusJakartaSans',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.cream,
          foregroundColor: AppColors.espresso,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          titleTextStyle: AppTypography.titleLarge,
        ),
        cardTheme: CardThemeData(
          color: AppColors.warmWhite,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cardRadius),
            side: const BorderSide(color: Color(0xFFE8DDD0), width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.terracotta,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonRadius),
            ),
            textStyle: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.espresso,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonRadius),
            ),
            side: const BorderSide(color: AppColors.espressoMuted),
            textStyle: AppTypography.labelLarge,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.terracotta,
            textStyle: AppTypography.labelLarge,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.warmWhite,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_inputRadius),
            borderSide: const BorderSide(color: Color(0xFFE8DDD0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_inputRadius),
            borderSide: const BorderSide(color: Color(0xFFE8DDD0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_inputRadius),
            borderSide:
                const BorderSide(color: AppColors.terracotta, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_inputRadius),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle: AppTypography.bodyMedium
              .copyWith(color: AppColors.espressoMuted),
          labelStyle: AppTypography.labelMedium
              .copyWith(color: AppColors.espressoLight),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.warmWhite,
          selectedItemColor: AppColors.terracotta,
          unselectedItemColor: AppColors.espressoMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: AppTypography.labelSmall,
          unselectedLabelStyle: AppTypography.labelSmall,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.terracotta,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: CircleBorder(),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.sageLight,
          labelStyle: AppTypography.labelMedium
              .copyWith(color: AppColors.espresso),
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFE8DDD0),
          thickness: 1,
          space: 1,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.warmWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
      );

  // ── Dark Theme ──
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.terracottaLight,
          onPrimary: AppColors.darkBg,
          primaryContainer: AppColors.terracotta,
          onPrimaryContainer: AppColors.darkTextPrimary,
          secondary: AppColors.sageMuted,
          onSecondary: AppColors.darkBg,
          secondaryContainer: AppColors.sage,
          onSecondaryContainer: AppColors.darkTextPrimary,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
          onSurfaceVariant: AppColors.darkTextSecondary,
          error: AppColors.error,
          onError: Colors.white,
          outline: AppColors.darkBorder,
          outlineVariant: AppColors.darkBorder,
        ),
        textTheme:
            AppTypography.textTheme(color: AppColors.darkTextPrimary),
        fontFamily: 'PlusJakartaSans',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBg,
          foregroundColor: AppColors.darkTextPrimary,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          centerTitle: false,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          titleTextStyle: AppTypography.titleLarge,
        ),
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cardRadius),
            side: const BorderSide(color: AppColors.darkBorder, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.terracottaLight,
            foregroundColor: AppColors.darkBg,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonRadius),
            ),
            textStyle: AppTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.darkTextPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonRadius),
            ),
            side: const BorderSide(color: AppColors.darkBorder),
            textStyle: AppTypography.labelLarge,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.terracottaLight,
            textStyle: AppTypography.labelLarge,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_inputRadius),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_inputRadius),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_inputRadius),
            borderSide: const BorderSide(
                color: AppColors.terracottaLight, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_inputRadius),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          hintStyle: AppTypography.bodyMedium
              .copyWith(color: AppColors.darkTextSecondary),
          labelStyle: AppTypography.labelMedium
              .copyWith(color: AppColors.darkTextSecondary),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.terracottaLight,
          unselectedItemColor: AppColors.darkTextSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: AppTypography.labelSmall,
          unselectedLabelStyle: AppTypography.labelSmall,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.terracottaLight,
          foregroundColor: AppColors.darkBg,
          elevation: 4,
          shape: CircleBorder(),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.darkCard,
          labelStyle: AppTypography.labelMedium
              .copyWith(color: AppColors.darkTextPrimary),
          side: const BorderSide(color: AppColors.darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.darkBorder,
          thickness: 1,
          space: 1,
        ),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.darkSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
        ),
      );
}
