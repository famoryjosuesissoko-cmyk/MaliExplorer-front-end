import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_error.dart';
import '../../core/widgets/app_loader.dart';
import '../../models/ville_model.dart';
import '../../services/ville_service.dart';
import '../../widgets/cards/destination_card.dart';
import '../../widgets/common/empty_view.dart';

class VillesScreen extends StatefulWidget {
  const VillesScreen({super.key});

  @override
  State<VillesScreen> createState() => _VillesScreenState();
}

class _VillesScreenState extends State<VillesScreen> {
  final _villeService = VilleService();
  late Future<List<VilleModel>> _villesFuture;

  @override
  void initState() {
    super.initState();
    _loadVilles();
  }

  void _loadVilles() {
    _villesFuture = _villeService.getAllVilles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Villes du Mali')),
      body: FutureBuilder<List<VilleModel>>(
        future: _villesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader(message: 'Chargement des villes...');
          }
          if (snapshot.hasError) {
            return AppError(
              message: 'Erreur lors du chargement des villes.',
              onRetry: () => setState(() => _loadVilles()),
            );
          }

          final villes = snapshot.data ?? [];
          if (villes.isEmpty) {
            return const EmptyView(title: 'Aucune ville trouvée', icon: Icons.location_city);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: villes.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.md),
            itemBuilder: (context, index) {
              final ville = villes[index];
              return DestinationCard(
                title: ville.nomVille,
                subtitle: ville.regionNom != null ? 'Région de ${ville.regionNom}' : ville.description,
                onTap: () => context.push('/villes/${ville.idVille}', extra: ville),
              );
            },
          );
        },
      ),
    );
  }
}
