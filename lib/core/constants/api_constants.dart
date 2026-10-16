/// Constantes pour les requêtes HTTP vers l'API backend Spring Boot.
class ApiConstants {
  ApiConstants._();

  static const Duration timeout = Duration(seconds: 15);
  static const Duration quickTimeout = Duration(seconds: 4);

  static List<String> get candidateUrls => [
        'http://127.0.0.1:8080/api',
        'http://localhost:8080/api',
        'http://10.0.2.2:8080/api',
      ];

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return 'http://127.0.0.1:8080/api';
  }

  static String resolveImageUrl(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();
    if (trimmed.startsWith('assets/')) return trimmed;

    // Supabase ou URLs distantes HTTPS externes -> préserver fidèlement
    if (trimmed.startsWith('https://')) return trimmed;

    // Normalisation des URLs locales vers 127.0.0.1:8080 (supporté à 100% par adb reverse sur appareil physique)
    if (trimmed.contains('10.0.2.2:8080')) {
      return trimmed.replaceAll('10.0.2.2:8080', '127.0.0.1:8080');
    }
    if (trimmed.contains('localhost:8080')) {
      return trimmed.replaceAll('localhost:8080', '127.0.0.1:8080');
    }

    if (trimmed.startsWith('http://')) return trimmed;

    // Chemins relatifs (ex: /api/images/..., uploads/images/..., api/images/...)
    if (trimmed.startsWith('/')) {
      return 'http://127.0.0.1:8080$trimmed';
    }
    if (trimmed.startsWith('uploads/')) {
      return 'http://127.0.0.1:8080/api/$trimmed';
    }
    if (trimmed.startsWith('api/')) {
      return 'http://127.0.0.1:8080/$trimmed';
    }

    return trimmed;
  }

  // Points de terminaison d'authentification
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authSync = '/auth/sync';

  // Points de terminaison des données
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
  static const String guides = '/guides';
  static const String quiz = '/quiz';
  static const String badges = '/badges';
  static const String progression = '/badges/progression';
  static const String favoris = '/favoris';
  static const String carte = '/carte';
  static const String carteMarqueurs = '/carte/marqueurs';
  static const String homeSlides = '/home-slides';
  static const String homeVilles = '/villes/home';
  static const String religions = '/religions';
  static const String recherche = '/recherche';
}
