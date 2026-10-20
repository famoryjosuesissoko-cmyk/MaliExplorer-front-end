import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/info_pratique_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

/// Fournisseur Riverpod pour le service des informations pratiques.
final infoPratiqueServiceProvider = Provider<InfoPratiqueService>((ref) {
  return InfoPratiqueService(ref.watch(apiServiceProvider));
});

/// Service HTTP responsable de la communication avec l'API backend pour les informations pratiques.
class InfoPratiqueService {
  final ApiService _apiService;

  InfoPratiqueService(this._apiService);

  /// Récupère la liste ordonnée des informations pratiques destinées aux voyageurs.
  Future<List<InfoPratiqueModel>> getInfosPratiques() async {
    final response = await _apiService.get(ApiConstants.infosPratiques);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      final List<InfoPratiqueModel> list = jsonList
          .whereType<Map<String, dynamic>>()
          .map((j) => InfoPratiqueModel.fromJson(j))
          .toList();
      list.sort((a, b) => a.ordreAffichage.compareTo(b.ordreAffichage));
      return list;
    } else {
      throw Exception('Erreur de chargement des informations pratiques (Code ${response.statusCode})');
    }
  }

  /// Récupère une fiche pratique par son identifiant unique.
  Future<InfoPratiqueModel?> getInfoPratiqueById(int id) async {
    final response = await _apiService.get('${ApiConstants.infosPratiques}/$id');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return InfoPratiqueModel.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Erreur récupération info pratique #$id (Code ${response.statusCode})');
    }
  }
}
