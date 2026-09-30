import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/article_model.dart';

/// Service pour récupérer et rechercher les articles culturels de MaliExplorer.
class ArticleService {
  final ApiService _apiService;

  ArticleService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<List<ArticleModel>> getAllArticles() async {
    final response = await _apiService.get(ApiConstants.articles);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List list;
      if (decoded is List) {
        list = decoded;
      } else if (decoded is Map && decoded['content'] != null) {
        list = decoded['content'] as List;
      } else {
        list = [];
      }
      return list.map((item) => ArticleModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception('Impossible de charger les articles');
  }

  Future<ArticleModel> getArticleById(int id) async {
    final response = await _apiService.get('${ApiConstants.articles}/$id');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return ArticleModel.fromJson(data);
    }
    throw Exception('Article introuvable');
  }

  Future<List<ArticleModel>> searchArticles(String keyword) async {
    final response = await _apiService.get('${ApiConstants.articles}/recherche', queryParams: {'q': keyword});
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      List list = decoded is List ? decoded : (decoded['content'] as List? ?? []);
      return list.map((item) => ArticleModel.fromJson(item as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
