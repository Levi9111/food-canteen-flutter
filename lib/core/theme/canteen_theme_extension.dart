import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class CanteenThemeColors extends ThemeExtension<CanteenThemeColors> {
  final Color background;
  final Color surface;
  final Color cardBackground;
  final Color cardBorder;
  final Color cardBorderLight;
  final Color headerBackground;
  final Color headerSub;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textOnHeader;
  final Color stripe;
  final Color tableHighlight;
  final Color accentGold;
  final Color accentNavy;
  final Color debit;
  final Color credit;
  final Color alert;

  const CanteenThemeColors({
    required this.background,
    required this.surface,
    required this.cardBackground,
    required this.cardBorder,
    required this.cardBorderLight,
    required this.headerBackground,
    required this.headerSub,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textOnHeader,
    required this.stripe,
    required this.tableHighlight,
    required this.accentGold,
    required this.accentNavy,
    required this.debit,
    required this.credit,
    required this.alert,
  });

  static const light = CanteenThemeColors(
    background: Color(0xFFF1F5F9), // Slate 100
    surface: Color(0xFFFFFFFF),
    cardBackground: Color(0xFFFFFFFF),
    cardBorder: Color(0xFF94A3B8), // Slate 400
    cardBorderLight: Color(0xFFCBD5E1), // Slate 300
    headerBackground: AppColors.bafNavy, // 0xFF0A192F
    headerSub: AppColors.bafDeepBlue, // 0xFF0E3A6C
    textPrimary: Color(0xFF0F172A), // Slate 900
    textSecondary: Color(0xFF475569), // Slate 600
    textMuted: Color(0xFF64748B), // Slate 500
    textOnHeader: Colors.white,
    stripe: Color(0xFFF8FAFC), // Slate 50
    tableHighlight: Color(0xFFE8F1FA), // Light BAF blue tint
    accentGold: AppColors.bafGold, // 0xFFC5A059
    accentNavy: AppColors.bafNavy,
    debit: AppColors.debitRed,
    credit: AppColors.creditGreen,
    alert: AppColors.balanceAlert,
  );

  static const dark = CanteenThemeColors(
    background: Color(0xFF0A1322), // Deep tactical dark navy
    surface: Color(0xFF132238), // Elevated dark navy surface
    cardBackground: Color(0xFF182A45), // Card dark container
    cardBorder: Color(0xFF2D4668), // Distinct contrast border
    cardBorderLight: Color(0xFF1E3554),
    headerBackground: Color(0xFF060D17), // Deepest command navy
    headerSub: Color(0xFF0E223D),
    textPrimary: Color(0xFFF8FAFC), // Crisp white/slate 50
    textSecondary: Color(0xFF94A3B8), // Slate 400
    textMuted: Color(0xFF64748B),
    textOnHeader: Colors.white,
    stripe: Color(0xFF0F1B2E), // Subtle dark stripe
    tableHighlight: Color(0xFF1A355B), // Subtle blue-tinted highlight
    accentGold: AppColors.bafGold, // Consistent gold branding
    accentNavy: AppColors.bafNavy,
    debit: Color(0xFFEF4444), // High-visibility red on dark
    credit: Color(0xFF22C55E), // High-visibility green on dark
    alert: Color(0xFFF59E0B), // High-visibility amber on dark
  );

  @override
  CanteenThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? cardBackground,
    Color? cardBorder,
    Color? cardBorderLight,
    Color? headerBackground,
    Color? headerSub,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? textOnHeader,
    Color? stripe,
    Color? tableHighlight,
    Color? accentGold,
    Color? accentNavy,
    Color? debit,
    Color? credit,
    Color? alert,
  }) {
    return CanteenThemeColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      cardBackground: cardBackground ?? this.cardBackground,
      cardBorder: cardBorder ?? this.cardBorder,
      cardBorderLight: cardBorderLight ?? this.cardBorderLight,
      headerBackground: headerBackground ?? this.headerBackground,
      headerSub: headerSub ?? this.headerSub,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      textOnHeader: textOnHeader ?? this.textOnHeader,
      stripe: stripe ?? this.stripe,
      tableHighlight: tableHighlight ?? this.tableHighlight,
      accentGold: accentGold ?? this.accentGold,
      accentNavy: accentNavy ?? this.accentNavy,
      debit: debit ?? this.debit,
      credit: credit ?? this.credit,
      alert: alert ?? this.alert,
    );
  }

  @override
  CanteenThemeColors lerp(ThemeExtension<CanteenThemeColors>? other, double t) {
    if (other is! CanteenThemeColors) return this;
    return CanteenThemeColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardBorderLight: Color.lerp(cardBorderLight, other.cardBorderLight, t)!,
      headerBackground: Color.lerp(headerBackground, other.headerBackground, t)!,
      headerSub: Color.lerp(headerSub, other.headerSub, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textOnHeader: Color.lerp(textOnHeader, other.textOnHeader, t)!,
      stripe: Color.lerp(stripe, other.stripe, t)!,
      tableHighlight: Color.lerp(tableHighlight, other.tableHighlight, t)!,
      accentGold: Color.lerp(accentGold, other.accentGold, t)!,
      accentNavy: Color.lerp(accentNavy, other.accentNavy, t)!,
      debit: Color.lerp(debit, other.debit, t)!,
      credit: Color.lerp(credit, other.credit, t)!,
      alert: Color.lerp(alert, other.alert, t)!,
    );
  }
}

extension CanteenThemeContext on BuildContext {
  CanteenThemeColors get canteenTheme {
    return Theme.of(this).extension<CanteenThemeColors>() ??
        (Theme.of(this).brightness == Brightness.dark
            ? CanteenThemeColors.dark
            : CanteenThemeColors.light);
  }

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
