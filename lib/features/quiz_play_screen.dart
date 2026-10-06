import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/services/auth_service.dart';
import '../core/services/quiz_service.dart';
import '../features/auth/auth_controller.dart';
import '../models/quiz_model.dart';
import '../providers/quiz_provider.dart';
import '../router/app_router.dart';

class QuizPlayScreen extends ConsumerStatefulWidget {
  final QuizModel? quiz;

  const QuizPlayScreen({super.key, this.quiz});

  @override
  ConsumerState<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends ConsumerState<QuizPlayScreen> {
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _isAnswerValidated = false;
  bool _isLoading = false;
  bool _isSubmitting = false;

  Timer? _timer;
  int _remainingSeconds = 30;

  int _correctCount = 0;
  int _wrongCount = 0;

  final List<QuestionItem> _questions = [];
  final Map<int, String> _userAnswers = {};

  final List<QuestionItem> _fallbackQuestions = [
    QuestionItem(
      idQuestion: 1,
      question: 'Qui a proclamé l\'indépendance du Mali le 22 septembre 1960 ?',
      options: ['Modibo Keïta', 'Moussa Traoré', 'Alpha Oumar Konaré', 'Tiéba Traoré'],
      correctAnswer: 'Modibo Keïta',
      duree: 30,
      points: 10,
    ),
    QuestionItem(
      idQuestion: 2,
      question: 'Quelle bataille historique en 1235 a consacré la victoire de Soundiata Keïta ?',
      options: ['Bataille de Kirina', 'Bataille de Tondibi', 'Bataille de Kansala', 'Bataille de Sikasso'],
      correctAnswer: 'Bataille de Kirina',
      duree: 30,
      points: 10,
    ),
    QuestionItem(
      idQuestion: 3,
      question: 'Quel souverain du Mali est réputé pour son célèbre pèlerinage fastueux à La Mecque en 1324 ?',
      options: ['Kankou Moussa', 'Soundiata Keïta', 'Sony Ali Ber', 'Askia Mohamed'],
      correctAnswer: 'Kankou Moussa',
      duree: 30,
      points: 10,
    ),
    QuestionItem(
      idQuestion: 4,
      question: 'En quel matériau est principalement construite la Grande Mosquée de Djenné ?',
      options: ['En terre crue (banco)', 'En marbre blanc', 'En granit taillé', 'En briques cuites'],
      correctAnswer: 'En terre crue (banco)',
      duree: 30,
      points: 10,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (_questions.isEmpty || _currentQuestionIndex >= _questions.length) return;

    final duration = _questions[_currentQuestionIndex].duree;
    _remainingSeconds = duration > 0 ? duration : 30;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
        });
        _handleTimeUp();
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _handleTimeUp() {
    if (_isAnswerValidated) return;
    if (_selectedOptionIndex == null) {
      // Temps écoulé sans sélection
      _wrongCount++;
    } else {
      _evaluateCurrentAnswer();
    }
    setState(() {
      _isAnswerValidated = true;
    });
  }

  Future<void> _loadQuizData() async {
    if (widget.quiz != null &&
        widget.quiz!.questions.isNotEmpty &&
        widget.quiz!.questions.first.propositions.isNotEmpty) {
      _initFromQuizModel(widget.quiz!);
      _startTimer();
      return;
    }

    if (widget.quiz != null && widget.quiz!.idQuiz > 0) {
      setState(() => _isLoading = true);
      try {
        final loaded = await ref
            .read(quizServiceProvider)
            .getQuizForPlay(widget.quiz!.idQuiz);
        if (mounted) {
          _initFromQuizModel(loaded);
          setState(() => _isLoading = false);
          _startTimer();
          return;
        }
      } catch (e) {
        // Fallback local en cas d'indisponibilité réseau
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _questions.clear();
        _questions.addAll(_fallbackQuestions);
      });
      _startTimer();
    }
  }

  void _initFromQuizModel(QuizModel qm) {
    _questions.clear();
    for (final q in qm.questions) {
      _questions.add(QuestionItem(
        idQuestion: q.idQuestion,
        question: q.nomQuestion,
        options: q.propositions.isNotEmpty
            ? q.propositions
            : ['Option A', 'Option B', 'Option C', 'Option D'],
        correctAnswer: q.reponse,
        duree: q.duree > 0 ? q.duree : 30,
        points: q.points ?? 10,
      ));
    }
    if (_questions.isEmpty) {
      _questions.addAll(_fallbackQuestions);
    }
  }

  void _onOptionSelected(int index) {
    if (_isAnswerValidated) return; // Empêcher la modification après validation
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _evaluateCurrentAnswer() {
    if (_questions.isEmpty || _selectedOptionIndex == null) return;
    final current = _questions[_currentQuestionIndex];
    final selectedText = current.options[_selectedOptionIndex!];
    _userAnswers[current.idQuestion] = selectedText;

    if (current.correctAnswer != null) {
      if (selectedText.trim().toLowerCase() == current.correctAnswer!.trim().toLowerCase()) {
        _correctCount++;
      } else {
        _wrongCount++;
      }
    } else {
      _correctCount++;
    }
  }

  void _onValidatePressed() {
    if (_selectedOptionIndex == null || _questions.isEmpty) return;
    _timer?.cancel();
    _evaluateCurrentAnswer();
    setState(() {
      _isAnswerValidated = true;
    });
  }

  Future<void> _onNextPressed() async {
    _timer?.cancel();
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _isAnswerValidated = false;
      });
      _startTimer();
    } else {
      await _submitAndShowResults();
    }
  }

  Future<void> _submitAndShowResults() async {
    _timer?.cancel();
    setState(() => _isSubmitting = true);

    final bool isAuthenticated = ref.read(authServiceProvider).currentUser != null ||
        ref.read(authControllerProvider).isAuthenticated;

    final quizId = widget.quiz?.idQuiz ?? 1;

    // Calcul du score basé sur les points réels des questions
    int calculatedScore = 0;
    int maxScore = 0;
    for (final q in _questions) {
      maxScore += q.points;
      final ans = _userAnswers[q.idQuestion];
      if (ans != null &&
          q.correctAnswer != null &&
          ans.trim().toLowerCase() == q.correctAnswer!.trim().toLowerCase()) {
        calculatedScore += q.points;
      }
    }
    if (maxScore == 0) maxScore = _questions.length * 10;

    final bool perfect = _correctCount == _questions.length && _questions.isNotEmpty;
    // Points d'activité selon cahier des charges : +20 complétion, +20 parfait
    int pointsGagnes = calculatedScore + 20 + (perfect ? 20 : 0);

    String badgeActuel = 'Kalanden';
    String prochainBadge = 'Fassoden';
    double progression = 0.3;
    String messageProgression = 'Continuez vos quiz pour devenir Fassoden (Citoyen) !';
    int totalPointsUtilisateur = pointsGagnes;

    if (isAuthenticated) {
      try {
        final res = await ref.read(quizServiceProvider).submitQuiz(
              quizId: quizId,
              reponses: _userAnswers,
            );

        calculatedScore = (res['scoreTotalObtenu'] as num?)?.toInt() ?? calculatedScore;
        maxScore = (res['scoreMaxPossible'] as num?)?.toInt() ?? maxScore;
        pointsGagnes = (res['pointsGagnesActivite'] as num?)?.toInt() ?? pointsGagnes;
        totalPointsUtilisateur = (res['totalPointsUtilisateur'] as num?)?.toInt() ?? totalPointsUtilisateur;

        final rawBadge = res['badgeActuel']?.toString() ?? 'KALANDEN';
        badgeActuel = _formatBadgeName(rawBadge);

        final rawNextBadge = res['prochainBadge']?.toString();
        prochainBadge = rawNextBadge != null ? _formatBadgeName(rawNextBadge) : 'Niveau maximal';

        progression = (res['progressionProchainBadge'] as num?)?.toDouble() ??
            (totalPointsUtilisateur / 100).clamp(0.0, 1.0);

        if (res['messageProgression'] != null) {
          messageProgression = res['messageProgression'] as String;
        }

        ref.invalidate(quizListProvider);
      } catch (e) {
        debugPrint('[QuizPlayScreen] Soumission backend: $e');
      }
    } else {
      // Pour les visiteurs : déterminer le badge prévisionnel
      badgeActuel = totalPointsUtilisateur >= 300
          ? 'Fassoden Yuman'
          : totalPointsUtilisateur >= 100
              ? 'Fassoden'
              : 'Kalanden';
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      _showQuizResultDialog(
        score: calculatedScore,
        maxScore: maxScore,
        pointsGagnes: pointsGagnes,
        totalPoints: totalPointsUtilisateur,
        badge: badgeActuel,
        prochainBadge: prochainBadge,
        progression: progression,
        message: messageProgression,
        correctCount: _correctCount,
        totalCount: _questions.length,
        isAuthenticated: isAuthenticated,
      );
    }
  }

  String _formatBadgeName(String raw) {
    final clean = raw.toUpperCase().replaceAll('_', ' ');
    if (clean.contains('YUMAN')) return 'Fassoden Yuman';
    if (clean.contains('FASODEN') || clean.contains('FASSODEN')) return 'Fassoden';
    return 'Kalanden';
  }

  String _getBadgeSubtitle(String badge) {
    if (badge.contains('Yuman')) return 'Bon citoyen';
    if (badge.contains('Fassoden')) return 'Citoyen';
    return 'Élève';
  }

  void _showQuizResultDialog({
    required int score,
    required int maxScore,
    required int pointsGagnes,
    required int totalPoints,
    required String badge,
    required String prochainBadge,
    required double progression,
    required String message,
    required int correctCount,
    required int totalCount,
    required bool isAuthenticated,
  }) {
    final badgeSubtitle = _getBadgeSubtitle(badge);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF9E6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Color(0xFFF2B544),
                size: 52,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Quiz Terminé !',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF075E4D),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Score & bonnes réponses
              Text(
                '$score / $maxScore pts',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF16332D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$correctCount bonne${correctCount > 1 ? 's' : ''} réponse${correctCount > 1 ? 's' : ''} • $_wrongCount erreur${_wrongCount > 1 ? 's' : ''} (Total : $totalCount)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6C7C77),
                ),
              ),
              const SizedBox(height: 14),

              // Points d'activité gagnés
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF075E4D).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars_rounded, color: Color(0xFFF2B544), size: 20),
                    const SizedBox(width: 6),
                    Text(
                      '+$pointsGagnes points calculés !',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF075E4D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Badge Bambara & Progression
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.military_tech_rounded, color: Color(0xFFD6A23A), size: 22),
                        const SizedBox(width: 6),
                        Text(
                          'Badge : $badge ($badgeSubtitle)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF16332D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progression.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0E8F76)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF6C7C77),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              if (!isAuthenticated) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFDBA74)),
                  ),
                  child: const Text(
                    '« Connectez-vous ou créez un compte pour valider vos points et débloquer votre badge Bambara ! »',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9A3412),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text(
              'Retour aux quiz',
              style: TextStyle(color: Color(0xFF6C7C77), fontWeight: FontWeight.w600),
            ),
          ),
          if (!isAuthenticated)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF075E4D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                context.push(AppRouter.login);
              },
              child: const Text(
                'Se connecter',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF075E4D),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF075E4D),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              const Text('Aucune question disponible', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: () => context.pop(), child: const Text('Retour')),
            ],
          ),
        ),
      );
    }

    final QuestionItem currentQuestion = _questions[_currentQuestionIndex];

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
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.quiz?.nomQuiz ?? 'QUIZ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
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
                  // Progression & Chronomètre
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildProgressBar()),
                      const SizedBox(width: 14),
                      _buildTimerBadge(),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Titre de la question
                  Text(
                    currentQuestion.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF16332D),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Liste des options (A, B, C, D)
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
                          currentQuestion: currentQuestion,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bouton d'action dynamique (Valider -> Suivant)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : _isAnswerValidated
                              ? _onNextPressed
                              : _selectedOptionIndex != null
                                  ? _onValidatePressed
                                  : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF075E4D),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFB5C4BE),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              _isAnswerValidated
                                  ? (_currentQuestionIndex == _questions.length - 1
                                      ? 'Voir mes résultats'
                                      : 'Question suivante')
                                  : 'Valider ma réponse',
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

  /// Badge dynamique du chronomètre
  Widget _buildTimerBadge() {
    final bool isLow = _remainingSeconds <= 5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isLow ? const Color(0xFFFEE2E2) : const Color(0xFFE8F5F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLow ? const Color(0xFFEF4444) : const Color(0xFF0E8F76),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            size: 16,
            color: isLow ? const Color(0xFFDC2626) : const Color(0xFF075E4D),
          ),
          const SizedBox(width: 4),
          Text(
            '${_remainingSeconds}s',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: isLow ? const Color(0xFFDC2626) : const Color(0xFF075E4D),
            ),
          ),
        ],
      ),
    );
  }

  /// Barre de progression segmentée avec compteur (ex: 1/4)
  Widget _buildProgressBar() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: List.generate(_questions.length, (index) {
              final bool isPassed = index <= _currentQuestionIndex;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(
                    right: index == _questions.length - 1 ? 0 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: isPassed ? const Color(0xFF075E4D) : const Color(0xFFDDE3E0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${_currentQuestionIndex + 1}/${_questions.length}',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF6C7C77),
          ),
        ),
      ],
    );
  }

  /// Carte d'une option de réponse avec feedback visuel réel (vert/rouge)
  Widget _buildOptionCard({
    required int index,
    required String optionText,
    required bool isSelected,
    required QuestionItem currentQuestion,
  }) {
    final String letter = String.fromCharCode(65 + index); // A, B, C, D

    Color borderColor = const Color(0xFFE2E8F0);
    Color bgColor = Colors.white;
    Color badgeColor = const Color(0xFFF1F5F3);
    Color letterColor = const Color(0xFF6C7C77);
    Widget? statusIcon;

    if (_isAnswerValidated) {
      final bool isCorrectAnswer = currentQuestion.correctAnswer != null &&
          optionText.trim().toLowerCase() == currentQuestion.correctAnswer!.trim().toLowerCase();

      if (isCorrectAnswer) {
        // Bonne réponse révélée en vert
        borderColor = const Color(0xFF0E8F76);
        bgColor = const Color(0xFFE8F5F1);
        badgeColor = const Color(0xFF0E8F76);
        letterColor = Colors.white;
        statusIcon = const Icon(Icons.check_circle_rounded, color: Color(0xFF0E8F76), size: 22);
      } else if (isSelected) {
        // Mauvaise réponse sélectionnée en rouge
        borderColor = const Color(0xFFDC2626);
        bgColor = const Color(0xFFFEE2E2);
        badgeColor = const Color(0xFFDC2626);
        letterColor = Colors.white;
        statusIcon = const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22);
      }
    } else if (isSelected) {
      borderColor = const Color(0xFF075E4D);
      badgeColor = const Color(0xFF075E4D);
      letterColor = Colors.white;
      statusIcon = const Icon(Icons.check_circle_rounded, color: Color(0xFF075E4D), size: 20);
    }

    return InkWell(
      onTap: () => _onOptionSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isSelected || _isAnswerValidated ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF075E4D).withValues(alpha: 0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badgeColor,
              ),
              child: Center(
                child: Text(
                  letter,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: letterColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: const Color(0xFF16332D),
                  height: 1.3,
                ),
              ),
            ),
            if (statusIcon != null) ...[
              const SizedBox(width: 8),
              statusIcon,
            ],
          ],
        ),
      ),
    );
  }
}

class QuestionItem {
  final int idQuestion;
  final String question;
  final List<String> options;
  final String? correctAnswer;
  final int duree;
  final int points;

  QuestionItem({
    required this.idQuestion,
    required this.question,
    required this.options,
    this.correctAnswer,
    this.duree = 30,
    this.points = 10,
  });
}
