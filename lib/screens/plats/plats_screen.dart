import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_error.dart';
import '../../core/widgets/app_loader.dart';
import '../../models/plat_model.dart';
import '../../services/plat_service.dart';
import '../../widgets/cards/destination_card.dart';
import '../../widgets/common/empty_view.dart';

class PlatsScreen extends StatefulWidget {
  const PlatsScreen({super.key});

  @override
  State<PlatsScreen> createState() => _PlatsScreenState();
}

class _PlatsScreenState extends State<PlatsScreen> {
  final _platService = PlatService();
  late Future<List<PlatModel>> _platsFuture;

  @override
  void initState() {
    super.initState();
    _loadPlats();
  }

  void _loadPlats() {
    _platsFuture = _platService.getAllPlats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gastronomie Malienne')),
      body: FutureBuilder<List<PlatModel>>(
        future: _platsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader(message: 'Chargement des spécialités culinaires...');
          }
          if (snapshot.hasError) {
            return AppError(
              message: 'Erreur lors du chargement des plats.',
              onRetry: () => setState(() => _loadPlats()),
            );
          }

          final plats = snapshot.data ?? [];
          if (plats.isEmpty) {
            return const EmptyView(title: 'Aucun plat enregistré', icon: Icons.restaurant_menu);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: plats.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.md),
            itemBuilder: (context, index) {
              final plat = plats[index];
              return DestinationCard(
                title: plat.nomPlat,
                subtitle: plat.description ?? plat.ingredients,
                imageUrl: plat.imagePlat,
                onTap: () => context.push('/plats/${plat.idPlat}', extra: plat),
              );
            },
          );
        },
      ),
    );
  }
}
