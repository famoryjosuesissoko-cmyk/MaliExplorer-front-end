import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimensions.dart';

/// Écran de présentation détaillée d'un plat traditionnel malien.
class DishDetailScreen extends StatelessWidget {
  const DishDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tiga Diga Na'),
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
                color: AppColors.sahelGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              ),
              child: const Center(
                child: Icon(
                  Icons.soup_kitchen,
                  size: 80,
                  color: AppColors.sahelGold,
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            const Text(
              'Tiga Diga Na (Sauce d\'arachide / Mafé)',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryForest,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Origine : Terroir du Mali / Afrique de l\'Ouest',
              style: TextStyle(
                color: AppColors.sahelGold,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppDimensions.md),
            const Divider(),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'Description & Histoire',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'Le Tiga Diga Na est l\'un des joyaux culinaires les plus emblématiques du Mali. '
              'Préparé à base de pâte d\'arachide grillée, de viande mijotée (bœuf ou mouton) '
              'et de légumes savoureux (gombo, patate douce, carotte), il se déguste '
              'généralement avec du riz blanc brisé ou du tô de mil.',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: AppDimensions.lg),
            const Text(
              'Ingrédients traditionnels',
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
                  '• Pâte d\'arachide pure du Mali (Tiga)\n'
                  '• Viande de bœuf ou mouton fermier\n'
                  '• Tomates fraîches et concentré de tomate\n'
                  '• Oignons, ail, piment frais et gombos\n'
                  '• Patates douces et chou\n'
                  '• Riz du fleuve Niger (Niono)',
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
