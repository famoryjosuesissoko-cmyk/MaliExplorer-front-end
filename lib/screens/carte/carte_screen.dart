import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_error.dart';
import '../../core/widgets/app_loader.dart';
import '../../models/lieu_historique_model.dart';
import '../../services/lieu_historique_service.dart';

class CarteScreen extends StatefulWidget {
  const CarteScreen({super.key});

  @override
  State<CarteScreen> createState() => _CarteScreenState();
}

class _CarteScreenState extends State<CarteScreen> {
  final _lieuService = LieuHistoriqueService();
  late Future<List<LieuHistoriqueModel>> _marqueursFuture;

  @override
  void initState() {
    super.initState();
    _marqueursFuture = _lieuService.getMarqueursCarte();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carte Interactive du Mali')),
      body: FutureBuilder<List<LieuHistoriqueModel>>(
        future: _marqueursFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader(message: 'Chargement des points géographiques...');
          }
          if (snapshot.hasError) {
            return AppError(
              message: 'Erreur lors du chargement des coordonnées GPS.',
              onRetry: () => setState(() {
                _marqueursFuture = _lieuService.getMarqueursCarte();
              }),
            );
          }

          final marqueurs = snapshot.data ?? [];

          return Column(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryForest.withValues(alpha: 0.1),
                  border: const Border(bottom: BorderSide(color: Color(0xFFDDE3E1))),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.map, size: 100, color: AppColors.secondaryEmerald),
                    Positioned(
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryForest,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                        ),
                        child: Text(
                          '${marqueurs.length} points géolocalisés au Mali',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppDimensions.md),
                  itemCount: marqueurs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.sm),
                  itemBuilder: (context, index) {
                    final item = marqueurs[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryForest.withValues(alpha: 0.12),
                          child: Icon(
                            item.has360 ? Icons.panorama_photosphere : Icons.location_on,
                            color: item.has360 ? AppColors.sahelGold : AppColors.primaryForest,
                          ),
                        ),
                        title: Text(item.nomLieuHisto, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          item.latitude != null && item.longitude != null
                              ? 'GPS : ${item.latitude!.toStringAsFixed(4)}, ${item.longitude!.toStringAsFixed(4)}'
                              : 'Coordonnées en cours de relevé',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/lieux/${item.idLieu}', extra: item),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
