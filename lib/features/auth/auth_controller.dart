import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';

class AuthState {
  final bool isLoading;
  final String? errorMessage;
  final Map<String, dynamic>? user;

  const AuthState({this.isLoading = false, this.errorMessage, this.user});

  bool get isAuthenticated => user != null;

  AuthState copyWith({bool? isLoading, String? errorMessage, Map<String, dynamic>? user}) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authServiceProvider));
});

final currentUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).userChanges;
});

class AuthController extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AuthState());

  void updateUserData(Map<String, dynamic> updated) {
    final current = Map<String, dynamic>.from(state.user ?? {});
    current.addAll(updated);
    state = state.copyWith(user: current);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = await _authService.login(email, password);
      state = state.copyWith(isLoading: false, user: user);
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
      );
      state = state.copyWith(isLoading: false, user: user);
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
        state = state.copyWith(user: updatedProfile);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
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
