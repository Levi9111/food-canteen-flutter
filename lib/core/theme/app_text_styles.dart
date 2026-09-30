import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle displayLarge(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: -0.5,
      );

  static TextStyle displayMedium(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: -0.3,
      );

  static TextStyle titleLarge(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle titleMedium(Color color) => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle bodyLarge(Color color) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.5,
      );

  static TextStyle bodyMedium(Color color) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: color,
        height: 1.4,
      );

  static TextStyle labelSmall(Color color) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );
}
