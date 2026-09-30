import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/app_card.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);
    final isDark = currentTheme == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.md),
        children: [
          const Text(
            'Affichage',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryForest),
          ),
          const SizedBox(height: AppDimensions.sm),
          AppCard(
            child: SwitchListTile(
              title: const Text('Mode Sombre (Dark Theme)'),
              subtitle: const Text('Ajuste le contraste pour un confort visuel'),
              value: isDark,
              activeThumbColor: AppColors.sahelGold,
              onChanged: (_) => ref.read(themeModeProvider.notifier).toggleTheme(),
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          const Text(
            'À propos de l\'application',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryForest),
          ),
          const SizedBox(height: AppDimensions.sm),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Application'),
                  subtitle: const Text(AppStrings.appName),
                  trailing: const Text('v1.0.0', style: TextStyle(color: AppColors.textSecondary)),
                ),
                const Divider(),
                const ListTile(
                  title: Text('Architecture'),
                  subtitle: Text('Flutter Mobile & Web + Spring Boot Backend + Firebase'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
