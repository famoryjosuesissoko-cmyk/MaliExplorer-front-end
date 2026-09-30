
/// Constantes pour les requêtes HTTP vers l'API backend Spring Boot.
class ApiConstants {
  ApiConstants._();

  static const Duration timeout = Duration(seconds: 15);

  /// URL personnalisable en cours d'exécution.
  static String _customBaseUrl = '';

  /// URL de base pour joindre le backend Spring Boot :
  /// - Par défaut : `http://localhost:8080/api` (Fonctionne pour Web et Téléphone USB via `adb reverse tcp:8080 tcp:8080`)
  /// - Wi-Fi direct : `http://192.168.10.255:8080/api`
  /// - Émulateur Android : `http://10.0.2.2:8080/api`
  static String get baseUrl {
    if (_customBaseUrl.isNotEmpty) return _customBaseUrl;
    return 'http://localhost:8080/api';
  }

  static set baseUrl(String url) {
    _customBaseUrl = url.trim();
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
