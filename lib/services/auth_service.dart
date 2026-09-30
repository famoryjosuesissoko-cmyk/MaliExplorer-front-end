import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/user_model.dart';

/// Service d'authentification coordonnant Firebase Auth et le backend Spring Boot.
class AuthService {
  final FirebaseAuth _firebaseAuth;
  final ApiService _apiService;

  AuthService({
    FirebaseAuth? firebaseAuth,
    ApiService? apiService,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _apiService = apiService ?? ApiService();

  ApiService get apiService => _apiService;

  /// Connexion : Firebase valide le mot de passe, puis transmet l'ID Token au backend Spring Boot
  Future<UserModel> login({required String email, required String password}) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Utilisateur Firebase introuvable');
      }

      final idToken = await firebaseUser.getIdToken();
      if (idToken == null) {
        throw Exception('Impossible d\'obtenir le token Firebase');
      }

      // Envoi du token chiffré à Spring Boot
      final response = await _apiService.post(
        ApiConstants.authLogin,
        body: {'idToken': idToken},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        _apiService.setAuthToken(idToken);
        return UserModel.fromJson(data);
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(error['message'] ?? 'Erreur lors de la synchronisation serveur');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  /// Inscription : Compte créé sur Firebase, données métier enregistrées dans MySQL via Spring Boot
  Future<UserModel> register({
    required String prenom,
    required String nom,
    required String email,
    required String password,
    UserRole role = UserRole.touriste,
    String? adresse,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Échec de création du compte Firebase');
      }

      await firebaseUser.updateDisplayName('$prenom $nom'.trim());
      final idToken = await firebaseUser.getIdToken();

      // Enregistrement sécurisé côté backend Spring Boot
      final response = await _apiService.post(
        ApiConstants.authRegister,
        body: {
          'idToken': idToken,
          'prenom': prenom.trim(),
          'nom': nom.trim(),
          'email': email.trim(),
          'role': role.name,
          'adresse': adresse?.trim(),
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        _apiService.setAuthToken(idToken);
        return UserModel.fromJson(data);
      } else {
        final error = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(error['message'] ?? 'Erreur lors de l\'enregistrement serveur');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  /// Récupère la session courante au lancement
  Future<UserModel?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    try {
      final idToken = await firebaseUser.getIdToken();
      if (idToken == null) return null;

      _apiService.setAuthToken(idToken);

      final response = await _apiService.post(
        ApiConstants.authLogin,
        body: {'idToken': idToken},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Réinitialisation de mot de passe via Firebase
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapFirebaseError(e));
    }
  }

  /// Déconnexion
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _apiService.setAuthToken(null);
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun compte associé à cette adresse email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée.';
      case 'weak-password':
        return 'Le mot de passe doit comporter au moins 6 caractères.';
      case 'invalid-email':
        return 'Format d\'adresse email invalide.';
      default:
        return e.message ?? 'Erreur d\'authentification.';
    }
  }
}
