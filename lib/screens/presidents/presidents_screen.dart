import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/app_error.dart';
import '../../models/president_model.dart';
import '../../services/president_service.dart';

class PresidentsScreen extends StatefulWidget {
  const PresidentsScreen({super.key});

  @override
  State<PresidentsScreen> createState() => _PresidentsScreenState();
}

class _PresidentsScreenState extends State<PresidentsScreen> {
  final PresidentService _service = PresidentService();
  late Future<List<PresidentModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAllPresidents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Présidents du Mali')),
      body: FutureBuilder<List<PresidentModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader(message: 'Chargement des présidents...');
          }
          if (snapshot.hasError) {
            return AppError(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _future = _service.getAllPresidents()),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(child: Text('Aucun président trouvé'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.sm),
            itemBuilder: (context, index) {
              final p = items[index];
              return ListTile(
                title: Text(p.nomPresident, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(p.periodeMandat),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/presidents/${p.idPresident}'),
              );
            },
          );
        },
      ),
    );
  }
}
