import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mali_explorer_frontend/features/religion_detail_screen.dart';
import 'package:mali_explorer_frontend/features/religions_list_screen.dart';
import 'package:mali_explorer_frontend/models/religion_model.dart';
import 'package:mali_explorer_frontend/providers/home_extended_providers.dart';

void main() {
  group('Religions Section — Jalon M3 Tests & Fallback Reliability', () {
    testWidgets('ReligionsListScreen affiche l\'état vide officiel lorsque la liste est vide', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            religionsProvider.overrideWith((ref) async => <ReligionModel>[]),
          ],
          child: const MaterialApp(
            home: ReligionsListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifie l'état vide officiel
      expect(
        find.text('Aucune religion répertoriée pour le moment'),
        findsOneWidget,
      );
      expect(
        find.textContaining(
          'Les données sur les religions et spiritualités du Mali',
          skipOffstage: false,
        ),
        findsOneWidget,
      );
      expect(find.text('Actualiser', skipOffstage: false), findsOneWidget);
    });

    testWidgets('ReligionsListScreen affiche l\'état vide de recherche en cas d\'absence de correspondance', (tester) async {
      final sample = ReligionModel(
        id: 1,
        nom: 'Islam',
        description: 'Religion majoritaire de paix et de concorde.',
        histoire: 'Introduit au IXe siècle.',
        pratiques: 'Prières quotidiennes, jeûne du Ramadan, aumône.',
        fetes: 'Tabaski (Aïd el-Kébir), Korité, Maouloud.',
        lieuxDeCulte: 'Grande Mosquée de Djenné, Mosquée de Sankoré.',
        regionsConcernees: 'Toutes les régions du Mali.',
        proportionPopulation: '94.8%',
        nombrePratiquantsEstime: '21 000 000',
        sourceStatistiques: 'RGPH-5',
        anneeStatistiques: '2022',
        methodologieStatistiques: 'Recensement',
        imageUrl: 'assets/images/islam.jpg',
        ordre: 1,
        publie: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            religionsProvider.overrideWith((ref) async => [sample]),
          ],
          child: const MaterialApp(
            home: ReligionsListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifie la présence de l'Islam
      expect(find.text('Islam'), findsOneWidget);

      // Saisie d'une recherche inexistante
      await tester.enterText(find.byType(TextField), 'Bouddhisme');
      await tester.pumpAndSettle();

      expect(find.text('Aucun résultat correspondant'), findsOneWidget);
      expect(find.text('Effacer la recherche'), findsOneWidget);

      // Effacer la recherche
      await tester.tap(find.text('Effacer la recherche'));
      await tester.pumpAndSettle();

      expect(find.text('Islam'), findsOneWidget);
    });

    testWidgets('ReligionDetailScreen affiche fidèlement les sections et l\'icône adaptée', (tester) async {
      final sample = ReligionModel(
        id: 2,
        nom: 'Christianisme',
        description: 'Communauté fraternelle engagée dans le dialogue interreligieux.',
        histoire: 'Présence historique missionnaire et laïque.',
        pratiques: 'Offices dominicaux, sacrements, pèlerinage de Kita.',
        fetes: 'Noël, Pâques, Assomption.',
        lieuxDeCulte: 'Cathédrale du Sacré-Cœur de Bamako, Sanctuaire marial de Kita',
        regionsConcernees: 'Bamako, Kita, Kayes, Ségou, San',
        proportionPopulation: '2.4%',
        nombrePratiquantsEstime: '500 000',
        sourceStatistiques: 'RGPH-5',
        anneeStatistiques: '2022',
        methodologieStatistiques: 'Recensement',
        imageUrl: 'https://supabase.co/christianisme.jpg',
        ordre: 2,
        publie: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReligionDetailScreen(religion: sample),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Christianisme'), findsOneWidget);
      expect(find.text('Édifices & Lieux de culte majeurs'), findsOneWidget);
      expect(find.text('Cathédrale du Sacré-Cœur de Bamako, Sanctuaire marial de Kita'), findsOneWidget);
      // Vérifie la présence de l'icône chrétienne église
      expect(find.byIcon(Icons.church_rounded), findsWidgets);
    });
  });
}
