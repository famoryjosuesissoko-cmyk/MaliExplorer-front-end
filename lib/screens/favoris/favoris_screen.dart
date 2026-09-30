import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/widgets/app_loader.dart';
import '../../core/widgets/app_error.dart';
import '../../providers/favori_provider.dart';

class FavorisScreen extends ConsumerWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorisAsync = ref.watch(favorisListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Favoris')),
      body: favorisAsync.when(
        data: (favoris) {
          if (favoris.isEmpty) {
            return const Center(child: Text('Aucun favori enregistré'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppDimensions.md),
            itemCount: favoris.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppDimensions.sm),
            itemBuilder: (context, index) {
              final f = favoris[index];
              return ListTile(
                title: Text(f.titre ?? 'Favori', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(f.typeElement ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    if (f.id != null) {
                      ref.read(favoriNotifierProvider.notifier).supprimerFavori(f.id!);
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const AppLoader(message: 'Chargement des favoris...'),
        error: (err, _) => AppError(
          message: err.toString(),
          onRetry: () => ref.refresh(favorisListProvider),
        ),
      ),
    );
  }
}
