/// Constantes pour les requêtes HTTP vers l'API backend Spring Boot.
class ApiConstants {
  ApiConstants._();

  static const Duration timeout = Duration(seconds: 15);
  static const Duration quickTimeout = Duration(seconds: 4);
  static const Duration probeTimeout = Duration(milliseconds: 1500);

  /// Hôte backend actif résolu dynamiquement (127.0.0.1 via adb reverse ou IP Wi-Fi locale)
  static String _activeHost = 'http://127.0.0.1:8080';

  static String get activeHost => _activeHost;

  /// Met à jour l'hôte actif dès qu'une URL candidate répond avec succès
  static void setActiveBaseUrl(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.endsWith('/api')) {
      _activeHost = trimmed.substring(0, trimmed.length - 4);
    } else if (trimmed.isNotEmpty) {
      _activeHost = trimmed;
    }
  }

  static List<String> get candidateUrls => [
        'http://127.0.0.1:8080/api',
        'http://10.25.143.142:8080/api',
        'http://localhost:8080/api',
        'http://10.0.2.2:8080/api',
      ];

  static String get baseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;
    return '$_activeHost/api';
  }

  static String resolveImageUrl(String? url, {String? version}) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();
    if (trimmed.startsWith('assets/')) return trimmed;

    // Supabase ou URLs distantes HTTPS externes -> préserver fidèlement avec cache-busting optionnel
    if (trimmed.startsWith('https://')) {
      if (version != null && version.isNotEmpty) {
        final sep = trimmed.contains('?') ? '&' : '?';
        return '$trimmed${sep}v=$version';
      }
      return trimmed;
    }

    // Normalisation des URLs locales vers l'hôte actif (127.0.0.1:8080 ou IP LAN Wi-Fi)
    if (trimmed.contains('10.0.2.2:8080')) {
      return trimmed.replaceAll('http://10.0.2.2:8080', _activeHost);
    }
    if (trimmed.contains('localhost:8080')) {
      return trimmed.replaceAll('http://localhost:8080', _activeHost);
    }
    if (trimmed.contains('127.0.0.1:8080') && _activeHost != 'http://127.0.0.1:8080') {
      return trimmed.replaceAll('http://127.0.0.1:8080', _activeHost);
    }

    if (trimmed.startsWith('http://')) {
      if (version != null && version.isNotEmpty) {
        final sep = trimmed.contains('?') ? '&' : '?';
        return '$trimmed${sep}v=$version';
      }
      return trimmed;
    }

    // Chemins relatifs (ex: /api/images/..., uploads/images/..., api/images/...)
    if (trimmed.startsWith('/')) {
      return '$_activeHost$trimmed';
    }
    if (trimmed.startsWith('uploads/')) {
      return '$_activeHost/api/$trimmed';
    }
    if (trimmed.startsWith('api/')) {
      return '$_activeHost/$trimmed';
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
  static const String langues = '/langues';
  static const String infosPratiques = '/infos-pratiques';
}
