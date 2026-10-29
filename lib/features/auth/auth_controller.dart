import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/api_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/badge_progression_service.dart';
import '../../core/services/historique_service.dart';
import '../../models/user_model.dart';
import '../../providers/favoris_provider.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final UserModel? userModel;
  final Map<String, dynamic>? user;

  const AuthState({
    this.isLoading = false,
    this.errorMessage,
    this.userModel,
    this.user,
  });

  bool get isAuthenticated => userModel != null || user != null;

  UserModel? get currentUserModel =>
      userModel ?? (user != null ? UserModel.fromJson(user!) : null);

  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserModel? userModel,
    Map<String, dynamic>? user,
  }) {
    final effectiveUserModel =
        userModel ?? (user != null ? UserModel.fromJson(user) : this.userModel);
    final effectiveUserMap = user ?? effectiveUserModel?.toMap() ?? this.user;

    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      userModel: effectiveUserModel,
      user: effectiveUserMap,
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authServiceProvider), ref);
});

final currentUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).userChanges;
});

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;
  final Ref _ref;
  StreamSubscription<User?>? _authSubscription;

  AuthController(this._authService, this._ref) : super(const AuthState()) {
    _initPersistedSession();

    if (_authService.currentUser != null) {
      syncProfile();
    }
    // Écoute automatique des changements d'état d'authentification Firebase
    _authSubscription = _authService.userChanges.listen((user) {
      if (user == null) {
        if (state.user != null || state.userModel != null) {
          state = const AuthState();
          _purgeUserSessionData();
        }
      } else {
        syncProfile();
      }
    });
  }

  Future<void> _initPersistedSession() async {
    try {
      final persisted = await AuthService.loadPersistedSessionData();
      if (persisted != null && state.user == null) {
        state = state.copyWith(userModel: persisted, user: persisted.toMap());
      }
    } catch (e) {
      debugPrint('[AuthController] Erreur initPersistedSession: $e');
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Purge exhaustive de toutes les données privées en mémoire et en cache local
  void _purgeUserSessionData() {
    try {
      // 1. Purge du cache local et de la liste mémoire des favoris
      _ref.read(favorisNotifierProvider.notifier).purgeLocalCacheAndMemory();

      // 2. Réinitialisation du token d'authentification HTTP backend
      _ref.read(apiServiceProvider).setAuthToken(null);

      // 3. Invalidation et remise à zéro des providers dépendants de la session
      _ref.invalidate(userProgressionProvider);
      _ref.invalidate(userHistoriqueProvider);
      _ref.invalidate(recommandationsProvider);
      _ref.invalidate(currentUserProvider);
      _ref.invalidate(historiqueIsOfflineProvider);
    } catch (e) {
      debugPrint('[AuthController] Erreur lors de la purge de session: $e');
    }
  }

  void updateUserData(Map<String, dynamic> updated) {
    final current = Map<String, dynamic>.from(state.user ?? {});
    current.addAll(updated);
    final model = UserModel.fromJson(current);
    AuthService.persistSessionData(model);
    state = state.copyWith(userModel: model, user: current);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.login(email, password);
      final model = UserModel.fromJson(user);
      await AuthService.persistSessionData(model);
      state = state.copyWith(isLoading: false, userModel: model, user: user);
      return true;
    } catch (e) {
      debugPrint('[AuthController] Erreur login: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _cleanErrorMessage(e.toString()),
      );
      return false;
    }
  }

  /// Connexion avec Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        // Annulé par l'utilisateur
        state = state.copyWith(isLoading: false);
        return false;
      }
      state = state.copyWith(isLoading: false, user: user);
      return true;
    } catch (e) {
      debugPrint('[AuthController] Erreur Google login: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _cleanErrorMessage(e.toString()),
      );
      return false;
    }
  }

  /// Envoie un lien de connexion magique (sans mot de passe) par email
  Future<bool> sendMagicLink(String email) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.sendSignInLinkToEmail(email);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email_link_pending', email.trim());
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      debugPrint('[AuthController] Erreur sendMagicLink: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _cleanErrorMessage(e.toString()),
      );
      return false;
    }
  }

  /// Valide le lien magique reçu par email
  Future<bool> handleEmailLink(String link, [String? explicitEmail]) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = explicitEmail ?? prefs.getString('email_link_pending') ?? '';
      if (savedEmail.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Veuillez saisir votre adresse e-mail pour valider la connexion.',
        );
        return false;
      }
      final user = await _authService.signInWithEmailLink(savedEmail, link);
      if (user != null) {
        await prefs.remove('email_link_pending');
        state = state.copyWith(isLoading: false, user: user);
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Le lien de connexion est invalide ou a expiré.',
      );
      return false;
    } catch (e) {
      debugPrint('[AuthController] Erreur handleEmailLink: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: _cleanErrorMessage(e.toString()),
      );
      return false;
    }
  }

  Future<bool> register({
    required String prenom,
    required String nom,
    required String email,
    required String password,
    required String role,
    String? adresse,
    String? telephone,
    String? photoUrl,
    String? nomOrganisation,
    String? pieceIdentite,
    String? langue,
    int? experience,
    String? description,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.register(
        prenom: prenom,
        nom: nom,
        email: email,
        password: password,
        role: role,
        adresse: adresse,
        telephone: telephone,
        photoUrl: photoUrl,
        nomOrganisation: nomOrganisation,
        pieceIdentite: pieceIdentite,
        langue: langue,
        experience: experience,
        description: description,
      );
      final model = UserModel.fromJson(user);
      await AuthService.persistSessionData(model);
      state = state.copyWith(isLoading: false, userModel: model, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _cleanErrorMessage(e.toString()),
      );
      return false;
    }
  }

  Future<bool> syncProfile() async {
    try {
      final updatedProfile = await _authService.syncProfileWithBackend();
      if (updatedProfile != null) {
        final model = UserModel.fromJson(updatedProfile);
        await AuthService.persistSessionData(model);
        state = state.copyWith(userModel: model, user: updatedProfile);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Déconnexion fiable, synchrone et sécurisée
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
    } finally {
      state = const AuthState();
      _purgeUserSessionData();
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: _cleanErrorMessage(e.toString()));
      return false;
    }
  }

  String _cleanErrorMessage(String message) {
    if (message.contains('user-not-found')) {
      return 'Aucun compte trouvé avec cet e-mail.';
    } else if (message.contains('wrong-password') || message.contains('invalid-credential')) {
      return 'Mot de passe ou identifiant incorrect.';
    } else if (message.contains('email-already-in-use')) {
      return 'Cette adresse e-mail est déjà utilisée.';
    } else if (message.contains('weak-password')) {
      return 'Le mot de passe doit comporter au moins 6 caractères.';
    } else if (message.contains('network-request-failed')) {
      return 'Erreur réseau : vérifiez votre connexion Internet.';
    } else if (message.contains('CONFIGURATION_NOT_FOUND')) {
      return 'Le fournisseur Email/Mot de passe doit être activé dans Firebase Console (Authentication > Sign-in method).';
    }
    return message.replaceAll('Exception: ', '');
  }
}
