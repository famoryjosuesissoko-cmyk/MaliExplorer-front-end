import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_colors.dart';
import '../router/app_router.dart';

class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({super.key});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  int _score = 0;

  final List<QuizQuestion> _questions = [
    // Question 1
    QuizQuestion(
      question: 'Où se situe la grande mosquée de Djenné ?',
      options: [
        'Dans la région de Ségou, au Mali',
        'Dans la région de Mopti, au Mali',
        'Dans la région de Tombouctou, au Mali',
        'Dans la région de Gao, au Mali',
      ],
      correctOptionIndex: 1, // B
    ),
    // Question 2
    QuizQuestion(
      question:
          'En quel matériau principal la Grande Mosquée de Djenné est-elle construite ?',
      options: [
        'En pierre taillée',
        'En banco (terre crue séchée)',
        'En briques rouges cuites',
        'En béton armé',
      ],
      correctOptionIndex: 1, // B
    ),
    // Question 3
    QuizQuestion(
      question:
          'Comment s\'appelle le festival annuel communautaire au cours duquel la population restaure les murs de la mosquée ?',
      options: [
        'La Traversée de la Tapama',
        'Le Crépissage',
        'Le Festival du Sahel',
        'La Biennale de Djenné',
      ],
      correctOptionIndex: 1, // B
    ),
    // Question 4
    QuizQuestion(
      question:
          'En quelle année la vieille ville de Djenné et sa mosquée ont-elles été inscrites au patrimoine mondial de l\'UNESCO ?',
      options: [
        '1960',
        '1988',
        '2005',
        '2012',
      ],
      correctOptionIndex: 1, // B
    ),
    // Question 5
    QuizQuestion(
      question:
          'À quoi servent les pieux en bois de palmier (appelés torons) qui dépassent des façades de la mosquée ?',
      options: [
        'À effrayer les oiseaux',
        'De support d\'échafaudage permanent et d\'élément d\'ingénierie structurelle',
        'À faire passer des câbles électriques',
        'De décoration purement esthétique',
      ],
      correctOptionIndex: 1, // B
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Par défaut, l'option correcte est présélectionnée comme sur la maquette
    _selectedOptionIndex = _questions[0].correctOptionIndex;
  }

  void _onOptionSelected(int index) {
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _onNextPressed() {
    if (_selectedOptionIndex == null) return;

    if (_selectedOptionIndex == _questions[_currentQuestionIndex].correctOptionIndex) {
      _score += 10;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        // Présélectionne l'option correcte pour la question suivante
        _selectedOptionIndex = _questions[_currentQuestionIndex].correctOptionIndex;
      });
    } else {
      _showQuizResultDialog();
    }
  }

  void _showQuizResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Column(
          children: const [
            Icon(Icons.emoji_events_rounded, color: Color(0xFFF2B544), size: 54),
            SizedBox(height: 10),
            Text(
              'Félicitations !',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF075E4D),
              ),
            ),
          ],
        ),
        content: Text(
          'Vous avez obtenu $_score / 50 points sur le quiz de la Grande Mosquée de Djenné !',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF4A5568),
            height: 1.4,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF075E4D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text(
              'Retour aux quiz',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final QuizQuestion currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF075E4D),
      body: Column(
        children: [
          // En-tête vert avec bouton retour et titre QUIZ
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              child: Row(
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
                  const SizedBox(width: 28),
                ],
              ),
            ),
          ),

          // Fiche blanche contenant la question et les options
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF7F8F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Barre de progression segmentée (1/5 -> 5/5)
                  _buildProgressBar(),

                  const SizedBox(height: 24),

                  // Titre de la question
                  Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF16332D),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Liste des 4 options (A, B, C, D)
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: currentQuestion.options.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildOptionCard(
                          index: index,
                          optionText: currentQuestion.options[index],
                          isSelected: _selectedOptionIndex == index,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bouton Suivant en bas
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _selectedOptionIndex != null ? _onNextPressed : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16332D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentQuestionIndex == _questions.length - 1
                            ? 'Terminer'
                            : 'Suivant',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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

  /// Barre de progression segmentée avec compteur (ex: 1/5)
  Widget _buildProgressBar() {
    return Row(
      children: [
        // Segments de la barre
        Expanded(
          child: Row(
            children: List.generate(_questions.length, (index) {
              final bool isPassed = index <= _currentQuestionIndex;
              return Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.only(right: index == _questions.length - 1 ? 0 : 5),
                  decoration: BoxDecoration(
                    color: isPassed ? const Color(0xFF075E4D) : const Color(0xFFDDE3E0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 12),
        // Compteur 1/5
        Text(
          '${_currentQuestionIndex + 1}/${_questions.length}',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6C7C77),
          ),
        ),
      ],
    );
  }

  /// Carte d'une option de réponse
  Widget _buildOptionCard({
    required int index,
    required String optionText,
    required bool isSelected,
  }) {
    final String letter = String.fromCharCode(65 + index); // A, B, C, D

    return InkWell(
      onTap: () => _onOptionSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF075E4D) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF075E4D).withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Lettre A, B, C, D dans un cercle
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF075E4D)
                    : const Color(0xFFF1F5F3),
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : const Color(0xFF6C7C77),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Texte de l'option
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: const Color(0xFF16332D),
                  height: 1.3,
                ),
              ),
            ),

            // Icône checkmark si sélectionné
            if (isSelected) ...[
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF075E4D),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctOptionIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
  });
}
