import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_text_field.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adresseController = TextEditingController();
  bool _obscurePassword = true;

  UserRole _selectedRole = UserRole.touriste;

  final List<UserRole> _allowedRoles = [
    UserRole.touriste,
    UserRole.guide,
    UserRole.artisan,
    UserRole.promoteur,
  ];

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
          prenom: _prenomController.text,
          nom: _nomController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole,
          adresse: _adresseController.text.isNotEmpty ? _adresseController.text : null,
        );

    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      final error = ref.read(authProvider).errorMessage;
      if (error != null) {
        Helpers.showErrorSnackBar(context, error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Rejoignez MaliExplorer',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gagnez des badges Bambara et sauvegardez vos lieux favoris.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppDimensions.lg),

                AppCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                controller: _prenomController,
                                label: 'Prénom',
                                validator: Validators.requiredField,
                              ),
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            Expanded(
                              child: AppTextField(
                                controller: _nomController,
                                label: 'Nom',
                                validator: Validators.requiredField,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.md),

                        AppTextField(
                          controller: _emailController,
                          label: 'Adresse email',
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: AppDimensions.md),

                        AppTextField(
                          controller: _passwordController,
                          label: 'Mot de passe (6 car. min)',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: Validators.password,
                        ),
                        const SizedBox(height: AppDimensions.md),

                        DropdownButtonFormField<UserRole>(
                          initialValue: _selectedRole,
                          decoration: InputDecoration(
                            labelText: 'Rôle utilisateur',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMd)),
                          ),
                          items: _allowedRoles.map((role) {
                            return DropdownMenuItem<UserRole>(
                              value: role,
                              child: Text(role.displayName),
                            );
                          }).toList(),
                          onChanged: (newRole) {
                            if (newRole != null) {
                              setState(() => _selectedRole = newRole);
                            }
                          },
                        ),
                        const SizedBox(height: AppDimensions.md),

                        AppTextField(
                          controller: _adresseController,
                          label: 'Ville / Adresse (optionnel)',
                          prefixIcon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: AppDimensions.lg),

                        AppButton(
                          text: "S'inscrire",
                          onPressed: _submit,
                          isLoading: authState.isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Déjà un compte ? ', style: TextStyle(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: const Text(
                        'Se connecter',
                        style: TextStyle(color: AppColors.primaryForest, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
