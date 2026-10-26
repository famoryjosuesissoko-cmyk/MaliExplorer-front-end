import 'package:flutter_test/flutter_test.dart';
import 'package:mali_explorer_frontend/models/region_model.dart';
import 'package:mali_explorer_frontend/models/ville_model.dart';

void main() {
  group('Jalons M4 & M5 — Tests Unitaires & Intégrité Régions et Villes', () {
    test('Les 16 régions administratives sont répertoriées avec des photos authentifiées', () {
      final regions = RegionData.regions;
      expect(regions.length, equals(16));

      // Vérifier que chaque région a un ID, un nom, un chef-lieu et une imageCover non vide
      for (final r in regions) {
        expect(r.id.isNotEmpty, isTrue, reason: 'ID manquant pour ${r.nom}');
        expect(r.nom.isNotEmpty, isTrue, reason: 'Nom manquant pour ${r.id}');
        expect(r.chefLieu.isNotEmpty, isTrue, reason: 'Chef-lieu manquant pour ${r.nom}');
        expect(r.imageCover.isNotEmpty, isTrue, reason: 'Photo manquante pour ${r.nom}');
        expect(r.latitude, isNotNull, reason: 'Latitude manquante pour ${r.nom}');
        expect(r.longitude, isNotNull, reason: 'Longitude manquante pour ${r.nom}');
      }

      // Vérifier la présence des régions clés avec leurs URLs Supabase authentifiées
      final kayes = RegionData.findById('kayes');
      expect(kayes, isNotNull);
      expect(kayes!.imageCover.startsWith('https://'), isTrue);
      expect(kayes.imageCover.contains('supabase.co'), isTrue);

      final koulikoro = RegionData.findById('koulikoro');
      expect(koulikoro, isNotNull);
      expect(koulikoro!.imageCover.startsWith('https://'), isTrue);

      final gao = RegionData.findById('gao');
      expect(gao, isNotNull);
      expect(gao!.imageCover.isNotEmpty, isTrue);

      final bandiagara = RegionData.findById('bandiagara');
      expect(bandiagara, isNotNull);
      expect(bandiagara!.imageCover.startsWith('https://'), isTrue);

      final san = RegionData.findById('san');
      expect(san, isNotNull);
      expect(san!.imageCover.startsWith('https://'), isTrue);
    });

    test('VilleModel désérialise correctement les coordonnées GPS et les images multiples', () {
      final json = {
        'id': 42,
        'nom': 'Djenné',
        'region': 'Mopti',
        'nbreHbt': '32 000',
        'description': 'Joyau de banco millénaire',
        'latitude': 13.9056,
        'longitude': -4.5533,
        'imageUrl': 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/villes/djenne.jpg',
      };

      final ville = VilleModel.fromJson(json);
      expect(ville.id, equals(42));
      expect(ville.nom, equals('Djenné'));
      expect(ville.region, equals('Mopti'));
      expect(ville.latitude, equals(13.9056));
      expect(ville.longitude, equals(-4.5533));
      expect(ville.cordonnees, equals('13.9056, -4.5533'));
      expect(ville.imageUrl.startsWith('https://'), isTrue);

      final serialized = ville.toJson();
      expect(serialized['latitude'], equals(13.9056));
      expect(serialized['longitude'], equals(-4.5533));
      expect(serialized['imageUrl'], equals(ville.imageUrl));
    });

    test('VilleModel extrait automatiquement latitude et longitude depuis une chaîne cordonnees', () {
      final json = {
        'id': 10,
        'nom': 'Koutiala',
        'region': 'Koutiala',
        'cordonnees': '12.3917, -5.4642',
        'imageUrl': 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/villes/koutiala.jpeg',
      };

      final ville = VilleModel.fromJson(json);
      expect(ville.latitude, equals(12.3917));
      expect(ville.longitude, equals(-5.4642));
    });

    test('defaultVilles contient des coordonnées GPS valides pour les villes majeures', () {
      expect(VilleModel.defaultVilles.length, greaterThanOrEqualTo(6));
      for (final v in VilleModel.defaultVilles) {
        expect(v.latitude, isNotNull, reason: 'Latitude manquante pour ${v.nom}');
        expect(v.longitude, isNotNull, reason: 'Longitude manquante pour ${v.nom}');
        expect(v.cordonnees, isNotNull, reason: 'Coordonnées manquantes pour ${v.nom}');
      }
    });
  });
}
