enum UserRole {
  touriste,
  guide,
  artisan,
  promoteur,
  admin,
  superAdmin;

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.touriste;
    switch (role.toLowerCase()) {
      case 'guide':
        return UserRole.guide;
      case 'artisan':
        return UserRole.artisan;
      case 'promoteur':
        return UserRole.promoteur;
      case 'admin':
        return UserRole.admin;
      case 'superadmin':
      case 'super_admin':
        return UserRole.superAdmin;
      case 'touriste':
      default:
        return UserRole.touriste;
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.touriste:
        return 'Touriste';
      case UserRole.guide:
        return 'Guide Touristique';
      case UserRole.artisan:
        return 'Artisan Local';
      case UserRole.promoteur:
        return "Promoteur d'Événement";
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.superAdmin:
        return 'Super Administrateur';
    }
  }
}

class UserModel {
  final int idUsers;
  final String firebaseUid;
  final String prenom;
  final String nom;
  final String email;
  final String? photoUrl;
  final String? adresse;
  final UserRole role;
  final int points;

  const UserModel({
    required this.idUsers,
    required this.firebaseUid,
    required this.prenom,
    required this.nom,
    required this.email,
    this.photoUrl,
    this.adresse,
    required this.role,
    this.points = 0,
  });

  String get nomComplet => '$prenom $nom'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUsers: json['idUsers'] as int? ?? 0,
      firebaseUid: json['firebaseUid'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      adresse: json['adresse'] as String?,
      role: UserRole.fromString(json['role'] as String?),
      points: json['points'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsers': idUsers,
      'firebaseUid': firebaseUid,
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'photoUrl': photoUrl,
      'adresse': adresse,
      'role': role.name,
      'points': points,
    };
  }
}
