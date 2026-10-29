import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mali_explorer_frontend/features/auth/auth_controller.dart';
import 'package:mali_explorer_frontend/features/chefs_etat_screen.dart';
import 'package:mali_explorer_frontend/features/ethnies_list_screen.dart';
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
import 'package:mali_explorer_frontend/providers/home_extended_providers.dart';
import 'package:mali_explorer_frontend/providers/presidents_provider.dart';
import 'package:mali_explorer_frontend/providers/quiz_provider.dart';

class _AdversarialFakeAuthController extends StateNotifier<AuthState> implements AuthController {
  _AdversarialFakeAuthController(super.initialState);

  void updateState(AuthState newState) {
    state = newState;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Adversarial Extreme Sample Data
  final extremeQuizzes = [
    QuizModel(
      idQuiz: 1,
      nomQuiz: 'Histoire et Dynasties Royales des Grands Empires du Mandingue, Songhaï, Ghana et Peul du Macina à travers les siècles',
      description: 'Testez vos connaissances approfondies sur les épopées mandingues de Soundiata Keïta et Kankou Moussa',
      imageQuiz: 'https://example.com/quiz-extreme.jpg',
      point: 10000,
      categorie: 'Patrimoine Mondial & Histoire Impériale',
      difficulte: 'Très Difficile',
      dateCreation: DateTime(2026, 10, 22, 18, 45),
      questions: List.generate(
        99,
        (i) => QuestionModel(
          idQuestion: i + 1,
          nomQuestion: 'Question approfondie $i sur la charte de Kurukan Fuga',
          duree: 180,
          propositions: const ['Option A', 'Option B', 'Option C', 'Option D'],
          points: 100,
        ),
      ),
    ),
    QuizModel(
      idQuiz: 2,
      nomQuiz: 'Architecture en Banco & Villes Mythiques du Fleuve Niger (Djenné, Tombouctou, Gao)',
      description: 'Les mystères des mosquées en terre crue soudano-sahélienne',
      imageQuiz: 'https://example.com/quiz-arch.jpg',
      point: 500,
      categorie: 'Architecture',
      difficulte: 'Expert',
      dateCreation: DateTime(2026, 10, 22, 9, 15),
      questions: [
        const QuestionModel(
          idQuestion: 1,
          nomQuestion: 'Date de construction de la Grande Mosquée de Djenné',
          duree: 45,
          propositions: ['1907', '1280'],
          points: 50,
        ),
      ],
    ),
  ];

  final extremeEthnies = [
    const EthnieModel(
      id: 1,
      nom: 'Touareg / Kel Tamasheq des Massifs de l\'Adrar des Ifoghas',
      region: 'Kidal, Ménaka, Tombouctou & Gao',
      population: '12 500 000 habitants répertoriés',
      description: 'Peuple nomade du grand Sahara malien, gardiens des écritures tifinagh et de l\'artisanat du cuir et de l\'argent ciselé.',
      imageUrl: 'https://example.com/touareg.jpg',
      photoHomme: '',
      photoFemme: '',
      titreHomme: '',
      articleHomme: '',
      titreFemme: '',
      articleFemme: '',
    ),
    const EthnieModel(
      id: 2,
      nom: 'Bambara / Bamanankan de Ségou, Sikasso et Koulikoro',
      region: 'Régions Centre et Sud du Mali',
      population: '8 500 000 habitants',
      description: 'Groupe mandingue majoritaire, maîtres de l\'agriculture, des masques Ciwara et des traditions royales.',
      imageUrl: 'https://example.com/bambara.jpg',
      photoHomme: '',
      photoFemme: '',
      titreHomme: '',
      articleHomme: '',
      titreFemme: '',
      articleFemme: '',
    ),
  ];

  final extremePresidents = [
    const PresidentModel(
      id: 1,
      nom: 'Touré',
      prenom: 'Son Excellence le Général d\'Armée Amadou Toumani',
      periodeMandat: '26 Mars 1991 - 08 Juin 1992 & 08 Juin 2002 - 22 Mars 2012',
      biographie: 'Président du Comité de Transition pour le Salut du Peuple puis président élu de la République, architecte du consensus démocratique.',
      photoUrl: 'https://example.com/att.jpg',
    ),
    const PresidentModel(
      id: 2,
      nom: 'Keïta',
      prenom: 'Modibo',
      periodeMandat: '22 Septembre 1960 - 19 Novembre 1968',
      biographie: 'Père de l\'indépendance nationale et premier président de la République du Mali.',
      photoUrl: 'https://example.com/modibo.jpg',
    ),
  ];

  group('Empirical Challenger M4 — Adversarial Responsiveness & Overflow Stress Suite (R6)', () {
    // =========================================================================
    // 1. HOME SCREEN ADVERSARIAL STRESS
    // =========================================================================
    testWidgets('1. HomeScreen [320x480, textScale=1.0, Logged In]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const loggedUser = UserModel(
        email: 'son.excellence.super.touriste@maliexplorer.gouv.ml',
        role: UserRole.touriste,
      );
      final fakeAuth = _AdversarialFakeAuthController(const AuthState(userModel: loggedUser));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
            homeSlidesProvider.overrideWith((ref) async => HomeSlideModel.defaultSlides),
            homeVillesProvider.overrideWith((ref) async => VilleModel.defaultVilles),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(1.0),
            ),
            child: MaterialApp(home: HomeScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('MaliExplorer'), findsOneWidget);
      expect(find.text('Se déconnecter'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('2. HomeScreen [320x480, textScale=1.5, Logged In]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const loggedUser = UserModel(
        email: 'son.excellence.super.touriste@maliexplorer.gouv.ml',
        role: UserRole.touriste,
      );
      final fakeAuth = _AdversarialFakeAuthController(const AuthState(userModel: loggedUser));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
            homeSlidesProvider.overrideWith((ref) async => HomeSlideModel.defaultSlides),
            homeVillesProvider.overrideWith((ref) async => VilleModel.defaultVilles),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
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
      expect(tester.takeException(), isNull);
    });

    testWidgets('3. HomeScreen [320x480, textScale=2.0 (MAX), Logged In]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const loggedUser = UserModel(
        email: 'son.excellence.super.touriste@maliexplorer.gouv.ml',
        role: UserRole.touriste,
      );
      final fakeAuth = _AdversarialFakeAuthController(const AuthState(userModel: loggedUser));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
            homeSlidesProvider.overrideWith((ref) async => HomeSlideModel.defaultSlides),
            homeVillesProvider.overrideWith((ref) async => VilleModel.defaultVilles),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: HomeScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('MaliExplorer'), findsOneWidget);
      expect(find.text('Se déconnecter'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('4. HomeScreen [320x480, textScale=2.0 (MAX), Logged Out]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeAuth = _AdversarialFakeAuthController(const AuthState());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
            homeSlidesProvider.overrideWith((ref) async => HomeSlideModel.defaultSlides),
            homeVillesProvider.overrideWith((ref) async => VilleModel.defaultVilles),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: HomeScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('MaliExplorer'), findsOneWidget);
      expect(find.text('Se connecter'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('5. HomeScreen [360x640, textScale=2.0, Full Page Scroll]: Zero RenderFlex overflow in all sections', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeAuth = _AdversarialFakeAuthController(const AuthState());

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
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: HomeScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Scroll through home page to expose Villes du Mali & Quiz banner
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Villes du Mali'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // =========================================================================
    // 2. QUIZ LIST SCREEN ADVERSARIAL STRESS
    // =========================================================================
    testWidgets('6. QuizListScreen [320x480, textScale=1.0, Extreme Quizzes]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quizListProvider.overrideWith((ref) async => extremeQuizzes),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(1.0),
            ),
            child: MaterialApp(home: QuizListScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('+10000 pts'), findsOneWidget);
      expect(find.text('Difficile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('7. QuizListScreen [320x480, textScale=1.5, Extreme Quizzes]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quizListProvider.overrideWith((ref) async => extremeQuizzes),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(1.5),
            ),
            child: MaterialApp(home: QuizListScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('+10000 pts'), findsOneWidget);
      expect(find.text('Difficile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('8. QuizListScreen [320x480, textScale=2.0 (MAX), Extreme Quizzes]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quizListProvider.overrideWith((ref) async => extremeQuizzes),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: QuizListScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('+10000 pts'), findsOneWidget);
      expect(find.text('Difficile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('9. QuizListScreen [360x640, textScale=2.0 (MAX), Extreme Quizzes]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quizListProvider.overrideWith((ref) async => extremeQuizzes),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: QuizListScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('+10000 pts'), findsOneWidget);
      expect(find.text('Difficile'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('10. QuizListScreen [320x480, textScale=2.0, Empty State]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            quizListProvider.overrideWith((ref) async => []),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: QuizListScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(tester.takeException(), isNull);
    });

    // =========================================================================
    // 3. PROFIL SCREEN ADVERSARIAL STRESS
    // =========================================================================
    testWidgets('11. ProfilScreen [320x480, textScale=1.0, Long Name & Promoteur]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const loggedUser = UserModel(
        email: 'tres.long.identifiant.promoteur.culturel@direction-nationale-tourisme-mali.gouv.ml',
        nom: 'Diarra Alassane Ouattara Touré',
        prenom: 'Son Excellence le Très Honorable Professeur Cheick Modibo',
        role: UserRole.promoteur,
      );
      final fakeAuth = _AdversarialFakeAuthController(const AuthState(
        userModel: loggedUser,
        user: {
          'nom': 'Diarra Alassane Ouattara Touré',
          'prenom': 'Son Excellence le Très Honorable Professeur Cheick Modibo',
          'email': 'tres.long.identifiant.promoteur.culturel@direction-nationale-tourisme-mali.gouv.ml',
          'role': 'promoteur',
        },
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
            currentUserProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(1.0),
            ),
            child: MaterialApp(home: ProfilScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Mon profil'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('12. ProfilScreen [320x480, textScale=1.5, Long Name & Guide]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const loggedUser = UserModel(
        email: 'guide.officiel.pays.dogon@maliexplorer.gouv.ml',
        nom: 'Guindo Sagara Dolo',
        prenom: 'Oumarou Babacar',
        role: UserRole.guide,
      );
      final fakeAuth = _AdversarialFakeAuthController(const AuthState(
        userModel: loggedUser,
        user: {
          'nom': 'Guindo Sagara Dolo',
          'prenom': 'Oumarou Babacar',
          'email': 'guide.officiel.pays.dogon@maliexplorer.gouv.ml',
          'role': 'guide',
        },
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
            currentUserProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(1.5),
            ),
            child: MaterialApp(home: ProfilScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Mon profil'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('13. ProfilScreen [320x480, textScale=2.0 (MAX), Touriste & Scroll]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const loggedUser = UserModel(
        email: 'grand.voyageur.international@maliexplorer.gouv.ml',
        nom: 'Kouyaté',
        prenom: 'Mamadou',
        role: UserRole.touriste,
      );
      final fakeAuth = _AdversarialFakeAuthController(const AuthState(
        userModel: loggedUser,
        user: {
          'nom': 'Kouyaté',
          'prenom': 'Mamadou',
          'email': 'grand.voyageur.international@maliexplorer.gouv.ml',
          'role': 'touriste',
        },
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
            currentUserProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: ProfilScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll through Profil options
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
    });

    testWidgets('14. ProfilScreen [360x640, textScale=2.0 (MAX), Visitor State]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final fakeAuth = _AdversarialFakeAuthController(const AuthState());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authControllerProvider.overrideWith((ref) => fakeAuth),
            currentUserProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: ProfilScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Bienvenue sur MaliExplorer'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // =========================================================================
    // 4. ETHNIES LIST SCREEN ADVERSARIAL STRESS
    // =========================================================================
    testWidgets('15. EthniesListScreen [320x480, textScale=1.0, Extreme Ethnies]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ethniesProvider.overrideWith((ref) async => extremeEthnies),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(1.0),
            ),
            child: MaterialApp(home: EthniesListScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Touareg'), findsOneWidget);
      expect(find.text('12 500 000 habitants répertoriés'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('16. EthniesListScreen [320x480, textScale=1.5, Extreme Ethnies]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ethniesProvider.overrideWith((ref) async => extremeEthnies),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(1.5),
            ),
            child: MaterialApp(home: EthniesListScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Touareg'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('17. EthniesListScreen [320x480, textScale=2.0 (MAX), Extreme Ethnies & Scroll]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ethniesProvider.overrideWith((ref) async => extremeEthnies),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: EthniesListScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll through ethnies list
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
    });

    testWidgets('18. EthniesListScreen [360x640, textScale=2.0 (MAX), Extreme Ethnies]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ethniesProvider.overrideWith((ref) async => extremeEthnies),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: EthniesListScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.textContaining('Touareg'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('19. EthniesListScreen [320x480, textScale=2.0, Empty State]: Zero RenderFlex overflow', (tester) async {
      final recordedErrors = <FlutterErrorDetails>[];
      final prevOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        recordedErrors.add(details);
        prevOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = prevOnError);

      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ethniesProvider.overrideWith((ref) async => []),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: EthniesListScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Aucune ethnie enregistrée pour le moment.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('20. EthniesListScreen [320x480, textScale=2.0, Error State]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ethniesProvider.overrideWith((ref) async => throw Exception('Adversarial Network Failure 503')),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: EthniesListScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Réessayer'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // =========================================================================
    // 5. CHEFS D'ÉTAT SCREEN ADVERSARIAL STRESS
    // =========================================================================
    testWidgets('21. ChefsEtatScreen [320x480, textScale=1.0, Extreme Mandate & Name]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presidentsProvider.overrideWith((ref) async => extremePresidents),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(1.0),
            ),
            child: MaterialApp(home: ChefsEtatScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Son Excellence le Général d\'Armée Amadou Toumani Touré'), findsOneWidget);
      expect(find.text('26 Mars 1991 - 08 Juin 1992 & 08 Juin 2002 - 22 Mars 2012'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('22. ChefsEtatScreen [320x480, textScale=1.5, Extreme Mandate & Name]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presidentsProvider.overrideWith((ref) async => extremePresidents),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(1.5),
            ),
            child: MaterialApp(home: ChefsEtatScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Son Excellence le Général d\'Armée Amadou Toumani Touré'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('23. ChefsEtatScreen [320x480, textScale=2.0 (MAX), Extreme Mandate & Scroll]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presidentsProvider.overrideWith((ref) async => extremePresidents),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: ChefsEtatScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Scroll through presidents list
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -250));
      await tester.pump(const Duration(milliseconds: 200));

      expect(tester.takeException(), isNull);
    });

    testWidgets('24. ChefsEtatScreen [360x640, textScale=2.0 (MAX), Extreme Mandate]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presidentsProvider.overrideWith((ref) async => extremePresidents),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(360, 640),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: ChefsEtatScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Son Excellence le Général d\'Armée Amadou Toumani Touré'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('25. ChefsEtatScreen [320x480, textScale=2.0, Empty State]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presidentsProvider.overrideWith((ref) async => []),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: ChefsEtatScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Aucun président disponible pour le moment.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('26. ChefsEtatScreen [320x480, textScale=2.0, Error State]: Zero RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            presidentsProvider.overrideWith((ref) async => throw Exception('Adversarial Database Timeout 504')),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(320, 480),
              textScaler: TextScaler.linear(2.0),
            ),
            child: MaterialApp(home: ChefsEtatScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Réessayer'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
