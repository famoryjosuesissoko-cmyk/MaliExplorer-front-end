import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/religion_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

/// Fournisseur Riverpod pour le service d'accès aux religions du Mali
final religionServiceProvider = Provider<ReligionService>((ref) {
  return ReligionService(ref.watch(apiServiceProvider));
});

/// Service HTTP responsable de la récupération et de la synchronisation des religions
class ReligionService {
  final ApiService _apiService;

  ReligionService(this._apiService);

  /// Récupère la liste de toutes les religions publiées depuis le backend Spring Boot.
  /// Si le backend renvoie HTTP 200 avec une liste vide [], retourne impérativement []
  /// sans jamais retomber sur ReligionModel.defaultReligions.
  Future<List<ReligionModel>> getReligions() async {
    final response = await _apiService.get(ApiConstants.religions);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      final List<ReligionModel> list = jsonList
          .whereType<Map<String, dynamic>>()
          .map((j) => ReligionModel.fromJson(j))
          .toList();
      list.sort((a, b) => a.ordre.compareTo(b.ordre));
      return list;
    } else {
      throw Exception(
        'Erreur de chargement des religions (Code ${response.statusCode})',
      );
    }
  }

  /// Récupère la fiche détaillée d'une religion par son identifiant unique.
  Future<ReligionModel?> getReligionById(int id) async {
    final response = await _apiService.get('${ApiConstants.religions}/$id');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );
      return ReligionModel.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Erreur récupération religion #$id (Code ${response.statusCode})',
      );
    }
  }
}
