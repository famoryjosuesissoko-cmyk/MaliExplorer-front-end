import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mali_explorer_frontend/core/services/search_service.dart';
import 'package:mali_explorer_frontend/features/chefs_etat_screen.dart';
import 'package:mali_explorer_frontend/features/ethnie_detail_screen.dart';
import 'package:mali_explorer_frontend/features/ethnies_list_screen.dart';
import 'package:mali_explorer_frontend/features/president_detail_screen.dart';
import 'package:mali_explorer_frontend/models/ethnie_model.dart';
import 'package:mali_explorer_frontend/models/president_model.dart';
import 'package:mali_explorer_frontend/providers/ethnies_provider.dart';
import 'package:mali_explorer_frontend/providers/presidents_provider.dart';
import 'package:mali_explorer_frontend/router/app_router.dart';

void main() {
  group('Milestone M3 — Isolation des données Ethnies (R4 & Features 13-16)', () {
    test('EthnieModel.fromJson does not contaminate custom ethnie with Dogon data', () {
      final customJson = {
        'id': 42,
        'nom': 'Bobo',
        'region': 'Ségou & San',
        'population': '200 000',
        'description': 'Peuple du Mali et du Burkina Faso.',
        'imageUrl': 'https://storage.supabase.co/media/bobo.jpg',
      };

      final ethnie = EthnieModel.fromJson(customJson);

      expect(ethnie.id, 42);
      expect(ethnie.nom, 'Bobo');
      expect(ethnie.region, 'Ségou & San');
      expect(ethnie.description, 'Peuple du Mali et du Burkina Faso.');
      expect(ethnie.imageUrl, 'https://storage.supabase.co/media/bobo.jpg');

      // Doit rester vide ou neutre, jamais Dogon !
      expect(ethnie.titreHomme, isNot(contains('Dogon')));
      expect(ethnie.articleHomme, isNot(contains('Hogon')));
      expect(ethnie.articleHomme, isNot(contains('Sirigé')));
      expect(ethnie.titreFemme, isNot(contains('Dogon')));
      expect(ethnie.articleFemme, isNot(contains('Dogon')));
      expect(ethnie.coutumes, isEmpty);
      expect(ethnie.photoHomme, isNot(contains('dogon_homme')));
      expect(ethnie.photoFemme, isNot(contains('dogon_femme')));
    });

    test('getLocalPhotoHomme and getLocalPhotoFemme return empty string for unknown ethnie', () {
      expect(EthnieModel.getLocalPhotoHomme('Sénoufo'), '');
      expect(EthnieModel.getLocalPhotoFemme('Sénoufo'), '');
      expect(EthnieModel.getLocalPhotoHomme('Bobo'), '');
      expect(EthnieModel.getLocalPhotoFemme('Bobo'), '');
    });

    testWidgets('EthnicityDetailScreen does not show Dogon content for a custom ethnie',
        (WidgetTester tester) async {
      const customEthnie = EthnieModel(
        id: 99,
        nom: 'Sénoufo',
        region: 'Sikasso',
        population: '1.5 million',
        description: 'Artisans du bois et paysans du sud.',
        imageUrl: '',
        photoHomme: '',
        photoFemme: '',
        titreHomme: '',
        articleHomme: '',
        titreFemme: '',
        articleFemme: '',
        coutumes: [],
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: EthnicityDetailScreen(ethnie: customEthnie),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Peuple Sénoufo'), findsOneWidget);
      expect(find.text('Artisans du bois et paysans du sud.'), findsOneWidget);

      // Aucune trace des traditions et coutumes Dogon dans la fiche
      expect(find.textContaining('Falaises de Bandiagara'), findsNothing);
      expect(find.textContaining('Hogon'), findsNothing);
      expect(find.textContaining('Awa'), findsNothing);
      expect(find.textContaining('Sirigé'), findsNothing);
      expect(find.textContaining('Coutumes & Rites Emblématiques'), findsNothing);
    });

    testWidgets('EthniesListScreen displays loading indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ethniesProvider.overrideWith((ref) => Future<List<EthnieModel>>.value(
                  const <EthnieModel>[],
                )),
            filteredEthniesProvider.overrideWithValue(const AsyncValue<List<EthnieModel>>.loading()),
          ],
          child: const MaterialApp(home: EthniesListScreen()),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('EthniesListScreen displays empty state and RefreshIndicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ethniesProvider.overrideWith((ref) => Future.value([])),
          ],
          child: const MaterialApp(home: EthniesListScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Aucune ethnie enregistrée pour le moment.'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('EthniesListScreen displays error state with retry button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ethniesProvider.overrideWith((ref) => Future<List<EthnieModel>>.error('Connexion impossible')),
          ],
          child: const MaterialApp(home: EthniesListScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Erreur de chargement des ethnies'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });
  });

  group('Milestone M3 — Synchronisation dynamique des Présidents (R5 & Features 17-19)', () {
    testWidgets('ChefsEtatScreen displays loading indicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presidentsProvider.overrideWith((ref) => Future.value(<PresidentModel>[])),
            filteredPresidentsProvider.overrideWithValue(const AsyncValue<List<PresidentModel>>.loading()),
          ],
          child: const MaterialApp(home: ChefsEtatScreen()),
        ),
      );
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('ChefsEtatScreen displays empty state and RefreshIndicator',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presidentsProvider.overrideWith((ref) => Future.value([])),
          ],
          child: const MaterialApp(home: ChefsEtatScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Aucun président disponible pour le moment.'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('ChefsEtatScreen displays error state with retry button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presidentsProvider.overrideWith((ref) => Future<List<PresidentModel>>.error('Erreur API')),
          ],
          child: const MaterialApp(home: ChefsEtatScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Erreur de chargement des présidents'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
    });

    testWidgets('ChefsEtatScreen renders custom president dynamically from API',
        (WidgetTester tester) async {
      const dynamicPresident = PresidentModel(
        id: 77,
        prenom: 'Moussa',
        nom: 'Diallo',
        periodeMandat: '2026 - 2031',
        biographie: 'Président élu lors de la transition démocratique moderne.',
        photoUrl: 'https://storage.supabase.co/media/moussa_diallo.jpg',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presidentsProvider.overrideWith((ref) => Future.value([dynamicPresident])),
          ],
          child: const MaterialApp(home: ChefsEtatScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Moussa Diallo'), findsOneWidget);
      expect(find.text('2026 - 2031'), findsOneWidget);
      expect(find.text('Président élu lors de la transition démocratique moderne.'), findsOneWidget);
    });

    testWidgets('PresidentDetailScreen navigates dynamically between API presidents',
        (WidgetTester tester) async {
      const pres1 = PresidentModel(
        id: 101,
        prenom: 'Oumar',
        nom: 'Cissé',
        periodeMandat: '1970 - 1975',
        biographie: 'Premier dirigeant de la ligue républicaine.',
        photoUrl: '',
      );
      const pres2 = PresidentModel(
        id: 102,
        prenom: 'Bakary',
        nom: 'Touré',
        periodeMandat: '1975 - 1980',
        biographie: 'Deuxième dirigeant de la république unie.',
        photoUrl: '',
      );

      final router = GoRouter(
        initialLocation: '/detail',
        routes: [
          GoRoute(
            path: '/detail',
            builder: (context, state) => const PresidentDetailScreen(president: pres1),
          ),
          GoRoute(
            path: AppRouter.presidentDetail,
            builder: (context, state) => PresidentDetailScreen(
              president: state.extra as PresidentModel?,
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presidentsProvider.overrideWith((ref) => Future.value([pres1, pres2])),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Oumar Cissé'), findsOneWidget);
      expect(find.text('1970 - 1975'), findsNWidgets(2));
      expect(find.text('Premier dirigeant de la ligue républicaine.'), findsOneWidget);
      // Le bouton vers le président suivant doit cibler Touré
      expect(find.text('Touré'), findsOneWidget);
    });

    test('SearchService includes dynamic presidents in local fallback search', () async {
      const customPres = PresidentModel(
        id: 88,
        prenom: 'Fatoumata',
        nom: 'Coulibaly',
        periodeMandat: '2028 - 2033',
        biographie: 'Première présidente de la République du Mali.',
        photoUrl: '',
      );

      final container = ProviderContainer(
        overrides: [
          presidentsProvider.overrideWith((ref) => Future.value([customPres])),
        ],
      );

      // S'assurer que le FutureProvider a bien émis sa valeur
      await container.read(presidentsProvider.future);

      final searchService = container.read(searchServiceProvider);
      final results = await searchService.search('Coulibaly');

      expect(results, isNotEmpty);
      final presResult = results.firstWhere((r) => r.titre.contains('Coulibaly'));
      expect(presResult.titre, equals('Fatoumata Coulibaly'));
      expect(presResult.categorie, equals('Chefs d\'État'));
      expect(presResult.route, equals(AppRouter.presidentDetail));
    });
  });
}
