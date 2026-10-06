class GuideModel {
  final int idUsers;
  final String? firebaseUid;
  final String prenom;
  final String nom;
  final String email;
  final String adresse;
  final String photoUrl;
  final String? dateCreation;
  final String role;
  final int experience;
  final String description;
  final String langue;
  final bool recherchePartenariat;
  final String? titreProjet;
  final String? besoinPartenariat;
  final String? statutModeration;

  const GuideModel({
    required this.idUsers,
    this.firebaseUid,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.adresse,
    required this.photoUrl,
    this.dateCreation,
    required this.role,
    required this.experience,
    required this.description,
    required this.langue,
    required this.recherchePartenariat,
    this.titreProjet,
    this.besoinPartenariat,
    this.statutModeration,
  });

  String get fullName => '$prenom $nom'.trim();

  factory GuideModel.fromJson(Map<String, dynamic> json) {
    return GuideModel(
      idUsers: json['idUsers'] ?? 0,
      firebaseUid: json['firebaseUid'],
      prenom: json['prenom'] ?? '',
      nom: json['nom'] ?? '',
      email: json['email'] ?? '',
      adresse: json['adresse'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      dateCreation: json['dateCreation']?.toString(),
      role: json['role'] ?? 'guide',
      experience: json['experience'] ?? 0,
      description: json['description'] ?? '',
      langue: json['langue'] ?? '',
      recherchePartenariat: json['recherchePartenariat'] ?? false,
      titreProjet: json['titreProjet'],
      besoinPartenariat: json['besoinPartenariat'],
      statutModeration: json['statutModeration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsers': idUsers,
      'firebaseUid': firebaseUid,
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'adresse': adresse,
      'photoUrl': photoUrl,
      'dateCreation': dateCreation,
      'role': role,
      'experience': experience,
      'description': description,
      'langue': langue,
      'recherchePartenariat': recherchePartenariat,
      'titreProjet': titreProjet,
      'besoinPartenariat': besoinPartenariat,
      'statutModeration': statutModeration,
    };
  }
}
