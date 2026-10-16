import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mali_explorer_frontend/models/region_model.dart';
import 'package:mali_explorer_frontend/features/region_detail_screen.dart';

void main() {
  group('Carte Immersive & Regions Tests', () {
    test('RegionData contains 11 administrative regions and 6 priority regions', () {
      expect(RegionData.regions.length, equals(11));
      expect(RegionData.priorityRegions.length, equals(6));

      final priorityIds = RegionData.priorityRegions.map((r) => r.id).toList();
      expect(priorityIds, contains('mopti'));
      expect(priorityIds, contains('bamako'));
      expect(priorityIds, contains('segou'));
      expect(priorityIds, contains('sikasso'));
      expect(priorityIds, contains('tombouctou'));
      expect(priorityIds, contains('gao'));
    });

    test('Region Mopti contains Djenne references and valid coordinates', () {
      final mopti = RegionData.findById('mopti');
      expect(mopti, isNotNull);
      expect(mopti!.chefLieu, equals('Mopti'));
      expect(mopti.latitude, inInclusiveRange(14.0, 15.0));
      expect(mopti.longitude, inInclusiveRange(-5.0, -3.0));
      expect(mopti.attraits.any((a) => a.contains('Djenné')), isTrue);
    });

    testWidgets('RegionDetailScreen displays statistics and UNESCO card for Mopti', (tester) async {
      final mopti = RegionData.findById('mopti')!;

      await tester.pumpWidget(
        MaterialApp(
          home: RegionDetailScreen(region: mopti),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Région de Mopti'), findsWidgets);
      expect(find.text('Chef-lieu'), findsOneWidget);
      expect(find.text('Mopti'), findsWidgets);
      expect(find.text('Population'), findsOneWidget);
      expect(find.text('Superficie'), findsOneWidget);
      expect(find.text('JOYAU PATRIMONIAL UNESCO'), findsOneWidget);
      expect(find.text('Voir la Fiche Détaillée de Djenné'), findsOneWidget);
      expect(find.text('Sites Historiques & Zones Clés'), findsOneWidget);
    });
  });
}

