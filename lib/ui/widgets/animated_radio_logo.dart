import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AnimatedRadioLogo extends StatefulWidget {
  final double size;

  const AnimatedRadioLogo({super.key, this.size = 180});

  @override
  State<AnimatedRadioLogo> createState() => _AnimatedRadioLogoState();
}

class _AnimatedRadioLogoState extends State<AnimatedRadioLogo>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _waveAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOutQuad,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return SizedBox(
      width: s * 1.5,
      height: s * 1.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Expanding Radio Frequency Wave Rings (Animated Pulsing)
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, _) {
              return Stack(
                alignment: Alignment.center,
                children: List.generate(3, (i) {
                  final progress = (_waveAnimation.value + (i / 3.0)) % 1.0;
                  final currentRadius = (s * 0.6) + (progress * s * 0.65);
                  final opacity = (1.0 - progress).clamp(0.0, 0.7);

                  return Container(
                    width: currentRadius,
                    height: currentRadius,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: (i % 2 == 0 ? AppTheme.primaryCyan : AppTheme.secondaryPurple)
                            .withValues(alpha: opacity * 0.4),
                        width: 1.5,
                      ),
                    ),
                  );
                }),
              );
            },
          ),

          // Rotating Ambient Gradient Aura
          AnimatedBuilder(
            animation: _rotationController,
            builder: (context, _) {
              return Transform.rotate(
                angle: _rotationController.value * 2 * math.pi,
                child: Container(
                  width: s * 1.1,
                  height: s * 1.1,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        AppTheme.primaryCyan.withValues(alpha: 0.25),
                        AppTheme.secondaryPurple.withValues(alpha: 0.35),
                        AppTheme.accentPink.withValues(alpha: 0.2),
                        AppTheme.primaryCyan.withValues(alpha: 0.25),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Center Logo Squircle with Shadow & Image
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final scale = 1.0 + (math.sin(_pulseAnimation.value * math.pi) * 0.04);
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: s,
              height: s,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(s * 0.24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryCyan.withValues(alpha: 0.35),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                  BoxShadow(
                    color: AppTheme.secondaryPurple.withValues(alpha: 0.25),
                    blurRadius: 36,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(s * 0.24),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.radio_rounded,
                          size: 72,
                          color: AppTheme.primaryCyan,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
