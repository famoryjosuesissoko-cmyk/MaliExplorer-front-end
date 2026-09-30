import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../models/ville_model.dart';

class VilleDetailScreen extends StatelessWidget {
  final int villeId;
  final VilleModel? initialVille;

  const VilleDetailScreen({super.key, required this.villeId, this.initialVille});

  @override
  Widget build(BuildContext context) {
    final ville = initialVille;

    return Scaffold(
      appBar: AppBar(title: Text(ville?.nomVille ?? 'Détail de la ville')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ville?.nomVille ?? 'Ville #$villeId',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
            ),
            if (ville?.regionNom != null) ...[
              const SizedBox(height: 4),
              Text('Région de ${ville!.regionNom}', style: const TextStyle(fontSize: 16, color: AppColors.sahelGold, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: AppDimensions.md),
            const Divider(),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'À propos de cette ville',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              ville?.description ?? 'Aucune information disponible.',
              style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textPrimary),
            ),
            if (ville?.latitude != null && ville?.longitude != null) ...[
              const SizedBox(height: AppDimensions.lg),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: AppColors.primaryForest),
                  title: const Text('Coordonnées GPS'),
                  subtitle: Text('Lat: ${ville!.latitude}, Long: ${ville.longitude}'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
