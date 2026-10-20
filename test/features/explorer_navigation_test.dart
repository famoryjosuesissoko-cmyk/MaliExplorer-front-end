import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mali_explorer_frontend/core/services/api_service.dart';
import 'package:mali_explorer_frontend/router/app_router.dart';

// Client HTTP simulé restituant les payloads réels des 8 thématiques de l'onglet Explorer
class _ExplorerEndpointsHttpClient extends http.BaseClient {
  static final Map<String, dynamic> _payloads = {
    'villes': [
      {
        'idVille': 1,
        'nomVille': 'Bamako',
        'descriptionVille': 'Capitale dynamique du Mali sur les rives du fleuve Niger.',
        'regionParent': 'District de Bamako',
        'latitude': 12.6392,
        'longitude': -8.0029,
      },
    ],
    'regions': [
      {
        'idRegion': 1,
        'nomRegion': 'Région de Tombouctou',
        'description': 'Berceau historique des manuscrits anciens.',
      },
    ],
    'plats': [
      {
        'idPlat': 1,
        'nomPlat': 'Tiguèdèguèna',
        'histoirePlat': 'Ragoût traditionnel à la pâte d\'arachide.',
        'regionOrigine': 'Bamako',
      },
    ],
    'ethnies': [
      {
        'idEthnie': 1,
        'nomEthnie': 'Bambara',
        'descriptionTraditions': 'Agriculture, arts du masque Ciwara et tradition orale.',
        'localisation': 'Centre et Sud du Mali',
      },
    ],
    'presidents': [
      {
        'idPresident': 1,
        'nomComplet': 'Modibo Keïta',
        'titre': 'Premier Président de la République du Mali',
        'periodeMandat': '1960 - 1968',
        'biographie': 'Père de l\'indépendance du Mali.',
      },
    ],
    'guides': [
      {
        'idGuide': 1,
        'nomComplet': 'Amadou Touré',
        'ville': 'Mopti',
        'specialite': 'Pays Dogon & Fleuve Niger',
        'statut': 'VALIDE',
        'disponible': true,
      },
    ],
    'langues': [
      {
        'idLangue': 1,
        'nom': 'Bamanankan',
        'codeIso': 'bm',
        'familleLinguistique': 'Mandé',
        'regionsParlees': 'Bamako, Ségou, Koulikoro, Sikasso',
        'pourcentageLocuteurs': '80%',
        'description': 'Principale langue véhiculaire du Mali.',
      },
    ],
    'infos-pratiques': [
      {
        'idInfo': 1,
        'categorie': 'SANTE_SECURITE',
        'titre': 'Numéros d\'urgence',
        'description': 'Police Secours : 17 | Protection Civile : 18 | SAMU : 15',
      },
    ],
    'religions': [
      {
        'idReligion': 1,
        'nom': 'Islam',
        'pourcentageEstime': 95,
        'description': 'Tradition soufie et malékite historique au Mali.',
        'estPublie': true,
      },
    ],
  };

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final path = request.url.path.replaceFirst('/api/', '');
    final payload = _payloads[path] ?? [];
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(payload))),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

void main() {
  testWidgets('ExplorerScreen navigates to all 8 thematic screens with real backend data', (tester) async {
    final apiService = ApiService(client: _ExplorerEndpointsHttpClient());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiServiceProvider.overrideWithValue(apiService),
        ],
        child: MaterialApp.router(
          routerConfig: AppRouter.router,
        ),
      ),
    );

    AppRouter.router.go(AppRouter.explorer);
    await tester.pumpAndSettle();

    final categories = [
      {'card': 'Villes & Régions', 'header': 'Villes & Territoires'},
      {'card': 'Gastronomie Malienne', 'header': 'Gastronomie'},
      {'card': 'Ethnies & Traditions', 'header': 'Peuples & Traditions'},
      {'card': 'Chefs d\'État & Histoire', 'header': 'Chefs d\'État'},
      {'card': 'Guides Touristiques', 'header': 'Guides'},
      {'card': 'Langues Nationales & Lexique', 'header': 'LANGUES NATIONALES DU MALI'},
      {'card': 'Infos Pratiques Voyageurs', 'header': 'INFORMATIONS PRATIQUES'},
      {'card': 'Religions & Spiritualités', 'header': 'Religions & Spiritualités'},
    ];

    for (final cat in categories) {
      final cardTitle = cat['card']!;
      final expectedHeader = cat['header']!;

      await tester.scrollUntilVisible(
        find.text(cardTitle),
        150.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();

      expect(find.text(cardTitle), findsOneWidget, reason: 'Card $cardTitle should be visible in ExplorerScreen');
      await tester.tap(find.text(cardTitle));
      await tester.pumpAndSettle();

      expect(find.text(expectedHeader), findsWidgets, reason: 'Header $expectedHeader should appear after tapping $cardTitle');
      expect(find.textContaining('Impossible de charger'), findsNothing, reason: 'No error state should appear on $cardTitle');
      expect(find.textContaining('Erreur de chargement'), findsNothing, reason: 'No error state should appear on $cardTitle');

      // Pop back to ExplorerScreen
      AppRouter.router.pop();
      await tester.pumpAndSettle();
    }
  });
}
