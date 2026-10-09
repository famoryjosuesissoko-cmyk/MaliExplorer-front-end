import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../main.dart';
import '../router/app_router.dart';
import 'auth/auth_controller.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  String _selectedLanguage = 'Français';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : const Color(0xFFF7F8F5),
      body: Column(
        children: [
          // Header
          Container(
            color: isDarkMode ? AppColors.darkBackgroundSecondary : const Color(0xFF075E4D),
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
                          'Paramètres',
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

          // Liste des options de réglages
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              children: [
                _buildSectionHeader('Préférences d\'affichage & Thème', isDarkMode),
                _buildCard([
                  SwitchListTile.adaptive(
                    value: isDarkMode,
                    activeThumbColor: isDarkMode ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: isDarkMode ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                      size: 24,
                    ),
                    title: Text(
                      'Mode Nuit / Jour',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.darkTextPrimary : null,
                      ),
                    ),
                    subtitle: Text(
                      isDarkMode ? 'Thème sombre actif' : 'Thème clair actif',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                      ),
                    ),
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).state =
                          val ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ], isDarkMode),

                const SizedBox(height: 20),

                _buildSectionHeader('Rôle Utilisateur & Espaces (Permissions)', isDarkMode),
                _buildCard([
                  Consumer(
                    builder: (context, ref, _) {
                      final auth = ref.watch(authControllerProvider);
                      final rawRole = (auth.user?['role'] ?? auth.user?['roleName'] ?? 'touriste').toString().toLowerCase();
                      final currentRole = rawRole.contains('artisan')
                          ? 'artisan'
                          : rawRole.contains('promoteur')
                              ? 'promoteur'
                              : rawRole.contains('admin')
                                  ? 'admin'
                                  : 'touriste';

                      void selectRole(String val) {
                        ref.read(authControllerProvider.notifier).updateUserData({'role': val});
                      }

                      return Column(
                        children: [
                          _buildRoleTile(
                            value: 'touriste',
                            currentRole: currentRole,
                            title: 'Touriste (Public uniquement)',
                            subtitle: 'Accès complet à la découverte, masquage des espaces de gestion',
                            color: const Color(0xFF075E4D),
                            isDark: isDarkMode,
                            onTap: () => selectRole('touriste'),
                          ),
                          const Divider(height: 1),
                          _buildRoleTile(
                            value: 'artisan',
                            currentRole: currentRole,
                            title: 'Artisan (Public + Espace Artisan)',
                            subtitle: 'Gestion atelier, créations d\'art et statistiques de vente',
                            color: const Color(0xFFD97706),
                            isDark: isDarkMode,
                            onTap: () => selectRole('artisan'),
                          ),
                          const Divider(height: 1),
                          _buildRoleTile(
                            value: 'promoteur',
                            currentRole: currentRole,
                            title: 'Promoteur (Public + Espace Promoteur)',
                            subtitle: 'Organisation de festivals, partenariats B2B et statistiques',
                            color: const Color(0xFF2563EB),
                            isDark: isDarkMode,
                            onTap: () => selectRole('promoteur'),
                          ),
                          const Divider(height: 1),
                          _buildRoleTile(
                            value: 'admin',
                            currentRole: currentRole,
                            title: 'Administrateur (Gestion complète)',
                            subtitle: 'Modération et validation des publications & accès complet',
                            color: const Color(0xFF7C3AED),
                            isDark: isDarkMode,
                            onTap: () => selectRole('admin'),
                          ),
                        ],
                      );
                    },
                  ),
                ], isDarkMode),

                const SizedBox(height: 20),

                _buildSectionHeader('Notifications & Alertes', isDarkMode),
                _buildCard([
                  SwitchListTile.adaptive(
                    value: _notificationsEnabled,
                    activeThumbColor: isDarkMode ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                    secondary: Icon(
                      Icons.notifications_active_outlined,
                      color: isDarkMode ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                      size: 24,
                    ),
                    title: Text(
                      'Notifications Push',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.darkTextPrimary : null,
                      ),
                    ),
                    subtitle: Text(
                      'Quiz, nouveaux monuments et actualités',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                      ),
                    ),
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: isDarkMode ? AppColors.darkBorder : null,
                  ),
                  SwitchListTile.adaptive(
                    value: _soundEnabled,
                    activeThumbColor: isDarkMode ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                    secondary: Icon(
                      Icons.volume_up_outlined,
                      color: isDarkMode ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                      size: 24,
                    ),
                    title: Text(
                      'Effets sonores des Quiz',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.darkTextPrimary : null,
                      ),
                    ),
                    subtitle: Text(
                      'Sons de validation et félicitations',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                      ),
                    ),
                    onChanged: (val) => setState(() => _soundEnabled = val),
                  ),
                ], isDarkMode),

                const SizedBox(height: 20),

                _buildSectionHeader('Langue & Région', isDarkMode),
                _buildCard([
                  ListTile(
                    leading: Icon(
                      Icons.language_rounded,
                      color: isDarkMode ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                      size: 24,
                    ),
                    title: Text(
                      'Langue',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.darkTextPrimary : null,
                      ),
                    ),
                    subtitle: Text(
                      _selectedLanguage,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: isDarkMode ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                    ),
                    onTap: () {
                      _showLanguageDialog();
                    },
                  ),
                ], isDarkMode),

                const SizedBox(height: 20),

                _buildSectionHeader('Stockage & Cache', isDarkMode),
                _buildCard([
                  ListTile(
                    leading: Icon(
                      Icons.cleaning_services_outlined,
                      color: isDarkMode ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                      size: 24,
                    ),
                    title: Text(
                      'Vider le cache d\'images',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.darkTextPrimary : null,
                      ),
                    ),
                    subtitle: Text(
                      'Libère de l\'espace de stockage local',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: isDarkMode ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Cache local vidé avec succès.'),
                          backgroundColor: isDarkMode ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                        ),
                      );
                    },
                  ),
                ], isDarkMode),

                const SizedBox(height: 20),

                _buildSectionHeader('Légal & Informations', isDarkMode),
                _buildCard([
                  ListTile(
                    leading: Icon(
                      Icons.description_outlined,
                      color: isDarkMode ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                      size: 24,
                    ),
                    title: Text(
                      'Conditions d\'utilisation',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.darkTextPrimary : null,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: isDarkMode ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                    ),
                    onTap: () => context.push(AppRouter.terms),
                  ),
                  Divider(
                    height: 1,
                    indent: 56,
                    color: isDarkMode ? AppColors.darkBorder : null,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.info_outline_rounded,
                      color: isDarkMode ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                      size: 24,
                    ),
                    title: Text(
                      'À propos de MaliExplorer',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? AppColors.darkTextPrimary : null,
                      ),
                    ),
                    subtitle: Text(
                      'Version 1.0.0 • ODC Mali',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: isDarkMode ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                    ),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'MaliExplorer',
                        applicationVersion: '1.0.0',
                        applicationIcon: Image.asset(
                          'assets/images/MaliExplorer.png',
                          width: 48,
                          height: 48,
                          errorBuilder: (ctx, err, stack) => const Icon(Icons.explore, size: 48, color: Color(0xFF075E4D)),
                        ),
                        children: const [
                          Text(
                            'Application culturelle, touristique et patrimoniale du Mali développée par Famory Josue Sissoko et Hamath Diallo au sein d\'Orange Digital Center (ODC).',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ],
                      );
                    },
                  ),
                ], isDarkMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final isDarkMode = ref.read(themeModeProvider) == ThemeMode.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sélectionner la langue',
          style: TextStyle(
            color: isDarkMode ? AppColors.darkTextPrimary : const Color(0xFF075E4D),
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                _selectedLanguage == 'Français' ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isDarkMode ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
              ),
              title: Text(
                'Français',
                style: TextStyle(color: isDarkMode ? AppColors.darkTextPrimary : null),
              ),
              onTap: () {
                setState(() => _selectedLanguage = 'Français');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(
                _selectedLanguage == 'Bambara (Bamanankan)' ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isDarkMode ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
              ),
              title: Text(
                'Bambara (Bamanankan)',
                style: TextStyle(color: isDarkMode ? AppColors.darkTextPrimary : null),
              ),
              onTap: () {
                setState(() => _selectedLanguage = 'Bambara (Bamanankan)');
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleTile({
    required String value,
    required String currentRole,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = currentRole == value;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : (isDark ? AppColors.darkBorder : Colors.grey.shade400),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 11,
                        height: 11,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, [bool isDark = false]) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children, [bool isDark = false]) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDark ? Border.all(color: AppColors.darkBorder) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
