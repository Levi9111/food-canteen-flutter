import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Tactical Card with zero round curves, featuring sharp precision edges,
/// military hairline dual-borders, and gold corner bracket accents [┌ ┐ └ ┘].
class TacticalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color backgroundColor;
  final Color borderColor;
  final Color? accentColor;
  final bool showCornerBrackets;
  final double cornerBracketSize;
  final double cornerBracketWidth;
  final VoidCallback? onTap;

  const TacticalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin = EdgeInsets.zero,
    this.backgroundColor = AppColors.ledgerSurface,
    this.borderColor = AppColors.ledgerBorderLight,
    this.accentColor,
    this.showCornerBrackets = true,
    this.cornerBracketSize = 8.0,
    this.cornerBracketWidth = 1.5,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            offset: const Offset(1, 2),
            blurRadius: 0, // Sharp crisp shadow
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top accent line if provided
          if (accentColor != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 2.5,
              child: Container(color: accentColor),
            ),

          // Corner brackets painter
          if (showCornerBrackets)
            Positioned.fill(
              child: CustomPaint(
                painter: _CornerBracketPainter(
                  bracketColor: accentColor ?? AppColors.bafGold,
                  length: cornerBracketSize,
                  strokeWidth: cornerBracketWidth,
                ),
              ),
            ),

          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        splashColor: AppColors.bafGold.withAlpha(30),
        highlightColor: AppColors.bafDeepBlue.withAlpha(20),
        child: cardContent,
      );
    }

    return cardContent;
  }
}

/// Custom painter for sharp military HUD/tactical corner brackets
class _CornerBracketPainter extends CustomPainter {
  final Color bracketColor;
  final double length;
  final double strokeWidth;

  const _CornerBracketPainter({
    required this.bracketColor,
    required this.length,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = bracketColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Top-Left [┌]
    final tl = Path()
      ..moveTo(0, length)
      ..lineTo(0, 0)
      ..lineTo(length, 0);
    canvas.drawPath(tl, paint);

    // Top-Right [┐]
    final tr = Path()
      ..moveTo(size.width - length, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, length);
    canvas.drawPath(tr, paint);

    // Bottom-Left [└]
    final bl = Path()
      ..moveTo(0, size.height - length)
      ..lineTo(0, size.height)
      ..lineTo(length, size.height);
    canvas.drawPath(bl, paint);

    // Bottom-Right [┘]
    final br = Path()
      ..moveTo(size.width - length, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height - length);
    canvas.drawPath(br, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) {
    return oldDelegate.bracketColor != bracketColor ||
        oldDelegate.length != length ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

/// Tactical Sharp Badge / Chip
class TacticalBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const TacticalBadge({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.bafDeepBlue,
    this.textColor = Colors.white,
    this.borderColor,
    this.fontSize = 9.5,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          color: borderColor ?? backgroundColor,
          width: 1.0,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

/// Tactical Metric Box for Dashboard Summaries
class TacticalMetricBox extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;
  final Color? accentColor;
  final IconData? icon;

  const TacticalMetricBox({
    super.key,
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
    this.accentColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TacticalCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      accentColor: accentColor ?? AppColors.bafGold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 12, color: accentColor ?? AppColors.bafGold),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: valueColor ?? AppColors.bafNavy,
              letterSpacing: -0.2,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.textMuted,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
