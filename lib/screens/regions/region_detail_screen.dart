import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../models/region_model.dart';

class RegionDetailScreen extends StatelessWidget {
  final int regionId;
  final RegionModel? initialRegion;

  const RegionDetailScreen({super.key, required this.regionId, this.initialRegion});

  @override
  Widget build(BuildContext context) {
    final region = initialRegion;

    return Scaffold(
      appBar: AppBar(title: Text(region?.nomRegion ?? 'Détail de la région')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (region?.imageRegion != null && region!.imageRegion!.startsWith('http'))
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: Image.network(
                  region.imageRegion!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: AppDimensions.md),
            Text(
              region?.nomRegion ?? 'Région #$regionId',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
            ),
            const SizedBox(height: AppDimensions.sm),
            if (region?.population != null)
              Text('Population : ${region!.population} habitants', style: const TextStyle(color: AppColors.textSecondary)),
            if (region?.superficie != null)
              Text('Superficie : ${region!.superficie} km²', style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: AppDimensions.md),
            const Divider(),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'Présentation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              region?.description ?? 'Aucune description disponible pour le moment.',
              style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
