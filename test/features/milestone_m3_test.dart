import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mali_explorer_frontend/core/services/api_service.dart';
import 'package:mali_explorer_frontend/core/services/guide_service.dart';
import 'package:mali_explorer_frontend/core/services/historique_service.dart';
import 'package:mali_explorer_frontend/features/gastronomie_list_screen.dart';
import 'package:mali_explorer_frontend/features/guides_screen.dart';
import 'package:mali_explorer_frontend/features/villes_list_screen.dart';
import 'package:mali_explorer_frontend/models/explorer_publication_model.dart';
import 'package:mali_explorer_frontend/models/guide_model.dart';
import 'package:mali_explorer_frontend/models/plat_model.dart';
import 'package:mali_explorer_frontend/models/ville_model.dart';
import 'package:mali_explorer_frontend/providers/guides_provider.dart';
import 'package:mali_explorer_frontend/providers/plats_provider.dart';
import 'package:mali_explorer_frontend/providers/villes_provider.dart';

class MockErrorClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value('Internal Server Error'.codeUnits),
      500,
    );
  }
}

void main() {
  group('M3 Verification Tests — GuideService & GuidesScreen', () {
    test('GuideService throws Exception on non-200 HTTP response', () async {
      final mockApi = ApiService(client: MockErrorClient());
      final service = GuideService(mockApi);

      expect(() => service.getGuides(), throwsA(isA<Exception>()));
    });

    testWidgets('GuidesScreen displays exact official message when no guides exist', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guidesProvider.overrideWith((ref) async => <GuideModel>[]),
            guideSearchQueryProvider.overrideWith((ref) => ''),
          ],
          child: const MaterialApp(
            home: GuidesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text(
          "Aucun guide n'est disponible pour le moment. Les profils des guides apparaîtront ici dès qu'ils seront inscrits, validés et disponibles.",
        ),
        findsOneWidget,
      );
      // Vérifie qu'aucun nom de guide fictif n'existe
      expect(find.text('Oumar Traoré'), findsNothing);
      expect(find.text('Awa Keita'), findsNothing);
    });

    testWidgets('GuidesScreen displays search empty message when search yields no result', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guidesProvider.overrideWith((ref) async => <GuideModel>[]),
            guideSearchQueryProvider.overrideWith((ref) => 'Introuvable'),
          ],
          child: const MaterialApp(
            home: GuidesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('Aucun guide ne correspond à vos critères de recherche'),
        findsOneWidget,
      );
      expect(find.text('Effacer la recherche'), findsOneWidget);
    });

    testWidgets('GuidesScreen displays interactive retry button on error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            guidesProvider.overrideWith((ref) async => throw Exception('Network error')),
          ],
          child: const MaterialApp(
            home: GuidesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Impossible de charger les guides touristiques'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });
  });

  group('M3 Verification Tests — Gastronomie & Villes Dynamic States', () {
    testWidgets('GastronomieListScreen displays empty state when 0 dishes in DB', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            platsProvider.overrideWith((ref) async => <PlatModel>[]),
            platSearchQueryProvider.overrideWith((ref) => ''),
          ],
          child: const MaterialApp(
            home: GastronomieListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Aucun plat traditionnel disponible pour le moment.'), findsOneWidget);
      // Vérifie que les plats fictifs ne sont pas affichés lorsque la base de données est vide
      expect(find.text('Saka-saka'), findsNothing);
      expect(find.text('Fakoye'), findsNothing);
    });

    testWidgets('GastronomieListScreen displays retry button on error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            platsProvider.overrideWith((ref) async => throw Exception('Server error')),
          ],
          child: const MaterialApp(
            home: GastronomieListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Impossible de charger les spécialités gastronomiques'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });

    testWidgets('VillesListScreen displays empty state when 0 cities in DB', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            villesProvider.overrideWith((ref) async => <VilleModel>[]),
            villeSearchQueryProvider.overrideWith((ref) => ''),
          ],
          child: const MaterialApp(
            home: VillesListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Aucune ville disponible pour le moment.'), findsOneWidget);
      expect(find.text('Koulikoro'), findsNothing);
      expect(find.text('Bandiagara'), findsNothing);
    });

    testWidgets('VillesListScreen displays retry button on error', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            villesProvider.overrideWith((ref) async => throw Exception('Server error')),
          ],
          child: const MaterialApp(
            home: VillesListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Impossible de charger les villes et territoires'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });
  });

  group('M3 Verification Tests — Global Mock Elimination & Models', () {
    test('ExplorerPublicationModel initialPublications contains only verified cultural events', () {
      final pubs = ExplorerPublicationModel.initialPublications;
      expect(pubs.isNotEmpty, isTrue);
      for (final pub in pubs) {
        expect(pub.type, equals(PublicationType.festivalEvenement));
        expect(pub.isValide, isTrue);
      }
    });

    test('HistoriqueService throws Exception on non-200 without fallback mock data', () async {
      final mockApi = ApiService(client: MockErrorClient());
      final service = HistoriqueService(mockApi);

      expect(() => service.getMonHistorique(), throwsA(isA<Exception>()));
    });
  });
}
