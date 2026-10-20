import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import '../providers/guides_provider.dart';
import '../router/app_router.dart';
import 'auth/auth_controller.dart';

class PromoteurDashboardScreen extends ConsumerStatefulWidget {
  const PromoteurDashboardScreen({super.key});

  @override
  ConsumerState<PromoteurDashboardScreen> createState() =>
      _PromoteurDashboardScreenState();
}

class _PromoteurDashboardScreenState
    extends ConsumerState<PromoteurDashboardScreen> {
  // Données du partenaire (Guide ou Promoteur) synchronisées avec le backend
  String _nomOrganisation = 'Espace Professionnel MaliExplorer';
  String _siegeOrganisation = 'Mali';
  String _nifRccm = 'Profil professionnel certifié';
  String _typePartenaire = 'PROMOTEUR'; // 'PROMOTEUR' ou 'GUIDE'
  String _statutModeration = 'EN_ATTENTE_VALIDATION'; // 'VALIDE', 'EN_ATTENTE_VALIDATION', 'REJETE'
  String? _motifRejet;

  // Projet ou fiche guide en cours
  String _titreProjet = 'Proposition de partenariat culturel et touristique';
  String _descriptionProjet =
      'Présentation de nos activités culturelles, circuits guidés et initiatives de valorisation du patrimoine malien.';
  String _besoinPartenariat =
      'Mise en visibilité sur le réseau MaliExplorer et collaboration avec les visiteurs et acteurs touristiques.';
  bool _recherchePartenariat = true;

  int _vues = 0;
  int _commentaires = 0;
  int _publications = 1;

  bool get _isGuide => _typePartenaire.toUpperCase() == 'GUIDE';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initFromLocalAuth();
      _fetchBackendData();
    });
  }

  /// Initialise les champs d'en-tête à partir de la session utilisateur connectée
  void _initFromLocalAuth() {
    final authState = ref.read(authControllerProvider);
    final userMap = authState.user;
    if (userMap != null) {
      final rawRole = (userMap['role'] ?? userMap['roleName'] ?? '').toString().toLowerCase();
      final isGuideRole = rawRole.contains('guide');
      final fullName = '${userMap['prenom'] ?? ''} ${userMap['nom'] ?? ''}'.trim();
      final org = (userMap['nomOrganisation'] ?? '').toString().trim();
      final adr = (userMap['adresse'] ?? '').toString().trim();

      setState(() {
        _typePartenaire = isGuideRole ? 'GUIDE' : 'PROMOTEUR';
        if (org.isNotEmpty) {
          _nomOrganisation = org;
        } else if (fullName.isNotEmpty) {
          _nomOrganisation = isGuideRole ? 'Guide : $fullName' : fullName;
        }
        if (adr.isNotEmpty) {
          _siegeOrganisation = adr;
        }
        if (isGuideRole) {
          _nifRccm = 'Spécialité : Guide Touristique';
          if (_titreProjet == 'Proposition de partenariat culturel et touristique') {
            _titreProjet = 'Candidature Guide Touristique : ${fullName.isNotEmpty ? fullName : "MaliExplorer"}';
          }
        }
      });
    }
  }

  /// Synchronise les statistiques, le projet et le statut de modération depuis Spring Boot
  Future<void> _fetchBackendData() async {
    try {
      final resStats = await ApiService().get('/partenaires/statistiques');
      if (resStats.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resStats.bodyBytes));
        if (mounted) {
          setState(() {
            _vues = (data['vues'] as num?)?.toInt() ?? _vues;
            _commentaires = (data['commentaires'] as num?)?.toInt() ?? _commentaires;
            _publications = (data['publications'] as num?)?.toInt() ?? _publications;
            if (data['statutModeration'] != null) {
              _statutModeration = data['statutModeration'].toString();
            }
          });
        }
      }

      final resProjet = await ApiService().get('/partenaires/mon-projet');
      if (resProjet.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resProjet.bodyBytes));
        if (mounted) {
          setState(() {
            if (data['typePartenaire'] != null && data['typePartenaire'].toString().isNotEmpty) {
              _typePartenaire = data['typePartenaire'].toString();
            }
            if (data['specialiteOuOrganisation'] != null &&
                data['specialiteOuOrganisation'].toString().isNotEmpty) {
              if (_isGuide) {
                _nifRccm = data['specialiteOuOrganisation'].toString();
                if (data['nomComplet'] != null && data['nomComplet'].toString().isNotEmpty) {
                  _nomOrganisation = 'Guide : ${data['nomComplet']}';
                }
              } else {
                _nomOrganisation = data['specialiteOuOrganisation'].toString();
              }
            } else if (data['nomComplet'] != null && data['nomComplet'].toString().isNotEmpty) {
              _nomOrganisation = data['nomComplet'].toString();
            }
            if (data['adresse'] != null && data['adresse'].toString().isNotEmpty) {
              _siegeOrganisation = data['adresse'].toString();
            }
            if (data['titreProjet'] != null && data['titreProjet'].toString().isNotEmpty) {
              _titreProjet = data['titreProjet'].toString();
            }
            if (data['besoinPartenariat'] != null && data['besoinPartenariat'].toString().isNotEmpty) {
              _besoinPartenariat = data['besoinPartenariat'].toString();
              _descriptionProjet = data['besoinPartenariat'].toString();
            }
            if (data['recherchePartenariat'] != null) {
              _recherchePartenariat = data['recherchePartenariat'] == true;
            }
            if (data['statutModeration'] != null) {
              _statutModeration = data['statutModeration'].toString();
            }
            _motifRejet = data['motifRejet']?.toString();
          });
        }
      }
    } catch (e) {
      debugPrint('[PromoteurDashboard] Note synchronisation stats: $e');
    }
  }

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
                Text(
                  _isGuide
                      ? 'Modifier ma fiche guide & demande'
                      : 'Modifier mon projet culturel',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF075E4D),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isGuide
                      ? 'Titre de votre offre / spécialité guide'
                      : 'Titre du projet / événement',
                  style: const TextStyle(
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
                    hintText: _isGuide
                        ? 'Ex : Circuits historiques Djenné & Pays Dogon'
                        : 'Ex : Festival International du Sahel',
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _isGuide
                      ? 'Présentation & expérience du guide'
                      : 'Description du projet',
                  style: const TextStyle(
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
                    hintText: _isGuide
                        ? 'Décrivez vos circuits, langues parlées et années d\'expérience...'
                        : 'Présentez la portée culturelle de l\'événement...',
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _isGuide
                      ? 'Disponibilités & proposition de partenariat'
                      : 'Besoins de partenariat & Sponsoring',
                  style: const TextStyle(
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
                    hintText: _isGuide
                        ? 'Zones couvertes, tarifs indicatifs, partenariats agences...'
                        : 'Montants, partenariats logistiques, médias...',
                  ),
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Soumettre à validation & activer le partenariat',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Envoyer le dossier dans Demandes de partenariat (Admin)',
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
                    onPressed: () async {
                      final t = titreController.text.trim();
                      final d = descController.text.trim();
                      final b = besoinController.text.trim();
                      setState(() {
                        _titreProjet = t;
                        _descriptionProjet = d;
                        _besoinPartenariat = b.isNotEmpty ? b : d;
                        _recherchePartenariat = rechercheActive;
                        _statutModeration = rechercheActive ? 'EN_ATTENTE_VALIDATION' : 'VALIDE';
                        _motifRejet = null;
                      });
                      Navigator.pop(ctx);
                      try {
                        final res = await ApiService().put(
                          '/partenaires/mon-projet',
                          body: {
                            'titreProjet': t,
                            'besoinPartenariat': b.isNotEmpty ? b : d,
                            'recherchePartenariat': rechercheActive,
                          },
                        );
                        if (res.statusCode == 200) {
                          ref.invalidate(guidesProvider);
                          await _fetchBackendData();
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Demande envoyée à l\'administration pour validation !'),
                              backgroundColor: Color(0xFF075E4D),
                            ),
                          );
                        }
                      } catch (err) {
                        debugPrint('[PromoteurDashboard] Erreur synchronisation: $err');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF075E4D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Soumettre la demande à validation',
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

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final dateController = TextEditingController();
    final lieuController = TextEditingController();
    final villeController = TextEditingController(text: 'Bamako');
    final prixController = TextEditingController(text: 'Gratuit');
    Uint8List? selectedImageBytes;
    String? selectedImageName;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
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
                const Row(
                  children: [
                    Icon(Icons.festival_rounded, color: Color(0xFF075E4D), size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Créer un nouvel événement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF075E4D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Titre de l\'événement *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF075E4D))),
                const SizedBox(height: 6),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'Ex: Nuit du Mandé, Biennale de Bamako...',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF075E4D))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: dateController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              hintText: 'Ex: 15 Mars 2026',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tarif *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF075E4D))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: prixController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              hintText: 'Ex: Gratuit ou 2000 FCFA',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Lieu *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF075E4D))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: lieuController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              hintText: 'Ex: Palais de la Culture',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ville *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF075E4D))),
                          const SizedBox(height: 6),
                          TextField(
                            controller: villeController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              hintText: 'Ex: Bamako',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF075E4D))),
                const SizedBox(height: 6),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    hintText: 'Programme, artistes invités...',
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () async {
                    try {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
                      if (picked != null) {
                        final bytes = await picked.readAsBytes();
                        setSheetState(() {
                          selectedImageBytes = bytes;
                          selectedImageName = picked.name;
                        });
                      }
                    } catch (e) {
                      debugPrint('Erreur image: $e');
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF075E4D).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF075E4D)),
                        const SizedBox(width: 8),
                        Text(
                          selectedImageName != null
                              ? 'Affiche sélectionnée : $selectedImageName'
                              : 'Sélectionner l\'affiche de l\'événement',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final titre = titleController.text.trim();
                            final date = dateController.text.trim();
                            if (titre.isEmpty || date.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Veuillez renseigner au moins le titre et la date.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            setSheetState(() => isSubmitting = true);
                            String imageUrl = '';
                            if (selectedImageBytes != null && selectedImageName != null) {
                              try {
                                imageUrl = await StorageService.uploadFile(
                                  folder: 'evenements',
                                  fileName: selectedImageName!,
                                  bytes: selectedImageBytes!,
                                );
                              } catch (e) {
                                debugPrint('Erreur upload affiche: $e');
                              }
                            }
                            try {
                              final body = {
                                'titre': titre,
                                'description': descController.text.trim(),
                                'dateDebut': date,
                                'lieu': lieuController.text.trim().isNotEmpty ? lieuController.text.trim() : 'Mali',
                                'ville': villeController.text.trim().isNotEmpty ? villeController.text.trim() : 'Bamako',
                                'prix': prixController.text.trim().isNotEmpty ? prixController.text.trim() : 'Gratuit',
                                'imageUrl': imageUrl.isNotEmpty ? imageUrl : null,
                                'statut': 'EN_ATTENTE',
                              };
                              final res = await ApiService().post('/evenements', body: body);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (res.statusCode == 200 || res.statusCode == 201) {
                                setState(() {
                                  _publications++;
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Événement soumis à l\'administration avec succès !'),
                                      backgroundColor: Color(0xFF075E4D),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              setSheetState(() => isSubmitting = false);
                              debugPrint('Erreur création événement: $e');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF075E4D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Soumettre l\'événement à validation',
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
                          const SizedBox(width: 10),
                          Text(
                            _isGuide ? 'Espace Guide & Partenariat' : 'Espace Promoteur',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 30.0),
                        child: Text(
                          _isGuide
                              ? 'Gestion de votre fiche guide certifié et demandes de partenariat'
                              : 'Gestion de vos événements, projets culturels et partenariats',
                          style: const TextStyle(
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

                        // Section Projet Culturel ou Fiche Guide en cours
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                _isGuide
                                    ? 'Ma Fiche Guide & Partenariat'
                                    : 'Mon Projet Culturel',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF16332D),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                if (!_isGuide)
                                  TextButton.icon(
                                    onPressed: _showAddEventDialog,
                                    icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                                    label: const Text('Événement'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFFD6A23A),
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

                        // Cartes d'actions rapides (Villes & Guides)
                        Row(
                          children: [
                            Expanded(
                              child: _buildSynergyCard(
                                title: 'Villes & Régions',
                                subtitle: 'Territoires & circuits',
                                icon: Icons.location_city_rounded,
                                color: const Color(0xFF075E4D),
                                onTap: () => context.push(AppRouter.villesList),
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
    final bool isValide = _statutModeration == 'VALIDE';
    final bool isRejete = _statutModeration == 'REJETE';

    final Color badgeBg = isValide
        ? const Color(0xFF10B981).withValues(alpha: 0.12)
        : isRejete
            ? const Color(0xFFDC2626).withValues(alpha: 0.12)
            : const Color(0xFFF59E0B).withValues(alpha: 0.12);

    final Color badgeColor = isValide
        ? const Color(0xFF059669)
        : isRejete
            ? const Color(0xFFDC2626)
            : const Color(0xFFD97706);

    final IconData badgeIcon = isValide
        ? Icons.verified_rounded
        : isRejete
            ? Icons.cancel_rounded
            : Icons.hourglass_top_rounded;

    final String badgeText = isValide
        ? 'Compte Validé'
        : isRejete
            ? 'Demande Rejetée'
            : 'En attente';

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
                child: Icon(
                  _isGuide ? Icons.person_pin_circle_rounded : Icons.business_center_rounded,
                  color: const Color(0xFF075E4D),
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
              Expanded(
                child: Text(
                  _isGuide ? _nifRccm : 'Organisation : $_nifRccm',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6C7C77),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Badge de modération (Validé / En attente / Rejeté)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      badgeIcon,
                      size: 13,
                      color: badgeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Affichage du motif de rejet lorsque l'administrateur a rejeté la demande
          if (isRejete) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFFDC2626), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Motif du refus administratif :',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (_motifRejet != null && _motifRejet!.trim().isNotEmpty)
                        ? _motifRejet!
                        : 'Veuillez compléter vos informations et resoumettre votre demande.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF991B1B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 34,
                    child: OutlinedButton.icon(
                      onPressed: _showEditProjectDialog,
                      icon: const Icon(Icons.edit_rounded, size: 14),
                      label: const Text('Corriger et resoumettre ma demande', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            label: 'Publications',
            value: '$_publications',
            icon: Icons.festival_rounded,
            color: const Color(0xFF075E4D),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            label: 'Partenariat',
            value: _recherchePartenariat ? 'Actif' : 'Inactif',
            icon: Icons.handshake_rounded,
            color: const Color(0xFFD6A23A),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            label: 'Vues',
            value: '$_vues',
            icon: Icons.visibility_rounded,
            color: const Color(0xFF0E8F76),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatItem(
            label: 'Commentaires',
            value: '$_commentaires',
            icon: Icons.chat_bubble_outline_rounded,
            color: const Color(0xFF2E7D32),
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
                child: Text(
                  _isGuide
                      ? 'CIRCUIT & GUIDE TOURISTIQUE CERTIFIÉ'
                      : 'FESTIVAL & ÉVÉNEMENT CULTUREL',
                  style: const TextStyle(
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
