import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/utils/helpers.dart';
import '../../core/widgets/app_button.dart';
import '../../models/lieu_historique_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favori_provider.dart';

class LieuDetailScreen extends ConsumerStatefulWidget {
  final int lieuId;
  final LieuHistoriqueModel? initialLieu;

  const LieuDetailScreen({super.key, required this.lieuId, this.initialLieu});

  @override
  ConsumerState<LieuDetailScreen> createState() => _LieuDetailScreenState();
}

class _LieuDetailScreenState extends ConsumerState<LieuDetailScreen> {
  bool _isFavori = false;
  bool _loadingFavori = true;

  @override
  void initState() {
    super.initState();
    _checkFavori();
  }

  void _checkFavori() async {
    final favoriService = ref.read(favoriServiceProvider);
    final fav = await favoriService.isLieuFavori(widget.lieuId);
    if (mounted) {
      setState(() {
        _isFavori = fav;
        _loadingFavori = false;
      });
    }
  }

  void _toggleFavori() async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      Helpers.showErrorSnackBar(context, 'Connectez-vous pour ajouter ce lieu à vos favoris.');
      return;
    }

    final favoriService = ref.read(favoriServiceProvider);
    final newState = await favoriService.toggleLieuFavori(widget.lieuId, _isFavori);
    setState(() => _isFavori = newState);
    if (mounted) {
      Helpers.showSuccessSnackBar(
        context,
        _isFavori ? 'Lieu ajouté aux favoris !' : 'Lieu retiré des favoris.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lieu = widget.initialLieu;

    return Scaffold(
      appBar: AppBar(
        title: Text(lieu?.nomLieuHisto ?? 'Détail du lieu'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavori ? Icons.favorite : Icons.favorite_border,
              color: _isFavori ? Colors.red : Colors.white,
            ),
            tooltip: _isFavori ? 'Retirer des favoris' : 'Ajouter aux favoris',
            onPressed: _loadingFavori ? null : _toggleFavori,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lieu?.nomLieuHisto ?? 'Monument # \${widget.lieuId}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryForest),
            ),
            if (lieu?.villeNom != null) ...[
              const SizedBox(height: 4),
              Text('Ville : \${lieu!.villeNom}', style: const TextStyle(fontSize: 15, color: AppColors.sahelGold, fontWeight: FontWeight.w600)),
            ],
            if (lieu?.epoque != null) ...[
              const SizedBox(height: 2),
              Text('Époque : \${lieu!.epoque}', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            ],
            const SizedBox(height: AppDimensions.md),

            if (lieu?.has360 == true) ...[
              AppButton(
                text: 'Démarrer la visite immersive 360°',
                icon: Icons.threesixty,
                color: AppColors.sahelGold,
                onPressed: () => context.push('/lieux/360', extra: lieu!.panorama360Url),
              ),
              const SizedBox(height: AppDimensions.md),
            ],

            const Divider(),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'Histoire & Signification',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              lieu?.description ?? 'Description en cours de rédaction par nos historiens.',
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            if (lieu?.latitude != null && lieu?.longitude != null) ...[
              const SizedBox(height: AppDimensions.lg),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: AppColors.primaryForest),
                  title: const Text('Localisation géographique'),
                  subtitle: Text('Latitude : \${lieu!.latitude}, Longitude : \${lieu.longitude}'),
                  trailing: const Icon(Icons.map, color: AppColors.primaryForest),
                  onTap: () => context.push('/carte'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
