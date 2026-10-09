import 'package:flutter_test/flutter_test.dart';
import 'package:mali_explorer_frontend/models/ethnie_model.dart';

void main() {
  group('EthnieModel R5 Tests - Visual & Ethnic Corrections', () {
    test('Bambara entry uses Bambara2.jpeg for female photo with exact case', () {
      final bambara = EthnieModel.defaultEthnies.firstWhere(
        (e) => e.nom.toLowerCase().contains('bambara'),
      );

      expect(bambara.photoFemme, 'assets/images/ethnies/Bambara2.jpeg');
      expect(bambara.photoHomme, 'assets/images/ethnies/bambara_homme.jpeg');
      expect(bambara.imageUrl, 'assets/images/ethnies/bambara_homme.jpeg');
      expect(bambara.langue, contains('Bamanankan'));
      expect(bambara.region, contains('Ségou'));
      expect(bambara.titreHomme, contains('Bogolan'));
      expect(bambara.titreFemme, contains('Bambara'));
      expect(bambara.coutumes, isNotEmpty);
    });

    test('Malinke entry uses malinke_homme.jpeg and malinke_femme.jpeg', () {
      final malinke = EthnieModel.defaultEthnies.firstWhere(
        (e) => e.nom.toLowerCase().contains('malink'),
      );

      expect(malinke.photoHomme, 'assets/images/ethnies/malinke_homme.jpeg');
      expect(malinke.photoFemme, 'assets/images/ethnies/malinke_femme.jpeg');
      expect(malinke.imageUrl, 'assets/images/ethnies/malinke_homme.jpeg');
      expect(malinke.langue, 'Maninkakan');
      expect(malinke.region, contains('Mandé'));
    });

    test('getLocalPhotoFemme resolves Bambara2.jpeg for Bambara', () {
      expect(
        EthnieModel.getLocalPhotoFemme('Bambara'),
        'assets/images/ethnies/Bambara2.jpeg',
      );
      expect(
        EthnieModel.getLocalPhotoFemme('bambara (bamana)'),
        'assets/images/ethnies/Bambara2.jpeg',
      );
    });

    test('getLocalPhotoHomme resolves malinke_homme.jpeg for Malinke', () {
      expect(
        EthnieModel.getLocalPhotoHomme('Malinké'),
        'assets/images/ethnies/malinke_homme.jpeg',
      );
      expect(
        EthnieModel.getLocalPhotoHomme('mandinka'),
        'assets/images/ethnies/dogon_homme.jpeg', // fallback if non-matching keyword
      );
      expect(
        EthnieModel.getLocalPhotoHomme('malinke'),
        'assets/images/ethnies/malinke_homme.jpeg',
      );
    });

    test('All default ethnies have complete and consistent attributes', () {
      expect(EthnieModel.defaultEthnies.length, 6);

      for (final ethnie in EthnieModel.defaultEthnies) {
        expect(ethnie.nom, isNotEmpty);
        expect(ethnie.region, isNotEmpty);
        expect(ethnie.population, isNotEmpty);
        expect(ethnie.langue, isNotEmpty);
        expect(ethnie.description, isNotEmpty);
        expect(ethnie.photoHomme, startsWith('assets/images/ethnies/'));
        expect(ethnie.photoFemme, startsWith('assets/images/ethnies/'));
        expect(ethnie.titreHomme, isNotEmpty);
        expect(ethnie.articleHomme, isNotEmpty);
        expect(ethnie.titreFemme, isNotEmpty);
        expect(ethnie.articleFemme, isNotEmpty);
        expect(ethnie.coutumes, isNotEmpty);
      }
    });

    test('fromJson falls back to local photos when json photo strings are empty', () {
      final parsed = EthnieModel.fromJson({
        'id': 6,
        'nom': 'Bambara',
        'photoHomme': '',
        'photoFemme': '   ',
      });

      expect(parsed.photoFemme, 'assets/images/ethnies/Bambara2.jpeg');
      expect(parsed.photoHomme, 'assets/images/ethnies/bambara_homme.jpeg');
    });

    test('displayPhoto returns photoHomme when available', () {
      final bambara = EthnieModel.defaultEthnies.firstWhere(
        (e) => e.nom.toLowerCase().contains('bambara'),
      );
      expect(bambara.displayPhoto, 'assets/images/ethnies/bambara_homme.jpeg');
    });
  });
}
