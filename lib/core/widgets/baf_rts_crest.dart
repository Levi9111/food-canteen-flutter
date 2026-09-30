import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BafRtsCrest extends StatelessWidget {
  final double size;
  final bool showLabel;

  const BafRtsCrest({
    super.key,
    this.size = 48.0,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/baf_logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return _buildStructuredInsignia();
      },
    );
  }

  Widget _buildStructuredInsignia() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.bafNavy,
        border: Border.all(color: AppColors.bafGold, width: 1.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Gold Diamond/Shield contour
          CustomPaint(
            size: Size(size, size),
            painter: _BafInsigniaPainter(),
          ),
          // BAF Roundel (Green circle with central Red disc)
          Container(
            width: size * 0.42,
            height: size * 0.42,
            decoration: const BoxDecoration(
              color: AppColors.bafRoundelGreen,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Container(
              width: size * 0.22,
              height: size * 0.22,
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
                  fontSize: (size * 0.16).clamp(8, 12),
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
