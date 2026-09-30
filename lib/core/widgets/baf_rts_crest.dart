import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BafRtsCrest extends StatefulWidget {
  final double size;
  final bool showLabel;

  const BafRtsCrest({
    super.key,
    this.size = 48.0,
    this.showLabel = false,
  });

  @override
  State<BafRtsCrest> createState() => _BafRtsCrestState();
}

class _BafRtsCrestState extends State<BafRtsCrest> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Image.asset(
          'assets/images/baf_logo.png',
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return _buildStructuredInsignia();
          },
        ),
      ),
    );
  }

  Widget _buildStructuredInsignia() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: AppColors.bafNavy,
        border: Border.all(
          color: _isHovered ? AppColors.bafGoldMuted : AppColors.bafGold,
          width: _isHovered ? 2.0 : 1.5,
        ),
        boxShadow: _isHovered
            ? [
                BoxShadow(
                  color: AppColors.bafGold.withAlpha(80),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Gold Diamond/Shield contour
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _BafInsigniaPainter(),
          ),
          // BAF Roundel (Green circle with central Red disc)
          Container(
            width: widget.size * 0.42,
            height: widget.size * 0.42,
            decoration: const BoxDecoration(
              color: AppColors.bafRoundelGreen,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: widget.size * 0.22,
              height: widget.size * 0.22,
              decoration: const BoxDecoration(
                color: AppColors.bafRoundelRed,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // BAF RTS Monogram
          Positioned(
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              color: AppColors.bafNavy,
              child: Text(
                'RTS BAF',
                style: TextStyle(
                  color: AppColors.bafGold,
                  fontSize: (widget.size * 0.16).clamp(8, 12),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BafInsigniaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.bafGold.withAlpha(200)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Eagle Wings Outlines
    final leftWing = Path()
      ..moveTo(size.width * 0.5, size.height * 0.35)
      ..lineTo(size.width * 0.12, size.height * 0.22)
      ..lineTo(size.width * 0.15, size.height * 0.42)
      ..lineTo(size.width * 0.5, size.height * 0.5);

    final rightWing = Path()
      ..moveTo(size.width * 0.5, size.height * 0.35)
      ..lineTo(size.width * 0.88, size.height * 0.22)
      ..lineTo(size.width * 0.85, size.height * 0.42)
      ..lineTo(size.width * 0.5, size.height * 0.5);

    canvas.drawPath(leftWing, paint);
    canvas.drawPath(rightWing, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
