import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/guide_model.dart';
import '../providers/guides_provider.dart';
import '../router/app_router.dart';

class GuidesScreen extends ConsumerStatefulWidget {
  const GuidesScreen({super.key});

  @override
  ConsumerState<GuidesScreen> createState() => _GuidesScreenState();
}

class _GuidesScreenState extends ConsumerState<GuidesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(guideSearchQueryProvider.notifier).state = '';
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Le numéro de téléphone n'est pas renseigné."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        return;
      }
    } catch (_) {}
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      return;
    } catch (_) {}
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Numéro de téléphone : $phoneNumber'),
          backgroundColor: const Color(0xFF075E4D),
          action: SnackBarAction(
            label: 'Copier',
            textColor: Colors.amber,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phoneNumber));
            },
          ),
        ),
      );
    }
  }

  Future<void> _sendEmail(BuildContext context, String email, String guideName) async {
    if (email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("L'adresse email n'est pas renseignée."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email.trim(),
      query:
          'subject=${Uri.encodeComponent("Demande de visite guidée - MaliExplorer")}&body=${Uri.encodeComponent("Bonjour $guideName,\n\nJe souhaiterais échanger avec vous concernant l\'organisation d\'une visite guidée au Mali.\n\nCordialement,")}',
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
        return;
      }
    } catch (_) {}
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      return;
    } catch (_) {}
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email : $email'),
          backgroundColor: const Color(0xFF075E4D),
          action: SnackBarAction(
            label: 'Copier',
            textColor: Colors.amber,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: email));
            },
          ),
        ),
      );
    }
  }

  void _showGuideContactSheet(BuildContext context, GuideModel guide, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    guide.photoUrl.isNotEmpty
                        ? guide.photoUrl
                        : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=400&auto=format&fit=crop',
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 58,
                      height: 58,
                      color: const Color(0xFF075E4D).withValues(alpha: 0.15),
                      child: const Icon(Icons.person, color: Color(0xFF075E4D)),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        guide.fullName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF16332D),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Guide Touristique Certifié (${guide.experience} ans d\'exp.)',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (guide.description.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                guide.description,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : const Color(0xFF6C7C77),
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'Langues : ${guide.langue.isNotEmpty ? guide.langue : "Bambara, Français"}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : const Color(0xFF6C7C77),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            if (guide.telephone.isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _makePhoneCall(context, guide.telephone);
                },
                icon: const Icon(Icons.phone_in_talk_rounded, size: 20),
                label: Text(
                  'Appeler (${guide.telephone})',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF075E4D),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
              ),
              const SizedBox(height: 10),
            ],
            if (guide.email.isNotEmpty) ...[
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _sendEmail(context, guide.email, guide.fullName);
                },
                icon: const Icon(Icons.email_outlined, size: 20),
                label: Text(
                  'Envoyer un e-mail (${guide.email})',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF075E4D),
                  side: const BorderSide(color: Color(0xFF075E4D), width: 1.5),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
            if (guide.telephone.isEmpty && guide.email.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Aucun canal de contact direct renseigné pour ce guide.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchQuery = ref.watch(guideSearchQueryProvider).trim();
    final guidesAsync = ref.watch(filteredGuidesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF075E4D),
      body: Column(
        children: [
          // En-tête vert
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Guides',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.only(left: 32.0),
                    child: Text(
                      'Des guides passionnés pour une expérience inoubliable au Mali !',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fiche blanche contenant la liste des guides
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF7F8F5),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: RefreshIndicator(
                color: const Color(0xFF075E4D),
                onRefresh: () async {
                  ref.invalidate(guidesProvider);
                  await ref.read(guidesProvider.future);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                  child: Column(
                    children: [
                      // Barre de recherche
                      _buildSearchBar(isDark),

                      const SizedBox(height: 18),

                      // État Riverpod dynamique
                      guidesAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF075E4D),
                            ),
                          ),
                        ),
                        error: (err, stack) => _buildErrorState(isDark, err.toString()),
                        data: (guides) {
                          if (guides.isEmpty) {
                            if (searchQuery.isNotEmpty) {
                              return _buildSearchEmptyState(isDark);
                            }
                            return _buildOfficialEmptyState(isDark);
                          }

                          return Column(
                            children: guides
                                .map((guide) => _buildGuideCardFromModel(guide, isDark))
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF0F3F1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF8B9B95), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(guideSearchQueryProvider.notifier).state = val;
              },
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher un guide...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white54 : const Color(0xFF8B9B95),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: _clearSearch,
              child: const Icon(
                Icons.cancel_rounded,
                color: Color(0xFF8B9B95),
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  /// État vide officiel quand la base de données ne contient aucun guide inscrit/validé
  Widget _buildOfficialEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF075E4D).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_pin_circle_outlined,
              color: Color(0xFF075E4D),
              size: 38,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Guides Touristiques',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF16332D),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Aucun guide n'est disponible pour le moment. Les profils des guides apparaîtront ici dès qu'ils seront inscrits, validés et disponibles.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark ? Colors.white70 : const Color(0xFF6C7C77),
            ),
          ),
        ],
      ),
    );
  }

  /// État vide quand la recherche textuelle ne retourne aucun résultat
  Widget _buildSearchEmptyState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: Colors.orange,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun guide ne correspond à vos critères de recherche',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF16332D),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _clearSearch,
            icon: const Icon(Icons.clear_rounded, size: 16),
            label: const Text('Effacer la recherche'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF075E4D),
              side: const BorderSide(color: Color(0xFF075E4D)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  /// État d'erreur réseau / serveur avec bouton « Réessayer »
  Widget _buildErrorState(bool isDark, [String? errorMessage]) {
    final bool isBlockedOrForbidden = errorMessage != null &&
        (errorMessage.contains('403') ||
            errorMessage.contains('bloqué') ||
            errorMessage.contains('Bloqué'));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isBlockedOrForbidden
                  ? Icons.lock_person_rounded
                  : Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isBlockedOrForbidden
                ? 'Accès Restreint ou Compte Bloqué'
                : 'Impossible de charger les guides touristiques',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF16332D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isBlockedOrForbidden
                ? 'Ce compte a été restreint par l\'administration. La session a été révoquée.'
                : 'Vérifiez votre connexion réseau et réessayez.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : const Color(0xFF6C7C77),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(guidesProvider),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text(
              'Réessayer',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF075E4D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCardFromModel(GuideModel guide, bool isDark) {
    final photo = guide.photoUrl.isNotEmpty
        ? guide.photoUrl
        : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=400&auto=format&fit=crop';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _showGuideContactSheet(context, guide, isDark),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    photo,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 78,
                      height: 78,
                      color: const Color(0xFF075E4D).withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.person,
                        color: Color(0xFF075E4D),
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              guide.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF075E4D),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded, color: Color(0xFF059669), size: 13),
                                SizedBox(width: 3),
                                Text(
                                  'Certifié',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        guide.description.isNotEmpty
                            ? guide.description
                            : 'Guide touristique (${guide.experience} ans d\'expérience)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : const Color(0xFF6C7C77),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.language_rounded,
                            color: Color(0xFF0E8F76),
                            size: 14,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              guide.langue.isNotEmpty
                                  ? guide.langue
                                  : 'Bambara, Français',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: isDark ? Colors.white60 : const Color(0xFF6C7C77),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Canaux cliquables : Appel téléphonique et/ou Email
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          if (guide.telephone.isNotEmpty)
                            InkWell(
                              onTap: () => _makePhoneCall(context, guide.telephone),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF075E4D),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF075E4D).withValues(alpha: 0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.call_rounded, size: 13, color: Colors.white),
                                    SizedBox(width: 5),
                                    Text(
                                      'Appeler',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (guide.email.isNotEmpty)
                            InkWell(
                              onTap: () => _sendEmail(context, guide.email, guide.fullName),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF075E4D).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF075E4D),
                                    width: 1.2,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.email_outlined, size: 13, color: Color(0xFF075E4D)),
                                    SizedBox(width: 5),
                                    Text(
                                      'Email',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF075E4D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (guide.telephone.isEmpty && guide.email.isEmpty)
                            InkWell(
                              onTap: () => _showGuideContactSheet(context, guide, isDark),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.info_outline_rounded, size: 13, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text(
                                      'Détails',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
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
