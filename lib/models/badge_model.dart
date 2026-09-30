/// Modèle représentant la progression culturelle et les Badges Bambara du joueur.
class BadgeModel {
  final String nom;
  final String code;
  final String description;
  final int seuilPoints;
  final bool debloque;
  final String iconName;

  const BadgeModel({
    required this.nom,
    required this.code,
    required this.description,
    required this.seuilPoints,
    this.debloque = false,
    required this.iconName,
  });

  static List<BadgeModel> defaultBadges(int currentPoints) {
    return [
      BadgeModel(
        nom: 'Kalanden',
        code: 'KALANDEN',
        description: 'Apprenti de la culture malienne (0 - 199 pts)',
        seuilPoints: 0,
        debloque: currentPoints >= 0,
        iconName: 'school',
      ),
      BadgeModel(
        nom: 'Fasoden',
        code: 'FASODEN',
        description: 'Citoyen du Savoir et ambassadeur (200 - 499 pts)',
        seuilPoints: 200,
        debloque: currentPoints >= 200,
        iconName: 'military_tech',
      ),
      BadgeModel(
        nom: 'Fasoden Yuman',
        code: 'FASODEN_YUMAN',
        description: 'Héros Culturel et Maître du Patrimoine (500+ pts)',
        seuilPoints: 500,
        debloque: currentPoints >= 500,
        iconName: 'workspace_premium',
      ),
    ];
  }
}

/// Progression complète renvoyée par le backend Spring Boot (/api/progression).
class ProgressionModel {
  final int idUsers;
  final String nomComplet;
  final String email;
  final int points;
  final String badge;
  final String? badgeCode;
  final String? badgeDescription;
  final String? nextBadge;
  final int? pointsToNextBadge;
  final double progression;
  final String? message;

  const ProgressionModel({
    required this.idUsers,
    required this.nomComplet,
    required this.email,
    required this.points,
    required this.badge,
    this.badgeCode,
    this.badgeDescription,
    this.nextBadge,
    this.pointsToNextBadge,
    this.progression = 0.0,
    this.message,
  });

  factory ProgressionModel.fromJson(Map<String, dynamic> json) {
    return ProgressionModel(
      idUsers: (json['idUsers'] as num?)?.toInt() ?? 0,
      nomComplet: json['nomComplet'] as String? ?? '',
      email: json['email'] as String? ?? '',
      points: (json['points'] as num?)?.toInt() ?? 0,
      badge: json['badge'] as String? ?? 'Kalanden',
      badgeCode: json['badgeCode'] as String?,
      badgeDescription: json['badgeDescription'] as String?,
      nextBadge: json['nextBadge'] as String?,
      pointsToNextBadge: (json['pointsToNextBadge'] as num?)?.toInt(),
      progression: (json['progression'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] as String?,
    );
  }
}
