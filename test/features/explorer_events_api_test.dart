import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mali_explorer_frontend/core/services/api_service.dart';
import 'package:mali_explorer_frontend/features/explorer_screen.dart';
import 'package:mali_explorer_frontend/models/explorer_publication_model.dart';
import 'package:mali_explorer_frontend/providers/explorer_provider.dart';

/// Client HTTP mockable pour tester les différents scénarios de l'API /evenements
class MockEvenementsHttpClient extends http.BaseClient {
  final int statusCode;
  final String body;
  final bool shouldThrow;

  MockEvenementsHttpClient({
    this.statusCode = 200,
    this.body = '[]',
    this.shouldThrow = false,
  });

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (shouldThrow) {
      throw const SocketException('Connexion au serveur Spring Boot refusée');
    }
    final bytes = utf8.encode(body);
    return http.StreamedResponse(
      Stream.value(bytes),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

void main() {
  group('ExplorerProvider & ExplorerScreen — Tests des 3 scénarios API', () {
    test('1. Données disponibles : Récupère et affiche uniquement les événements de l\'API (aucun mock)', () async {
      final mockData = [
        {
          'id': 42,
          'titre': 'Festival Réel du Mali 2027',
          'description': 'Festival culturel live depuis la base de données.',
          'nomOrganisateur': 'Promoteur Officiel',
          'ville': 'Bamako',
          'statut': 'VALIDE',
          'type': 'festivalEvenement',
          'vues': 10,
          'nombreCommentaires': 2,
        }
      ];

      final mockClient = MockEvenementsHttpClient(
        statusCode: 200,
        body: jsonEncode(mockData),
      );
      final apiService = ApiService(client: mockClient);
      final notifier = ExplorerPublicationsNotifier(apiService);

      // Attendre la résolution asynchrone
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, isA<AsyncData<List<ExplorerPublicationModel>>>());
      final pubs = notifier.state.value!;
      expect(pubs.length, equals(1));
      expect(pubs.first.id, equals('42'));
      expect(pubs.first.titre, equals('Festival Réel du Mali 2027'));
      expect(pubs.first.auteur, equals('Promoteur Officiel'));
      // Vérifier l'absence totale de fallback vers fest-001 / fest-002 / fest-003
      expect(pubs.any((p) => p.id == 'fest-001'), isFalse);
      expect(pubs.any((p) => p.id == 'fest-002'), isFalse);
    });

    test('2. Liste vide : L\'API renvoie [] -> AsyncData([]) sans fallback codé en dur', () async {
      final mockClient = MockEvenementsHttpClient(
        statusCode: 200,
        body: '[]',
      );
      final apiService = ApiService(client: mockClient);
      final notifier = ExplorerPublicationsNotifier(apiService);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, isA<AsyncData<List<ExplorerPublicationModel>>>());
      final pubs = notifier.state.value!;
      expect(pubs, isEmpty);
      // Confirmer qu'aucun événement hardcodé n'a été injecté
      expect(pubs.any((p) => p.id == 'fest-001'), isFalse);
    });

    test('3. API indisponible : L\'API échoue -> AsyncError (non confondu avec réponse vide, aucun mock)', () async {
      final mockClient = MockEvenementsHttpClient(
        shouldThrow: true,
      );
      final apiService = ApiService(client: mockClient);
      final notifier = ExplorerPublicationsNotifier(apiService);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(notifier.state, isA<AsyncError<List<ExplorerPublicationModel>>>());
      expect(notifier.state.hasError, isTrue);
      // S'assurer que state n'est PAS confondu avec une liste vide
      expect(notifier.state.valueOrNull, isNull);
    });

    testWidgets('UI Widget Test — Affichage de l\'état données réelles', (tester) async {
      final mockData = [
        {
          'id': 99,
          'titre': 'Festival Ségou Art Live Test',
          'description': 'Description du festival live.',
          'nomOrganisateur': 'Fondation Festival',
          'ville': 'Ségou',
          'statut': 'VALIDE',
          'type': 'festivalEvenement',
        }
      ];
      final mockClient = MockEvenementsHttpClient(
        statusCode: 200,
        body: jsonEncode(mockData),
      );
      final apiService = ApiService(client: mockClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(apiService),
            explorerFilterTypeProvider.overrideWith((ref) => 'festivals'),
          ],
          child: const MaterialApp(
            home: ExplorerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Festival Ségou Art Live Test'), findsOneWidget);
      expect(find.textContaining('Fondation Festival'), findsOneWidget);
      expect(find.text('Festival des Masques & Traditions Dogon (FESTIMA)'), findsNothing);
    });

    testWidgets('UI Widget Test — Affichage de l\'état liste vide informatif', (tester) async {
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
          child: const MaterialApp(
            home: ExplorerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Aucun événement publié pour le moment.'), findsOneWidget);
      expect(find.byIcon(Icons.event_busy_rounded), findsOneWidget);
    });

    testWidgets('UI Widget Test — Affichage de l\'erreur avec bouton Réessayer', (tester) async {
      final mockClient = MockEvenementsHttpClient(
        shouldThrow: true,
      );
      final apiService = ApiService(client: mockClient);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            apiServiceProvider.overrideWithValue(apiService),
            explorerFilterTypeProvider.overrideWith((ref) => 'festivals'),
          ],
          child: const MaterialApp(
            home: ExplorerScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Événements temporairement indisponibles'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });
  });
}
