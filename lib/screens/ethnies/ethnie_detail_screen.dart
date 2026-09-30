import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../models/ethnie_model.dart';

class EthnieDetailScreen extends StatelessWidget {
  final int ethnieId;
  final EthnieModel? initialEthnie;

  const EthnieDetailScreen({super.key, required this.ethnieId, this.initialEthnie});

  @override
  Widget build(BuildContext context) {
    final ethnie = initialEthnie;

    return Scaffold(
      appBar: AppBar(title: Text(ethnie?.nomEthnie ?? "Détail de l'ethnie")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ethnie?.imageEthnie != null && ethnie!.imageEthnie!.startsWith('http'))
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: Image.network(ethnie.imageEthnie!, height: 200, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: AppDimensions.md),
            Text(
              ethnie?.nomEthnie ?? 'Ethnie #$ethnieId',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
            ),
            if (ethnie?.langue != null) ...[
              const SizedBox(height: 4),
              Text('Langue parlée : ${ethnie!.langue}', style: const TextStyle(color: AppColors.sahelGold, fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: AppDimensions.md),
            const Divider(),
            const SizedBox(height: AppDimensions.sm),
            const Text('Histoire & Société', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: AppDimensions.sm),
            Text(ethnie?.description ?? 'Information non disponible.', style: const TextStyle(fontSize: 15, height: 1.5)),
            if (ethnie?.tradition != null) ...[
              const SizedBox(height: AppDimensions.lg),
              const Text('Coutumes & Traditions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: AppDimensions.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  child: Text(ethnie!.tradition!, style: const TextStyle(fontSize: 14, height: 1.4)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
