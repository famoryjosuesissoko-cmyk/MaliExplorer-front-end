import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_error.dart';
import '../../core/widgets/app_loader.dart';
import '../../models/lieu_historique_model.dart';
import '../../services/lieu_historique_service.dart';
import '../../widgets/cards/destination_card.dart';
import '../../widgets/common/empty_view.dart';

class LieuxScreen extends StatefulWidget {
  const LieuxScreen({super.key});

  @override
  State<LieuxScreen> createState() => _LieuxScreenState();
}

class _LieuxScreenState extends State<LieuxScreen> {
  final _lieuService = LieuHistoriqueService();
  late Future<List<LieuHistoriqueModel>> _lieuxFuture;
  bool _only360 = false;

  @override
  void initState() {
    super.initState();
    _loadLieux();
  }

  void _loadLieux() {
    _lieuxFuture = _only360 ? _lieuService.getLieuxWith360() : _lieuService.getAllLieux();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lieux Historiques'),
        actions: [
          IconButton(
            icon: Icon(_only360 ? Icons.panorama_photosphere : Icons.panorama_photosphere_outlined),
            tooltip: 'Filtrer avec visite 360°',
            onPressed: () {
              setState(() {
                _only360 = !_only360;
                _loadLieux();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<LieuHistoriqueModel>>(
        future: _lieuxFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader(message: 'Chargement des monuments historiques...');
          }
          if (snapshot.hasError) {
            return AppError(
              message: 'Erreur lors du chargement des lieux historiques.',
              onRetry: () => setState(() => _loadLieux()),
            );
          }

          final lieux = snapshot.data ?? [];
          if (lieux.isEmpty) {
            return const EmptyView(
              title: 'Aucun lieu historique trouvé',
              subtitle: 'Essayez de désactiver le filtre 360°',
              icon: Icons.temple_buddhist,
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: lieux.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.md),
            itemBuilder: (context, index) {
              final lieu = lieux[index];
              return DestinationCard(
                title: lieu.nomLieuHisto,
                subtitle: lieu.epoque != null ? 'Époque : ${lieu.epoque}' : lieu.description,
                trailing: lieu.has360
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.sahelGold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.threesixty, size: 16, color: AppColors.sahelGold),
                            SizedBox(width: 4),
                            Text('360°', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.sahelGold)),
                          ],
                        ),
                      )
                    : null,
                onTap: () => context.push('/lieux/${lieu.idLieu}', extra: lieu),
              );
            },
          );
        },
      ),
    );
  }
}
