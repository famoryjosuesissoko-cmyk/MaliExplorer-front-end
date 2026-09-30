import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mon Profil')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_circle, size: 72, color: Colors.grey),
                const SizedBox(height: AppDimensions.md),
                const Text('Vous n\'êtes pas connecté', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppDimensions.lg),
                AppButton(text: 'Se connecter', onPressed: () => context.push('/auth/login')),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Paramètres',
            onPressed: () => context.push('/profile/settings'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: AppColors.primaryForest.withValues(alpha: 0.15),
                    child: Text(
                      user.prenom.isNotEmpty ? user.prenom[0].toUpperCase() : 'M',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.sm),
                  Text(user.nomComplet, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(user.email, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.sahelGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                    ),
                    child: Text(
                      user.role.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.sahelGold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.lg),

            AppCard(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.star_outline, color: AppColors.sahelGold),
                    title: const Text('Points de Savoir'),
                    trailing: Text('${user.points} pts', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.military_tech_outlined, color: AppColors.primaryForest),
                    title: const Text('Mes Badges Bambara'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/badges'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.favorite_border, color: Colors.red),
                    title: const Text('Mes Favoris'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/favoris'),
                  ),
                  if (user.adresse != null) ...[
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.location_on_outlined, color: AppColors.textSecondary),
                      title: const Text('Adresse'),
                      subtitle: Text(user.adresse!),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.xl),

            AppButton(
              text: 'Se déconnecter',
              isOutlined: true,
              color: AppColors.error,
              icon: Icons.logout,
              onPressed: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/home');
              },
            ),
          ],
        ),
      ),
    );
  }
}
