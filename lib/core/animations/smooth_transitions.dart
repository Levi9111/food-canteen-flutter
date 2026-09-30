import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';

/// Opens a dialog with a silky-smooth easeOutCubic fade and subtle scale transition.
Future<T?> showSmoothMilitaryDialog<T>({
  required BuildContext context,
  required Widget child,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withAlpha(120),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (ctx, anim1, anim2) => child,
    transitionBuilder: (ctx, anim1, anim2, widget) {
      final curved = CurvedAnimation(
        parent: anim1,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1.0).animate(curved),
          child: widget,
        ),
      );
    },
  );
}

/// Smoothly animates numerical changes in metric values with easeOutCubic curve.
class SmoothAnimatedCounter extends StatelessWidget {
  final double value;
  final String prefix;
  final TextStyle style;
  final Duration duration;

  const SmoothAnimatedCounter({
    super.key,
    required this.value,
    this.prefix = '',
    required this.style,
    this.duration = const Duration(milliseconds: 350),
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'en_US');

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animValue, _) {
        return Text(
          '$prefix${formatter.format(animValue)}',
          style: style,
        );
      },
    );
  }
}

/// A metric card with smooth value animation and zero-curve military borders.
class SmoothAnimatedMetricCard extends StatelessWidget {
  final String title;
  final double value;
  final String prefix;
  final Color textColor;
  final bool highlight;
  final bool useExpanded;

  const SmoothAnimatedMetricCard({
    super.key,
    required this.title,
    required this.value,
    this.prefix = '৳ ',
    required this.textColor,
    this.highlight = false,
    this.useExpanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.ledgerSurface,
        border: Border.all(
          color: highlight ? textColor : AppColors.ledgerBorderLight,
          width: highlight ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.textMuted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          SmoothAnimatedCounter(
            value: value,
            prefix: prefix,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );

    return useExpanded ? Expanded(child: card) : card;
  }
}

/// Silky smooth transition between content changes.
class SmoothFadeSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const SmoothFadeSwitcher({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: child,
    );
  }
}
