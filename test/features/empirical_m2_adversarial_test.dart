import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mali_explorer_frontend/features/langues_nationales_screen.dart';
import 'package:mali_explorer_frontend/features/infos_pratiques_screen.dart';
import 'package:mali_explorer_frontend/models/langue_model.dart';
import 'package:mali_explorer_frontend/models/info_pratique_model.dart';
import 'package:mali_explorer_frontend/providers/langues_provider.dart';
import 'package:mali_explorer_frontend/providers/infos_pratiques_provider.dart';

void main() {
  group('Milestone 2 Adversarial Stress Suite — Models Robustness', () {
    test('LangueModel handles completely empty JSON and invalid types without crashing', () {
      final emptyJson = <String, dynamic>{};
      final model = LangueModel.fromJson(emptyJson);

      expect(model.id, 0);
      expect(model.nom, '');
      expect(model.nomLocal, '');
      expect(model.locuteurs, '');
      expect(model.regions, '');
      expect(model.description, '');
      expect(model.imageUrl, isNull);
      expect(model.ordreAffichage, 0);
      expect(model.lexique, isEmpty);
    });

    test('LangueModel survives corrupted strings, negative IDs, and malformed lexique JSON', () {
      final dirtyJson = <String, dynamic>{
        'id': 'not-an-int',
        'nom': 'Test Langue',
        'nomLocal': null,
        'locuteurs': 12345, // int instead of String
        'regions': true, // bool instead of String
        'description': null,
        'imageUrl': '   ', // whitespace only
        'ordreAffichage': '99',
        'lexique': '{bad-json-syntax[',
      };

      final model = LangueModel.fromJson(dirtyJson);

      expect(model.id, 0); // fallback from tryParse failure
      expect(model.nom, 'Test Langue');
      expect(model.nomLocal, 'Test'); // fallback from nom.split(' ').first
      expect(model.locuteurs, '12345');
      expect(model.regions, 'true');
      expect(model.description, '');
      expect(model.imageUrl, isNull);
      expect(model.ordreAffichage, 99);
      expect(model.lexique, isEmpty); // bad json caught safely
    });

    test('InfoPratiqueModel handles missing fields, empty strings, and weird data types', () {
      final emptyJson = <String, dynamic>{};
      final model = InfoPratiqueModel.fromJson(emptyJson);

      expect(model.id, 0);
      expect(model.titre, '');
      expect(model.categorie, 'DIVERS');
      expect(model.description, '');
      expect(model.conseils, isNull);
      expect(model.coordonnees, isNull);
      expect(model.imageUrl, isNull);
      expect(model.ordreAffichage, 0);
      expect(model.badge, isNull);
      expect(model.itemsList, isEmpty);
      expect(model.emergencyRows, isEmpty);
      expect(model.defaultIcon, Icons.info_outline_rounded);
      expect(model.displayBadge, 'Info Voyageur');
    });

    test('InfoPratiqueModel emergencyRows handles malformed lines with multiple colons or no colons', () {
      final model = InfoPratiqueModel.fromJson({
        'id': 10,
        'titre': 'Urgences',
        'categorie': 'URGENCES',
        'coordonnees': 'Numéro direct\nPolice: 17: gratuit\nSAMU : 15\n\n   \n',
      });

      final rows = model.emergencyRows;
      expect(rows.length, 3);
      expect(rows[0].key, 'Numéro direct');
      expect(rows[0].value, '');
      expect(rows[1].key, 'Police');
      expect(rows[1].value, '17: gratuit');
      expect(rows[2].key, 'SAMU');
      expect(rows[2].value, '15');
    });
  });

  group('Milestone 2 Adversarial Stress Suite — UI Edge Cases', () {
    testWidgets('LanguesNationalesScreen handles null imageUrl without error and does not render Image', (tester) async {
      const langueWithoutImage = LangueModel(
        id: 1,
        nom: 'Bambara',
        nomLocal: 'Bamanankan',
        locuteurs: '80%',
        regions: 'Mali',
        description: 'Test description',
        imageUrl: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languesProvider.overrideWith((ref) async => [langueWithoutImage]),
          ],
          child: const MaterialApp(home: LanguesNationalesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Bambara'), findsWidgets);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('InfosPratiquesScreen handles null imageUrl without error and does not render Image', (tester) async {
      const infoWithoutImage = InfoPratiqueModel(
        id: 1,
        titre: 'Visa Mali',
        description: 'Formalités administratives',
        categorie: 'VISAS',
        imageUrl: null,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            infosPratiquesProvider.overrideWith((ref) async => [infoWithoutImage]),
          ],
          child: const MaterialApp(home: InfosPratiquesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Visa Mali'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('LanguesNationalesScreen empty state contains proper informative message', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languesProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: LanguesNationalesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Langues Nationales du Mali'), findsOneWidget);
      expect(find.byIcon(Icons.record_voice_over_outlined), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('InfosPratiquesScreen empty state contains proper informative message', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            infosPratiquesProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: InfosPratiquesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Informations Pratiques Voyageurs'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Search query with emojis or special characters does not crash LanguesNationalesScreen', (tester) async {
      const mockLangue = LangueModel(
        id: 1,
        nom: 'Bamanankan',
        nomLocal: 'Bamanankan',
        locuteurs: '80%',
        regions: 'National',
        description: 'Langue nationale',
        lexique: [
          LexiqueItemModel(mot: 'Bonjour', phonetique: '', traduction: 'Hello', categorie: 'Salutations'),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languesProvider.overrideWith((ref) async => [mockLangue]),
          ],
          child: const MaterialApp(home: LanguesNationalesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Enter emoji or special regex characters
      await tester.enterText(find.byType(TextField), r'!@#$%^&*()_+{}[]|:;\"<>,.?/~`🇲🇱✨');
      await tester.pumpAndSettle();

      expect(find.text('Aucune expression trouvée pour cette recherche.'), findsOneWidget);
    });

    testWidgets('Search query with emojis or special characters does not crash InfosPratiquesScreen', (tester) async {
      const mockInfo = InfoPratiqueModel(
        id: 1,
        titre: 'Devises',
        description: 'FCFA',
        categorie: 'DEVISES',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            infosPratiquesProvider.overrideWith((ref) async => [mockInfo]),
          ],
          child: const MaterialApp(home: InfosPratiquesScreen()),
        ),
      );

      await tester.pumpAndSettle();

      // Enter weird characters
      await tester.enterText(find.byType(TextField), r'###$$$&&&***%%%');
      await tester.pumpAndSettle();

      expect(find.text('Aucun résultat pour cette catégorie ou recherche.'), findsOneWidget);
    });
  });
}
