import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/app_error.dart';
import '../../models/evenement_model.dart';
import '../../services/evenement_service.dart';

class EvenementDetailScreen extends StatefulWidget {
  final int evenementId;
  const EvenementDetailScreen({super.key, required this.evenementId});

  @override
  State<EvenementDetailScreen> createState() => _EvenementDetailScreenState();
}

class _EvenementDetailScreenState extends State<EvenementDetailScreen> {
  final EvenementService _service = EvenementService();
  late Future<EvenementModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getEvenementById(widget.evenementId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail Événement')),
      body: FutureBuilder<EvenementModel?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader();
          }
          if (snapshot.hasError) {
            return AppError(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _future = _service.getEvenementById(widget.evenementId)),
            );
          }
          final e = snapshot.data;
          if (e == null) return const Center(child: Text("Événement introuvable"));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.nomEvenement, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppDimensions.sm),
                if (e.lieu != null)
                  Text('Lieu : ${e.lieu}', style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: AppDimensions.md),
                Text(e.description ?? '', style: const TextStyle(fontSize: 16, height: 1.5)),
              ],
            ),
          );
        },
      ),
    );
  }
}
