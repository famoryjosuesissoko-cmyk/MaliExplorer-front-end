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

    // Chronologie ajustée sur 5 secondes pour bien décomposer chaque étape
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
    // 1. Apparition initiale de la carte et de la loupe (0.0s -> 0.75s)
    // -------------------------------------------------------------------------
    _mapOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.12, curve: Curves.easeOut),
      ),
    );

    _mapScaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.00, 0.15, curve: Curves.easeOutBack),
      ),
    );

    _loupeOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.02, 0.10, curve: Curves.easeIn),
      ),
    );

    // -------------------------------------------------------------------------
    // 2. Trajet de la loupe (Ancré sur un repère central de 280x280)
    // - posEst   : Splash 1 (Rouge - Est)
    // - posNord  : Splash 2 (Jaune - Nord)
    // - posOuest : Splash 3 (Vert - Ouest)
    // - posCentre: Splash 4 (Zoom central)
    // -------------------------------------------------------------------------
    const Offset posEst = Offset(50.0, -15.0);
    const Offset posNord = Offset(10.0, -55.0);
    const Offset posOuest = Offset(-50.0, 20.0);
    const Offset posCentre = Offset(0.0, 0.0);

    _loupePositionAnimation = TweenSequence<Offset>([
      // Splash 1 : Pause sur l'Est
      TweenSequenceItem(tween: ConstantTween<Offset>(posEst), weight: 20),
      // Mouvement vers le Nord (Splash 2)
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: posEst,
          end: posNord,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 15,
      ),
      // Pause sur le Nord
      TweenSequenceItem(tween: ConstantTween<Offset>(posNord), weight: 15),
      // Mouvement vers l'Ouest (Splash 3)
      TweenSequenceItem(
        tween: Tween<Offset>(
          begin: posNord,
          end: posOuest,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 15,
      ),
      // Pause sur l'Ouest
      TweenSequenceItem(tween: ConstantTween<Offset>(posOuest), weight: 15),
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

    // Rotation dynamique du manche de la loupe lors du déplacement
    _loupeRotationAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 20),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: -0.25,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(-0.25), weight: 15),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.25,
          end: 0.20,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 15,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(0.20), weight: 15),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.20,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_controller);

    // -------------------------------------------------------------------------
    // 3. Splash 3 : Apparition du texte "MaliExplorer"
    // -------------------------------------------------------------------------
    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 0.78, curve: Curves.easeIn),
      ),
    );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0.15, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.65, 0.78, curve: Curves.easeOutCubic),
          ),
        );

    // -------------------------------------------------------------------------
    // 4. Splash 4 : Zoom immersif de la loupe
    // -------------------------------------------------------------------------
    _loupeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 80),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 32.0,
        ).chain(CurveTween(curve: Curves.easeInExpo)),
        weight: 15,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(32.0), weight: 5),
    ]).animate(_controller);

    // -------------------------------------------------------------------------
    // 5. Splash 5 : Fondu blanc final
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
          final bool isZooming = progress > 0.80;

          // Fondu progressif de la carte au moment de la traversée de la loupe
          final double mapOpacity = isZooming
              ? math.max(0.0, 1.0 - ((progress - 0.80) / 0.10))
              : _mapOpacityAnimation.value;

          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // 1. Arrière-plan
              Container(color: AppColors.pureWhite),

              // 2. Zone d'Animation unifiée (Repère fixe pour la carte et la loupe)
              Center(
                child: SizedBox(
                  width: 280,
                  height: 280,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Carte du Mali SVG
                      Opacity(
                        opacity: mapOpacity,
                        child: Transform.scale(
                          scale: _mapScaleAnimation.value,
                          child: SvgPicture.asset(
                            'assets/images/carte.svg',
                            width: 210,
                            height: 196,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Texte "MaliExplorer" (Splash 3)
                      if (progress >= 0.62)
                        Positioned(
                          right: -110,
                          child: FadeTransition(
                            opacity: _textOpacityAnimation,
                            child: SlideTransition(
                              position: _textSlideAnimation,
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                    fontSize: 24,
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

                      // Loupe SVG mobile + Zoom
                      Transform.translate(
                        offset: _loupePositionAnimation.value,
                        child: Transform.rotate(
                          angle: _loupeRotationAnimation.value,
                          child: Transform.scale(
                            scale: _loupeScaleAnimation.value,
                            alignment: const Alignment(
                              -0.3,
                              -0.3,
                            ), // Point pivot sur la lentille
                            child: Opacity(
                              opacity: _loupeOpacityAnimation.value,
                              child: SvgPicture.asset(
                                'assets/images/loupe.svg',
                                width: 75,
                                height: 65,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Voile Blanc de transition (Splash 5)
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
