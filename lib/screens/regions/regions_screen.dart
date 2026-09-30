import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_error.dart';
import '../../core/widgets/app_loader.dart';
import '../../models/region_model.dart';
import '../../services/region_service.dart';
import '../../widgets/cards/destination_card.dart';
import '../../widgets/common/empty_view.dart';

class RegionsScreen extends StatefulWidget {
  const RegionsScreen({super.key});

  @override
  State<RegionsScreen> createState() => _RegionsScreenState();
}

class _RegionsScreenState extends State<RegionsScreen> {
  final _regionService = RegionService();
  late Future<List<RegionModel>> _regionsFuture;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  void _loadRegions() {
    _regionsFuture = _regionService.getAllRegions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Régions du Mali')),
      body: FutureBuilder<List<RegionModel>>(
        future: _regionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader(message: 'Chargement des régions...');
          }
          if (snapshot.hasError) {
            return AppError(
              message: 'Erreur lors du chargement des régions.',
              onRetry: () => setState(() => _loadRegions()),
            );
          }

          final regions = snapshot.data ?? [];
          if (regions.isEmpty) {
            return const EmptyView(title: 'Aucune région trouvée', icon: Icons.terrain);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: regions.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.md),
            itemBuilder: (context, index) {
              final region = regions[index];
              return DestinationCard(
                title: region.nomRegion,
                subtitle: region.description ?? 'Superficie : ${region.superficie ?? 'N/A'} km²',
                imageUrl: region.imageRegion,
                onTap: () => context.push('/regions/${region.idRegion}', extra: region),
              );
            },
          );
        },
      ),
    );
  }
}
