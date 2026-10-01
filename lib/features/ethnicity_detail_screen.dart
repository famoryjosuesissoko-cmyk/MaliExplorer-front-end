import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// Écran de présentation détaillée d'une ethnie et culture du Mali.
class EthnicityDetailScreen extends StatelessWidget {
  const EthnicityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Culture Dogon'),
        backgroundColor: AppColors.primaryForest,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.secondaryEmerald.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: const Center(
                child: Icon(
                  Icons.account_balance,
                  size: 80,
                  color: AppColors.secondaryEmerald,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            const Text(
              'Le Peuple Dogon',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryForest,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Région : Falaise de Bandiagara (Patrimoine Mondial UNESCO)',
              style: TextStyle(
                color: AppColors.sahelGold,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            const Divider(),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'Histoire & Cosmogonie',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'Établi le long des falaises de grès de Bandiagara, le peuple Dogon est mondialement '
              'renommé pour sa cosmogonie d\'une richesse exceptionnelle, son art rituel, '
              'ses maisons en banco aux toits de chaume et ses célèbres danses de masques '
              '(le masque Kanaga et la fête du Dama).',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: AppDimensions.lg),
            const Text(
              'Traditions & Savoir-faire',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.md),
                child: Text(
                  '• Architecture en banco intégrée aux falaises (greniers à mil)\n'
                  '• Culte des ancêtres et société secrète des masques Awa\n'
                  '• Connaissance astronomique séculaire (étoile Sirius / Sigi Tolo)\n'
                  '• Métallurgie et sculpture sur bois sacrée\n'
                  '• La Toguna : maison de palabres des sages du village',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
