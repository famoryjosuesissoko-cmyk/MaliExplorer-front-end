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
  final _passwordController = TextEditingController();
  final _resetEmailController = TextEditingController();

  bool _obscurePassword = true;
  bool _showEmailForm = false; // Bascule entre vue choix et formulaire email

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .login(_emailController.text, _passwordController.text);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connexion réussie ! Bienvenue sur MaliExplorer.'),
          backgroundColor: AppColors.primaryForest,
        ),
      );
      context.go(AppRouter.home);
    } else {
      final error =
          ref.read(authControllerProvider).errorMessage ??
          'Erreur de connexion';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    }
  }

  void _handleGoogleLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Connexion Google : service en cours d\'initialisation. Veuillez utiliser la connexion par Email.',
        ),
        backgroundColor: AppColors.sahelGold,
      ),
    );
  }

  void _showPasswordResetDialog() {
    _resetEmailController.text = _emailController.text.trim();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: AppColors.primaryForest),
            SizedBox(width: 10),
            Text(
              'Mot de passe oublié',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryForest,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Saisissez votre adresse email pour recevoir un lien sécurisé de réinitialisation :',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'exemple@domaine.com',
                prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryForest),
                filled: true,
                fillColor: AppColors.mistIvory,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryForest, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryForest,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final email = _resetEmailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez saisir une adresse email valide.'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              Navigator.of(ctx).pop();
              final success = await ref
                  .read(authControllerProvider.notifier)
                  .sendPasswordReset(email);

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Un lien de réinitialisation a été envoyé à $email.'),
                      backgroundColor: AppColors.primaryForest,
                    ),
                  );
                } else {
                  final err = ref.read(authControllerProvider).errorMessage ??
                      'Impossible d\'envoyer le lien.';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Envoyer le lien'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      body: Column(
        children: [
          // ==================== PARTIE SUPÉRIEURE : HERO BANNER ====================
          SizedBox(
            height: size.height * 0.40,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image de fond Arch / Mali
                Image.asset(
                  'assets/images/auth_hero.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF075E4D), Color(0xFF16332D)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),

                // Voile léger pour contraste
                Container(
                  color: Colors.black.withValues(alpha: 0.12),
                ),

                // Logo officiel MaliExplorer sans ombre
                SafeArea(
                  child: Align(
                    alignment: const Alignment(0, -0.65),
                    child: Image.asset(
                      'assets/images/MaliExplorer.png',
                      height: 95,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Text(
                        'MaliExplorer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
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
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                        firstChild: _buildFigmaOptionsView(),
                        secondChild: _buildFigmaEmailFormView(authState),
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
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF16332D),
                            size: 22,
                          ),
                          onPressed: () {
                            if (_showEmailForm) {
                              setState(() => _showEmailForm = false);
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
  Widget _buildFigmaOptionsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Connexion',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF064E3B),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Accédez à votre espace personnel\net continuez votre exploration.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/google_icon.png',
                  height: 22,
                  width: 22,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.g_mobiledata_rounded,
                    color: Colors.redAccent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Se connecter avec Google',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Bouton Email
        InkWell(
          onTap: () => setState(() => _showEmailForm = true),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/gmail_icon.png',
                  height: 20,
                  width: 20,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.mail_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
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

        // Footer Inscription
        Center(child: _buildFooterRegister()),
      ],
    );
  }

  /// Écran Figma 2 : Interface connexionEmail (Champs Email & Password)
  Widget _buildFigmaEmailFormView(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connexion',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF064E3B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Donnez votre email & mot de passe',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 28),

          // Champ Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'Adresse email',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              prefixIcon: const Icon(Icons.mail_outline_rounded, color: Color(0xFF374151), size: 22),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xFF064E3B), width: 1.6),
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Veuillez saisir votre email';
              if (!v.contains('@')) return 'Format d\'email invalide';
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Champ Mot de passe
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Mot de passe',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF374151), size: 22),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF6B7280),
                  size: 22,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(color: Color(0xFF064E3B), width: 1.6),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Veuillez saisir votre mot de passe';
              if (v.length < 6) return 'Au moins 6 caractères requis';
              return null;
            },
          ),

          const SizedBox(height: 8),

          // Mot de passe oublié
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showPasswordResetDialog,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Mot de passe oublié ?',
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Bouton Se connecter
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: authState.isLoading ? null : _handleEmailLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF064E3B),
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
                  : const Text(
                      'Se connecter',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // Footer Inscription
          Center(child: _buildFooterRegister()),
        ],
      ),
    );
  }

  Widget _buildFooterRegister() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Pas encore de compte ? ',
          style: TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13.5,
          ),
        ),
        GestureDetector(
          onTap: () => context.push(AppRouter.register),
          child: const Text(
            'S\'inscrire',
            style: TextStyle(
              color: Color(0xFF111827),
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
