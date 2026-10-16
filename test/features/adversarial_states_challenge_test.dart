import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mali_explorer_frontend/core/services/api_service.dart';
import 'package:mali_explorer_frontend/core/services/plat_service.dart';
import 'package:mali_explorer_frontend/core/services/ville_service.dart';
import 'package:mali_explorer_frontend/features/guides_screen.dart';
import 'package:mali_explorer_frontend/features/gastronomie_list_screen.dart';
import 'package:mali_explorer_frontend/features/villes_list_screen.dart';

class MockClientHandler extends http.BaseClient {
  final Future<http.Response> Function(http.BaseRequest request) _handler;
  MockClientHandler(this._handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _handler(request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  group('Empirical Challenge: Guides Dynamic States & Exact Copy', () {
    testWidgets('GuidesScreen with real GuideService renders EXACT official copy on empty list []', (tester) async {
      final mockClient = MockClientHandler((req) async {
        return http.Response(jsonEncode([]), 200, headers: {'content-type': 'application/json'});
      });
      final apiService = ApiService(client: mockClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(apiService),
          ],
          child: const MaterialApp(
            home: GuidesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      const expectedExactCopy =
          "Aucun guide n'est disponible pour le moment. Les profils des guides apparaîtront ici dès qu'ils seront inscrits, validés et disponibles.";

      // 1. Le texte officiel exact doit être présent
      expect(find.text(expectedExactCopy), findsOneWidget);

      // 2. Aucun profil fictif de guide
      expect(find.text('Oumar Traoré'), findsNothing);
      expect(find.text('Awa Keita'), findsNothing);
      expect(find.text('Ibrahim Coulibaly'), findsNothing);
    });

    testWidgets('GuidesScreen with real GuideService renders error UI with retry action on HTTP 500', (tester) async {
      int requestCount = 0;
      final mockClient = MockClientHandler((req) async {
        requestCount++;
        return http.Response('Internal Server Error', 500);
      });
      final apiService = ApiService(client: mockClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(apiService),
          ],
          child: const MaterialApp(
            home: GuidesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Vérifie que l'état d'erreur est affiché et NON l'état vide
      expect(find.text('Impossible de charger les guides touristiques'), findsOneWidget);
      expect(find.text('Vérifiez votre connexion réseau et réessayez.'), findsOneWidget);
      expect(
        find.text(
          "Aucun guide n'est disponible pour le moment. Les profils des guides apparaîtront ici dès qu'ils seront inscrits, validés et disponibles.",
        ),
        findsNothing,
      );

      // Vérifie que le bouton de réessai existe et déclenche le rechargement
      final retryButton = find.text('Réessayer');
      expect(retryButton, findsOneWidget);
      final initialRequests = requestCount;
      await tester.tap(retryButton);
      await tester.pump();
      expect(requestCount, greaterThan(initialRequests));
    });

    testWidgets('GuidesScreen with real GuideService renders error UI on network exception', (tester) async {
      final mockClient = MockClientHandler((req) async {
        throw http.ClientException('Connection refused');
      });
      final apiService = ApiService(client: mockClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(apiService),
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

    testWidgets('GuidesScreen displays real guide items when API returns data', (tester) async {
      final mockGuides = [
        {
          'idGuide': 1,
          'prenom': 'Amadou',
          'nom': 'Diallo',
          'email': 'amadou@example.com',
          'telephone': '+223 70 00 00 01',
          'langue': 'Français, Bambara, Anglais',
          'adresse': 'Djenné',
          'description': 'Guide certifié de Djenné',
          'anneesExperience': 7,
          'tarifJournalier': 25000,
          'specialites': 'Histoire, Architecture',
          'statutModeration': 'VALIDE',
          'estDisponible': true,
        }
      ];

      final mockClient = MockClientHandler((req) async {
        return http.Response(jsonEncode(mockGuides), 200, headers: {'content-type': 'application/json'});
      });
      final apiService = ApiService(client: mockClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(apiService),
          ],
          child: const MaterialApp(
            home: GuidesScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Amadou Diallo'), findsOneWidget);
      expect(find.text('Guide certifié de Djenné'), findsOneWidget);
      expect(
        find.text(
          "Aucun guide n'est disponible pour le moment. Les profils des guides apparaîtront ici dès qu'ils seront inscrits, validés et disponibles.",
        ),
        findsNothing,
      );
    });
  });

  group('Empirical Verification: Authentic Data & Mock-Free Behavior', () {
    test('PlatService: returns empty list [] when backend is empty', () async {
      final emptyClient = MockClientHandler((req) async {
        return http.Response(jsonEncode([]), 200, headers: {'content-type': 'application/json'});
      });
      final platServiceEmpty = PlatService(ApiService(client: emptyClient));
      final resultEmpty = await platServiceEmpty.getPlats();

      // Confirme que PlatService retourne une liste vide [] sans la remplacer par defaultPlats !
      expect(resultEmpty.isEmpty, isTrue);
    });

    test('PlatService: throws exception on HTTP 500 error to trigger Riverpod error state', () async {
      final errorClient = MockClientHandler((req) async {
        return http.Response('Server Error', 500);
      });
      final platServiceError = PlatService(ApiService(client: errorClient));
      expect(() => platServiceError.getPlats(), throwsA(isA<Exception>()));
    });

    test('VilleService: returns empty list [] when backend is empty', () async {
      final emptyClient = MockClientHandler((req) async {
        return http.Response(jsonEncode([]), 200, headers: {'content-type': 'application/json'});
      });
      final villeServiceEmpty = VilleService(ApiService(client: emptyClient));
      final resultEmpty = await villeServiceEmpty.getVilles();

      // Confirme que VilleService retourne une liste vide [] sans la remplacer par defaultVilles !
      expect(resultEmpty.isEmpty, isTrue);
    });

    test('VilleService: throws exception on HTTP 500 error to trigger Riverpod error state', () async {
      final errorClient = MockClientHandler((req) async {
        return http.Response('Server Error', 500);
      });
      final villeServiceError = VilleService(ApiService(client: errorClient));
      expect(() => villeServiceError.getVilles(), throwsA(isA<Exception>()));
    });

    testWidgets('GastronomieListScreen with default PlatService displays empty state on empty API []', (tester) async {
      final emptyClient = MockClientHandler((req) async {
        return http.Response(jsonEncode([]), 200, headers: {'content-type': 'application/json'});
      });
      final apiService = ApiService(client: emptyClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(apiService),
          ],
          child: const MaterialApp(
            home: GastronomieListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Aucun plat traditionnel disponible pour le moment.'), findsOneWidget);
      expect(find.text('Tigadèguèna'), findsNothing);
    });

    testWidgets('GastronomieListScreen with default PlatService shows retry UI on HTTP 500', (tester) async {
      final errorClient = MockClientHandler((req) async {
        return http.Response('Internal Server Error', 500);
      });
      final apiService = ApiService(client: errorClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(apiService),
          ],
          child: const MaterialApp(
            home: GastronomieListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Impossible de charger les spécialités gastronomiques'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
      expect(find.text('Tigadèguèna'), findsNothing);
    });

    testWidgets('VillesListScreen with default VilleService displays empty state on empty API []', (tester) async {
      final emptyClient = MockClientHandler((req) async {
        return http.Response(jsonEncode([]), 200, headers: {'content-type': 'application/json'});
      });
      final apiService = ApiService(client: emptyClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(apiService),
          ],
          child: const MaterialApp(
            home: VillesListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Aucune ville disponible pour le moment.'), findsOneWidget);
      expect(find.text('Tombouctou'), findsNothing);
    });

    testWidgets('VillesListScreen with default VilleService shows retry UI on HTTP 500', (tester) async {
      final errorClient = MockClientHandler((req) async {
        return http.Response('Internal Server Error', 500);
      });
      final apiService = ApiService(client: errorClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(apiService),
          ],
          child: const MaterialApp(
            home: VillesListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Impossible de charger les villes et territoires'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
      expect(find.text('Tombouctou'), findsNothing);
    });
  });
}
