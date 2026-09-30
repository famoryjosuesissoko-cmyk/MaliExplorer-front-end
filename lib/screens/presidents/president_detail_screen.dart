import 'package:flutter/material.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/app_error.dart';
import '../../models/president_model.dart';
import '../../services/president_service.dart';

class PresidentDetailScreen extends StatefulWidget {
  final int presidentId;
  const PresidentDetailScreen({super.key, required this.presidentId});

  @override
  State<PresidentDetailScreen> createState() => _PresidentDetailScreenState();
}

class _PresidentDetailScreenState extends State<PresidentDetailScreen> {
  final PresidentService _service = PresidentService();
  late Future<PresidentModel> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getPresidentById(widget.presidentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Détail Président')),
      body: FutureBuilder<PresidentModel>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoader();
          }
          if (snapshot.hasError) {
            return AppError(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _future = _service.getPresidentById(widget.presidentId)),
            );
          }
          final p = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.nomPresident, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppDimensions.sm),
                Text('Mandat : ${p.periodeMandat}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppDimensions.md),
                Text(p.biographie ?? '', style: const TextStyle(fontSize: 16, height: 1.5)),
              ],
            ),
          );
        },
      ),
    );
  }
}
