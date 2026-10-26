import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../core/services/api_service.dart';
import '../core/services/auth_service.dart';
import '../core/services/storage_service.dart';
import '../providers/explorer_provider.dart';
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
  String _nomOrganisation = 'Espace Professionnel MaliExplorer';
  String _siegeOrganisation = 'Mali';
  String _nifRccm = 'Profil professionnel certifié';
  String _typePartenaire = 'PROMOTEUR'; // 'PROMOTEUR', 'GUIDE', ou 'ADMIN'
  String _statutModeration = 'VALIDE';
  String? _motifRejet;

  // Projet ou circuit guide en cours
  String _titreProjet = '';
  String _descriptionProjet = '';
  String _besoinPartenariat = '';
  bool _recherchePartenariat = false;

  int _vues = 0;
  int _commentaires = 0;
  int _publications = 0;
  int _billetsVendus = 0;
  bool _isLoading = true;
  String? _errorMessage;

  // Événements du promoteur & Commandes de billets
  List<Map<String, dynamic>> _mesEvenements = [];
  List<Map<String, dynamic>> _mesCommandes = [];

  // Activités récentes (Dashboard Mobile Administrateur)
  List<Map<String, dynamic>> _activitesRecentes = [];
  Timer? _adminRefreshTimer;

  bool get _isAdmin => _typePartenaire.toUpperCase() == 'ADMIN';
  bool get _isGuide => _typePartenaire.toUpperCase() == 'GUIDE';

  bool get _hasGuideCircuit {
    final t = _titreProjet.trim();
    if (t.isEmpty) return false;
    if (t.startsWith('Candidature Guide')) return false;
    if (t.startsWith("Demande d'adhésion")) return false;
    return true;
  }

  bool get _hasPromoteurProjet {
    final t = _titreProjet.trim();
    if (t.isEmpty) return false;
    if (t.startsWith("Demande d'adhésion")) return false;
    if (t.startsWith('Candidature Guide')) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(authControllerProvider.notifier).syncProfile();
      if (!mounted) return;
      _initFromLocalAuth();
      await _fetchBackendData();
      if (mounted && _isAdmin) {
        _adminRefreshTimer = Timer.periodic(
          const Duration(seconds: 30),
          (_) => _fetchBackendData(silent: true),
        );
      }
    });
  }

  @override
  void dispose() {
    _adminRefreshTimer?.cancel();
    super.dispose();
  }

  void _initFromLocalAuth() {
    final authState = ref.read(authControllerProvider);
    final userMap = authState.user;
    final userModel = authState.userModel;

    final rawRole = (userModel?.role.name ??
            userMap?['role'] ??
            userMap?['roleName'] ??
            AuthService.cachedRole ??
            '')
        .toString()
        .toLowerCase();
    final isAdminRole = rawRole.contains('admin');
    final isGuideRole = !isAdminRole && rawRole.contains('guide');
    final fullName = userModel != null
        ? '${userModel.prenom} ${userModel.nom}'.trim()
        : '${userMap?['prenom'] ?? ''} ${userMap?['nom'] ?? ''}'.trim();
    final org = (userModel?.nomOrganisation ?? userMap?['nomOrganisation'] ?? '')
        .toString()
        .trim();
    final adr =
        (userModel?.adresse ?? userMap?['adresse'] ?? '').toString().trim();
    final statut = (userModel?.statutModeration ??
            userMap?['statutModeration'] ??
            AuthService.cachedStatutModeration ??
            'VALIDE')
        .toString()
        .toUpperCase();

    setState(() {
      if (statut.isNotEmpty) {
        _statutModeration = statut;
      }
      if (isAdminRole) {
        _typePartenaire = 'ADMIN';
        _nomOrganisation = fullName.isNotEmpty ? 'Admin : $fullName' : 'Administration MaliExplorer';
        _nifRccm = 'Supervision & Modération';
      } else if (isGuideRole) {
        _typePartenaire = 'GUIDE';
        _nomOrganisation = fullName.isNotEmpty ? 'Guide : $fullName' : 'Guide Touristique';
        _nifRccm = 'Spécialité : Guide Touristique';
      } else {
        _typePartenaire = 'PROMOTEUR';
        if (org.isNotEmpty) {
          _nomOrganisation = org;
        } else if (fullName.isNotEmpty) {
          _nomOrganisation = fullName;
        }
      }
      if (adr.isNotEmpty) {
        _siegeOrganisation = adr;
      }
    });
  }

  Future<void> _fetchBackendData({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      if (_isAdmin) {
        final resAct = await ApiService().get('/admin/dashboard/activites-recentes');
        final resCmd = await ApiService().get('/evenements/billets/admin');
        if (!mounted) return;
        setState(() {
          if (resAct.statusCode == 200) {
            final decoded = jsonDecode(utf8.decode(resAct.bodyBytes));
            if (decoded is List) {
              _activitesRecentes = decoded
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();
            }
          }
          if (resCmd.statusCode == 200) {
            final decodedCmd = jsonDecode(utf8.decode(resCmd.bodyBytes));
            if (decodedCmd is List) {
              _mesCommandes = decodedCmd
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();
            }
          }
          _isLoading = false;
        });
        return;
      }

      final resStats = await ApiService().get('/partenaires/statistiques');
      if (resStats.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resStats.bodyBytes));
        if (mounted) {
          setState(() {
            _vues = (data['vues'] as num?)?.toInt() ?? 0;
            _commentaires = (data['commentaires'] as num?)?.toInt() ?? 0;
            _publications = (data['publications'] as num?)?.toInt() ?? 0;
            _billetsVendus = (data['billetsVendus'] as num?)?.toInt() ?? 0;
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
            if (data['typePartenaire'] != null &&
                data['typePartenaire'].toString().isNotEmpty &&
                !_isAdmin) {
              _typePartenaire = data['typePartenaire'].toString();
            }
            if (data['specialiteOuOrganisation'] != null &&
                data['specialiteOuOrganisation'].toString().isNotEmpty) {
              if (_isGuide) {
                _nifRccm = data['specialiteOuOrganisation'].toString();
                if (data['nomComplet'] != null &&
                    data['nomComplet'].toString().isNotEmpty) {
                  _nomOrganisation = 'Guide : ${data['nomComplet']}';
                }
              } else {
                _nomOrganisation = data['specialiteOuOrganisation'].toString();
              }
            } else if (data['nomComplet'] != null &&
                data['nomComplet'].toString().isNotEmpty) {
              _nomOrganisation = data['nomComplet'].toString();
            }
            if (data['adresse'] != null &&
                data['adresse'].toString().isNotEmpty) {
              _siegeOrganisation = data['adresse'].toString();
            }
            _titreProjet = data['titreProjet']?.toString() ?? '';
            _besoinPartenariat = data['besoinPartenariat']?.toString() ?? '';
            _descriptionProjet = _besoinPartenariat;
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

      if (!_isGuide) {
        final resEvts = await ApiService().get('/evenements/mes-evenements');
        if (resEvts.statusCode == 200) {
          final listEvts = jsonDecode(utf8.decode(resEvts.bodyBytes));
          if (listEvts is List && mounted) {
            setState(() {
              _mesEvenements = listEvts
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();
              _publications = _mesEvenements.length;
            });
          }
        }
        final resCmds = await ApiService().get('/evenements/billets/promoteur');
        if (resCmds.statusCode == 200) {
          final listCmds = jsonDecode(utf8.decode(resCmds.bodyBytes));
          if (listCmds is List && mounted) {
            setState(() {
              _mesCommandes = listCmds
                  .whereType<Map>()
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList();
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _publications = _hasGuideCircuit ? 1 : 0;
          });
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('[PromoteurDashboard] Note synchronisation: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Impossible de synchroniser les données avec le serveur.';
        });
      }
    }
  }

  void _showEditProjectDialog() {
    final isCreatingFirst = _isGuide ? !_hasGuideCircuit : !_hasPromoteurProjet;
    final initialTitle = isCreatingFirst ? '' : _titreProjet;
    final initialDesc = isCreatingFirst ? '' : _descriptionProjet;
    final initialBesoin = isCreatingFirst ? '' : _besoinPartenariat;

    final titreController = TextEditingController(text: initialTitle);
    final descController = TextEditingController(text: initialDesc);
    final besoinController = TextEditingController(text: initialBesoin);
    bool rechercheActive = isCreatingFirst ? true : _recherchePartenariat;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final bottomPadding = MediaQuery.of(ctx).viewInsets.bottom > 0
              ? MediaQuery.of(ctx).viewInsets.bottom + 24
              : MediaQuery.of(ctx).padding.bottom + 40;
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: bottomPadding,
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
                        ? (isCreatingFirst
                            ? 'Créer mon circuit touristique'
                            : 'Modifier mon circuit & ma fiche guide')
                        : (isCreatingFirst
                            ? 'Créer mon projet culturel'
                            : 'Modifier mon projet culturel'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF075E4D),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isGuide
                        ? 'Titre du circuit / spécialité guide *'
                        : 'Titre du projet culturel *',
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
                        ? 'Itinéraire, langues parlées & expérience *'
                        : 'Description du projet *',
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
                          ? 'Décrivez les étapes du circuit, la durée et les langues parlées...'
                          : 'Présentez la portée culturelle du projet...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _isGuide
                        ? 'Zones couvertes, disponibilités & tarifs indicatifs'
                        : 'Besoins de partenariat & sponsoring',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF075E4D),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: besoinController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: _isGuide
                          ? 'Ex : Départs de Bamako/Ségou, groupes de 2 à 10 personnes...'
                          : 'Partenariats logistiques, médias, institutions...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _isGuide
                          ? 'Rendre mon circuit visible aux visiteurs'
                          : 'Activer la recherche de partenaires',
                      style: const TextStyle(
                          fontSize: 13.5, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _isGuide
                          ? 'Afficher ce circuit sur la liste publique des guides certifiés'
                          : 'Afficher ce projet dans les opportunités de partenariat',
                      style:
                          const TextStyle(fontSize: 11.5, color: Colors.grey),
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
                        if (t.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez saisir un titre.'),
                              backgroundColor: Color(0xFFDC2626),
                            ),
                          );
                          return;
                        }
                        final combinedBesoin = b.isNotEmpty && d.isNotEmpty
                            ? '$d\n$b'
                            : (b.isNotEmpty ? b : d);
                        Navigator.pop(ctx);
                        try {
                          final res = await ApiService().put(
                            '/partenaires/mon-projet',
                            body: {
                              'titreProjet': t,
                              'besoinPartenariat': combinedBesoin,
                              'recherchePartenariat': rechercheActive,
                            },
                          );
                          if (res.statusCode == 200) {
                            ref.invalidate(guidesProvider);
                            await _fetchBackendData();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isGuide
                                        ? (isCreatingFirst
                                            ? 'Circuit créé et publié avec succès !'
                                            : 'Circuit mis à jour avec succès !')
                                        : 'Projet culturel enregistré avec succès !',
                                  ),
                                  backgroundColor: const Color(0xFF075E4D),
                                ),
                              );
                            }
                          }
                        } catch (err) {
                          debugPrint(
                              '[PromoteurDashboard] Erreur sauvegarde: $err');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF075E4D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isCreatingFirst
                            ? (_isGuide
                                ? 'Publier mon circuit'
                                : 'Enregistrer le projet')
                            : 'Enregistrer les modifications',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDateIso(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _formatTime24(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  DateTime? _tryParseIsoDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return DateTime.tryParse(raw.trim());
  }

  TimeOfDay? _tryParseTime(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.trim().split(':');
    if (parts.length >= 2) {
      final h = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (h != null && m != null) {
        return TimeOfDay(hour: h, minute: m);
      }
    }
    return null;
  }

  void _showEventDialog({Map<String, dynamic>? existingEvent}) {
    final bool isEditing = existingEvent != null && existingEvent['id'] != null;
    final titleController = TextEditingController(
      text: existingEvent?['titre']?.toString() ?? '',
    );
    final descController = TextEditingController(
      text: existingEvent?['description']?.toString() ?? '',
    );
    final lieuController = TextEditingController(
      text: existingEvent?['lieu']?.toString() ?? '',
    );
    final villeController = TextEditingController(
      text: existingEvent?['ville']?.toString() ?? 'Bamako',
    );
    final prixController = TextEditingController(
      text: existingEvent?['prix']?.toString() ?? 'Gratuit',
    );

    DateTime selectedDateDebut =
        _tryParseIsoDate(existingEvent?['dateDebut']?.toString()) ??
            DateTime.now().add(const Duration(days: 1));
    TimeOfDay selectedHeureDebut =
        _tryParseTime(existingEvent?['heureDebut']?.toString()) ??
            const TimeOfDay(hour: 9, minute: 0);
    DateTime selectedDateFin =
        _tryParseIsoDate(existingEvent?['dateFin']?.toString()) ??
            selectedDateDebut;
    TimeOfDay selectedHeureFin =
        _tryParseTime(existingEvent?['heureFin']?.toString()) ??
            const TimeOfDay(hour: 18, minute: 0);

    Uint8List? selectedImageBytes;
    String? selectedImageName;
    String existingImageUrl = (existingEvent?['imageUrl'] ??
            existingEvent?['afficheUrl'] ??
            '')
        .toString();
    bool isSubmitting = false;
    String? formError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final bottomPadding = MediaQuery.of(ctx).viewInsets.bottom > 0
              ? MediaQuery.of(ctx).viewInsets.bottom + 24
              : MediaQuery.of(ctx).padding.bottom + 40;
          return Padding(
            padding: EdgeInsets.only(
              top: 20,
              left: 20,
              right: 20,
              bottom: bottomPadding,
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
                  Row(
                    children: [
                      const Icon(Icons.festival_rounded,
                          color: Color(0xFF075E4D), size: 24),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isEditing
                              ? 'Modifier l\'événement'
                              : 'Créer un nouvel événement',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (formError != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Text(
                        formError!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Titre de l\'événement *',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF075E4D)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      hintText: 'Ex : Nuit du Mandé, Biennale de Bamako...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Sélecteurs Date de début & Heure de début
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date de début *',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF075E4D)),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: ctx,
                                  initialDate: selectedDateDebut,
                                  firstDate: DateTime(2024),
                                  lastDate: DateTime(2032),
                                );
                                if (picked != null) {
                                  setSheetState(() {
                                    selectedDateDebut = picked;
                                    if (selectedDateFin.isBefore(picked)) {
                                      selectedDateFin = picked;
                                    }
                                    formError = null;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded,
                                        size: 16, color: Color(0xFF075E4D)),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDateIso(selectedDateDebut),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
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
                            const Text(
                              'Heure de début *',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF075E4D)),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: ctx,
                                  initialTime: selectedHeureDebut,
                                );
                                if (picked != null) {
                                  setSheetState(() {
                                    selectedHeureDebut = picked;
                                    formError = null;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                        size: 16, color: Color(0xFF075E4D)),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatTime24(selectedHeureDebut),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Sélecteurs Date de fin & Heure de fin
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Date de fin *',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF075E4D)),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: ctx,
                                  initialDate:
                                      selectedDateFin.isBefore(selectedDateDebut)
                                          ? selectedDateDebut
                                          : selectedDateFin,
                                  firstDate: selectedDateDebut,
                                  lastDate: DateTime(2032),
                                );
                                if (picked != null) {
                                  setSheetState(() {
                                    selectedDateFin = picked;
                                    formError = null;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_available_rounded,
                                        size: 16, color: Color(0xFF075E4D)),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDateIso(selectedDateFin),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
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
                            const Text(
                              'Heure de fin *',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF075E4D)),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: ctx,
                                  initialTime: selectedHeureFin,
                                );
                                if (picked != null) {
                                  setSheetState(() {
                                    selectedHeureFin = picked;
                                    formError = null;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.schedule_rounded,
                                        size: 16, color: Color(0xFF075E4D)),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatTime24(selectedHeureFin),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
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
                            const Text('Lieu *',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF075E4D))),
                            const SizedBox(height: 6),
                            TextField(
                              controller: lieuController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                hintText: 'Ex : Palais de la Culture',
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
                            const Text('Ville *',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF075E4D))),
                            const SizedBox(height: 6),
                            TextField(
                              controller: villeController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                hintText: 'Ex : Bamako',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('Tarif du billet (FCFA ou Gratuit) *',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF075E4D))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: prixController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      hintText: 'Ex : Gratuit ou 5000 FCFA',
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Description & programme',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF075E4D))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      hintText: 'Programme, artistes invités, informations pratiques...',
                    ),
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: () async {
                      try {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 85);
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
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF075E4D)
                                .withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_rounded,
                              color: Color(0xFF075E4D)),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              selectedImageName != null
                                  ? 'Affiche sélectionnée : $selectedImageName'
                                  : (existingImageUrl.isNotEmpty
                                      ? 'Modifier l\'affiche de l\'événement'
                                      : 'Sélectionner l\'affiche de l\'événement'),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF075E4D),
                              ),
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
                              if (titre.isEmpty) {
                                setSheetState(() {
                                  formError =
                                      'Veuillez renseigner le titre de l\'événement.';
                                });
                                return;
                              }
                              final dateDebutStr =
                                  _formatDateIso(selectedDateDebut);
                              final dateFinStr =
                                  _formatDateIso(selectedDateFin);
                              final heureDebutStr =
                                  _formatTime24(selectedHeureDebut);
                              final heureFinStr =
                                  _formatTime24(selectedHeureFin);

                              if (dateFinStr.compareTo(dateDebutStr) < 0) {
                                setSheetState(() {
                                  formError =
                                      'La date de fin ne peut pas être antérieure à la date de début.';
                                });
                                return;
                              }
                              if (dateFinStr == dateDebutStr &&
                                  heureFinStr.compareTo(heureDebutStr) < 0) {
                                setSheetState(() {
                                  formError =
                                      'L\'heure de fin doit être postérieure ou égale à l\'heure de début.';
                                });
                                return;
                              }

                              setSheetState(() {
                                isSubmitting = true;
                                formError = null;
                              });

                              String imageUrl = existingImageUrl;
                              if (selectedImageBytes != null &&
                                  selectedImageName != null) {
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

                              final bool isPromoteurValide =
                                  _statutModeration == 'VALIDE' ||
                                      _statutModeration == 'APPROUVE';
                              try {
                                final body = {
                                  'titre': titre,
                                  'description': descController.text.trim(),
                                  'dateDebut': dateDebutStr,
                                  'dateFin': dateFinStr,
                                  'heureDebut': heureDebutStr,
                                  'heureFin': heureFinStr,
                                  'lieu': lieuController.text.trim().isNotEmpty
                                      ? lieuController.text.trim()
                                      : 'Bamako',
                                  'ville':
                                      villeController.text.trim().isNotEmpty
                                          ? villeController.text.trim()
                                          : 'Bamako',
                                  'prix': prixController.text.trim().isNotEmpty
                                      ? prixController.text.trim()
                                      : 'Gratuit',
                                  'imageUrl':
                                      imageUrl.isNotEmpty ? imageUrl : null,
                                  'afficheUrl':
                                      imageUrl.isNotEmpty ? imageUrl : null,
                                  'statut':
                                      isPromoteurValide ? 'VALIDE' : 'EN_ATTENTE',
                                };
                                final res = isEditing
                                    ? await ApiService().put(
                                        '/evenements/${existingEvent['id']}',
                                        body: body,
                                      )
                                    : await ApiService()
                                        .post('/evenements', body: body);

                                if (res.statusCode == 200 ||
                                    res.statusCode == 201) {
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  ref.invalidate(explorerPublicationsProvider);
                                  await _fetchBackendData();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEditing
                                              ? 'Événement mis à jour avec succès !'
                                              : (isPromoteurValide
                                                  ? 'Événement publié avec succès !'
                                                  : 'Événement soumis à validation avec succès !'),
                                        ),
                                        backgroundColor:
                                            const Color(0xFF075E4D),
                                      ),
                                    );
                                  }
                                } else {
                                  setSheetState(() {
                                    isSubmitting = false;
                                    formError =
                                        'Erreur lors de l\'enregistrement (${res.statusCode}).';
                                  });
                                }
                              } catch (e) {
                                setSheetState(() {
                                  isSubmitting = false;
                                  formError = 'Erreur : $e';
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF075E4D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              isEditing
                                  ? 'Enregistrer les modifications'
                                  : ((_statutModeration == 'VALIDE' ||
                                          _statutModeration == 'APPROUVE')
                                      ? 'Publier l\'événement'
                                      : 'Soumettre l\'événement à validation'),
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String headerTitle = _isAdmin
        ? 'Administration Mobile'
        : (_isGuide ? 'Espace Guide & Partenariat' : 'Espace Promoteur');
    final String headerSubtitle = _isAdmin
        ? 'Suivi en temps réel des activités récentes et des commandes de billets'
        : (_isGuide
            ? 'Gestion de votre circuit touristique et de votre fiche guide certifié'
            : 'Gestion de vos événements, billetterie et partenariats culturels');

    return Scaffold(
      backgroundColor: const Color(0xFF075E4D),
      body: Column(
        children: [
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
                      Expanded(
                        child: Text(
                          headerTitle,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _fetchBackendData(),
                        tooltip: 'Actualiser',
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: Text(
                      headerSubtitle,
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
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: RefreshIndicator(
                color: const Color(0xFF075E4D),
                onRefresh: () => _fetchBackendData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 110),
                  child: _isAdmin
                      ? _buildAdminMobileDashboard()
                      : _buildPartnerDashboardContent(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMobileDashboard() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF075E4D)),
        ),
      );
    }

    if (_errorMessage != null && _activitesRecentes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 40, color: Color(0xFFDC2626)),
            const SizedBox(height: 10),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF991B1B),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _fetchBackendData(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF075E4D),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Résumé rapide Admin
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                label: 'Activités suivies',
                value: '${_activitesRecentes.length}',
                icon: Icons.notifications_active_rounded,
                color: const Color(0xFF075E4D),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatItem(
                label: 'Commandes billets',
                value: '${_mesCommandes.length}',
                icon: Icons.confirmation_number_rounded,
                color: const Color(0xFFD6A23A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Row(
          children: [
            Icon(Icons.history_edu_rounded,
                color: Color(0xFF075E4D), size: 20),
            SizedBox(width: 8),
            Text(
              'Activités récentes',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF16332D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Nouveaux comptes, guides, promoteurs, événements, circuits et achats de billets',
          style: TextStyle(fontSize: 12, color: Color(0xFF6C7C77)),
        ),
        const SizedBox(height: 12),
        if (_activitesRecentes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Aucune activité récente enregistrée pour le moment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6C7C77), fontSize: 13),
            ),
          )
        else
          ..._activitesRecentes.map(_buildActivityTile),
        const SizedBox(height: 26),
        _buildTicketOrdersSection(isAdminView: true),
      ],
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> act) {
    final String categorie =
        (act['categorie'] ?? act['type'] ?? '').toString().toUpperCase();
    final String type = (act['type'] ?? 'Activité').toString();
    final String titre = (act['titre'] ?? '').toString();
    final String acteur =
        (act['acteur'] ?? act['auteur'] ?? '').toString();
    final String date = (act['date'] ?? '').toString();
    final String statut = (act['statut'] ?? '').toString();
    final String detail =
        (act['detail'] ?? act['description'] ?? '').toString();

    IconData icon = Icons.bolt_rounded;
    Color color = const Color(0xFF075E4D);
    if (categorie.contains('TOURISTE') || categorie.contains('INSCRIPTION')) {
      icon = Icons.person_add_alt_1_rounded;
      color = const Color(0xFF059669);
    } else if (categorie.contains('GUIDE')) {
      icon = Icons.person_pin_circle_rounded;
      color = const Color(0xFFD97706);
    } else if (categorie.contains('PROMOTEUR')) {
      icon = Icons.business_center_rounded;
      color = const Color(0xFF2563EB);
    } else if (categorie.contains('EVENEMENT')) {
      icon = Icons.festival_rounded;
      color = const Color(0xFF7C3AED);
    } else if (categorie.contains('CIRCUIT')) {
      icon = Icons.tour_rounded;
      color = const Color(0xFF0D9488);
    } else if (categorie.contains('BILLET')) {
      icon = Icons.confirmation_number_rounded;
      color = const Color(0xFFD6A23A);
    } else if (categorie.contains('QUIZ')) {
      icon = Icons.emoji_events_rounded;
      color = const Color(0xFF8E24AA);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                    ),
                    if (date.isNotEmpty)
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF6C7C77),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  titre,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16332D),
                  ),
                ),
                if (acteur.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Par : $acteur',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                ],
                if (detail.isNotEmpty || statut.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (statut.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statut,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF075E4D),
                            ),
                          ),
                        ),
                      if (detail.isNotEmpty)
                        Text(
                          detail,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6C7C77),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerDashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOrganisationCard(),
        const SizedBox(height: 20),
        _buildStatsRow(),
        const SizedBox(height: 24),
        if (_isGuide) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Mon Circuit & Fiche Guide',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16332D),
                  ),
                ),
              ),
              if (_hasGuideCircuit)
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
          _buildGuideCircuitSection(),
        ] else ...[
          // Espace Promoteur : Mes Événements
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Mes Événements Culturels',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF16332D),
                  ),
                ),
              ),
              if (_mesEvenements.isNotEmpty)
                TextButton.icon(
                  onPressed: () => _showEventDialog(),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                  label: const Text('Créer un événement'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF075E4D),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          _buildPromoteurEventsSection(),
          const SizedBox(height: 24),
          _buildTicketOrdersSection(isAdminView: false),
        ],
        const SizedBox(height: 26),
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
          'Associez des professionnels locaux certifiés à vos activités',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF6C7C77),
          ),
        ),
        const SizedBox(height: 14),
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
    );
  }

  Widget _buildGuideCircuitSection() {
    if (!_hasGuideCircuit) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF075E4D).withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.tour_rounded,
              size: 44,
              color: Color(0xFF8B9B95),
            ),
            const SizedBox(height: 12),
            const Text(
              "Vous n'avez pas encore de circuit enregistré.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16332D),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Créez votre premier circuit pour le proposer aux visiteurs.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF6C7C77),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showEditProjectDialog,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Créer un circuit'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF075E4D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDF9EE),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFD6A23A).withValues(alpha: 0.5),
                  ),
                ),
                child: const Text(
                  'CIRCUIT & GUIDE TOURISTIQUE CERTIFIÉ',
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
                _recherchePartenariat ? 'Publié' : 'En pause',
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
          if (_besoinPartenariat.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _besoinPartenariat,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF4A5568),
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _showEditProjectDialog,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Modifier mon circuit'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF075E4D),
                side: const BorderSide(color: Color(0xFF075E4D)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoteurEventsSection() {
    if (_mesEvenements.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF075E4D).withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.event_note_rounded,
              size: 44,
              color: Color(0xFF8B9B95),
            ),
            const SizedBox(height: 12),
            const Text(
              "Vous n'avez pas encore publié d'événement.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16332D),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Créez votre premier événement pour le faire découvrir aux visiteurs.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF6C7C77),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showEventDialog(),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Créer un événement'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF075E4D),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _mesEvenements.map((evt) {
        final String statut = (evt['statut'] ?? 'VALIDE').toString().toUpperCase();
        final bool isValide = statut == 'VALIDE' || statut == 'APPROUVE';
        final bool isRejete = statut == 'REJETE' || statut == 'REFUSE';
        final String titre = (evt['titre'] ?? 'Événement').toString();
        final String dateDebut = (evt['dateDebut'] ?? '').toString();
        final String heureDebut = (evt['heureDebut'] ?? '').toString();
        final String dateFin = (evt['dateFin'] ?? '').toString();
        final String heureFin = (evt['heureFin'] ?? '').toString();
        final String lieu = (evt['lieu'] ?? '').toString();
        final String ville = (evt['ville'] ?? '').toString();
        final String prix = (evt['prix'] ?? 'Gratuit').toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF075E4D).withValues(alpha: 0.12),
            ),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isValide
                          ? const Color(0xFF10B981).withValues(alpha: 0.12)
                          : isRejete
                              ? const Color(0xFFDC2626).withValues(alpha: 0.12)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isValide
                          ? 'Publié'
                          : isRejete
                              ? 'Rejeté'
                              : 'En attente',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isValide
                            ? const Color(0xFF059669)
                            : isRejete
                                ? const Color(0xFFDC2626)
                                : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showEventDialog(existingEvent: evt),
                    icon: const Icon(Icons.edit_outlined, size: 15),
                    label: const Text('Modifier'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF075E4D),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                titre,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16332D),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 13, color: Color(0xFF075E4D)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Début : $dateDebut${heureDebut.isNotEmpty ? ' à $heureDebut' : ''}'
                      '${dateFin.isNotEmpty ? ' • Fin : $dateFin${heureFin.isNotEmpty ? ' à $heureFin' : ''}' : ''}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF4A5568),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.place_rounded,
                      size: 14, color: Color(0xFFD6A23A)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${lieu.isNotEmpty ? lieu : 'Mali'}${ville.isNotEmpty ? ', $ville' : ''} • Tarif : $prix',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF6C7C77),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTicketOrdersSection({required bool isAdminView}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.confirmation_number_rounded,
                color: Color(0xFFD6A23A), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isAdminView
                    ? 'Commandes de billets (Plateforme)'
                    : 'Commandes de billets reçues',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF16332D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (_mesCommandes.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
            ),
            child: const Text(
              'Aucune commande de billet enregistrée pour le moment.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Color(0xFF6C7C77)),
            ),
          )
        else
          ..._mesCommandes.map((cmd) {
            final refCmd = (cmd['referenceCommande'] ?? '').toString();
            final titreEvt = (cmd['titreEvenement'] ?? 'Événement').toString();
            final acheteur = (cmd['nomAcheteur'] ?? 'Visiteur').toString();
            final qte = (cmd['quantite'] ?? 1).toString();
            final total = (cmd['montantTotal'] ?? 0).toString();
            final devise = (cmd['devise'] ?? 'FCFA').toString();
            final canal = (cmd['canalPaiement'] ?? '').toString();
            final dateCreation = (cmd['dateCreation'] ?? '').toString();
            final dateStr = dateCreation.length >= 16
                ? dateCreation.substring(0, 16).replaceAll('T', ' ')
                : dateCreation;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          titreEvt,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF075E4D),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFF10B981).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$total $devise',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Participant : $acheteur • $qte billet(s) • $canal',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4A5568),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Réf : $refCmd${dateStr.isNotEmpty ? ' • $dateStr' : ''}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6C7C77),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildOrganisationCard() {
    final bool isValide =
        _statutModeration == 'VALIDE' || _statutModeration == 'APPROUVE';
    final bool isRejete =
        _statutModeration == 'REJETE' || _statutModeration == 'REFUSE';

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
                  _isGuide
                      ? Icons.person_pin_circle_rounded
                      : Icons.business_center_rounded,
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      Icon(Icons.info_outline_rounded,
                          color: Color(0xFFDC2626), size: 16),
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
                      label: const Text(
                        'Corriger et resoumettre ma demande',
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.bold),
                      ),
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
        if (!_isGuide) ...[
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatItem(
              label: 'Billets vendus',
              value: '$_billetsVendus',
              icon: Icons.confirmation_number_rounded,
              color: const Color(0xFFD6A23A),
            ),
          ),
        ],
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
