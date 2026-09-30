import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/app_error.dart';
import '../../models/evenement_model.dart';
import '../../services/evenement_service.dart';

class EvenementsScreen extends StatefulWidget {
  const EvenementsScreen({super.key});

  @override
  State<EvenementsScreen> createState() => _EvenementsScreenState();
}

class _EvenementsScreenState extends State<EvenementsScreen> {
  final EvenementService _service = EvenementService();
  late Future<List<EvenementModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAllEvenements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Événements Culturels')),
      body: FutureBuilder<List<EvenementModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader(message: 'Chargement des événements...');
          }
          if (snapshot.hasError) {
            return AppError(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _future = _service.getAllEvenements()),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Aucun événement trouvé'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.sm),
            itemBuilder: (context, index) {
              final e = items[index];
              return ListTile(
                title: Text(e.nomEvenement, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(e.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/evenements/${e.idEvenement}'),
              );
            },
          );
        },
      ),
    );
  }
}
