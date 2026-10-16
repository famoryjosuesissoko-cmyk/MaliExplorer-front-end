import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../features/auth/auth_controller.dart';
import '../router/app_router.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  late TextEditingController _adresseController;

  bool _isLoading = false;
  bool _isUploadingPhoto = false;
  bool _isPickingImage = false;
  Uint8List? _previewBytes;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? '';
    final parts = displayName.split(' ');
    final prenom = parts.isNotEmpty ? parts.first : '';
    final nom = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final authState = ref.read(authControllerProvider);
    final userMap = authState.user;

    _prenomController = TextEditingController(text: userMap?['prenom'] ?? prenom);
    _nomController = TextEditingController(text: userMap?['nom'] ?? nom);
    _emailController = TextEditingController(text: user?.email ?? userMap?['email'] ?? '');
    _telephoneController = TextEditingController(text: userMap?['telephone'] ?? '');
    _adresseController = TextEditingController(text: userMap?['adresse'] ?? '');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _pickAndChangeAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _isPickingImage) return;

    _isPickingImage = true;
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (bytes.lengthInBytes > StorageService.maxFileSizeBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La photo dépasse 10 Mo.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      setState(() {
        _previewBytes = bytes;
        _isUploadingPhoto = true;
      });

      final apiService = ref.read(apiServiceProvider);
      final photoUrl = await StorageService.uploadFile(
        folder: 'avatars',
        fileName: picked.name,
        bytes: bytes,
        apiService: apiService,
      );

      // Persistance dans MySQL
      try {
        await apiService.put('/utilisateurs/me/photo', body: {'photoUrl': photoUrl});
      } catch (e) {
        debugPrint('[PersonalInfo] Sync MySQL photo: $e');
      }

      await user.updatePhotoURL(photoUrl);
      await user.reload();
      ref.read(authControllerProvider.notifier).updateUserData({'photoUrl': photoUrl});
      await ref.read(authControllerProvider.notifier).syncProfile();
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo mise à jour avec succès.'),
            backgroundColor: Color(0xFF075E4D),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Photo appliquée localement. Pour la synchroniser sur le serveur, assurez-vous que Spring Boot tourne et lancez dans un terminal : adb reverse tcp:8080 tcp:8080',
            ),
            backgroundColor: Color(0xFFD97706),
            duration: Duration(seconds: 6),
          ),
        );
      }
    } finally {
      _isPickingImage = false;
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final apiService = ref.read(apiServiceProvider);
      final prenom = _prenomController.text.trim();
      final nom = _nomController.text.trim();
      final adresse = _adresseController.text.trim();
      final telephone = _telephoneController.text.trim();
      final fullName = '$prenom $nom'.trim();

      if (user != null) {
        if (fullName.isNotEmpty) {
          await user.updateDisplayName(fullName);
        }
        await user.reload();
      }

      // 1. Sauvegarde dans Spring Boot / MySQL
      try {
        await apiService.put('/utilisateurs/me', body: {
          'prenom': prenom,
          'nom': nom,
          'adresse': adresse,
        });
      } catch (e) {
        debugPrint('[PersonalInfo] Erreur sync MySQL: $e');
      }

      // 2. Notification immédiate du StateNotifier Riverpod
      ref.read(authControllerProvider.notifier).updateUserData({
        'prenom': prenom,
        'nom': nom,
        'telephone': telephone,
        'adresse': adresse,
        'displayName': fullName,
      });

      // 3. Synchronisation backend
      await ref.read(authControllerProvider.notifier).syncProfile();

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informations personnelles enregistrées avec succès !'),
            backgroundColor: Color(0xFF075E4D),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final passFormKey = GlobalKey<FormState>();
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isChanging = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                const Icon(Icons.lock_reset_rounded, color: Color(0xFF075E4D)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Modifier le mot de passe',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF075E4D),
                    ),
                  ),
                ),
              ],
            ),
            content: Form(
              key: passFormKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Saisissez votre nouveau mot de passe (au moins 6 caractères).',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: obscureNew,
                    style: TextStyle(color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D)),
                    validator: (val) {
                      if (val == null || val.length < 6) {
                        return 'Au moins 6 caractères requis';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      labelStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77)),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF075E4D)),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setDialogState(() => obscureNew = !obscureNew),
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF0F3F1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: obscureConfirm,
                    style: TextStyle(color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D)),
                    validator: (val) {
                      if (val != newPasswordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      labelStyle: TextStyle(color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77)),
                      prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF075E4D)),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setDialogState(() => obscureConfirm = !obscureConfirm),
                      ),
                      filled: true,
                      fillColor: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF0F3F1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF075E4D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: isChanging
                    ? null
                    : () async {
                        if (!passFormKey.currentState!.validate()) return;
                        setDialogState(() => isChanging = true);
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await user.updatePassword(newPasswordController.text.trim());
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Mot de passe mis à jour avec succès !'),
                                  backgroundColor: Color(0xFF075E4D),
                                ),
                              );
                            }
                          }
                        } on FirebaseAuthException catch (e) {
                          setDialogState(() => isChanging = false);
                          if (e.code == 'requires-recent-login') {
                            final email = FirebaseAuth.instance.currentUser?.email;
                            if (email != null) {
                              await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Pour des raisons de sécurité, un email de réinitialisation vous a été envoyé à $email.'),
                                    backgroundColor: const Color(0xFF075E4D),
                                  ),
                                );
                              }
                            }
                          } else {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erreur : ${e.message}'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        } catch (e) {
                          setDialogState(() => isChanging = false);
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                child: isChanging
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Mettre à jour'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final photoUrl = user?.photoURL;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      body: Column(
        children: [
          // En-tête
          Container(
            color: const Color(0xFF075E4D),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRouter.profil);
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Informations personnelles',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                  ],
                ),
              ),
            ),
          ),

          // Formulaire
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Photo de profil
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF075E4D), width: 2.5),
                              color: const Color(0xFFE8F4F0),
                            ),
                            child: _previewBytes != null
                                ? ClipOval(
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.memory(
                                          _previewBytes!,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                        ),
                                        if (_isUploadingPhoto)
                                          Container(
                                            color: Colors.black38,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                : _isUploadingPhoto
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF075E4D),
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : (photoUrl != null && photoUrl.isNotEmpty)
                                        ? ClipOval(
                                            child: CachedNetworkImage(
                                              imageUrl: photoUrl,
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                              placeholder: (context, url) => const Center(
                                                child: CircularProgressIndicator(strokeWidth: 2),
                                              ),
                                              errorWidget: (context, url, error) => const Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Color(0xFF075E4D),
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Color(0xFF075E4D),
                                          ),
                          ),
                          GestureDetector(
                            onTap: _isUploadingPhoto ? null : _pickAndChangeAvatar,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF075E4D),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildTextField(
                      controller: _prenomController,
                      label: 'Prénom',
                      icon: Icons.person_outline_rounded,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Prénom requis' : null,
                    ),

                    const SizedBox(height: 14),

                    _buildTextField(
                      controller: _nomController,
                      label: 'Nom',
                      icon: Icons.badge_outlined,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Nom requis' : null,
                    ),

                    const SizedBox(height: 14),

                    _buildTextField(
                      controller: _emailController,
                      label: 'Adresse e-mail',
                      icon: Icons.mail_outline_rounded,
                      readOnly: true,
                    ),

                    const SizedBox(height: 14),

                    _buildTextField(
                      controller: _telephoneController,
                      label: 'Numéro de téléphone',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),

                    const SizedBox(height: 14),

                    _buildTextField(
                      controller: _adresseController,
                      label: 'Adresse / Ville',
                      icon: Icons.location_on_outlined,
                      isDark: Theme.of(context).brightness == Brightness.dark,
                    ),

                    const SizedBox(height: 24),

                    // Section Sécurité & Mot de passe
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.darkSurface
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.darkBorder
                              : Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF075E4D).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF075E4D), size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sécurité du compte',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? AppColors.darkTextPrimary
                                        : const Color(0xFF16332D),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Mot de passe & authentification',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? AppColors.darkTextSecondary
                                        : const Color(0xFF6C7C77),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _showChangePasswordDialog,
                            child: Text(
                              'Modifier',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color(0xFFD6A23A)
                                    : const Color(0xFF075E4D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF075E4D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 2,
                        ),
                        onPressed: _isLoading ? null : _saveChanges,
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                            : const Text(
                                'Enregistrer les modifications',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    bool isDark = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: 14,
        color: isDark
            ? AppColors.darkTextPrimary
            : (readOnly ? Colors.grey[700] : const Color(0xFF16332D)),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF075E4D), size: 22),
        filled: true,
        fillColor: isDark
            ? (readOnly ? AppColors.darkBackgroundSecondary : AppColors.darkSurfaceElevated)
            : (readOnly ? const Color(0xFFEEEEEE) : Colors.white),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF075E4D), width: 1.6),
        ),
      ),
    );
  }
}

