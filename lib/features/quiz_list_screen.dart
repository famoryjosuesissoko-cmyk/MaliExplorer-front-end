import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

class QuizListScreen extends StatefulWidget {
  const QuizListScreen({super.key});

  @override
  State<QuizListScreen> createState() => _QuizListScreenState();
}

class _QuizListScreenState extends State<QuizListScreen> {
  int _selectedNavIndex = 3; // Onglet Quiz actif

  final List<QuizThemeItem> _quizList = [
    QuizThemeItem(
      title: 'La mosquée de Djenné',
      questionsCount: 5,
      points: 50,
      imageUrl:
          'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?q=80&w=800&auto=format&fit=crop',
    ),
    QuizThemeItem(
      title: 'Les Dogons',
      questionsCount: 5,
      points: 50,
      imageUrl:
          'https://images.unsplash.com/photo-1578922746465-3a80a228f223?q=80&w=800&auto=format&fit=crop',
    ),
    QuizThemeItem(
      title: 'La ville de Tombouctou',
      questionsCount: 5,
      points: 50,
      imageUrl:
          'https://images.unsplash.com/photo-1516426122078-c23e76319801?q=80&w=800&auto=format&fit=crop',
    ),
    QuizThemeItem(
      title: 'Gastronomie & Recettes',
      questionsCount: 5,
      points: 50,
      imageUrl:
          'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800&auto=format&fit=crop',
    ),
    QuizThemeItem(
      title: 'Histoire & Rois du Mali',
      questionsCount: 5,
      points: 50,
      imageUrl:
          'https://images.unsplash.com/photo-1534447677768-be436bb09401?q=80&w=800&auto=format&fit=crop',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;

    return Scaffold(
      backgroundColor: const Color(0xFF075E4D),
      body: Stack(
        children: [
          // Structure globale : En-tête vert + Fiche blanche
          Column(
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
                            onPressed: () => context.pop(),
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
                          const SizedBox(width: 28), // Équilibre le bouton retour
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
                    child: Column(
                      children: _quizList.map((quiz) => _buildQuizCard(quiz)).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Barre de navigation inférieure flottante
          Positioned(
            left: math.max(16.0, screenWidth * 0.04),
            right: math.max(16.0, screenWidth * 0.04),
            bottom: math.max(12.0, MediaQuery.of(context).padding.bottom + 6.0),
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard(QuizThemeItem quiz) {
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
          image: NetworkImage(quiz.imageUrl),
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
                // Titre et nombre de questions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        quiz.title,
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
                        '${quiz.questionsCount} questions',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF2B544), // Or / Jaune
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Points et Bouton Commencer
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${quiz.points} points',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF2B544),
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () {
                        // Ouvre le jeu de quiz
                        context.push(AppRouter.quizPlay);
                      },
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

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Accueil', isSelected: _selectedNavIndex == 0, onTap: () => context.go(AppRouter.home)),
          _buildNavItem(1, Icons.menu_book_rounded, 'Carte', isSelected: _selectedNavIndex == 1),
          _buildNavItem(2, Icons.explore_outlined, 'Découvrir', isSelected: _selectedNavIndex == 2, onTap: () => context.push(AppRouter.monParcours)),
          _buildNavItem(3, Icons.help_outline_rounded, 'Quiz', isSelected: _selectedNavIndex == 3),
          _buildNavItem(4, Icons.person_outline_rounded, 'Profil', isSelected: _selectedNavIndex == 4, onTap: () => context.push(AppRouter.profil)),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {required bool isSelected, VoidCallback? onTap}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedNavIndex = index;
          });
          if (onTap != null) onTap();
        },
        borderRadius: BorderRadius.circular(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected)
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF075E4D),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              )
            else
              Icon(icon, color: const Color(0xFF6C7C77), size: 22),
            const SizedBox(height: 2.5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF075E4D) : const Color(0xFF6C7C77),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizThemeItem {
  final String title;
  final int questionsCount;
  final int points;
  final String imageUrl;

  QuizThemeItem({
    required this.title,
    required this.questionsCount,
    required this.points,
    required this.imageUrl,
  });
}
