import 'dart:convert';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/user_model.dart';

/// Service pour récupérer et mettre à jour les profils utilisateurs.
class UserService {
  final ApiService _apiService;

  UserService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await _apiService.get('${ApiConstants.users}/me');
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }
    } catch (_) {}
    return null;
  }

  Future<UserModel> getUserById(int id) async {
    final response = await _apiService.get('${ApiConstants.users}/$id');
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    }
    throw Exception('Impossible de récupérer l\'utilisateur ID $id');
  }

  Future<UserModel> updateProfile(int id, Map<String, dynamic> updates) async {
    final response = await _apiService.put('${ApiConstants.users}/$id', body: updates);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return UserModel.fromJson(data);
    }
    throw Exception('Échec de la mise à jour du profil');
  }
}
