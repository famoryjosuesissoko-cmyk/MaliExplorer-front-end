import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_colors.dart';
import '../core/services/badge_progression_service.dart';
import '../core/services/historique_service.dart';
import '../features/auth/auth_controller.dart';
import '../models/historique_point_model.dart';
import '../models/progression_model.dart';
import '../router/app_router.dart';

class MonParcoursScreen extends ConsumerStatefulWidget {
  const MonParcoursScreen({super.key});

  @override
  ConsumerState<MonParcoursScreen> createState() => _MonParcoursScreenState();
}

class _MonParcoursScreenState extends ConsumerState<MonParcoursScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressionAsync = ref.watch(userProgressionProvider);
    final historiqueAsync = ref.watch(userHistoriqueProvider);
    final List<HistoriquePointModel> historiqueItems = historiqueAsync.valueOrNull ?? const [];
    final user = FirebaseAuth.instance.currentUser;
    final authState = ref.watch(authControllerProvider);
    final userMap = authState.user;

    final String displayName = (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user.displayName!
        : (userMap != null && (userMap['prenom'] != null || userMap['nom'] != null))
            ? '${userMap['prenom'] ?? ''} ${userMap['nom'] ?? ''}'.trim()
            : 'Explorateur MaliExplorer';

    final String? photoUrl = user?.photoURL ?? userMap?['photoUrl'];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackgroundSecondary : const Color(0xFF075E4D),
      body: Stack(
        children: [
          Column(
            children: [
              // 1. En-tête vert
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                            'Mon parcours',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                    ],
                  ),
                ),
              ),

              // 2. Fiche blanche avec tout le contenu
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBackground : const Color(0xFFF7F8F5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: RefreshIndicator(
                    color: const Color(0xFF075E4D),
                    onRefresh: () async {
                      ref.invalidate(userProgressionProvider);
                      ref.invalidate(userHistoriqueProvider);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 110),
                      child: progressionAsync.when(
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(color: Color(0xFF075E4D)),
                          ),
                        ),
                        error: (error, stack) => _buildContent(
                          isDark: isDark,
                          displayName: displayName,
                          photoUrl: photoUrl,
                          historiqueItems: historiqueItems,
                          progression: const ProgressionModel(
                            points: 0,
                            badge: 'Kalanden',
                            nextBadge: 'Fasoden',
                            pointsToNextBadge: 100,
                            progression: 0.0,
                            message: 'Continuez vos quiz pour débloquer le badge Fasoden !',
                          ),
                        ),
                        data: (data) => _buildContent(
                          isDark: isDark,
                          displayName: displayName,
                          photoUrl: photoUrl,
                          historiqueItems: historiqueItems,
                          progression: data ??
                              const ProgressionModel(
                                points: 0,
                                badge: 'Kalanden',
                                nextBadge: 'Fasoden',
                                pointsToNextBadge: 100,
                                progression: 0.0,
                                message: 'Participez à des quiz pour cumuler des points !',
                              ),
                        ),
                      ),
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

  Widget _buildContent({
    required bool isDark,
    required String displayName,
    required String? photoUrl,
    required ProgressionModel progression,
    required List<HistoriquePointModel> historiqueItems,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Carte utilisateur & progression dynamique
        _buildUserProfileProgressCard(
          displayName: displayName,
          photoUrl: photoUrl,
          progression: progression,
          isDark: isDark,
        ),

        const SizedBox(height: 18),

        // 3 Statistiques réelles
        _buildStatsRow(progression, historiqueItems.length, isDark),

        const SizedBox(height: 24),

        // Section Mes quiz et résultats récents
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mes quiz et résultats',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
              ),
            ),
            TextButton.icon(
              onPressed: () => context.push(AppRouter.historique),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                Icons.history_rounded,
                size: 15,
                color: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
              ),
              label: Text(
                'Historique complet',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _buildQuizResultsSection(historiqueItems, isDark),

        const SizedBox(height: 24),

        // Section Mes Badges Bambara
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mes Badges Bambara',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
              ),
            ),
            Text(
              '3 Niveaux',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF4DB6AC) : const Color(0xFF075E4D),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Liste des 3 Badges de niveau (Kalanden, Fasoden, Fasoden Yuman)
        _buildBadgesRow(progression.points, isDark),

        const SizedBox(height: 24),

        // Section Récompense spéciale
        Text(
          'Récompenses culturelles',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
          ),
        ),

        const SizedBox(height: 14),

        // 3 Récompenses spéciales
        _buildSpecialRewardsRow(progression.points, isDark),
      ],
    );
  }

  /// Carte utilisateur avec Avatar, Nom, Tags et Jauge de points dynamique
  Widget _buildUserProfileProgressCard({
    required String displayName,
    required String? photoUrl,
    required ProgressionModel progression,
    required bool isDark,
  }) {
    final int points = progression.points;
    final int nextSeuil = points >= 300
        ? 300
        : (progression.nextBadge?.toLowerCase().contains('yuman') == true ? 300 : 100);

    final double progressRatio = nextSeuil > 0 ? (points / nextSeuil).clamp(0.0, 1.0) : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
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
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8F4F0),
                  border: Border.all(
                    color: const Color(0xFF075E4D),
                    width: 2,
                  ),
                ),
                child: (photoUrl != null && photoUrl.isNotEmpty)
                    ? ClipOval(
                        child: Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const Icon(
                            Icons.person_rounded,
                            color: Color(0xFF075E4D),
                            size: 32,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF075E4D),
                        size: 32,
                      ),
              ),
              const SizedBox(width: 14),

              // Nom et Badges de statut
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildTag(progression.badge),
                        const SizedBox(width: 8),
                        _buildTag(points >= 300
                            ? 'Niveau 3'
                            : (points >= 100 ? 'Niveau 2' : 'Niveau 1')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressRatio,
              minHeight: 8,
              backgroundColor: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F3),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF2B544)),
            ),
          ),
          const SizedBox(height: 5),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              points >= 300
                  ? '$points points (Niveau maximal atteint !)'
                  : '$points / $nextSeuil points pour ${progression.nextBadge ?? "le palier supérieur"}',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF2B544),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Ligne des 3 statistiques dynamiques
  Widget _buildStatsRow(ProgressionModel progression, int realActivityCount, bool isDark) {
    final int points = progression.points;
    final int badgesDebloques = points >= 300 ? 3 : (points >= 100 ? 2 : 1);

    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF2B544),
            value: points.toString(),
            label: 'Points',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            icon: Icons.assignment_outlined,
            iconColor: const Color(0xFF075E4D),
            value: realActivityCount.toString(),
            label: 'Activités\nréalisées',
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatItem(
            icon: Icons.emoji_events_outlined,
            iconColor: const Color(0xFFF2B544),
            value: '$badgesDebloques / 3',
            label: 'Badges\ndébloqués',
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildQuizResultsSection(List<HistoriquePointModel> items, bool isDark) {
    if (items.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.quiz_outlined,
              size: 36,
              color: Color(0xFF075E4D),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucun quiz réalisé pour le moment',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Lancez un quiz culturel pour voir vos scores et débloquer vos badges Bambara.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRouter.quizList),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF075E4D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 18),
              label: const Text(
                'Découvrir les quiz',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final displayList = items.take(5).toList();

    return Column(
      children: displayList.map((item) {
        final desc = item.description ?? 'Quiz culturel';
        final descLower = desc.toLowerCase();
        final isAbandon = item.action.toUpperCase() == 'QUIZ_ABANDON' || descLower.contains('abandonné');
        final isNonValide = !isAbandon && descLower.contains('non validé');

        final Color statusColor = isAbandon
            ? const Color(0xFFDC2626)
            : isNonValide
                ? const Color(0xFFD97706)
                : const Color(0xFF075E4D);

        final Color statusBg = isAbandon
            ? (isDark ? const Color(0xFF4C1D24) : const Color(0xFFFEE2E2))
            : isNonValide
                ? (isDark ? const Color(0xFF3B2F17) : const Color(0xFFFEF3C7))
                : (isDark ? const Color(0xFF134E42) : const Color(0xFFE8F5F1));

        final IconData statusIcon = isAbandon
            ? Icons.flag_rounded
            : isNonValide
                ? Icons.refresh_rounded
                : Icons.military_tech_rounded;

        final String formattedDate = item.dateGain != null
            ? dateFormat.format(item.dateGain!)
            : 'Récemment';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isAbandon ? '0 pt' : '+${item.pointsGagnes} pts',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Container(
      height: 94,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  /// Ligne des 3 Badges réels selon les seuils Bambara (0-99, 100-299, 300+)
  Widget _buildBadgesRow(int points, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildBadgeCard(
            title: 'Kalanden',
            level: 'Élève',
            points: '0 - 99 pts',
            color: const Color(0xFFD6A23A),
            isUnlocked: true,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBadgeCard(
            title: 'Fasoden',
            level: 'Citoyen',
            points: '100 - 299 pts',
            color: const Color(0xFF94A3B8),
            isUnlocked: points >= 100,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildBadgeCard(
            title: 'Fasoden Yuman',
            level: 'Bon citoyen',
            points: '300+ pts',
            color: const Color(0xFFF2B544),
            isUnlocked: points >= 300,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard({
    required String title,
    required String level,
    required String points,
    required Color color,
    required bool isUnlocked,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? color.withValues(alpha: 0.5)
              : (isDark ? AppColors.darkBorder : Colors.black.withValues(alpha: 0.05)),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icône médaille / badge avec opacité si verrouillé
          Opacity(
            opacity: isUnlocked ? 1.0 : 0.4,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.14),
              ),
              child: Icon(
                isUnlocked ? Icons.military_tech_rounded : Icons.lock_outline_rounded,
                color: isUnlocked ? color : (isDark ? AppColors.darkTextDisabled : Colors.grey),
                size: 26,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            level,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            points,
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w400,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  /// Ligne des 3 Récompenses spéciales
  Widget _buildSpecialRewardsRow(int points, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildSpecialRewardItem(
            icon: Icons.history_edu_rounded,
            title: 'Expert en Histoire',
            isUnlocked: points >= 50,
            iconColor: const Color(0xFF075E4D),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSpecialRewardItem(
            icon: Icons.soup_kitchen_rounded,
            title: 'Ambassadeur\nGastronomie',
            isUnlocked: points >= 150,
            iconColor: const Color(0xFFF2B544),
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSpecialRewardItem(
            icon: Icons.explore_outlined,
            title: 'Explorateur du\nMali',
            isUnlocked: points >= 300,
            iconColor: const Color(0xFF0E8F76),
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialRewardItem({
    required IconData icon,
    required String title,
    required bool isUnlocked,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? iconColor.withValues(alpha: 0.4)
              : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: isUnlocked ? 1.0 : 0.4,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF7F8F5),
                border: Border.all(
                  color: isUnlocked ? iconColor : Colors.grey,
                  width: 1.5,
                ),
              ),
              child: Icon(
                isUnlocked ? icon : Icons.lock_outline_rounded,
                color: isUnlocked ? iconColor : Colors.grey,
                size: 22,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
