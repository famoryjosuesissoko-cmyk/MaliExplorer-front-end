import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../widgets/home/home_banner.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MaliExplorer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline),
            onPressed: () => context.push('/favoris'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeBanner(),
            const SizedBox(height: AppDimensions.lg),
            Text(
              'Explorer le Mali',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppDimensions.md),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: AppDimensions.md,
              mainAxisSpacing: AppDimensions.md,
              children: [
                _CategoryCard(
                  title: 'Régions',
                  icon: Icons.map,
                  color: AppColors.primaryForest,
                  onTap: () => context.push('/regions'),
                ),
                _CategoryCard(
                  title: 'Villes',
                  icon: Icons.location_city,
                  color: AppColors.secondaryEmerald,
                  onTap: () => context.push('/villes'),
                ),
                _CategoryCard(
                  title: 'Lieux Historiques',
                  icon: Icons.account_balance,
                  color: AppColors.earthOchre,
                  onTap: () => context.push('/lieux'),
                ),
                _CategoryCard(
                  title: 'Plats Typiques',
                  icon: Icons.restaurant,
                  color: AppColors.terracotta,
                  onTap: () => context.push('/plats'),
                ),
                _CategoryCard(
                  title: 'Ethnies',
                  icon: Icons.people,
                  color: AppColors.indigoMali,
                  onTap: () => context.push('/ethnies'),
                ),
                _CategoryCard(
                  title: 'Présidents',
                  icon: Icons.history_edu,
                  color: AppColors.sahelGold,
                  onTap: () => context.push('/presidents'),
                ),
                _CategoryCard(
                  title: 'Quiz Culturel',
                  icon: Icons.quiz,
                  color: AppColors.accentRed,
                  onTap: () => context.push('/quiz'),
                ),
                _CategoryCard(
                  title: 'Carte Interactive',
                  icon: Icons.explore,
                  color: AppColors.secondaryEmerald,
                  onTap: () => context.push('/carte'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: AppDimensions.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
