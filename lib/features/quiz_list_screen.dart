import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/app_colors.dart';
import '../core/services/auth_service.dart';
import '../features/auth/auth_controller.dart';
import '../models/quiz_model.dart';
import '../providers/quiz_provider.dart';
import '../router/app_router.dart';

class QuizListScreen extends ConsumerStatefulWidget {
  const QuizListScreen({super.key});

  @override
  ConsumerState<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends ConsumerState<QuizListScreen> {
  String _selectedCategory = 'Tous';
  final List<String> _categories = ['Tous', 'Histoire', 'Culture', 'Gastronomie'];

  void _onStartQuiz(QuizModel quiz) {
    final bool isAuthenticated = ref.read(authServiceProvider).currentUser != null ||
        ref.read(authControllerProvider).isAuthenticated;

    if (!isAuthenticated) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : Colors.white,
          title: Column(
            children: [
              const Icon(Icons.emoji_events_rounded, color: AppColors.solarYellow, size: 48),
              const SizedBox(height: 10),
              Text(
                'Enregistrez vos points',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextPrimary
                      : AppColors.primaryForest,
                ),
              ),
            ],
          ),
          content: Text(
            'Connectez-vous ou créez un compte pour valider vos ${quiz.point} points et débloquer votre badge Bambara !',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkTextSecondary
                  : const Color(0xFF4A5568),
              height: 1.4,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push(AppRouter.quizPlay, extra: quiz);
              },
              child: Text(
                'Mode Découverte',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary
                      : const Color(0xFF6C7C77),
                  fontSize: 13,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryForest,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push(AppRouter.login);
              },
              child: const Text('Se connecter', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } else {
      context.push(AppRouter.quizPlay, extra: quiz);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.primaryForest,
      body: Column(
        children: [
          // En-tête vert / sombre selon Figma
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: Column(
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
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Quiz',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Testez vos connaissances sur le Mali et gagnez des points !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFD6F5EC),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contenu principal de la liste des quiz
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : const Color(0xFFF7F8F5),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Pilules de filtrage par catégorie (Figma Image 2)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _categories.map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = cat;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryForest
                                      : (isDark ? AppColors.darkSurface : Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryForest
                                        : (isDark ? AppColors.darkBorder : AppColors.borderLight),
                                  ),
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark ? AppColors.darkTextSecondary : const Color(0xFF4A5568)),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // Liste des cartes de quiz
                  Expanded(
                    child: ref.watch(quizListProvider).when(
                          data: (quizzes) {
                            final filtered = quizzes.where((q) {
                              if (_selectedCategory == 'Tous') return true;
                              return q.categorie.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
                                  q.nomQuiz.toLowerCase().contains(_selectedCategory.toLowerCase());
                            }).toList();

                            if (filtered.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.quiz_outlined,
                                      size: 48,
                                      color: isDark ? AppColors.darkTextDisabled : const Color(0xFF8B9B95),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Aucun quiz pour cette catégorie.',
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return _buildQuizCard(filtered[index], isDark);
                              },
                            );
                          },
                          loading: () => Center(
                            child: CircularProgressIndicator(
                              color: isDark ? AppColors.secondaryEmerald : AppColors.primaryForest,
                            ),
                          ),
                          error: (error, stack) => Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Erreur de chargement des quiz',
                                    style: TextStyle(
                                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF991B1B),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    error.toString(),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6B7280),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryForest,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    ),
                                    onPressed: () => ref.refresh(quizListProvider),
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    label: const Text('Réessayer'),
                                  ),
                                ],
                              ),
                            ),
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

  /// Carte de Quiz conforme à la maquette Figma (Image 2 - Écran 3)
  Widget _buildQuizCard(QuizModel quiz, bool isDark) {
    final diffLower = quiz.difficulte.toLowerCase();
    Color diffBg;
    Color diffTextColor;
    String diffLabel;

    if (diffLower.contains('facil')) {
      diffBg = isDark ? const Color(0xFF134E42) : const Color(0xFFD1FAE5);
      diffTextColor = isDark ? AppColors.success : const Color(0xFF047857);
      diffLabel = 'Facile';
    } else if (diffLower.contains('diffic')) {
      diffBg = isDark ? const Color(0xFF4C1D24) : const Color(0xFFFEE2E2);
      diffTextColor = isDark ? AppColors.error : const Color(0xFFDC2626);
      diffLabel = 'Difficile';
    } else {
      diffBg = isDark ? const Color(0xFF483515) : const Color(0xFFFEF3C7);
      diffTextColor = isDark ? AppColors.solarYellow : const Color(0xFFB45309);
      diffLabel = 'Moyen';
    }

    final nbQuestions = quiz.questions.isNotEmpty ? quiz.questions.length : 10;
    final dureeMin = nbQuestions;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.borderLight,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _onStartQuiz(quiz),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Vignette photo avec bords arrondis (Figma)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: quiz.imageQuiz,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 76,
                      height: 76,
                      color: isDark ? AppColors.darkSurfaceElevated : Colors.grey[200],
                      child: const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 76,
                      height: 76,
                      color: isDark ? AppColors.darkSurfaceElevated : Colors.grey[200],
                      child: Icon(
                        Icons.quiz,
                        color: isDark ? AppColors.darkTextDisabled : Colors.grey[400],
                        size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Contenu textuel : Titre, durée & points (Figma)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quiz.nomQuiz,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextPrimary : const Color(0xFF16332D),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$nbQuestions questions • $dureeMin min',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkTextSecondary : const Color(0xFF6C7C77),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '+${quiz.point} pts',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.solarYellow,
                            ),
                          ),
                          const Spacer(),
                          // Badge de difficulté
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: diffBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              diffLabel,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: diffTextColor,
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
