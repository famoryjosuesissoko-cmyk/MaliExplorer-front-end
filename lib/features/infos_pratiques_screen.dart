import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

class InfosPratiquesScreen extends StatelessWidget {
  const InfosPratiquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackgroundSecondary : const Color(0xFFF7F9F8),
      body: Column(
        children: [
          // En-tête vert MaliExplorer
          Container(
            color: const Color(0xFF075E4D),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRouter.explorer);
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INFORMATIONS PRATIQUES (F17)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Guide essentiel du voyageur au Mali',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFD1E7DD),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Contenu avec onglets / cartes thématiques
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                // 1. Visas et formalités d'entrée
                _buildInfoSection(
                  context,
                  icon: Icons.badge_rounded,
                  titre: '1. Visas & Formalités d\'Entrée',
                  badge: 'Obligatoire',
                  badgeColor: const Color(0xFFC53030),
                  items: const [
                    'Passeport : Valide au moins 6 mois après la date de retour prévue.',
                    'Visa d\'entrée : Requis pour la plupart des ressortissants hors CEDEAO. Disponible auprès des consulats et ambassades du Mali ou via le portail officiel de visa biométrique.',
                    'Ressortissants CEDEAO : Entrée sans visa sur présentation d\'un passeport ou d\'une carte d\'identité biométrique CEDEAO en cours de validité.',
                    'Enregistrement : Déclaration auprès des services de police/gendarmerie ou de l\'hôtel à l\'arrivée en province.',
                  ],
                ),

                const SizedBox(height: 14),

                // 2. Santé & Vaccinations
                _buildInfoSection(
                  context,
                  icon: Icons.medical_services_rounded,
                  titre: '2. Santé & Vaccinations',
                  badge: 'Exigé à l\'arrivée',
                  badgeColor: const Color(0xFFDD6B20),
                  items: const [
                    'Fièvre Jaune : Vaccination strictement obligatoire. Le carnet international de vaccination (jaune) est systématiquement contrôlé à l\'aéroport international Président Modibo Keïta de Bamako-Sénou.',
                    'Paludisme : Traitement préventif fortement recommandé (chimioprophylaxie) toute l\'année, particulièrement durant et après la saison des pluies. Prévoir répulsifs cutanés et moustiquaires.',
                    'Vaccins recommandés : Hépatites A et B, Méningite A+C+Y+W135, Fièvre typhoïde, Tétanos.',
                    'Eau & Alimentation : Boire de l\'eau minérale capsulée ou préalablement filtrée/bouillie. Éviter les glaçons non sécurisés.',
                  ],
                ),

                const SizedBox(height: 14),

                // 3. Monnaie, Banques & Moyens de paiement
                _buildInfoSection(
                  context,
                  icon: Icons.payments_rounded,
                  titre: '3. Devises, Monnaie & Paiements',
                  badge: 'FCFA (XOF)',
                  badgeColor: const Color(0xFF2E7D32),
                  items: const [
                    'Monnaie officielle : Franc CFA d\'Afrique de l\'Ouest (XOF). Parité fixe avec l\'Euro (1 EUR = 655,957 XOF).',
                    'Mobile Money : Orange Money et Moov Money sont omniprésents et acceptés par la quasi-totalité des commerces, taxis et artisans.',
                    'Cartes bancaires : Les cartes Visa et Mastercard sont acceptées dans les grands hôtels, supermarchés et aux distributeurs automatiques (GAB) à Bamako et grandes villes.',
                    'Espèces : Indispensables pour les marchés artisanaux, transports fluviaux et zones rurales.',
                  ],
                ),

                const SizedBox(height: 14),

                // 4. Climat & Saisons touristiques
                _buildInfoSection(
                  context,
                  icon: Icons.wb_sunny_rounded,
                  titre: '4. Climat & Meilleure Période',
                  badge: 'Saison fraîche : Nov - Fév',
                  badgeColor: const Color(0xFF3182CE),
                  items: const [
                    'Saison fraîche et sèche (Novembre à Février) : Températures idéales (25°C - 32°C le jour, 15°C - 18°C la nuit). Période reine pour visiter les villes historiques, les festivals et naviguer sur le fleuve Niger.',
                    'Saison chaude (Mars à Mai) : Chaleur intense (38°C à 44°C). Vent sec d\'Harmattan.',
                    'Saison des pluies / Hivernage (Juin à Octobre) : Végétation luxuriante, averses tropicales régulières, fleuve à son niveau maximal.',
                  ],
                ),

                const SizedBox(height: 14),

                // 5. Numéros d'urgence utiles
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2825) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF075E4D).withValues(alpha: 0.15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.contact_phone_rounded, color: Color(0xFF075E4D), size: 22),
                          SizedBox(width: 10),
                          Text(
                            'Numéros d\'Urgence au Mali',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF075E4D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildEmergencyRow('Police Secours', '17 / 80 00 11 15'),
                      const Divider(height: 14),
                      _buildEmergencyRow('Sapeurs-Pompiers (Incendie & Secours)', '18 / 80 00 12 01'),
                      const Divider(height: 14),
                      _buildEmergencyRow('Gendarmerie Nationale', '80 00 11 14'),
                      const Divider(height: 14),
                      _buildEmergencyRow('SAMU / Urgences Médicales Bamako', '15 / 20 22 27 77'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildEmergencyRow(String label, String number) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF2D3748)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFE6FFFA),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF075E4D),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required String titre,
    required String badge,
    required Color badgeColor,
    required List<String> items,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2825) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF075E4D).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF075E4D), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF075E4D),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: badgeColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(Icons.circle, size: 6, color: Color(0xFF075E4D)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Colors.grey[300] : const Color(0xFF4A5568),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

