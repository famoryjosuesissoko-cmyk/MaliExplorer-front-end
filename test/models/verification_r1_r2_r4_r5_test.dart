import 'package:flutter_test/flutter_test.dart';
import 'package:mali_explorer_frontend/models/favori_model.dart';
import 'package:mali_explorer_frontend/models/religion_model.dart';
import 'package:mali_explorer_frontend/core/services/search_service.dart';
import 'package:mali_explorer_frontend/core/services/api_service.dart';
import 'package:mali_explorer_frontend/core/constants/api_constants.dart';
import 'package:mali_explorer_frontend/models/region_model.dart';
import 'package:mali_explorer_frontend/models/plat_model.dart';
import 'package:http/http.dart' as http;

class MockApiService extends ApiService {
  @override
  Future<http.Response> get(String endpoint, {Map<String, dynamic>? queryParams, Map<String, String>? headers}) async {
    // Simuler absence de réseau pour tester le fallback local
    throw Exception('Simulated network error');
  }
}

void main() {
  group('R1 — Verification FavoriModel remote URLs and preservation', () {
    test('displayPhoto prioritizes remote https URL over any local fallback', () {
      const remoteUrl = 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/presidents/new_president_10.jpg';
      final favori = FavoriModel(
        id: 10,
        titre: 'Nouveau Président Test',
        categorie: 'Chef d\'État',
        imageUrl: remoteUrl,
        route: '/presidentDetail',
      );

      expect(favori.displayPhoto, equals(remoteUrl));
      expect(favori.displayPhoto, isNot(contains('modibo_keita.jpeg')));
    });

    test('displayPhoto prioritizes remote http dish URL over local dish fallback', () {
      const remoteUrl = 'http://example.com/images/nouveau_plat_special.jpg';
      final favori = FavoriModel(
        id: 99,
        titre: 'Nouveau Plat Inconnu',
        categorie: 'Plat traditionnel',
        imageUrl: remoteUrl,
        route: '/dishDetail',
      );

      expect(favori.displayPhoto, equals(remoteUrl));
      expect(favori.displayPhoto, isNot(contains('tiguadegue_na.jpeg')));
    });

    test('fromJson preserves remote URL in nested president object', () {
      final json = {
        'id': 15,
        'president': {
          'id': 15,
          'prenom': 'Cheick',
          'nom': 'Modibo',
          'photoUrl': 'https://storage.supabase.com/presidents/cheick.jpg',
        },
      };

      final favori = FavoriModel.fromJson(json);
      expect(favori.imageUrl, equals('https://storage.supabase.com/presidents/cheick.jpg'));
      expect(favori.displayPhoto, equals('https://storage.supabase.com/presidents/cheick.jpg'));
      expect(favori.titre, equals('Cheick Modibo'));
      expect(favori.categorie, equals('Chef d\'État'));
      expect(favori.route, equals('/presidentDetail'));
    });

    test('fromJson preserves remote URL in nested plat object', () {
      final json = {
        'id': 42,
        'plat': {
          'id': 42,
          'nom': 'Plat de Sikasso',
          'imageUrl': 'https://storage.supabase.com/plats/sikasso_special.jpg',
        },
      };

      final favori = FavoriModel.fromJson(json);
      expect(favori.imageUrl, equals('https://storage.supabase.com/plats/sikasso_special.jpg'));
      expect(favori.displayPhoto, equals('https://storage.supabase.com/plats/sikasso_special.jpg'));
      expect(favori.titre, equals('Plat de Sikasso'));
      expect(favori.categorie, equals('Plat traditionnel'));
      expect(favori.route, equals('/dishDetail'));
    });

    test('toJson preserves remote imageUrl for local cache serialization', () {
      const remoteUrl = 'https://supabase.co/media/test.png';
      final favori = FavoriModel(
        id: 7,
        titre: 'Test Favori',
        categorie: 'Culture',
        imageUrl: remoteUrl,
        route: '/test',
      );

      final json = favori.toJson();
      expect(json['imageUrl'], equals(remoteUrl));
      expect(json['titre'], equals('Test Favori'));
      expect(json['id'], equals(7));
    });

    test('displayPhoto correctly falls back to local assets when imageUrl is empty', () {
      final favoriPres = FavoriModel(
        id: 1,
        titre: 'Modibo Keïta',
        categorie: 'Chef d\'État',
        imageUrl: '',
        route: '/presidentDetail',
      );
      expect(favoriPres.displayPhoto, equals('assets/images/presidents/modibo_keita.jpeg'));

      final favoriPlat = FavoriModel(
        id: 2,
        titre: 'Tiguadèguè Na',
        categorie: 'Plat traditionnel',
        imageUrl: '',
        route: '/dishDetail',
      );
      expect(favoriPlat.displayPhoto, equals('assets/images/plats/tiguadegue_na.jpeg'));
    });
  });

  group('R2 — Verification SearchService & AppRouter', () {
    test('normalizeText handles accents, upper-case, hyphens and extra spaces', () {
      expect(SearchService.normalizeText('SÉGOU-KORO  '), equals('segou koro'));
      expect(SearchService.normalizeText('Éthnie Dogon-Bamana'), equals('ethnie dogon bamana'));
      expect(SearchService.normalizeText('Djenné'), equals('djenne'));
      expect(SearchService.normalizeText('Tô & Zaamin'), equals('to & zaamin'));
      expect(SearchService.normalizeText('Çà et là'), equals('ca et la'));
    });

    test('search returns exact dish for sagasaga with dishDetail route', () async {
      final searchService = SearchService(MockApiService());
      final results = await searchService.search('sagasaga');

      expect(results, isNotEmpty);
      final sagaResult = results.firstWhere((r) => r.titre.toLowerCase().contains('saka'));
      expect(sagaResult.categorie, equals('Gastronomie'));
      expect(sagaResult.route, equals('/dish-detail'));
      expect(sagaResult.payload, isA<PlatModel>());
      expect((sagaResult.payload as PlatModel).nom, contains('Sakasaka'));
    });

    test('search for mopti returns Region and City without confusion', () async {
      final searchService = SearchService(MockApiService());
      final results = await searchService.search('mopti');

      expect(results, isNotEmpty);
      final hasRegion = results.any((r) => r.categorie == 'Régions');
      final hasVille = results.any((r) => r.categorie == 'Villes & Patrimoine');
      expect(hasRegion, isTrue);
      expect(hasVille, isTrue);
    });

    test('search for non-existent keyword returns empty list', () async {
      final searchService = SearchService(MockApiService());
      final results = await searchService.search('introuvable_xyz_999');

      expect(results, isEmpty);
    });

    test('RegionData has 16 regions and does not default unknown search to Mopti', () {
      expect(RegionData.regions.length, equals(16));
      final bamako = RegionData.findById('bamako');
      expect(bamako, isNotNull);
      expect(bamako!.nom, contains('Bamako'));
      expect(bamako.nom, isNot(contains('Mopti')));
    });
  });

  group('R4 — Verification ReligionModel DTO aliases & synchronization', () {
    test('fromJson parses Angular Admin payload with all aliases', () {
      final angularJson = {
        'id': 3,
        'nom': 'Christianisme',
        'descriptionHistorique': 'Histoire du christianisme au Mali introduite par les missionnaires.',
        'pourcentageEstime': 2.5,
        'courantsOuBranches': ['Catholicisme', 'Protestantisme'],
        'lieuxEmblematiques': 'Cathédrale de Bamako',
        'pratiquesEtFetes': 'Noël, Pâques, messe dominicale',
        'ordreAffichage': 2,
        'estPublie': true,
        'photoUrl': 'https://supabase.co/christianisme.jpg',
      };

      final model = ReligionModel.fromJson(angularJson);
      expect(model.id, equals(3));
      expect(model.nom, equals('Christianisme'));
      expect(model.description, equals('Histoire du christianisme au Mali introduite par les missionnaires.'));
      expect(model.histoire, equals('Histoire du christianisme au Mali introduite par les missionnaires.'));
      expect(model.proportionPopulation, equals('2.5%'));
      expect(model.branches, equals('Catholicisme\nProtestantisme'));
      expect(model.lieuxDeCulte, equals('Cathédrale de Bamako'));
      expect(model.pratiques, equals('Noël, Pâques, messe dominicale'));
      expect(model.fetes, equals('Noël, Pâques, messe dominicale'));
      expect(model.ordre, equals(2));
      expect(model.publie, isTrue);
      expect(model.imageUrl, equals('https://supabase.co/christianisme.jpg'));
    });

    test('fromJson parses Spring Boot backend payload conventions', () {
      final springJson = {
        'id': 1,
        'nom': 'Islam',
        'description': 'Description islam',
        'histoire': 'Histoire islam',
        'proportionPopulation': '94.8%',
        'branches': 'Sunnite malékite, Soufisme',
        'lieuxDeCulte': 'Grande Mosquée de Djenné',
        'pratiques': 'Prière, Jeûne',
        'fetes': 'Tabaski, Korité',
        'ordre': 1,
        'publie': true,
        'imageUrl': 'assets/images/islam.jpg',
      };

      final model = ReligionModel.fromJson(springJson);
      expect(model.id, equals(1));
      expect(model.nom, equals('Islam'));
      expect(model.description, equals('Description islam'));
      expect(model.histoire, equals('Histoire islam'));
      expect(model.proportionPopulation, equals('94.8%'));
      expect(model.branches, equals('Sunnite malékite, Soufisme'));
      expect(model.lieuxDeCulte, equals('Grande Mosquée de Djenné'));
      expect(model.pratiques, equals('Prière, Jeûne'));
      expect(model.fetes, equals('Tabaski, Korité'));
      expect(model.ordre, equals(1));
      expect(model.publie, isTrue);
      expect(model.imageUrl, equals('assets/images/islam.jpg'));
    });
  });

  group('R5 — Verification ApiConstants resolveImageUrl', () {
    test('handles empty or null gracefully', () {
      expect(ApiConstants.resolveImageUrl(null), equals(''));
      expect(ApiConstants.resolveImageUrl(''), equals(''));
      expect(ApiConstants.resolveImageUrl('   '), equals(''));
    });

    test('preserves local assets', () {
      expect(ApiConstants.resolveImageUrl('assets/images/plats/to.jpeg'), equals('assets/images/plats/to.jpeg'));
    });

    test('preserves remote Supabase and HTTPS URLs', () {
      const url = 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/test.jpg';
      expect(ApiConstants.resolveImageUrl(url), equals(url));
    });
  });
}
