import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFF075E4D),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRouter.profil);
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
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Aide & Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                  ],
                ),
              ),
            ),
          ),

          // Contenu
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              children: [
                // Carte Contact ODC
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF075E4D).withValues(alpha: 0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
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
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF075E4D).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.support_agent_rounded, color: Color(0xFF075E4D), size: 28),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assistance MaliExplorer',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF075E4D)),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Équipe projet & ODC Mali',
                                  style: TextStyle(fontSize: 12.5, color: Color(0xFF6C7C77)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildContactRow(Icons.mail_outline_rounded, 'Email', 'contact@maliexplorer.ml'),
                      const SizedBox(height: 10),
                      _buildContactRow(Icons.location_on_outlined, 'Lieu', 'Orange Digital Center, Bamako, Mali'),
                      const SizedBox(height: 10),
                      _buildContactRow(Icons.person_pin_circle_outlined, 'Développeurs', 'Famory Josue Sissoko & Hamath Diallo'),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'QUESTIONS FRÉQUENTES (FAQ)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6C7C77),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                _buildFaqTile(
                  'Comment gagner des points et badges ?',
                  'Participez aux Quiz thématiques sur l\'histoire, la gastronomie et le patrimoine malien. Chaque bonne réponse vous rapporte des points pour faire évoluer votre badge Bambara.',
                ),
                _buildFaqTile(
                  'Comment s\'inscrire comme Guide ou Artisan ?',
                  'Lors de l\'inscription, sélectionnez le rôle correspondant (Guide ou Artisan). Fournissez vos justificatifs professionnels (pièce d\'identité, certificat) pour validation par notre équipe.',
                ),
                _buildFaqTile(
                  'Les photos et documents sont-ils protégés ?',
                  'Oui, tous vos documents et photos sont stockés de manière sécurisée via notre infrastructure cloud avec chiffrement des accès.',
                ),
                _buildFaqTile(
                  'Comment sauvegarder mes lieux et plats favoris ?',
                  'Sur chaque fiche détaillée (Plat, Ethnie, Ville ou Lieu historique), cliquez sur le cœur en haut à droite pour l\'ajouter instantanément à vos Favoris.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF075E4D)),
        const SizedBox(width: 10),
        Text('$label : ', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF16332D))),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568)),
          ),
        ),
      ],
    );
  }

  static Widget _buildFaqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        iconColor: const Color(0xFF075E4D),
        collapsedIconColor: const Color(0xFF6C7C77),
        title: Text(
          question,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: Color(0xFF16332D)),
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF4A5568), height: 1.45),
          ),
        ],
      ),
    );
  }
}
