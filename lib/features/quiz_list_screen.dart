import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
  void _onStartQuiz(QuizModel quiz) {
    final bool isAuthenticated = ref.read(authServiceProvider).currentUser != null ||
        ref.read(authControllerProvider).isAuthenticated;

    if (!isAuthenticated) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          backgroundColor: Colors.white,
          title: const Column(
            children: [
              Icon(Icons.emoji_events_rounded, color: Color(0xFFF2B544), size: 48),
              SizedBox(height: 10),
              Text(
                'Enregistrez vos points',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF075E4D),
                ),
              ),
            ],
          ),
          content: Text(
            'Connectez-vous ou créez un compte pour valider vos ${quiz.point} points et débloquer votre badge Bambara !',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF4A5568), height: 1.4),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push(AppRouter.quizPlay, extra: quiz);
              },
              child: const Text(
                'Mode Découverte',
                style: TextStyle(color: Color(0xFF6C7C77), fontSize: 13),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF075E4D),
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
                            'QUIZ',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 28),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Testez vos connaissances sur le Mali et\ntentez de gagner des points !',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Fiche blanche contenant les cartes de quiz
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 110),
                child: ref.watch(quizListProvider).when(
                      data: (quizzes) {
                        if (quizzes.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.quiz_outlined, size: 48, color: Color(0xFF8B9B95)),
                                  SizedBox(height: 12),
                                  Text(
                                    'Aucun quiz disponible pour le moment.',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6C7C77),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: quizzes.map((q) => _buildQuizCard(q)).toList(),
                        );
                      },
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 50),
                        child: Center(
                          child: CircularProgressIndicator(color: Color(0xFF075E4D)),
                        ),
                      ),
                      error: (error, stack) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline_rounded, size: 44, color: Colors.redAccent),
                              const SizedBox(height: 8),
                              Text(
                                'Erreur de chargement des quiz',
                                style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF075E4D),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(QuizModel quiz) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      height: 96,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        image: DecorationImage(
          image: NetworkImage(quiz.imageQuiz),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Voile sombre texturé pour la lisibilité
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.80),
                  Colors.black.withValues(alpha: 0.60),
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),

          // Contenu : Titre + points + bouton Commencer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        quiz.nomQuiz,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${quiz.questions.isNotEmpty ? quiz.questions.length : 4} questions • ${quiz.categorie}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF2B544),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${quiz.point} points',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF2B544),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () => _onStartQuiz(quiz),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF075E4D),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF2B544), width: 1),
                        ),
                        child: const Text(
                          'Commencer',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
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
    );
  }
}
