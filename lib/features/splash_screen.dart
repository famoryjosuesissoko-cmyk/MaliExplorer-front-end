import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Apparition Carte
  late Animation<double> _mapOpacityAnimation;
  late Animation<double> _mapScaleAnimation;

  // Trajet & Animation Loupe
  late Animation<Offset> _loupePositionAnimation;
  late Animation<double> _loupeRotationAnimation;
  late Animation<double> _loupeScaleAnimation;
  late Animation<double> _loupeOpacityAnimation;

  // Apparition Texte "MaliExplorer"
  late Animation<double> _textOpacityAnimation;
  late Animation<Offset> _textSlideAnimation;

  // Fondu final
  late Animation<double> _fadeTransitionAnimation;

  @override
  void initState() {
    super.initState();

    // Chronologie ajustée sur 5 secondes (5000 ms)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _setupAnimationTimeline();

    _controller.forward().then((_) {
      if (mounted) {
        context.go(AppRouter.home);
      }
    });
  }

  void _setupAnimationTimeline() {
    // -------------------------------------------------------------------------
    // 1. Apparition initiale de la carte et de la loupe (0.0s -> 0.8s)
    // -------------------------------------------------------------------------
    _mapOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.14, curve: Curves.easeOut),
      ),
    );

    _mapScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.16, curve: Curves.easeOutBack),
      ),
    );

    _loupeOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.02, 0.12, curve: Curves.easeIn),
      ),
    );

    // -------------------------------------------------------------------------
    // 2. Trajet de la loupe (Positions relatives au centre)
    // -------------------------------------------------------------------------
    const Offset posEst = Offset(46.0, 10.0);
    const Offset posNord = Offset(6.0, -48.0);
    const Offset posOuest = Offset(-56.0, 18.0);
    const Offset posCentre = Offset(0.0, 0.0);

    _loupePositionAnimation = TweenSequence<Offset>([
      // Splash 1 : Pause sur l'Est
      TweenSequenceItem(tween: ConstantTween<Offset>(posEst), weight: 22),
      // Mouvement vers le Nord (Splash 2)
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: posEst,
          end: posNord,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 15,
      ),
      // Pause sur le Nord
      TweenSequenceItem(tween: ConstantTween<Offset>(posNord), weight: 12),
      // Mouvement vers l'Ouest (Splash 3)
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: posNord,
          end: posOuest,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 15,
      ),
      // Pause sur l'Ouest (avec apparition du texte)
      TweenSequenceItem(tween: ConstantTween<Offset>(posOuest), weight: 16),
      // Mouvement vers le centre pour le Zoom (Splash 4)
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: posOuest,
          end: posCentre,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 10,
      ),
      // Maintien au centre
      TweenSequenceItem(tween: ConstantTween<Offset>(posCentre), weight: 10),
    ]).animate(_controller);

    // Rotation dynamique du manche de la loupe
    _loupeRotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 22),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: -0.22,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(-0.22), weight: 12),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.22,
          end: 0.18,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0.18), weight: 16),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.18,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_controller);

    // -------------------------------------------------------------------------
    // 3. Apparition du texte "MaliExplorer" (Splash 3)
    // -------------------------------------------------------------------------
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.56, 0.72, curve: Curves.easeIn),
      ),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0.20, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.56, 0.72, curve: Curves.easeOutCubic),
          ),
        );

    // -------------------------------------------------------------------------
    // 4. Zoom immersif de la loupe (Splash 4)
    // -------------------------------------------------------------------------
    _loupeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 78),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 26.0,
        ).chain(CurveTween(curve: Curves.easeInCubic)),
        weight: 14,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(26.0), weight: 8),
    ]).animate(_controller);

    // -------------------------------------------------------------------------
    // 5. Fondu blanc final (Splash 5)
    // -------------------------------------------------------------------------
    _fadeTransitionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.88, 1.00, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double progress = _controller.value;
          final bool isZooming = progress > 0.78;

          // Fondu progressif de la carte au moment de la traversée de la loupe
          final double mapOpacity = isZooming
              ? math.max(0.0, 1.0 - ((progress - 0.78) / 0.12))
              : _mapOpacityAnimation.value;

          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // 1. Arrière-plan blanc
              Container(color: AppColors.pureWhite),

              // 2. Zone centrale : Carte + Texte "MaliExplorer"
              Center(
                child: Opacity(
                  opacity: mapOpacity,
                  child: Transform.scale(
                    scale: _mapScaleAnimation.value,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Carte du Mali SVG
                        SvgPicture.asset(
                          'assets/images/carte.svg',
                          width: 200,
                          height: 186,
                          fit: BoxFit.contain,
                        ),

                        // Texte "MaliExplorer" (Splash 3)
                        if (progress >= 0.52)
                          FadeTransition(
                            opacity: _textOpacityAnimation,
                            child: SlideTransition(
                              position: _textSlideAnimation,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12.0),
                                child: RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      fontFamily: 'Roboto',
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Mali',
                                        style: TextStyle(
                                          color: Color(0xFF075E4D),
                                        ),
                                      ),
                                      TextSpan(
                                        text: 'Explorer',
                                        style: TextStyle(
                                          color: Color(0xFFC62828),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. Loupe SVG mobile + Zoom géant (Splash 4)
              Center(
                child: Transform.translate(
                  offset: _loupePositionAnimation.value,
                  child: Transform.rotate(
                    angle: _loupeRotationAnimation.value,
                    child: Transform.scale(
                      scale: _loupeScaleAnimation.value,
                      alignment: const Alignment(-0.35, -0.25),
                      child: Opacity(
                        opacity: _loupeOpacityAnimation.value,
                        child: SvgPicture.asset(
                          'assets/images/loupe.svg',
                          width: 78,
                          height: 68,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 4. Voile Blanc de transition (Splash 5)
              if (progress >= 0.88)
                IgnorePointer(
                  child: Container(
                    color: AppColors.pureWhite.withValues(
                      alpha: _fadeTransitionAnimation.value,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}