import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mali_explorer_frontend/features/infos_pratiques_screen.dart';
import 'package:mali_explorer_frontend/models/info_pratique_model.dart';
import 'package:mali_explorer_frontend/providers/infos_pratiques_provider.dart';

void main() {
  group('InfosPratiquesScreen — Tests Widgets, Onglets Fixes & États', () {
    testWidgets('Affiche l\'indicateur de chargement au démarrage', (tester) async {
      final completer = Completer<List<InfoPratiqueModel>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            infosPratiquesProvider.overrideWith((ref) => completer.future),
          ],
          child: const MaterialApp(
            home: InfosPratiquesScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('Affiche l\'état vide officiel dédié si aucune information n\'est enregistrée', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            infosPratiquesProvider.overrideWith((ref) async => <InfoPratiqueModel>[]),
          ],
          child: const MaterialApp(
            home: InfosPratiquesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Informations Pratiques Voyageurs'), findsOneWidget);
      expect(
        find.text(
          'Aucune information pratique répertoriée pour le moment. Les guides essentiels apparaîtront dès qu\'ils seront renseignés et publiés par l\'administration.',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('Affiche l\'état d\'erreur avec bouton Réessayer en cas de panne réseau', (tester) async {
      int callCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            infosPratiquesProvider.overrideWith((ref) async {
              callCount++;
              if (callCount == 1) {
                throw Exception('Erreur serveur HTTP 500');
              }
              return <InfoPratiqueModel>[
                const InfoPratiqueModel(
                  id: 1,
                  titre: 'Formalités Visas',
                  description: 'Passeport valide 6 mois.',
                  categorie: 'VISAS',
                ),
              ];
            }),
          ],
          child: const MaterialApp(
            home: InfosPratiquesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Erreur de chargement'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);

      // Clic sur Réessayer
      await tester.tap(find.text('Réessayer'));
      await tester.pumpAndSettle();

      expect(callCount, 2);
      expect(find.text('Formalités Visas'), findsOneWidget);
    });

    testWidgets('Préserve les onglets fixes (Visas, Santé, Devises, Climat, Urgences) et filtre le contenu', (tester) async {
      final mockData = [
        const InfoPratiqueModel(
          id: 1,
          titre: '1. Visas & Formalités',
          description: 'Passeport valide 6 mois.',
          categorie: 'VISAS',
          conseils: 'Passeport valide au moins 6 mois.',
        ),
        const InfoPratiqueModel(
          id: 2,
          titre: '2. Santé & Vaccinations',
          description: 'Vaccination fièvre jaune.',
          categorie: 'SANTE',
          conseils: 'Fièvre jaune obligatoire.',
        ),
        const InfoPratiqueModel(
          id: 5,
          titre: 'Numéros d\'Urgence au Mali',
          description: 'Numéros d\'urgence 24/7',
          categorie: 'URGENCES',
          coordonnees: 'Police Secours: 17\nSapeurs-Pompiers: 18',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            infosPratiquesProvider.overrideWith((ref) async => mockData),
          ],
          child: const MaterialApp(
            home: InfosPratiquesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérification de la présence des onglets fixes officiels
      expect(find.text('Tous'), findsOneWidget);
      expect(find.text('Visas'), findsOneWidget);
      expect(find.text('Santé'), findsOneWidget);
      expect(find.text('Devises'), findsOneWidget);
      expect(find.text('Climat'), findsOneWidget);
      expect(find.text('Urgences'), findsOneWidget);

      // En mode "Tous", les trois sections doivent être visibles
      expect(find.text('1. Visas & Formalités'), findsOneWidget);
      expect(find.text('2. Santé & Vaccinations'), findsOneWidget);
      expect(find.text('Numéros d\'Urgence au Mali'), findsOneWidget);

      // Clic sur l'onglet Visas
      await tester.tap(find.text('Visas'));
      await tester.pumpAndSettle();

      // Seule la section Visas doit être affichée
      expect(find.text('1. Visas & Formalités'), findsOneWidget);
      expect(find.text('2. Santé & Vaccinations'), findsNothing);
      expect(find.text('Numéros d\'Urgence au Mali'), findsNothing);

      // Clic sur l'onglet Urgences
      await tester.tap(find.text('Urgences'));
      await tester.pumpAndSettle();

      // La section urgence doit afficher les numéros
      expect(find.text('Numéros d\'Urgence au Mali'), findsOneWidget);
      expect(find.text('Police Secours'), findsOneWidget);
      expect(find.text('17'), findsOneWidget);
      expect(find.text('Sapeurs-Pompiers'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('1. Visas & Formalités'), findsNothing);
    });
  });
}
