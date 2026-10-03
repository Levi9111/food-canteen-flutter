import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/baf_rts_crest.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.65, curve: Curves.easeIn)),
    );

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        widget.onComplete();
      }
    });

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bafNavy,
      body: Stack(
        children: [
          // Background military radial glow
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.bafDeepBlue.withAlpha(160),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Animated Branding
          Center(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Crest with gold glow border
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.bafNavy,
                            border: Border.all(color: AppColors.bafGold, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.bafGold.withAlpha(50),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const BafRtsCrest(size: 88),
                        ),
                        const SizedBox(height: 24),

                        // Bangladesh Air Force
                        const Text(
                          'BANGLADESH AIR FORCE',
                          style: TextStyle(
                            color: AppColors.bafGold,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Food Canteen RTS
                        const Text(
                          'FOOD CANTEEN RTS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Subtitle
                        Text(
                          'Recruits Training School • Shamshernagar',
                          style: TextStyle(
                            color: Colors.white.withAlpha(190),
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Sleek Loading Indicator
                        SizedBox(
                          width: 140,
                          child: LinearProgressIndicator(
                            value: _animController.value,
                            color: AppColors.bafGold,
                            backgroundColor: AppColors.bafDeepBlue,
                            minHeight: 2.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom System Tag
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'TACTICAL CANTEEN MANAGEMENT SYSTEM',
                style: TextStyle(
                  color: Colors.white.withAlpha(120),
                  fontSize: 9,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
