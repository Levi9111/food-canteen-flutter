import 'package:flutter/material.dart';

/// Centralized layout spacing tokens for BAF RTS Food Canteen app.
class AppSpacing {
  // Base spacing units
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;

  // Insets for bottom navigation bar clearance across scrollable views
  static const double bottomNavHeight = 64.0;
  static const double bottomInset = 84.0;
  static const EdgeInsets scrollPaddingWithBottomNav = EdgeInsets.only(bottom: bottomInset);

  // Standard dialog / sheet max width
  static const double maxDialogWidth = 420.0;
}
