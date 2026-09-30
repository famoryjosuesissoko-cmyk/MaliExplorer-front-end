import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Minuteur visuel circulaire pour les sessions de quiz.
class QuizTimerWidget extends StatelessWidget {
  final int secondsRemaining;
  final int totalSeconds;

  const QuizTimerWidget({
    super.key,
    required this.secondsRemaining,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? secondsRemaining / totalSeconds : 0.0;
    final color = secondsRemaining <= 5 ? AppColors.error : AppColors.sahelGold;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: color.withValues(alpha: 0.2),
          ),
        ),
        Text(
          '$secondsRemaining',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
      ],
    );
  }
}
