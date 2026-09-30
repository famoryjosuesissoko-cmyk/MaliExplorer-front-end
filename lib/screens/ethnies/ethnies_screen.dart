import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_error.dart';
import '../../core/widgets/app_loader.dart';
import '../../models/ethnie_model.dart';
import '../../services/ethnie_service.dart';
import '../../widgets/cards/destination_card.dart';
import '../../widgets/common/empty_view.dart';

class EthniesScreen extends StatefulWidget {
  const EthniesScreen({super.key});

  @override
  State<EthniesScreen> createState() => _EthniesScreenState();
}

class _EthniesScreenState extends State<EthniesScreen> {
  final _ethnieService = EthnieService();
  late Future<List<EthnieModel>> _ethniesFuture;

  @override
  void initState() {
    super.initState();
    _loadEthnies();
  }

  void _loadEthnies() {
    _ethniesFuture = _ethnieService.getAllEthnies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ethnies & Traditions')),
      body: FutureBuilder<List<EthnieModel>>(
        future: _ethniesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader(message: 'Chargement des ethnies...');
          }
          if (snapshot.hasError) {
            return AppError(
              message: 'Erreur lors du chargement des ethnies.',
              onRetry: () => setState(() => _loadEthnies()),
            );
          }

          final ethnies = snapshot.data ?? [];
          if (ethnies.isEmpty) {
            return const EmptyView(title: 'Aucune ethnie enregistrée', icon: Icons.people_outline);
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: ethnies.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppDimensions.md),
            itemBuilder: (context, index) {
              final ethnie = ethnies[index];
              return DestinationCard(
                title: ethnie.nomEthnie,
                subtitle: ethnie.langue != null ? 'Langue : ${ethnie.langue}' : ethnie.description,
                imageUrl: ethnie.imageEthnie,
                onTap: () => context.push('/ethnies/${ethnie.idEthnie}', extra: ethnie),
              );
            },
          );
        },
      ),
    );
  }
}
