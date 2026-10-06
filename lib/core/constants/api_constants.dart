import 'package:flutter/foundation.dart';

/// Constantes pour les requêtes HTTP vers l'API backend Spring Boot.
class ApiConstants {
  ApiConstants._();

  static const Duration timeout = Duration(seconds: 15);

  static const String fallbackLanUrl = 'http://10.117.204.142:8080/api';

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    if (kIsWeb) {
      return 'http://localhost:8080/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      // 127.0.0.1 fonctionne directement pour le téléphone physique connecté en adb reverse
      return 'http://127.0.0.1:8080/api';
    } else {
      return 'http://localhost:8080/api';
    }
  }

  // Endpoints Authentification
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authSync = '/auth/sync';

  // Endpoints Données
  static const String users = '/utilisateurs';
  static const String regions = '/regions';
  static const String villes = '/villes';
  static const String plats = '/plats';
  static const String ethnies = '/ethnies';
  static const String lieux = '/lieux-historiques';
  static const String lieuxHistoriques = '/lieux-historiques';
  static const String presidents = '/presidents';
  static const String articles = '/articles';
  static const String evenements = '/evenements';
  static const String artisans = '/artisans';
  static const String guides = '/guides';
  static const String quiz = '/quiz';
  static const String badges = '/badges';
  static const String progression = '/badges/progression';
  static const String favoris = '/favoris';
  static const String carte = '/carte';
  static const String carteMarqueurs = '/carte/marqueurs';
}
