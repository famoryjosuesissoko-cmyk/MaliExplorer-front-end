import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mali_explorer_frontend/models/info_pratique_model.dart';

void main() {
  group('InfoPratiqueModel — Tests Unitaires', () {
    test('Désérialisation et accesseurs pour la catégorie VISAS', () {
      final json = {
        'id': 1,
        'titre': '1. Visas & Formalités',
        'description': 'Passeport valide au moins 6 mois.',
        'categorie': 'VISAS',
        'conseils': '• Passeport valide 6 mois\n• Visa biométrique officiel',
        'badge': 'Obligatoire',
        'ordreAffichage': 1,
      };

      final model = InfoPratiqueModel.fromJson(json);

      expect(model.id, 1);
      expect(model.titre, '1. Visas & Formalités');
      expect(model.categorie, 'VISAS');
      expect(model.defaultIcon, Icons.badge_rounded);
      expect(model.defaultBadgeColor, const Color(0xFFC53030));
      expect(model.displayBadge, 'Obligatoire');
      expect(model.itemsList, ['Passeport valide 6 mois', 'Visa biométrique officiel']);
    });

    test('Désérialisation et accesseurs pour la catégorie SANTE', () {
      final json = {
        'id': 2,
        'titre': 'Santé & Vaccins',
        'description': '- Fièvre jaune obligatoire\n- Paludisme chimioprophylaxie',
        'categorie': 'SANTE',
        'ordre': 2,
      };

      final model = InfoPratiqueModel.fromJson(json);

      expect(model.id, 2);
      expect(model.categorie, 'SANTE');
      expect(model.defaultIcon, Icons.medical_services_rounded);
      expect(model.defaultBadgeColor, const Color(0xFFDD6B20));
      expect(model.displayBadge, 'Exigé à l\'arrivée');
      expect(model.itemsList, ['Fièvre jaune obligatoire', 'Paludisme chimioprophylaxie']);
    });

    test('Extraction structurée des lignes d\'urgence via emergencyRows', () {
      final json = {
        'id': 5,
        'titre': 'Urgences au Mali',
        'description': 'Numéros d\'urgence nationaux',
        'categorie': 'URGENCES',
        'coordonnees': 'Police Secours: 17 / 80 00 11 15\nSapeurs-Pompiers: 18 / 80 00 12 01\nSAMU: 15',
        'ordreAffichage': 5,
      };

      final model = InfoPratiqueModel.fromJson(json);

      expect(model.categorie, 'URGENCES');
      expect(model.defaultIcon, Icons.contact_phone_rounded);
      expect(model.defaultBadgeColor, const Color(0xFFE53E3E));
      expect(model.displayBadge, 'Urgence 24/7');

      final rows = model.emergencyRows;
      expect(rows.length, 3);
      expect(rows[0].key, 'Police Secours');
      expect(rows[0].value, '17 / 80 00 11 15');
      expect(rows[1].key, 'Sapeurs-Pompiers');
      expect(rows[1].value, '18 / 80 00 12 01');
      expect(rows[2].key, 'SAMU');
      expect(rows[2].value, '15');
    });

    test('Sérialisation toJson et gestion des champs optionnels', () {
      const model = InfoPratiqueModel(
        id: 3,
        titre: 'Devises & Monnaie',
        description: 'Franc CFA (XOF)',
        categorie: 'DEVISES',
        ordreAffichage: 3,
      );

      final map = model.toJson();

      expect(map['id'], 3);
      expect(map['titre'], 'Devises & Monnaie');
      expect(map['categorie'], 'DEVISES');
      expect(map['ordreAffichage'], 3);
      expect(map.containsKey('imageUrl'), isFalse);
      expect(map.containsKey('badge'), isFalse);
    });
  });
}
