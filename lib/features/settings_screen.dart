import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../main.dart';
import '../router/app_router.dart';

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
      backgroundColor: const Color(0xFFF7F8F5),
      body: Column(
        children: [
          // Header
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
                _buildSectionHeader('Préférences d\'affichage & Thème'),
                _buildCard([
                  SwitchListTile.adaptive(
                    value: isDarkMode,
                    activeThumbColor: const Color(0xFF075E4D),
                    secondary: Icon(
                      isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: const Color(0xFF075E4D),
                      size: 24,
                    ),
                    title: const Text(
                      'Mode Nuit / Jour',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      isDarkMode ? 'Thème sombre actif' : 'Thème clair actif',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6C7C77)),
                    ),
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).state =
                          val ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ]),

                const SizedBox(height: 20),

                _buildSectionHeader('Notifications & Alertes'),
                _buildCard([
                  SwitchListTile.adaptive(
                    value: _notificationsEnabled,
                    activeThumbColor: const Color(0xFF075E4D),
                    secondary: const Icon(
                      Icons.notifications_active_outlined,
                      color: Color(0xFF075E4D),
                      size: 24,
                    ),
                    title: const Text(
                      'Notifications Push',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Quiz, nouveaux monuments et actualités',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6C7C77)),
                    ),
                    onChanged: (val) => setState(() => _notificationsEnabled = val),
                  ),
                  const Divider(height: 1, indent: 56),
                  SwitchListTile.adaptive(
                    value: _soundEnabled,
                    activeThumbColor: const Color(0xFF075E4D),
                    secondary: const Icon(
                      Icons.volume_up_outlined,
                      color: Color(0xFF075E4D),
                      size: 24,
                    ),
                    title: const Text(
                      'Effets sonores des Quiz',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Sons de validation et félicitations',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6C7C77)),
                    ),
                    onChanged: (val) => setState(() => _soundEnabled = val),
                  ),
                ]),

                const SizedBox(height: 20),

                _buildSectionHeader('Langue & Région'),
                _buildCard([
                  ListTile(
                    leading: const Icon(Icons.language_rounded, color: Color(0xFF075E4D), size: 24),
                    title: const Text(
                      'Langue',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _selectedLanguage,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF6C7C77)),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF6C7C77)),
                    onTap: () {
                      _showLanguageDialog();
                    },
                  ),
                ]),

                const SizedBox(height: 20),

                _buildSectionHeader('Stockage & Cache'),
                _buildCard([
                  ListTile(
                    leading: const Icon(Icons.cleaning_services_outlined, color: Color(0xFF075E4D), size: 24),
                    title: const Text(
                      'Vider le cache d\'images',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Libère de l\'espace de stockage local',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6C7C77)),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF6C7C77)),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cache local vidé avec succès.'),
                          backgroundColor: Color(0xFF075E4D),
                        ),
                      );
                    },
                  ),
                ]),

                const SizedBox(height: 20),

                _buildSectionHeader('Légal & Informations'),
                _buildCard([
                  ListTile(
                    leading: const Icon(Icons.description_outlined, color: Color(0xFF075E4D), size: 24),
                    title: const Text(
                      'Conditions d\'utilisation',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF6C7C77)),
                    onTap: () => context.push(AppRouter.terms),
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: Color(0xFF075E4D), size: 24),
                    title: const Text(
                      'À propos de MaliExplorer',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text(
                      'Version 1.0.0 • ODC Mali',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6C7C77)),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF6C7C77)),
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
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sélectionner la langue', style: TextStyle(color: Color(0xFF075E4D), fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                _selectedLanguage == 'Français' ? Icons.radio_button_checked : Icons.radio_button_off,
                color: const Color(0xFF075E4D),
              ),
              title: const Text('Français'),
              onTap: () {
                setState(() => _selectedLanguage = 'Français');
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: Icon(
                _selectedLanguage == 'Bambara (Bamanankan)' ? Icons.radio_button_checked : Icons.radio_button_off,
                color: const Color(0xFF075E4D),
              ),
              title: const Text('Bambara (Bamanankan)'),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: Color(0xFF6C7C77),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}
