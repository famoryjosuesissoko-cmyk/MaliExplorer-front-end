class ProgressionModel {
  final int points;
  final String badge;
  final String? nextBadge;
  final int pointsToNextBadge;
  final double progression;
  final String? message;
  final String? nomComplet;
  final String? email;

  const ProgressionModel({
    required this.points,
    required this.badge,
    this.nextBadge,
    required this.pointsToNextBadge,
    required this.progression,
    this.message,
    this.nomComplet,
    this.email,
  });

  factory ProgressionModel.fromJson(Map<String, dynamic> json) {
    return ProgressionModel(
      points: (json['points'] as num?)?.toInt() ?? 0,
      badge: json['badge']?.toString() ?? 'Kalanden',
      nextBadge: json['nextBadge']?.toString(),
      pointsToNextBadge: (json['pointsToNextBadge'] as num?)?.toInt() ?? 0,
      progression: (json['progression'] as num?)?.toDouble() ?? 0.0,
      message: json['message']?.toString(),
      nomComplet: json['nomComplet']?.toString(),
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'badge': badge,
      'nextBadge': nextBadge,
      'pointsToNextBadge': pointsToNextBadge,
      'progression': progression,
      'message': message,
      'nomComplet': nomComplet,
      'email': email,
    };
  }
}

