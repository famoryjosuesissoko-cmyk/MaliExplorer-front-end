import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

  AuthService([ApiService? apiService])
    : _apiService = apiService ?? ApiService();

  /// Utilisateur actuellement connecté dans Firebase Auth
  User? get currentUser => _auth.currentUser;

  /// Flux réactif des changements d'état d'authentification Firebase
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Flux réactif complet incluant les mises à jour de profil et rechargements
  Stream<User?> get userChanges => _auth.userChanges();

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

    return springProfile ??
        {
          'email': userCredential.user?.email ?? email,
          'displayName': userCredential.user?.displayName,
          'idToken': idToken,
        };
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
    final body = {
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

    Map<String, dynamic>? springProfile;
    try {
      final response = await _apiService.post('/auth/register', body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        springProfile = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Si Spring Boot est temporairement injoignable, le compte Firebase existe déjà
    }

    return springProfile ??
        {
          'email': email,
          'nom': nom,
          'prenom': prenom,
          'role': role,
          'adresse': adresse,
          'photoUrl': photoUrl,
          'nomOrganisation': nomOrganisation,
          'pieceIdentite': pieceIdentite,
        };
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
        return jsonDecode(utf8.decode(meResponse.bodyBytes)) as Map<String, dynamic>;
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
          return jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
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
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
    _apiService.setAuthToken(null);
  }
}
