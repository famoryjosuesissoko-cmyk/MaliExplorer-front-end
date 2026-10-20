import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mali_explorer_frontend/features/langues_nationales_screen.dart';
import 'package:mali_explorer_frontend/models/langue_model.dart';
import 'package:mali_explorer_frontend/providers/langues_provider.dart';

void main() {
  group('LanguesNationalesScreen — Tests Widgets & États Dynamiques', () {
    testWidgets('Affiche l\'indicateur de chargement au démarrage', (tester) async {
      final completer = Completer<List<LangueModel>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languesProvider.overrideWith((ref) => completer.future),
          ],
          child: const MaterialApp(
            home: LanguesNationalesScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('Affiche le message officiel dédié lorsque la liste est vide', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languesProvider.overrideWith((ref) async => <LangueModel>[]),
          ],
          child: const MaterialApp(
            home: LanguesNationalesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Langues Nationales du Mali'), findsOneWidget);
      expect(
        find.text(
          'Aucune langue répertoriée dans la base de données pour le moment. Les langues apparaîtront dès qu\'elles seront enregistrées et publiées par l\'administrateur.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.record_voice_over_outlined), findsOneWidget);
    });

    testWidgets('Affiche l\'état d\'erreur avec bouton Réessayer en cas d\'exception', (tester) async {
      int fetchCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languesProvider.overrideWith((ref) async {
              fetchCount++;
              if (fetchCount == 1) {
                throw Exception('Erreur réseau 500');
              }
              return <LangueModel>[
                const LangueModel(
                  id: 1,
                  nom: 'Bamanankan (Bambara)',
                  nomLocal: 'Bamanankan',
                  locuteurs: '~80%',
                  regions: 'Bamako',
                  description: 'Langue nationale.',
                ),
              ];
            }),
          ],
          child: const MaterialApp(
            home: LanguesNationalesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);

      // Clic sur le bouton Réessayer
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();

      expect(fetchCount, 2);
      expect(find.text('Bamanankan (Bambara)'), findsOneWidget);
    });

    testWidgets('Affiche les données réelles et filtre le lexique par recherche', (tester) async {
      const mockLangue = LangueModel(
        id: 1,
        nom: 'Bamanankan (Bambara)',
        nomLocal: 'Bamanankan',
        locuteurs: '~80% de la population',
        regions: 'Bamako, Ségou',
        description: 'Langue véhiculaire majeure.',
        lexique: [
          LexiqueItemModel(
            mot: 'I ni sogoma',
            phonetique: 'i-ni-so-go-ma',
            traduction: 'Bonjour le matin',
            categorie: 'Salutations',
          ),
          LexiqueItemModel(
            mot: 'I ni tché',
            phonetique: 'i-ni-tché',
            traduction: 'Merci',
            categorie: 'Courtoisie',
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            languesProvider.overrideWith((ref) async => [mockLangue]),
          ],
          child: const MaterialApp(
            home: LanguesNationalesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérification des données de la langue
      expect(find.text('Bamanankan (Bambara)'), findsOneWidget);
      expect(find.text('~80% de la population'), findsOneWidget);
      expect(find.text('Régions : Bamako, Ségou'), findsOneWidget);
      expect(find.text('I ni sogoma'), findsOneWidget);
      expect(find.text('I ni tché'), findsOneWidget);

      // Saisie d'une recherche
      await tester.enterText(find.byType(TextField), 'Merci');
      await tester.pumpAndSettle();

      // 'I ni tché' doit rester visible, 'I ni sogoma' doit disparaître
      expect(find.text('I ni tché'), findsOneWidget);
      expect(find.text('I ni sogoma'), findsNothing);

      // Recherche sans résultat
      await tester.enterText(find.byType(TextField), 'IntrouvableXYZ');
      await tester.pumpAndSettle();

      expect(find.text('Aucune expression trouvée pour cette recherche.'), findsOneWidget);
    });
  });
}
