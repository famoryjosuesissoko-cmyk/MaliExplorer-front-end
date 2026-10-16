import 'package:flutter_test/flutter_test.dart';
import 'package:mali_explorer_frontend/models/ville_model.dart';
import 'package:mali_explorer_frontend/models/plat_model.dart';
import 'package:mali_explorer_frontend/models/ethnie_model.dart';
import 'package:mali_explorer_frontend/models/president_model.dart';

void main() {
  group('Audit & Synchronisation Modèles Flutter <-> Admin <-> Backend', () {
    test('VilleModel priorise les URLs distantes uploadées depuis l\'Admin', () {
      final json = {
        'id': 10,
        'nom': 'Bamako',
        'region': 'District de Bamako',
        'description': 'Capitale du Mali',
        'imageUrl': 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/villes/bamako_new.jpg',
      };

      final ville = VilleModel.fromJson(json);
      expect(ville.imageUrl, contains('supabase.co'));
      expect(ville.displayPhoto, contains('supabase.co'));
    });

    test('PlatModel priorise les URLs distantes uploadées depuis l\'Admin', () {
      final json = {
        'id': 5,
        'nom': 'Tiguadèguè Na',
        'description': 'Sauce arachide traditionnelle',
        'imageUrl': 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/plats/tiga_updated.jpg',
        'difficulte': 'Facile',
      };

      final plat = PlatModel.fromJson(json);
      expect(plat.imageUrl, contains('tiga_updated.jpg'));
      expect(plat.displayPhoto, contains('tiga_updated.jpg'));
      expect(plat.difficulte, equals('Facile'));
    });

    test('EthnieModel préserve imageUrl et photoHomme distantes', () {
      final json = {
        'id': 1,
        'nom': 'Bambara',
        'imageUrl': 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/ethnies/bambara_remote.jpg',
        'photoHomme': 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/ethnies/bambara_remote.jpg',
      };

      final ethnie = EthnieModel.fromJson(json);
      expect(ethnie.imageUrl, contains('bambara_remote.jpg'));
      expect(ethnie.displayPhoto, contains('bambara_remote.jpg'));
    });

    test('PresidentModel displayPhoto retourne l\'URL distante sans forcer l\'asset local', () {
      final json = {
        'id': 1,
        'prenom': 'Modibo',
        'nom': 'Keïta',
        'periodeMandat': '1960 - 1968',
        'biographie': 'Premier président du Mali indépendant',
        'photoUrl': 'https://dzhqwkpwaljqsjwoqvso.supabase.co/storage/v1/object/public/maliexplorer-media/presidents/modibo_hd.jpg',
      };

      final president = PresidentModel.fromJson(json);
      expect(president.photoUrl, contains('modibo_hd.jpg'));
      expect(president.displayPhoto, contains('modibo_hd.jpg'));
    });
  });
}

