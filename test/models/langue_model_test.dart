import 'package:flutter_test/flutter_test.dart';
import 'package:mali_explorer_frontend/models/langue_model.dart';

void main() {
  group('LangueModel & LexiqueItemModel — Tests Unitaires', () {
    test('Désérialisation complète depuis un objet JSON valide', () {
      final json = {
        'id': 1,
        'nom': 'Bamanankan (Bambara)',
        'nomLocal': 'Bamanankan',
        'locuteurs': '~80% de la population',
        'regions': 'Bamako, Ségou, Sikasso',
        'description': 'Langue véhiculaire principale du Mali.',
        'imageUrl': 'https://example.com/bambara.jpg',
        'ordreAffichage': 1,
        'lexique': [
          {
            'mot': 'I ni sogoma',
            'phonetique': 'i-ni-so-go-ma',
            'traduction': 'Bonjour (matin)',
            'categorie': 'Salutations',
          },
          {
            'mot': 'I ni tché',
            'phonetique': 'i-ni-tché',
            'traduction': 'Merci',
            'categorie': 'Courtoisie',
          }
        ]
      };

      final model = LangueModel.fromJson(json);

      expect(model.id, 1);
      expect(model.nom, 'Bamanankan (Bambara)');
      expect(model.nomLocal, 'Bamanankan');
      expect(model.locuteurs, '~80% de la population');
      expect(model.regions, 'Bamako, Ségou, Sikasso');
      expect(model.description, 'Langue véhiculaire principale du Mali.');
      expect(model.imageUrl, 'https://example.com/bambara.jpg');
      expect(model.ordreAffichage, 1);
      expect(model.lexique.length, 2);
      expect(model.lexique[0].mot, 'I ni sogoma');
      expect(model.lexique[0].phonetique, 'i-ni-so-go-ma');
      expect(model.lexique[0].traduction, 'Bonjour (matin)');
      expect(model.lexique[0].categorie, 'Salutations');
    });

    test('Support des alias idLangue, nom_local et ordre', () {
      final json = {
        'idLangue': 42,
        'nom': 'Soninké (Maraka)',
        'nom_local': 'Sooninkanxanne',
        'locuteurs': '~7%',
        'regions': 'Kayes',
        'description': 'Langue de l\'ancien Wagadou.',
        'ordre': 4,
      };

      final model = LangueModel.fromJson(json);

      expect(model.id, 42);
      expect(model.nom, 'Soninké (Maraka)');
      expect(model.nomLocal, 'Sooninkanxanne');
      expect(model.ordreAffichage, 4);
      expect(model.lexique, isEmpty);
      expect(model.imageUrl, isNull);
    });

    test('Décodage souple du lexique fourni sous forme de chaîne JSON sérialisée', () {
      final json = {
        'id': 3,
        'nom': 'Songhaï',
        'nomLocal': 'Songhoy Senni',
        'locuteurs': '~10%',
        'regions': 'Tombouctou, Gao',
        'description': 'Langue de l\'Empire Songhaï.',
        'lexique': '[{"mot":"Fofo","phonetique":"fo-fo","traduction":"Merci","categorie":"Courtoisie"}]',
      };

      final model = LangueModel.fromJson(json);

      expect(model.lexique.length, 1);
      expect(model.lexique.first.mot, 'Fofo');
      expect(model.lexique.first.traduction, 'Merci');
    });

    test('Sérialisation toJson préserve fidèlement les attributs', () {
      const item = LexiqueItemModel(
        mot: 'Jam waali',
        phonetique: 'djam-waa-li',
        traduction: 'Bonjour',
        categorie: 'Salutations',
      );

      const model = LangueModel(
        id: 2,
        nom: 'Fulfulde (Peul)',
        nomLocal: 'Pulaar',
        locuteurs: '~15%',
        regions: 'Mopti',
        description: 'Langue pastorale.',
        imageUrl: 'https://example.com/fulfulde.jpg',
        ordreAffichage: 2,
        lexique: [item],
      );

      final map = model.toJson();

      expect(map['id'], 2);
      expect(map['nom'], 'Fulfulde (Peul)');
      expect(map['nomLocal'], 'Pulaar');
      expect(map['imageUrl'], 'https://example.com/fulfulde.jpg');
      expect(map['lexique'], isA<List>());
      expect((map['lexique'] as List).length, 1);
      expect((map['lexique'] as List).first['mot'], 'Jam waali');
    });
  });
}
