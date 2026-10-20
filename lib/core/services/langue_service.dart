import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/langue_model.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

/// Fournisseur Riverpod pour l'accès au service des langues nationales.
final langueServiceProvider = Provider<LangueService>((ref) {
  return LangueService(ref.watch(apiServiceProvider));
});

/// Service HTTP responsable de la communication avec l'API backend pour les langues nationales.
class LangueService {
  final ApiService _apiService;

  LangueService(this._apiService);

  /// Récupère la liste de toutes les langues nationales publiées depuis le backend Spring Boot.
  Future<List<LangueModel>> getLangues() async {
    final response = await _apiService.get(ApiConstants.langues);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      final List<LangueModel> list = jsonList
          .whereType<Map<String, dynamic>>()
          .map((j) => LangueModel.fromJson(j))
          .toList();
      list.sort((a, b) => a.ordreAffichage.compareTo(b.ordreAffichage));
      return list;
    } else {
      throw Exception('Erreur de chargement des langues nationales (Code ${response.statusCode})');
    }
  }

  /// Récupère le détail d'une langue nationale par son identifiant unique.
  Future<LangueModel?> getLangueById(int id) async {
    final response = await _apiService.get('${ApiConstants.langues}/$id');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return LangueModel.fromJson(data);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception('Erreur lors de la récupération de la langue #$id (Code ${response.statusCode})');
    }
  }
}
