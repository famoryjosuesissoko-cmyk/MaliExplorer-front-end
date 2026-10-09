import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';

class ArtisanDashboardScreen extends StatefulWidget {
  const ArtisanDashboardScreen({super.key});

  @override
  State<ArtisanDashboardScreen> createState() => _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState extends State<ArtisanDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Données de l'artisan (alignées avec le modèle Backend ArtisanModel)
  final String _nomAtelier = 'Atelier Bogolan & Poterie de Djenné';
  String _typeArtisanat = 'Poterie d\'art & Tissage Bogolan';
  final String _statutModeration = 'VALIDE'; // 'VALIDE', 'EN_ATTENTE', 'REJETE'

  // Projet atelier & partenariat B2B
  String _titreProjet = 'Acquisition de 2 fours à céramique et modernisation de l\'atelier';
  String _besoinPartenariat =
      'Recherche d\'un financement de 3 500 000 FCFA ou d\'un partenaire technique pour l\'acquisition d\'équipements modernes de cuisson afin de multiplier par trois la production d\'œuvres exportables.';
  bool _recherchePartenariat = true;

  // Liste des produits dans la boutique
  final List<ArtisanProductItem> _products = [
    ArtisanProductItem(
      title: "Canari d'argile soudanais de luxe",
      price: "25 000 FCFA",
      description:
          "Pot d'argile fait main selon les traditions millénaires de Djenné, orné de motifs spirituels.",
      imageUrl:
          'https://images.unsplash.com/photo-1578749556568-bc2c40e68b61?q=80&w=800&auto=format&fit=crop',
    ),
    ArtisanProductItem(
      title: "Bogolan traditionnel teint à la boue",
      price: "15 000 FCFA",
      description:
          "Tissu précieux teint aux motifs ancestraux du Mali à base de décoctions végétales et de boue fermentée du fleuve Niger.",
      imageUrl:
          'https://images.unsplash.com/photo-1606744824163-985d376605aa?q=80&w=800&auto=format&fit=crop',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showEditProjectDialog() {
    final titreController = TextEditingController(text: _titreProjet);
    final besoinController = TextEditingController(text: _besoinPartenariat);
    final typeController = TextEditingController(text: _typeArtisanat);
    bool recherche = _recherchePartenariat;

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
                  'Modifier mon projet d\'atelier & B2B',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF075E4D),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Spécialité / Type d\'artisanat',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF075E4D),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: typeController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    hintText: 'Ex: Poterie soudanaise, Bogolan...',
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Titre du projet de modernisation',
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
                    hintText: 'Ex: Acquisition de matériel moderne',
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Besoin d\'accompagnement ou de financement',
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
                    hintText: 'Détaillez vos besoins techniques ou financiers...',
                  ),
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Recherche active de partenaires B2B',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: Color(0xFF16332D),
                    ),
                  ),
                  subtitle: const Text(
                    'Visibilité dans l\'annuaire des artisans en recherche de mécènes',
                    style: TextStyle(fontSize: 11.5, color: Colors.grey),
                  ),
                  value: recherche,
                  activeThumbColor: const Color(0xFF075E4D),
                  onChanged: (val) {
                    setModalState(() => recherche = val);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _typeArtisanat = typeController.text;
                        _titreProjet = titreController.text;
                        _besoinPartenariat = besoinController.text;
                        _recherchePartenariat = recherche;
                      });
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Projet d\'atelier mis à jour avec succès'),
                          backgroundColor: Color(0xFF075E4D),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF075E4D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Enregistrer les modifications',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. En-tête vert Espace Artisan
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
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
                      const Expanded(
                        child: Text(
                          'Espace Artisan',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      // Badge Modération
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _statutModeration == 'VALIDE'
                                  ? Icons.verified_rounded
                                  : Icons.hourglass_top_rounded,
                              size: 13,
                              color: const Color(0xFF4ADE80),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _statutModeration,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Text(
                      '$_nomAtelier • $_typeArtisanat',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. TabBar (Mes Créations / Mon Projet & B2B)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: Colors.white,
                ),
                labelColor: const Color(0xFF075E4D),
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.storefront_rounded, size: 18),
                    text: 'Mes Créations',
                  ),
                  Tab(
                    icon: Icon(Icons.handshake_rounded, size: 18),
                    text: 'Projet B2B & Atelier',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 3. Fiche blanche avec TabBarView
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF7F8F5),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(26),
                  ),
                ),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Onglet 1 : Mes Créations (Boutique de l'artisan)
                    _buildCreationsTab(),

                    // Onglet 2 : Projet Atelier & Recherche de Partenariat
                    _buildProjetTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Onglet 1 : Créations
  Widget _buildCreationsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Catalogue (${_products.length} articles)',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16332D),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => context.push(AppRouter.artisanAddProduct),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF075E4D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'Ajouter',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._products.asMap().entries.map((entry) {
            final int index = entry.key;
            final ArtisanProductItem product = entry.value;
            return _buildProductCard(product, index);
          }),
        ],
      ),
    );
  }

  // Onglet 2 : Projet d'Atelier & Partenariat B2B
  Widget _buildProjetTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte statut B2B
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF075E4D),
                  const Color(0xFF075E4D).withValues(alpha: 0.85),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Accompagnement & Financement',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _recherchePartenariat
                            ? 'Actif — Visible par les mécènes & investisseurs'
                            : 'En pause — Dossier masqué aux partenaires',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Carte Détail du Projet
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Dossier de modernisation',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF16332D),
                      ),
                    ),
                    IconButton(
                      onPressed: _showEditProjectDialog,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFF075E4D),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),
                const Text(
                  'Titre du projet',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C7C77),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _titreProjet,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16332D),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Besoins identifiés (Équipement / Financement)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C7C77),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _besoinPartenariat,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF2D3748),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Spécialité artisanale',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C7C77),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _typeArtisanat,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF075E4D),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Bouton Modifier
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _showEditProjectDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF075E4D),
                side: const BorderSide(color: Color(0xFF075E4D)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.edit_note_rounded, size: 20),
              label: const Text(
                'Modifier le dossier de partenariat',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ArtisanProductItem product, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du produit
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              product.imageUrl,
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 150,
                color: const Color(0xFFE2E8F0),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: Color(0xFF94A3B8),
                    size: 36,
                  ),
                ),
              ),
            ),
          ),

          // Détails du produit
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16332D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF075E4D),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6C7C77),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),

                // Boutons d'action (Modifier & Supprimer)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          context.push(AppRouter.artisanAddProduct),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF16332D),
                        side: BorderSide(
                          color: Colors.black.withValues(alpha: 0.15),
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 15),
                      label: const Text(
                        'Modifier',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _products.removeAt(index);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.title} supprimé'),
                            backgroundColor: const Color(0xFF075E4D),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFDC2626),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArtisanProductItem {
  final String title;
  final String price;
  final String description;
  final String imageUrl;

  ArtisanProductItem({
    required this.title,
    required this.price,
    required this.description,
    required this.imageUrl,
  });
}
