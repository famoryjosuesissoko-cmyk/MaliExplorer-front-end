import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mali_explorer_frontend/core/services/api_service.dart';
import 'package:mali_explorer_frontend/features/auth/auth_controller.dart';
import 'package:mali_explorer_frontend/features/chefs_etat_screen.dart';
import 'package:mali_explorer_frontend/features/ethnies_list_screen.dart';
import 'package:mali_explorer_frontend/features/explorer_screen.dart';
import 'package:mali_explorer_frontend/features/home_screen.dart';
import 'package:mali_explorer_frontend/features/profil_screen.dart';
import 'package:mali_explorer_frontend/features/quiz_list_screen.dart';
import 'package:mali_explorer_frontend/models/ethnie_model.dart';
import 'package:mali_explorer_frontend/models/home_slide_model.dart';
import 'package:mali_explorer_frontend/models/president_model.dart';
import 'package:mali_explorer_frontend/models/quiz_model.dart';
import 'package:mali_explorer_frontend/models/user_model.dart';
import 'package:mali_explorer_frontend/models/ville_model.dart';
import 'package:mali_explorer_frontend/providers/ethnies_provider.dart';
import 'package:mali_explorer_frontend/providers/explorer_provider.dart';
import 'package:mali_explorer_frontend/providers/home_extended_providers.dart';
import 'package:mali_explorer_frontend/providers/presidents_provider.dart';
import 'package:mali_explorer_frontend/providers/quiz_provider.dart';

class _FakeAuthController extends StateNotifier<AuthState> implements AuthController {
  _FakeAuthController(super.initialState);

  void updateState(AuthState newState) {
    state = newState;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockEvenementsHttpClient extends http.BaseClient {
  final int statusCode;
  final String body;

  MockEvenementsHttpClient({
    this.statusCode = 200,
    this.body = '[]',
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final bytes = utf8.encode(body);
    return http.StreamedResponse(
      Stream.value(bytes),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Test Quiz sample data
  final sampleQuizzes = [
    QuizModel(
      idQuiz: 1,
      nomQuiz: 'Histoire & Grands Empires du Mali',
      description: 'Testez vos connaissances sur l\'empire du Mali',
      imageQuiz: 'https://example.com/quiz-histoire.jpg',
      point: 40,
      categorie: 'Histoire',
      difficulte: 'Moyen',
      dateCreation: DateTime(2026, 10, 21, 14, 30),
      questions: List.generate(
        10,
        (i) => QuestionModel(
          idQuestion: i + 1,
          nomQuestion: 'Question test ${i + 1}',
          duree: 25,
          propositions: const ['Option A', 'Option B', 'Option C', 'Option D'],
          points: 10,
        ),
      ),
    ),
    QuizModel(
      idQuiz: 2,
      nomQuiz: 'Villes Mythiques & Patrimoine — Architecture Soudano-Sahélienne',
      description: 'Explorez Djenné, Tombouctou et les falaises de Bandiagara',
      imageQuiz: 'https://example.com/quiz-villes.jpg',
      point: 50,
      categorie: 'Patrimoine',
      difficulte: 'Difficile',
      dateCreation: DateTime(2026, 10, 21, 16, 0),
      questions: List.generate(
        4,
        (i) => QuestionModel(
          idQuestion: i + 1,
          nomQuestion: 'Question patrimoine ${i + 1}',
          duree: 30,
          propositions: const ['Option 1', 'Option 2'],
          points: 10,
        ),
      ),
    ),
  ];

  final List<EthnieModel> sampleEthnies = [
    const EthnieModel(
      id: 1,
      nom: 'Bambara',
      region: 'Ségou & Koulikoro',
      population: '6 000 000',
      description: 'Plus grand groupe ethnique du Mali.',
      imageUrl: 'https://example.com/bambara.jpg',
      photoHomme: '',
      photoFemme: '',
      titreHomme: '',
      articleHomme: '',
      titreFemme: '',
      articleFemme: '',
    ),
    const EthnieModel(
      id: 2,
      nom: 'Dogon',
      region: 'Bandiagara & Mopti',
      population: '800 000',
      description: 'Peuple des falaises et gardien de cosmogonies ancestrales.',
      imageUrl: 'https://example.com/dogon.jpg',
      photoHomme: '',
      photoFemme: '',
      titreHomme: '',
      articleHomme: '',
      titreFemme: '',
      articleFemme: '',
    ),
  ];

  final List<PresidentModel> samplePresidents = [
    const PresidentModel(
      id: 1,
      nom: 'Keïta',
      prenom: 'Modibo',
      periodeMandat: '1960 - 1968',
      biographie: 'Père de l\'indépendance de la République du Mali.',
      photoUrl: 'https://example.com/modibo.jpg',
    ),
  ];

  group('Milestone M4 — R6: Anti-Overflow & Screen Responsiveness Suite', () {
    // -------------------------------------------------------------------------
    // 1. HOME SCREEN RESPONSIVENESS (360x640, 320x568, and 1.5x Text Scale)
    // -------------------------------------------------------------------------
    testWidgets('1. HomeScreen header at 360x640 (standard phone): zero RenderFlex overflow with Se déconnecter', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const loggedUser = UserModel(
        email: 'touriste@maliexplorer.ml',
        role: UserRole.touriste,
      );
      final fakeAuth = _FakeAuthController(const AuthState(userModel: loggedUser));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
            homeSlidesProvider.overrideWith((ref) async => HomeSlideModel.defaultSlides),
            homeVillesProvider.overrideWith((ref) async => VilleModel.defaultVilles),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('MaliExplorer'), findsOneWidget);
      expect(find.text('Se déconnecter'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Zero RenderFlex overflow on 360x640 HomeScreen header');
    });

    testWidgets('2. HomeScreen header at ultra-narrow 320x568: zero RenderFlex overflow with Se déconnecter', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const loggedUser = UserModel(
        email: 'touriste.narrow@maliexplorer.ml',
        role: UserRole.touriste,
      );
      final fakeAuth = _FakeAuthController(const AuthState(userModel: loggedUser));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
            homeSlidesProvider.overrideWith((ref) async => HomeSlideModel.defaultSlides),
            homeVillesProvider.overrideWith((ref) async => VilleModel.defaultVilles),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('MaliExplorer'), findsOneWidget);
      expect(find.text('Se déconnecter'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Zero RenderFlex overflow on 320x568 HomeScreen header');
    });

    testWidgets('3. HomeScreen header at ultra-narrow 320x568: zero RenderFlex overflow with Se connecter', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeAuth = _FakeAuthController(const AuthState());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
            homeSlidesProvider.overrideWith((ref) async => HomeSlideModel.defaultSlides),
            homeVillesProvider.overrideWith((ref) async => VilleModel.defaultVilles),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('MaliExplorer'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Zero RenderFlex overflow on 320x568 unauthenticated HomeScreen header');
    });

    testWidgets('4. HomeScreen header under accessibility text scale (1.5x) at 360x640: zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const loggedUser = UserModel(
        email: 'large.font@maliexplorer.ml',
        role: UserRole.touriste,
      );
      final fakeAuth = _FakeAuthController(const AuthState(userModel: loggedUser));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
            homeSlidesProvider.overrideWith((ref) async => HomeSlideModel.defaultSlides),
            homeVillesProvider.overrideWith((ref) async => VilleModel.defaultVilles),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(1.5),
            ),
            child: MaterialApp(home: HomeScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('MaliExplorer'), findsOneWidget);
      expect(find.text('Se déconnecter'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Zero RenderFlex overflow under 1.5x font scale');
    });

    // -------------------------------------------------------------------------
    // 2. QUIZ LIST SCREEN RESPONSIVENESS (360x640, 320x568, and 1.5x Text Scale)
    // -------------------------------------------------------------------------
    testWidgets('5. QuizListScreen cards at 360x640: zero RenderFlex overflow on metadata row and badges', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quizListProvider.overrideWith((ref) async => sampleQuizzes),
          ],
          child: const MaterialApp(home: QuizListScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Histoire & Grands Empires du Mali'), findsOneWidget);
      expect(find.text('10 questions • 10 min'), findsOneWidget);
      expect(find.text('+40 pts'), findsOneWidget);
      expect(find.text('Moyen'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Zero RenderFlex overflow on 360x640 Quiz cards');
    });

    testWidgets('6. QuizListScreen cards at ultra-narrow 320x568: zero RenderFlex overflow on long titles and metadata', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quizListProvider.overrideWith((ref) async => sampleQuizzes),
          ],
          child: const MaterialApp(home: QuizListScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Histoire & Grands Empires du Mali'), findsOneWidget);
      expect(find.text('+40 pts'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Zero RenderFlex overflow on 320x568 Quiz cards');
    });

    testWidgets('7. QuizListScreen cards under accessibility text scale (1.5x) at 360x640: zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quizListProvider.overrideWith((ref) async => sampleQuizzes),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(1.5),
            ),
            child: MaterialApp(home: QuizListScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Histoire & Grands Empires du Mali'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Zero RenderFlex overflow on 1.5x font scale Quiz cards');
    });

    testWidgets('7b. QuizListScreen cards under accessibility text scale (1.5x) at ultra-narrow 320x568: zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quizListProvider.overrideWith((ref) async => sampleQuizzes),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(1.5),
            ),
            child: MaterialApp(home: QuizListScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Histoire & Grands Empires du Mali'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Zero RenderFlex overflow on 320x568 @ 1.5x font scale Quiz cards');
    });

    // -------------------------------------------------------------------------
    // 3. OTHER KEY SCREENS RESPONSIVENESS AT 320px
    // -------------------------------------------------------------------------
    testWidgets('8. EthniesListScreen at ultra-narrow 320x568: zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ethniesProvider.overrideWith((ref) async => sampleEthnies),
          ],
          child: const MaterialApp(home: EthniesListScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Bambara'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Zero RenderFlex overflow on 320px EthniesListScreen');
    });

    testWidgets('9. ChefsEtatScreen at ultra-narrow 320x568: zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presidentsProvider.overrideWith((ref) async => samplePresidents),
          ],
          child: const MaterialApp(home: ChefsEtatScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Modibo Keïta'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Zero RenderFlex overflow on 320px ChefsEtatScreen');
    });

    testWidgets('10. ProfilScreen at ultra-narrow 320x568: zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const loggedUser = UserModel(
        email: 'user.profile@maliexplorer.ml',
        nom: 'Diallo',
        prenom: 'Amadou',
        role: UserRole.touriste,
      );
      final fakeAuth = _FakeAuthController(const AuthState(
        userModel: loggedUser,
        user: {
          'nom': 'Diallo',
          'prenom': 'Amadou',
          'email': 'user.profile@maliexplorer.ml',
        },
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
            currentUserProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MaterialApp(home: ProfilScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Amadou Diallo'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'Zero RenderFlex overflow on 320px ProfilScreen');
    });
  });

  group('Milestone M4 — R7: Official Verbatim Empty States Suite', () {
    testWidgets('11. Événements : affiche rigoureusement « Aucun événement publié pour le moment. »', (tester) async {
      final mockClient = MockEvenementsHttpClient(
        statusCode: 200,
        body: '[]',
      );
      final apiService = ApiService(client: mockClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(apiService),
            explorerFilterTypeProvider.overrideWith((ref) => 'festivals'),
          ],
          child: const MaterialApp(home: ExplorerScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Aucun événement publié pour le moment.'), findsOneWidget);
      expect(find.byIcon(Icons.event_busy_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('12. Présidents : affiche rigoureusement « Aucun président disponible pour le moment. »', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presidentsProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: ChefsEtatScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Aucun président disponible pour le moment.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('13. Ethnies : affiche rigoureusement « Aucune ethnie enregistrée pour le moment. »', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ethniesProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(home: EthniesListScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Aucune ethnie enregistrée pour le moment.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
