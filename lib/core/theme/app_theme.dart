import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'canteen_theme_extension.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.bafDeepBlue,
      scaffoldBackgroundColor: AppColors.ledgerBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.bafDeepBlue,
        secondary: AppColors.bafGold,
        surface: AppColors.ledgerSurface,
        error: AppColors.debitRed,
        onPrimary: AppColors.textOnDark,
        onSecondary: AppColors.bafNavy,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bafNavy,
        foregroundColor: AppColors.textOnDark,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      // Sharp rectangular cards without rounded edges
      cardTheme: CardThemeData(
        color: AppColors.ledgerSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: const BorderSide(color: AppColors.ledgerBorderLight, width: 1),
        ),
      ),
      // Sharp, precise input fields for accounting entry
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.ledgerSurface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: AppColors.ledgerBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: AppColors.ledgerBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: AppColors.bafDeepBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: AppColors.debitRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: const BorderSide(color: AppColors.debitRed, width: 2),
        ),
        labelStyle: AppTextStyles.bodyMedium(AppColors.textSecondary),
        hintStyle: AppTextStyles.bodyMedium(AppColors.textMuted),
      ),
      // Sharp, crisp enterprise buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bafDeepBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: AppTextStyles.titleMedium(Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.bafDeepBlue,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: const BorderSide(color: AppColors.bafDeepBlue, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          textStyle: AppTextStyles.titleMedium(AppColors.bafDeepBlue),
        ),
      ),
      // Sharp tabular data styling
      dividerTheme: const DividerThemeData(
        color: AppColors.ledgerBorderLight,
        thickness: 1,
        space: 1,
      ),
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(AppColors.bafNavy),
        headingTextStyle: AppTextStyles.labelSmall(Colors.white),
        dataRowColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.bafLightBlue;
          }
          return null;
        }),
        dataTextStyle: AppTextStyles.bodyMedium(AppColors.textPrimary),
        horizontalMargin: 12,
        columnSpacing: 16,
      ),
      extensions: const [
        CanteenThemeColors.light,
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.bafGold,
      scaffoldBackgroundColor: const Color(0xFF0A1322),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.bafGold,
        secondary: AppColors.bafGold,
        surface: Color(0xFF132238),
        error: Color(0xFFEF4444),
        onPrimary: AppColors.bafNavy,
        onSecondary: AppColors.bafNavy,
        onSurface: Color(0xFFF8FAFC),
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF060D17),
        foregroundColor: AppColors.bafGold,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF182A45),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Color(0xFF2D4668), width: 1),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF132238),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Color(0xFF2D4668), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: Color(0xFF2D4668), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppColors.bafGold, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.bafGold,
          foregroundColor: AppColors.bafNavy,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.bafGold,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          side: const BorderSide(color: AppColors.bafGold, width: 1.5),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        ),
      ),
      extensions: const [
        CanteenThemeColors.dark,
      ],
    );
  }
}
