import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import 'api_service.dart';
import 'firebase_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(apiServiceProvider));
});

/// Service gérant la double authentification Firebase Auth + synchronisation Spring Boot
class AuthService {
  final FirebaseAuth _auth = FirebaseService.auth;
  final ApiService _apiService;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '258002604598-oudpvulcb2u6cv5tiq1o96l1tmik2127.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  static String? cachedRole;
  static String? cachedStatutModeration;
  static String? cachedStatut;
  static UserModel? cachedUserModel;

  static const String prefRoleKey = 'user_role';
  static const String prefStatutModerationKey = 'statut_moderation';
  static const String prefStatutKey = 'user_statut';
  static const String prefUserKey = 'cached_user_model';

  static Future<void> persistSessionData(UserModel user) async {
    cachedUserModel = user;
    cachedRole = user.role.name;
    cachedStatutModeration = user.statutModeration;
    cachedStatut = user.statut;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefRoleKey, user.role.name);
      if (user.statutModeration != null && user.statutModeration!.isNotEmpty) {
        await prefs.setString(prefStatutModerationKey, user.statutModeration!);
      } else {
        await prefs.remove(prefStatutModerationKey);
      }
      if (user.statut != null && user.statut!.isNotEmpty) {
        await prefs.setString(prefStatutKey, user.statut!);
      } else {
        await prefs.remove(prefStatutKey);
      }
      await prefs.setString(prefUserKey, jsonEncode(user.toJson()));
    } catch (e) {
      debugPrint('[AuthService] Erreur persistance session: $e');
    }
  }

  static Future<UserModel?> loadPersistedSessionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      cachedRole = prefs.getString(prefRoleKey);
      cachedStatutModeration = prefs.getString(prefStatutModerationKey);
      cachedStatut = prefs.getString(prefStatutKey);
      final rawUser = prefs.getString(prefUserKey);
      if (rawUser != null && rawUser.isNotEmpty) {
        cachedUserModel = UserModel.fromJson(jsonDecode(rawUser) as Map<String, dynamic>);
        return cachedUserModel;
      }
      if (cachedRole != null && cachedRole!.isNotEmpty) {
        cachedUserModel = UserModel(
          email: '',
          role: UserRole.fromString(cachedRole),
          statut: cachedStatut,
          statutModeration: cachedStatutModeration,
        );
        return cachedUserModel;
      }
    } catch (e) {
      debugPrint('[AuthService] Erreur chargement session: $e');
    }
    return cachedUserModel;
  }

  static Future<void> clearPersistedSessionData() async {
    cachedUserModel = null;
    cachedRole = null;
    cachedStatutModeration = null;
    cachedStatut = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(prefRoleKey);
      await prefs.remove(prefStatutModerationKey);
      await prefs.remove(prefStatutKey);
      await prefs.remove(prefUserKey);
    } catch (_) {}
  }

  AuthService([ApiService? apiService])
    : _apiService = apiService ?? ApiService();

  /// Utilisateur actuellement connecté dans Firebase Auth
  User? get currentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  /// Flux réactif des changements d'état d'authentification Firebase
  Stream<User?> get authStateChanges {
    try {
      return _auth.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Flux réactif complet incluant les mises à jour de profil et rechargements
  Stream<User?> get userChanges {
    try {
      return _auth.userChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Récupère le Firebase ID Token actuel ou en génère un nouveau
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final token = await user.getIdToken(forceRefresh);
    if (token != null) {
      _apiService.setAuthToken(token);
    }
    return token;
  }

  /// Connexion par Email et Mot de passe
  /// OBJECTIF 2 : Firebase établit d'abord la session. Spring Boot synchronise ensuite.
  Future<Map<String, dynamic>> login(String email, String password) async {
    // 1. Authentification Firebase
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // 2. Récupération du JWT ID Token
    final idToken = await userCredential.user?.getIdToken();
    if (idToken != null) {
      _apiService.setAuthToken(idToken);
    }

    // 3. Synchronisation avec Spring Boot (ne bloque pas la session Firebase en cas de latence/indisponibilité)
    Map<String, dynamic>? springProfile;
    if (idToken != null) {
      try {
        final response = await _apiService.post(
          '/auth/login',
          body: {'idToken': idToken},
        );
        if (response.statusCode == 200) {
          springProfile = jsonDecode(response.body) as Map<String, dynamic>;
        }
      } catch (_) {
        // En cas d'erreur de communication avec Spring Boot, la session Firebase locale reste active
      }
    }

    if (cachedRole == null) {
      await loadPersistedSessionData();
    }

    final result = springProfile ??
        {
          'email': userCredential.user?.email ?? email,
          'displayName': userCredential.user?.displayName,
          'idToken': idToken,
          'role': cachedRole ?? 'touriste',
          if (cachedStatutModeration != null) 'statutModeration': cachedStatutModeration,
        };
    await persistSessionData(UserModel.fromJson(result));
    return result;
  }

  /// Inscription d'un nouvel utilisateur (Touriste, Guide ou Promoteur)
  /// OBJECTIF 2 : Firebase crée le compte d'abord. Spring Boot persiste ensuite sans bloquer.
  Future<Map<String, dynamic>> register({
    required String prenom,
    required String nom,
    required String email,
    required String password,
    required String role, // 'touriste', 'guide', 'promoteur'
    String? adresse,
    String? telephone,
    String? photoUrl,
    String? nomOrganisation,
    String? pieceIdentite,
    String? langue,
    int? experience,
    String? description,
  }) async {
    // 1. Création du compte dans Firebase Auth
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Mise à jour du nom d'affichage Firebase
    try {
      await userCredential.user?.updateDisplayName('$prenom $nom'.trim());
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await userCredential.user?.updatePhotoURL(photoUrl);
      }
    } catch (_) {}

    // 2. Récupération du token Firebase
    final idToken = await userCredential.user?.getIdToken();
    if (idToken != null) {
      _apiService.setAuthToken(idToken);
    }

    // 3. Persistance dans le backend Spring Boot & base MySQL
    // Note de sécurité : le mot de passe Firebase n'est JAMAIS stocké dans Spring Boot/MySQL
    final body = <String, dynamic>{
      'idToken': idToken,
      'prenom': prenom.trim(),
      'nom': nom.trim(),
      'email': email.trim(),
      'adresse': adresse?.trim() ?? '',
      'telephone': telephone?.trim() ?? '',
      'photoUrl': photoUrl ?? '',
      'role': role.toLowerCase(),
      'nomOrganisation': nomOrganisation?.trim() ?? '',
      'pieceIdentite': pieceIdentite ?? '',
    };
    if (langue != null && langue.trim().isNotEmpty) {
      body['langue'] = langue.trim();
    }
    if (experience != null) {
      body['experience'] = experience;
    }
    if (description != null && description.trim().isNotEmpty) {
      body['description'] = description.trim();
    }

    Map<String, dynamic>? springProfile;
    try {
      final response = await _apiService.post('/auth/register', body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        springProfile = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Si Spring Boot est temporairement injoignable, le compte Firebase existe déjà
    }

    final result = springProfile ??
        <String, dynamic>{
          'email': email,
          'nom': nom,
          'prenom': prenom,
          'role': role,
          'adresse': adresse,
          'photoUrl': photoUrl,
          'nomOrganisation': nomOrganisation,
          'pieceIdentite': pieceIdentite,
        };
    if (springProfile == null) {
      if (langue != null && langue.trim().isNotEmpty) {
        result['langue'] = langue.trim();
      }
      if (experience != null) {
        result['experience'] = experience;
      }
      if (description != null && description.trim().isNotEmpty) {
        result['description'] = description.trim();
      }
    }
    await persistSessionData(UserModel.fromJson(result));
    return result;
  }

  /// Synchronise manuellement le profil avec Spring Boot après reconnexion ou mise à jour
  Future<Map<String, dynamic>?> syncProfileWithBackend() async {
    final token = await getIdToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
    try {
      // 1. Lecture directe depuis MySQL via la route de profil connecté
      final meResponse = await _apiService.get('/utilisateurs/me');
      if (meResponse.statusCode == 200) {
        final profile = jsonDecode(utf8.decode(meResponse.bodyBytes)) as Map<String, dynamic>;
        await persistSessionData(UserModel.fromJson(profile));
        return profile;
      }
    } catch (e) {
      debugPrint('[AuthService] Info sync direct /me: $e');
    }

    // 2. Repli via /auth/login avec idToken Firebase
    try {
      if (token != null) {
        final response = await _apiService.post(
          '/auth/login',
          body: {'idToken': token},
        );
        if (response.statusCode == 200) {
          final profile = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
          await persistSessionData(UserModel.fromJson(profile));
          return profile;
        }
      }
    } catch (_) {}
    return null;
  }

  /// Connexion avec Google (Google Sign-In)
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    // 1. Déclencher le flux d'authentification Google natif
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      // L'utilisateur a fermé ou annulé la boîte de dialogue Google
      return null;
    }

    // 2. Obtenir les jetons d'authentification Google
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 3. Authentifier sur Firebase avec le credential Google
    final UserCredential userCredential = await _auth.signInWithCredential(credential);
    final idToken = await userCredential.user?.getIdToken();
    if (idToken != null) {
      _apiService.setAuthToken(idToken);
    }

    // 4. Synchroniser avec Spring Boot & MySQL
    Map<String, dynamic>? springProfile;
    if (idToken != null) {
      try {
        final response = await _apiService.post(
          '/auth/login',
          body: {'idToken': idToken},
        );
        if (response.statusCode == 200) {
          springProfile = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        }
      } catch (e) {
        debugPrint('[AuthService] Info sync Spring Boot Google login: $e');
      }
    }

    final displayName = userCredential.user?.displayName ?? googleUser.displayName ?? '';
    final nameParts = displayName.isNotEmpty ? displayName.split(' ') : ['Utilisateur', 'Google'];
    final prenom = nameParts.first;
    final nom = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : 'Google';

    return springProfile ??
        {
          'email': userCredential.user?.email ?? googleUser.email,
          'displayName': displayName,
          'prenom': prenom,
          'nom': nom,
          'photoUrl': userCredential.user?.photoURL ?? googleUser.photoUrl,
          'idToken': idToken,
        };
  }

  /// Envoie un lien de connexion sans mot de passe (Magic Link) par e-mail
  Future<void> sendSignInLinkToEmail(String email) async {
    final cleanEmail = email.trim();
    final actionCodeSettings = ActionCodeSettings(
      url: 'https://maliexplorer.firebaseapp.com/finishSignUp?email=$cleanEmail',
      handleCodeInApp: true,
      androidPackageName: 'com.maliexplorer.mali_explorer_frontend',
      androidInstallApp: true,
      androidMinimumVersion: '12',
    );

    await _auth.sendSignInLinkToEmail(
      email: cleanEmail,
      actionCodeSettings: actionCodeSettings,
    );
  }

  /// Valide le lien de connexion reçu par e-mail et connecte l'utilisateur
  Future<Map<String, dynamic>?> signInWithEmailLink(String email, String emailLink) async {
    if (!_auth.isSignInWithEmailLink(emailLink)) {
      throw Exception('Le lien fourni n\'est pas un lien de connexion Firebase valide.');
    }

    final userCredential = await _auth.signInWithEmailLink(
      email: email.trim(),
      emailLink: emailLink.trim(),
    );

    final idToken = await userCredential.user?.getIdToken();
    if (idToken != null) {
      _apiService.setAuthToken(idToken);
    }

    // Synchronisation avec Spring Boot
    Map<String, dynamic>? springProfile;
    if (idToken != null) {
      try {
        final response = await _apiService.post(
          '/auth/login',
          body: {'idToken': idToken},
        );
        if (response.statusCode == 200) {
          springProfile = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        }
      } catch (e) {
        debugPrint('[AuthService] Info sync Spring Boot Email Link: $e');
      }
    }

    return springProfile ??
        {
          'email': userCredential.user?.email ?? email,
          'displayName': userCredential.user?.displayName,
          'idToken': idToken,
        };
  }

  /// Réinitialisation de mot de passe via Firebase Auth
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Déconnexion
  Future<void> logout() async {
    await clearPersistedSessionData();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
    _apiService.setAuthToken(null);
  }
}
