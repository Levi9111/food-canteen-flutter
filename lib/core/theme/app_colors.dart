import 'package:flutter/material.dart';

class AppColors {
  // Official BAF & Military Color Palette
  static const Color bafNavy = Color(0xFF0A192F);       // Deep Air Force Navy
  static const Color bafDeepBlue = Color(0xFF0E3A6C);   // Classic BAF Ensign Blue
  static const Color bafSkyBlue = Color(0xFF3B82C4);    // Air Wing Sky Blue
  static const Color bafLightBlue = Color(0xFFE8F1FA);  // Pale Blue Tint for Tables
  static const Color bafGold = Color(0xFFC5A059);       // Brass / Rank Gold
  static const Color bafGoldMuted = Color(0xFFD4AF37);

  // National / BAF Roundel Accents
  static const Color bafRoundelGreen = Color(0xFF006A4E); // Bangladesh Green
  static const Color bafRoundelRed = Color(0xFFF42A41);   // Bangladesh Red

  // Enterprise Ledger & Neutral Colors (High Contrast, Crisp)
  static const Color ledgerSurface = Color(0xFFFFFFFF);
  static const Color ledgerBackground = Color(0xFFF1F5F9); // Crisp Slate 100
  static const Color ledgerHeader = Color(0xFF0F2744);     // Deep Navy Header
  static const Color ledgerBorder = Color(0xFF94A3B8);     // Sharp Slate 400 Grid
  static const Color ledgerBorderLight = Color(0xFFCBD5E1);// Sharp Slate 300 Grid
  static const Color ledgerStripe = Color(0xFFF8FAFC);     // Alternate row zebra

  // Typography Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Accounting Status Colors
  static const Color debitRed = Color(0xFFDC2626);      // Expenses / Charges
  static const Color creditGreen = Color(0xFF15803D);   // Deposits / Payments
  static const Color balanceAlert = Color(0xFFB45309);  // Dues / Arrears Warning
  static const Color cleared = Color(0xFF047857);       // Nil Balance / Settled
}
