import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/app_colors.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../main.dart';
import '../router/app_router.dart';
import 'auth/auth_controller.dart';

class ProfilScreen extends ConsumerStatefulWidget {
  const ProfilScreen({super.key});

  @override
  ConsumerState<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends ConsumerState<ProfilScreen> {
  bool _isUploadingAvatar = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUploadAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez vous connecter pour modifier votre profil.'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Modifier votre photo de profil',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF075E4D),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF075E4D)),
                title: const Text('Choisir dans la galerie'),
                onTap: () async {
                  Navigator.pop(ctx);
                  _processPickedImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF075E4D)),
                title: const Text('Prendre une photo'),
                onTap: () async {
                  Navigator.pop(ctx);
                  _processPickedImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _processPickedImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (bytes.lengthInBytes > StorageService.maxFileSizeBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La photo dépasse la taille maximale autorisée de 10 Mo.'),
              backgroundColor: Color(0xFFDC2626),
            ),
          );
        }
        return;
      }

      setState(() {
        _isUploadingAvatar = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      final apiService = ref.read(apiServiceProvider);

      // Upload vers Supabase Storage
      final photoUrl = await StorageService.uploadFile(
        folder: 'avatars',
        fileName: picked.name,
        bytes: bytes,
        apiService: apiService,
      );

      // Mise à jour de Firebase Auth et état Riverpod
      await user?.updatePhotoURL(photoUrl);
      await user?.reload();
      ref.read(authControllerProvider.notifier).updateUserData({'photoUrl': photoUrl});

      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo de profil mise à jour avec succès !'),
            backgroundColor: Color(0xFF075E4D),
          ),
        );
      }
    } catch (e) {
      debugPrint('[ProfilScreen] Erreur mise à jour avatar: $e');
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value ?? FirebaseAuth.instance.currentUser;
    final authState = ref.watch(authControllerProvider);
    final userMap = authState.user;
    final photoUrl = user?.photoURL ?? userMap?['photoUrl'];
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final String rawRole = (userMap?['role'] ?? userMap?['roleName'] ?? 'touriste').toString().toLowerCase();
    final bool isArtisan = rawRole.contains('artisan');
    final bool isPromoteur = rawRole.contains('promoteur');
    final bool isAdmin = rawRole.contains('admin');

    final String displayName = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user.displayName!
        : (userMap != null && (userMap['prenom'] != null || userMap['nom'] != null))
            ? '${userMap['prenom'] ?? ''} ${userMap['nom'] ?? ''}'.trim()
            : 'Utilisateur MaliExplorer';

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : const Color(0xFFF7F8F5),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Barre supérieure : Flèche retour & Titre "Mon profil"
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRouter.home);
                      }
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: isDarkMode ? AppColors.darkTextPrimary : const Color(0xFF16332D),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Mon profil',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? AppColors.darkTextPrimary : const Color(0xFF075E4D),
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // 2. Contenu défilable
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  children: [
                    // Photo de profil avec badge caméra cliquable
                    Center(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF075E4D),
                                width: 2.5,
                              ),
                              color: const Color(0xFFE8F4F0),
                            ),
                            child: _isUploadingAvatar
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
                                          width: 96,
                                          height: 96,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF075E4D),
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          errorWidget: (context, url, error) => const Icon(
                                            Icons.person_rounded,
                                            size: 50,
                                            color: Color(0xFF075E4D),
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person_rounded,
                                        size: 50,
                                        color: Color(0xFF075E4D),
                                      ),
                          ),
                          GestureDetector(
                            onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                            child: Container(
                              padding: const EdgeInsets.all(7),
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
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Nom et Email de l'utilisateur
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? AppColors.darkTextPrimary : const Color(0xFF075E4D),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      user?.email ?? 'Visiteur',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                        color: isDarkMode ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Badge du Rôle utilisateur
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isArtisan
                                ? const Color(0xFFD97706)
                                : isPromoteur
                                    ? const Color(0xFF2563EB)
                                    : isAdmin
                                        ? const Color(0xFF7C3AED)
                                        : const Color(0xFF075E4D))
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isArtisan
                            ? 'Artisan'
                            : isPromoteur
                                ? 'Promoteur Culturel'
                                : isAdmin
                                    ? 'Administrateur'
                                    : 'Touriste',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isArtisan
                              ? const Color(0xFFD97706)
                              : isPromoteur
                                  ? const Color(0xFF2563EB)
                                  : isAdmin
                                      ? const Color(0xFF7C3AED)
                                      : const Color(0xFF075E4D),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Options du menu conformes à la maquette
                    _buildMenuItem(
                      icon: Icons.person_rounded,
                      title: 'Informations personnelles',
                      isDark: isDarkMode,
                      onTap: () => context.push(AppRouter.personalInfo),
                    ),
                    _buildMenuItem(
                      icon: Icons.favorite_border_rounded,
                      title: 'Favoris',
                      isDark: isDarkMode,
                      onTap: () => context.push(AppRouter.favoris),
                    ),
                    _buildSwitchMenuItem(
                      icon: isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      title: isDarkMode ? 'Mode Nuit (Sombre)' : 'Mode Jour (Clair)',
                      value: isDarkMode,
                      isDark: isDarkMode,
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).state =
                            val ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                    // Redirige vers Mon Parcours (Quiz, Résultats & Badges Bambara)
                    _buildMenuItem(
                      icon: Icons.emoji_events_outlined,
                      title: 'Mes quiz et resultats',
                      isDark: isDarkMode,
                      onTap: () => context.push(AppRouter.monParcours),
                    ),
                    // Redirige vers Historique (Journal chronologique des points et activités)
                    _buildMenuItem(
                      icon: Icons.history_rounded,
                      title: 'Historique',
                      isDark: isDarkMode,
                      onTap: () => context.push(AppRouter.historique),
                    ),
                    // Espaces Professionnels & Partenariats B2B (Strictement isolés par rôle)
                    if (isArtisan || isAdmin)
                      _buildMenuItem(
                        icon: Icons.storefront_rounded,
                        title: 'Espace Artisan',
                        subtitle: 'Atelier, catalogue de vente & outillage',
                        isDark: isDarkMode,
                        onTap: () => context.push(AppRouter.artisanDashboard),
                      ),
                    if (isPromoteur || isAdmin)
                      _buildMenuItem(
                        icon: Icons.campaign_rounded,
                        title: 'Espace Promoteur',
                        subtitle: 'Festivals, projets culturels & sponsors B2B',
                        isDark: isDarkMode,
                        onTap: () => context.push(AppRouter.promoteurDashboard),
                      ),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Paramètres',
                      isDark: isDarkMode,
                      onTap: () => context.push(AppRouter.settings),
                    ),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Aide & support',
                      isDark: isDarkMode,
                      onTap: () => context.push(AppRouter.helpSupport),
                    ),
                    _buildMenuItem(
                      icon: Icons.logout_rounded,
                      title: 'Deconnexion',
                      isDestructive: true,
                      isDark: isDarkMode,
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        ref.read(apiServiceProvider).setAuthToken(null);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Déconnexion réussie'),
                              backgroundColor: isDarkMode ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                            ),
                          );
                          context.go(AppRouter.login);
                        }
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isDark = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 13.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 23,
                  color: isDestructive
                      ? const Color(0xFFDC2626)
                      : (isDark ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: isDestructive
                              ? const Color(0xFFDC2626)
                              : (isDark ? AppColors.darkTextPrimary : const Color(0xFF075E4D)),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isDestructive)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark ? AppColors.darkTextSecondary : const Color(0xFF16332D),
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchMenuItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isDark = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 23,
            color: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF075E4D),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
              activeTrackColor: (isDark ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D)).withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
