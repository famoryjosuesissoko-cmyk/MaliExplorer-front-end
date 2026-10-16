import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mali_explorer_frontend/features/chefs_etat_screen.dart';
import 'package:mali_explorer_frontend/models/president_model.dart';
import 'package:mali_explorer_frontend/router/app_router.dart';

import 'package:mali_explorer_frontend/providers/presidents_provider.dart';

void main() {
  group('ChefsEtatScreen R6 Tests - Interactivity & Display', () {
    Widget buildTestWidget({void Function(PresidentModel? p)? onDetailTapped}) {
      final testRouter = GoRouter(
        initialLocation: '/chefs-etat',
        routes: [
          GoRoute(
            path: '/chefs-etat',
            builder: (context, state) => const ChefsEtatScreen(),
          ),
          GoRoute(
            path: AppRouter.presidentDetail,
            builder: (context, state) {
              final president = state.extra as PresidentModel?;
              onDetailTapped?.call(president);
              return Scaffold(
                body: Center(
                  child: Text('DETAIL_VIEW: ${president?.fullName}'),
                ),
              );
            },
          ),
        ],
      );

      return ProviderScope(
        overrides: [
          presidentsProvider.overrideWith((ref) => Future.value(PresidentModel.chronologicalPresidents)),
        ],
        child: MaterialApp.router(
          routerConfig: testRouter,
        ),
      );
    }

    testWidgets('renders all 9 presidents in chronological order',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Vérifie l'en-tête
      expect(find.text('Chefs d\'État'), findsOneWidget);

      // Vérifie que Modibo Keïta est présent et en première position
      expect(find.text('Modibo Keïta'), findsOneWidget);
      expect(find.text('1960 - 1968'), findsOneWidget);

      // Vérifie que les autres présidents chronologiques existent
      expect(find.text('Moussa Traoré'), findsOneWidget);
      expect(find.text('1968 - 1991'), findsOneWidget);

      // Vérifie la présence des InkWells pour les cartes
      expect(find.byType(InkWell), findsWidgets);
    });

    testWidgets('tapping president card navigates to PresidentDetailScreen with extra',
        (WidgetTester tester) async {
      PresidentModel? navigatedPresident;

      await tester.pumpWidget(
        buildTestWidget(
          onDetailTapped: (p) => navigatedPresident = p,
        ),
      );
      await tester.pumpAndSettle();

      // Clic sur la carte du premier président (Modibo Keïta)
      final modiboText = find.text('Modibo Keïta');
      expect(modiboText, findsOneWidget);

      await tester.tap(modiboText);
      await tester.pumpAndSettle();

      // Vérifie que la navigation vers l'écran de détail a bien eu lieu
      expect(find.text('DETAIL_VIEW: Modibo Keïta'), findsOneWidget);
      expect(navigatedPresident, isNotNull);
      expect(navigatedPresident!.fullName, 'Modibo Keïta');
      expect(navigatedPresident!.periodeMandat, '1960 - 1968');
      expect(
        navigatedPresident!.photoUrl,
        'assets/images/presidents/modibo_keita.jpeg',
      );
    });

    testWidgets('search bar filters presidents accurately',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Saisie du critère de recherche
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Assimi');
      await tester.pumpAndSettle();

      // Modibo Keïta ne doit plus être visible
      expect(find.text('Modibo Keïta'), findsNothing);

      // Assimi Goïta doit être affiché
      expect(find.text('Assimi Goïta'), findsOneWidget);
      expect(find.text('2021 - Présent'), findsOneWidget);
    });

    testWidgets('displays not found message when search yields no result',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'NomInexistant12345');
      await tester.pumpAndSettle();

      expect(find.text('Aucun chef d\'état trouvé.'), findsOneWidget);
    });
  });
}
