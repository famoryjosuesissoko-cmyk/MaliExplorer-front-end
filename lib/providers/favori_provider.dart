import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/favori_model.dart';
import '../services/favori_service.dart';
import 'auth_provider.dart';

final favoriServiceProvider = Provider<FavoriService>((ref) {
  final apiService = ref.watch(authServiceProvider).apiService;
  return FavoriService(apiService: apiService);
});

final favorisListProvider = FutureProvider<List<FavoriModel>>((ref) async {
  final authState = ref.watch(authProvider);
  if (!authState.isAuthenticated) return [];

  final favoriService = ref.watch(favoriServiceProvider);
  return await favoriService.getMesFavoris();
});

class FavoriNotifier extends StateNotifier<AsyncValue<List<FavoriModel>>> {
  final FavoriService _favoriService;
  final Ref _ref;

  FavoriNotifier(this._favoriService, this._ref) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final list = await _favoriService.getMesFavoris();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> supprimerFavori(int id) async {
    await _favoriService.supprimerFavori(id);
    _ref.invalidate(favorisListProvider);
    await refresh();
  }
}

final favoriNotifierProvider = StateNotifierProvider<FavoriNotifier, AsyncValue<List<FavoriModel>>>((ref) {
  final service = ref.watch(favoriServiceProvider);
  return FavoriNotifier(service, ref);
});
