import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../models/plat_model.dart';

class PlatDetailScreen extends StatelessWidget {
  final int platId;
  final PlatModel? initialPlat;

  const PlatDetailScreen({super.key, required this.platId, this.initialPlat});

  @override
  Widget build(BuildContext context) {
    final plat = initialPlat;

    return Scaffold(
      appBar: AppBar(title: Text(plat?.nomPlat ?? 'Détail de la recette')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (plat?.imagePlat != null && plat!.imagePlat!.startsWith('http'))
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: Image.network(plat.imagePlat!, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: AppDimensions.md),
            Text(
              plat?.nomPlat ?? 'Plat #$platId',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
            ),
            if (plat?.regionNom != null) ...[
              const SizedBox(height: 4),
              Text('Origine : Région de ${plat!.regionNom}', style: const TextStyle(color: AppColors.sahelGold, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: AppDimensions.md),
            const Divider(),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'Description & Histoire',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(plat?.description ?? 'Information non disponible.', style: const TextStyle(fontSize: 15, height: 1.5)),
            if (plat?.ingredients != null) ...[
              const SizedBox(height: AppDimensions.lg),
              const Text(
                'Ingrédients traditionnels',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppDimensions.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Text(plat!.ingredients!, style: const TextStyle(fontSize: 14, height: 1.4)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
