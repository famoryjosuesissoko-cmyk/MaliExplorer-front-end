import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class PromoteurDashboardScreen extends ConsumerStatefulWidget {
  const PromoteurDashboardScreen({super.key});

  @override
  ConsumerState<PromoteurDashboardScreen> createState() =>
      _PromoteurDashboardScreenState();
}

class _PromoteurDashboardScreenState
    extends ConsumerState<PromoteurDashboardScreen> {
  // Données du promoteur (modifiables localement et synchronisables)
  final String _nomOrganisation = 'Agence Sahel Roots Événements';
  final String _siegeOrganisation = 'Bamako, ACI 2000';
  final String _nifRccm = '0841234567-RCCM';
  final String _statutModeration = 'VALIDE'; // 'VALIDE', 'EN_ATTENTE', 'REJETE'

  // Projet en cours
  String _titreProjet = 'Festival des Masques et Traditions du Mali 2027';
  String _descriptionProjet =
      'Grand rassemblement culturel panafricain célébrant les danses masquées Dogon, la poésie nomade Touareg et les tissages traditionnels de Ségou.';
  String _besoinPartenariat =
      'Recherche de sponsors hôteliers, d\'investisseurs B2B et d\'un co-financement de 10 000 000 FCFA pour la logistique scénique, la promotion internationale et l\'accueil des délégations.';
  bool _recherchePartenariat = true;

  void _showEditProjectDialog() {
    final titreController = TextEditingController(text: _titreProjet);
    final descController = TextEditingController(text: _descriptionProjet);
    final besoinController = TextEditingController(text: _besoinPartenariat);
    bool rechercheActive = _recherchePartenariat;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Modifier mon projet culturel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF075E4D),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Titre du projet / événement',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF075E4D),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: titreController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Ex : Festival International du Sahel',
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Description du projet',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF075E4D),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Présentez la portée culturelle de l\'événement...',
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Besoins de partenariat & Sponsoring',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF075E4D),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: besoinController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Montants, partenariats logistiques, médias...',
                  ),
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Activer la recherche de partenariats',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Rendre la fiche visible aux investisseurs',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                  value: rechercheActive,
                  activeThumbColor: const Color(0xFF075E4D),
                  onChanged: (val) {
                    setModalState(() {
                      rechercheActive = val;
                    });
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _titreProjet = titreController.text.trim();
                        _descriptionProjet = descController.text.trim();
                        _besoinPartenariat = besoinController.text.trim();
                        _recherchePartenariat = rechercheActive;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Projet culturel mis à jour avec succès !'),
                          backgroundColor: Color(0xFF075E4D),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF075E4D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Enregistrer les modifications',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF075E4D),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. En-tête vert Espace Promoteur
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go(AppRouter.home);
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
                          const SizedBox(width: 10),
                          const Text(
                            'Espace Promoteur',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.only(left: 30.0),
                        child: Text(
                          'Gestion de vos événements, projets culturels et partenariats',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Fiche blanche principale
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF7F8F5),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 110),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Carte Organisation & Modération
                        _buildOrganisationCard(),

                        const SizedBox(height: 20),

                        // Statistiques rapides
                        _buildStatsRow(),

                        const SizedBox(height: 24),

                        // Section Projet Culturel en cours
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Mon Projet Culturel',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF16332D),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _showEditProjectDialog,
                              icon: const Icon(Icons.edit_outlined, size: 16),
                              label: const Text('Modifier'),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF075E4D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        _buildProjectCard(),

                        const SizedBox(height: 26),

                        // Section Synergies & Collaborations
                        const Text(
                          'Synergies & Réseau MaliExplorer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16332D),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Associez des professionnels locaux certifiés à vos événements',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6C7C77),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // 2 cartes d'actions rapides (Artisans & Guides)
                        Row(
                          children: [
                            Expanded(
                              child: _buildSynergyCard(
                                title: 'Artisans Exposants',
                                subtitle: 'Bogolan, cuir, bijoux',
                                icon: Icons.handyman_rounded,
                                color: const Color(0xFF075E4D),
                                onTap: () => context.push(AppRouter.artisans),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildSynergyCard(
                                title: 'Guides Touristiques',
                                subtitle: 'Circuits & visites',
                                icon: Icons.person_pin_circle_rounded,
                                color: const Color(0xFFD6A23A),
                                onTap: () => context.push(AppRouter.guides),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrganisationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF075E4D).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  color: Color(0xFF075E4D),
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nomOrganisation,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16332D),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _siegeOrganisation,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6C7C77),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'NIF / RCCM : $_nifRccm',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C7C77),
                ),
              ),
              // Badge de modération
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statutModeration == 'VALIDE'
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _statutModeration == 'VALIDE'
                          ? Icons.verified_rounded
                          : Icons.hourglass_top_rounded,
                      size: 13,
                      color: _statutModeration == 'VALIDE'
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _statutModeration == 'VALIDE'
                          ? 'Compte Validé'
                          : 'En attente',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _statutModeration == 'VALIDE'
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            label: 'Projet actif',
            value: '1',
            icon: Icons.festival_rounded,
            color: const Color(0xFF075E4D),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            label: 'Partenariats',
            value: _recherchePartenariat ? 'Activé' : 'Inactif',
            icon: Icons.handshake_rounded,
            color: const Color(0xFFD6A23A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            label: 'Visibilité',
            value: 'Nationale',
            icon: Icons.visibility_rounded,
            color: const Color(0xFF0E8F76),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Color(0xFF16332D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF6C7C77),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF075E4D).withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF9EE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFD6A23A).withValues(alpha: 0.5),
                  ),
                ),
                child: const Text(
                  'FESTIVAL & ÉVÉNEMENT CULTUREL',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF8B4513),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                _recherchePartenariat
                    ? Icons.check_circle_rounded
                    : Icons.pause_circle_rounded,
                size: 16,
                color: _recherchePartenariat
                    ? const Color(0xFF059669)
                    : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                _recherchePartenariat ? 'Recherche active' : 'En pause',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _recherchePartenariat
                      ? const Color(0xFF059669)
                      : Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _titreProjet,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF075E4D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _descriptionProjet,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF4A5568),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF9EE),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD6A23A).withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.handshake_rounded,
                        color: Color(0xFF8B4513), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Besoins de Partenariat & Sponsoring :',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _besoinPartenariat,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF5D4037),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSynergyCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6C7C77),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
