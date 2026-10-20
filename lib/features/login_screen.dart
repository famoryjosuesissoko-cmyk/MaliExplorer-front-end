import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';
import 'auth/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  bool _showEmailForm = false; // Bascule entre vue choix et formulaire email
  bool _emailLinkSent = false; // Indique si le lien magique a été expédié

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() async {
    _appLinks = AppLinks();
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _processIncomingLink(initialUri.toString());
      }
    } catch (_) {}

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _processIncomingLink(uri.toString());
    });
  }

  void _processIncomingLink(String link) async {
    if (link.contains('apiKey') || link.contains('finishSignUp') || link.contains('mode=signIn')) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .handleEmailLink(link, _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion par lien e-mail réussie ! Bienvenue sur MaliExplorer.'),
            backgroundColor: AppColors.primaryForest,
          ),
        );
        context.go(AppRouter.home);
      } else {
        final err = ref.read(authControllerProvider).errorMessage ?? 'Lien de connexion invalide';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  /// Envoi du lien de connexion sécurisé sans mot de passe vers l'email saisi
  Future<void> _handleSendEmailLink() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();

    final success = await ref
        .read(authControllerProvider.notifier)
        .sendMagicLink(email);

    if (!mounted) return;

    if (success) {
      setState(() => _emailLinkSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lien de connexion envoyé à $email !'),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF4DB6AC)
              : AppColors.primaryForest,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      final error = ref.read(authControllerProvider).errorMessage ??
          'Impossible d\'envoyer le lien de connexion.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    final success = await ref
        .read(authControllerProvider.notifier)
        .signInWithGoogle();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion Google réussie ! Bienvenue sur MaliExplorer.'),
          backgroundColor: AppColors.primaryForest,
        ),
      );
      context.go(AppRouter.home);
    } else {
      final error = ref.read(authControllerProvider).errorMessage;
      if (error != null && error.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF7F8F5),
      body: Column(
        children: [
          // ==================== PARTIE SUPÉRIEURE : HERO BANNER FIGMA ====================
          SizedBox(
            height: (size.height * 0.38).clamp(240.0, 320.0),
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image de fond Arch / Mali de haute qualité
                Image.asset(
                  'assets/images/auth_hero.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/auth_hero.png',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, trace) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF075E4D), Color(0xFF16332D)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                ),

                // Dégradé sombre pour sublimer le logo et le texte MaliExplorer
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.60),
                        Colors.black.withValues(alpha: 0.20),
                        Colors.black.withValues(alpha: 0.45),
                      ],
                    ),
                  ),
                ),

                // Logo officiel MaliExplorer & Titre alignés en haut à gauche (Conforme HomeScreen & Figma)
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/MaliExplorer.png',
                            height: 42,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.explore,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'MaliExplorer',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  offset: Offset(0, 1.5),
                                  blurRadius: 4.0,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ==================== PARTIE INFÉRIEURE : FICHE ARRONDIR FIGMA ====================
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackgroundSecondary : const Color(0xFFF7F8F5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: isDark ? const Border(top: BorderSide(color: AppColors.darkBorder, width: 1)) : null,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 16),
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 200),
                        crossFadeState: _showEmailForm
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: _buildFigmaOptionsView(isDark),
                        secondChild: _buildFigmaEmailFormView(authState, isDark),
                      ),
                    ),
                  ),

                  // Flèche retour en bas à gauche Figma
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0, bottom: 12.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
                            size: 22,
                          ),
                          onPressed: () {
                            if (_showEmailForm) {
                              setState(() {
                                _showEmailForm = false;
                                _emailLinkSent = false;
                              });
                            } else if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRouter.home);
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Écran Figma 1 : Interface Connexion (Choix Google vs Email)
  Widget _buildFigmaOptionsView(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connexion',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF064E3B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Accédez à votre espace personnel\net continuez votre exploration.',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
            height: 1.45,
          ),
        ),
        const SizedBox(height: 36),

        // Bouton Google
        InkWell(
          onTap: _handleGoogleLogin,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/google_icon.png',
                  height: 22,
                  width: 22,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Text(
                  'Se connecter avec Google',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Bouton Email -> Déclenche le formulaire pour recevoir le lien direct sans mot de passe
        InkWell(
          onTap: () => setState(() {
            _showEmailForm = true;
            _emailLinkSent = false;
          }),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: isDark ? AppColors.primaryInteractive : const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.email_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 12),
                Text(
                  'Se connecter avec Email',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Pied de page Inscription
        Center(child: _buildFooterRegister(isDark)),
      ],
    );
  }

  /// Écran Figma 2 : Interface connexion par Email (Lien sécurisé sans mot de passe)
  Widget _buildFigmaEmailFormView(AuthState authState, bool isDark) {
    if (_emailLinkSent) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF4DB6AC) : const Color(0xFF064E3B)).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_read_rounded,
                    color: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF064E3B),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Lien de connexion envoyé !',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF064E3B),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Un lien direct a été envoyé à :\n${_emailController.text.trim()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ouvrez votre application de messagerie sur ce téléphone et touchez le lien reçu pour vous connecter automatiquement.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _handleSendEmailLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.primaryInteractive : const Color(0xFF064E3B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Renvoyer le lien',
                            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => setState(() => _emailLinkSent = false),
                  child: Text(
                    'Modifier l\'adresse email',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF064E3B),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(child: _buildFooterRegister(isDark)),
        ],
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connexion par Email',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF064E3B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Entrez votre adresse email pour recevoir votre lien de connexion sécurisé sans mot de passe.',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),

          // Champ Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              hintText: 'Adresse email',
              hintStyle: TextStyle(
                color: isDark ? AppColors.darkTextDisabled : const Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF374151),
                size: 22,
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurface : Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF064E3B),
                  width: 1.6,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Veuillez saisir votre email';
              if (!v.contains('@')) return 'Format d\'email invalide';
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Bouton Recevoir le lien
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _handleSendEmailLink,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.primaryInteractive : const Color(0xFF064E3B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 0,
              ),
              child: authState.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Recevoir mon lien de connexion',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // Pied de page Inscription
          Center(child: _buildFooterRegister(isDark)),
        ],
      ),
    );
  }

  Widget _buildFooterRegister(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Pas encore de compte ? ',
          style: TextStyle(
            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
            fontSize: 13.5,
          ),
        ),
        GestureDetector(
          onTap: () => context.push(AppRouter.register),
          child: Text(
            'S\'inscrire',
            style: TextStyle(
              color: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF111827),
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
