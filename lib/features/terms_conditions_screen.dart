import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

/// Écran des Conditions Générales d'Utilisation de MaliExplorer.
/// Conforme à la charte graphique MaliExplorer et détaillant l'ensemble des règles de la plateforme.
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F5),
      body: Column(
        children: [
          // En-tête vert MaliExplorer
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
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Conditions d\'utilisation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
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

          // Contenu du document
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bannière officielle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF075E4D).withValues(alpha: 0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF075E4D).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.gavel_rounded,
                            color: Color(0xFF075E4D),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MaliExplorer • Charte & CGU',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF075E4D),
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Dernière mise à jour : Octobre 2026',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6C7C77),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildSection(
                    title: '1. Présentation & Origine du Projet',
                    content:
                        'MaliExplorer est une plateforme numérique innovante dédiée à la valorisation, à la préservation et au rayonnement du riche patrimoine culturel, historique, gastronomique et touristique de la République du Mali.\n\n'
                        'Cette application a été conçue et développée par Famory Josue Sissoko et Hamath Diallo, dans le cadre des programmes d\'accélération et de développement technologique soutenus par Orange Digital Center (ODC) Mali.',
                  ),

                  _buildSection(
                    title: '2. Acceptation des Conditions',
                    content:
                        'L\'accès et l\'utilisation de MaliExplorer sont subordonnés à l\'acceptation pleine et sans réserve des présentes Conditions Générales d\'Utilisation (CGU). '
                        'En créant un compte sur la plateforme (que ce soit en qualité de Touriste, de Guide, d\'Artisan ou de Promoteur culturel), vous reconnaissez avoir pris connaissance des présentes dispositions et vous engagez à les respecter.',
                  ),

                  _buildSection(
                    title: '3. Comptes Utilisateurs & Responsabilités',
                    content:
                        '• Exactitude des informations : L\'utilisateur s\'engage à fournir des renseignements personnels et professionnels sincères, exacts et à jour lors de son inscription.\n'
                        '• Sécurité du compte : Chaque utilisateur est responsable de la confidentialité de ses identifiants et de toutes les activités effectuées sous son profil.\n'
                        '• Rôles professionnels (Guides, Artisans, Promoteurs) : Les professionnels s\'engagent à soumettre des pièces justificatives authentiques (pièces d\'identité, enregistrements légaux, certifications) soumises à la modération de l\'équipe MaliExplorer.',
                  ),

                  _buildSection(
                    title: '4. Règles Générales d\'Utilisation de la Plateforme',
                    content:
                        'MaliExplorer est un espace d\'échange bienveillant et de découverte culturelle. Il est formellement interdit de :\n'
                        '• Diffuser des propos haineux, diffamatoires, discriminatoires ou contraires aux bonnes mœurs.\n'
                        '• Altérer le bon fonctionnement de l\'application, tenter des intrusions non autorisées ou exploiter des failles de sécurité.\n'
                        '• Falsifier les scores de quiz, badges ou récompenses de gamification.',
                  ),

                  _buildSection(
                    title: '5. Contenus Publiés par les Utilisateurs & Partenaires',
                    content:
                        'Les artisans, guides et promoteurs demeurent propriétaires des contenus (textes, photographies de créations, tarifs) qu\'ils publient sur la plateforme. Toutefois, ils concèdent à MaliExplorer une licence non exclusive, gratuite et mondiale pour afficher, diffuser et promouvoir ces créations dans le cadre de la promotion du savoir-faire malien.\n\n'
                        'MaliExplorer se réserve le droit de retirer sans préavis tout contenu ne respectant pas les critères de qualité, d\'authenticité ou de légalité.',
                  ),

                  _buildSection(
                    title: '6. Authenticité & Exactitude des Informations Culturelles',
                    content:
                        'Les contenus historiques, ethniques et patrimoniaux sont vérifiés et documentés selon les traditions et sources orales et écrites du Mali. Les guides et promoteurs s\'engagent à transmettre une vision fidèle, respectueuse et rigoureuse des traditions des différentes communautés maliennes.',
                  ),

                  _buildSection(
                    title: '7. Droits & Responsabilités de MaliExplorer',
                    content:
                        'MaliExplorer s\'efforce d\'assurer une disponibilité optimale des services, mais ne peut garantir une absence totale d\'interruptions techniques temporaires. '
                        'La plateforme intervient comme facilitateur culturel et vitrine d\'artisans et guides locaux, sans se substituer aux transactions directes conclues entre visiteurs et prestataires indépendants.',
                  ),

                  _buildSection(
                    title: '8. Respect Communautaire & Sauvegarde du Patrimoine',
                    content:
                        'MaliExplorer valorise les sites classés au patrimoine mondial de l\'UNESCO (Djenné, Tombouctou, Pays Dogon, Tombeau des Askia). Tout utilisateur, visiteur ou guide s\'engage à respecter l\'intégrité physique et la sacralité des monuments et coutumes locales rencontrés.',
                  ),

                  _buildSection(
                    title: '9. Contact & Modalités de Support',
                    content:
                        'Pour toute question relative aux présentes conditions, pour signaler un problème technique ou pour contacter l\'équipe éditoriale :\n\n'
                        '• Équipe de développement : Famory Josue Sissoko & Hamath Diallo\n'
                        '• Partenaire technologique : Orange Digital Center (ODC) Mali\n'
                        '• E-mail : contact@maliexplorer.ml / support@odcmali.org\n'
                        '• Ville : Bamako, République du Mali',
                  ),

                  const SizedBox(height: 16),

                  // Bouton de retour / confirmation
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF075E4D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRouter.home);
                        }
                      },
                      child: const Text(
                        'J\'ai compris et je ferme',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

  Widget _buildSection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF075E4D),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4A5568),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
