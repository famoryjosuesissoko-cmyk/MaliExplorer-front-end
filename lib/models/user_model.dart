import 'package:flutter/foundation.dart';

enum UserRole {
  touriste,
  guide,
  promoteur,
  admin,
  superAdmin,
  autre;

  static UserRole fromString(String? role) {
    if (role == null) return UserRole.touriste;
    final r = role.toLowerCase().trim();
    if (r.contains('superadmin')) return UserRole.superAdmin;
    if (r.contains('admin')) return UserRole.admin;
    if (r.contains('promoteur') || r.contains('partenaire')) return UserRole.promoteur;
    if (r.contains('guide')) return UserRole.guide;
    if (r.contains('touriste')) return UserRole.touriste;
    return UserRole.autre;
  }
}

@immutable
class UserModel {
  final int? idUsers;
  final String? firebaseUid;
  final String email;
  final String nom;
  final String prenom;
  final String? adresse;
  final String? telephone;
  final String? pieceIdentite;
  final String? nomOrganisation;
  final String? photoUrl;
  final UserRole role;
  final String? statut;
  final String? statutModeration;
  final int points;

  const UserModel({
    this.idUsers,
    this.firebaseUid,
    required this.email,
    this.nom = '',
    this.prenom = '',
    this.adresse,
    this.telephone,
    this.pieceIdentite,
    this.nomOrganisation,
    this.photoUrl,
    this.role = UserRole.touriste,
    this.statut,
    this.statutModeration,
    this.points = 0,
  });

  bool get isPromoteur => role == UserRole.promoteur;
  bool get isGuide => role == UserRole.guide;
  bool get isAdmin => role == UserRole.admin || role == UserRole.superAdmin;
  bool get isTouriste => role == UserRole.touriste;

  bool get isPromoteurValide =>
      isPromoteur &&
      (statutModeration?.toUpperCase() == 'VALIDE' ||
          statutModeration?.toUpperCase() == 'APPROUVE');

  bool get isPromoteurEnAttente =>
      isPromoteur &&
      (statutModeration == null ||
          statutModeration?.toUpperCase() == 'EN_ATTENTE' ||
          statutModeration?.toUpperCase() == 'EN_ATTENTE_VALIDATION');

  bool get isPromoteurRejete =>
      isPromoteur &&
      (statutModeration?.toUpperCase() == 'REJETE' ||
          statutModeration?.toUpperCase() == 'REFUSE');

  bool get isGuideValide =>
      (role == UserRole.guide) &&
      (statutModeration == 'VALIDE' ||
          statutModeration == 'APPROUVE' ||
          statutModeration?.toUpperCase() == 'VALIDE' ||
          statutModeration?.toUpperCase() == 'APPROUVE');

  bool get isGuideEnAttente =>
      (role == UserRole.guide) &&
      (statutModeration == 'EN_ATTENTE_VALIDATION' ||
          statutModeration == 'EN_ATTENTE' ||
          statutModeration == null ||
          statutModeration!.isEmpty ||
          statutModeration?.toUpperCase() == 'EN_ATTENTE_VALIDATION' ||
          statutModeration?.toUpperCase() == 'EN_ATTENTE');

  bool get isGuideRejete =>
      (role == UserRole.guide) &&
      (statutModeration == 'REJETE' ||
          statutModeration == 'REFUSE' ||
          statutModeration?.toUpperCase() == 'REJETE' ||
          statutModeration?.toUpperCase() == 'REFUSE');

  bool get isProValide => isPromoteurValide || isGuideValide;
  bool get isProEnAttente => isPromoteurEnAttente || isGuideEnAttente;
  bool get isProRejete => isPromoteurRejete || isGuideRejete;

  String get displayName {
    final full = '$prenom $nom'.trim();
    return full.isNotEmpty ? full : 'Utilisateur MaliExplorer';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role'] ?? json['type'] ?? json['roleName'];
    final rawStatutMod = json['statutModeration'] ?? json['statut_moderation'];

    return UserModel(
      idUsers: json['idUsers'] is int
          ? json['idUsers']
          : (json['id'] is int ? json['id'] : int.tryParse(json['idUsers']?.toString() ?? '')),
      firebaseUid: json['firebaseUid']?.toString() ?? json['uid']?.toString(),
      email: json['email']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      prenom: json['prenom']?.toString() ?? '',
      adresse: json['adresse']?.toString(),
      telephone: json['telephone']?.toString(),
      pieceIdentite: json['pieceIdentite']?.toString() ?? json['piece_identite']?.toString(),
      nomOrganisation: json['nomOrganisation']?.toString() ?? json['nom_organisation']?.toString(),
      photoUrl: json['photoUrl']?.toString() ?? json['photoURL']?.toString(),
      role: UserRole.fromString(rawRole?.toString()),
      statut: json['statut']?.toString(),
      statutModeration: rawStatutMod?.toString(),
      points: json['points'] is int
          ? json['points']
          : (int.tryParse(json['points']?.toString() ?? '') ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'idUsers': idUsers,
        'firebaseUid': firebaseUid,
        'email': email,
        'nom': nom,
        'prenom': prenom,
        'adresse': adresse,
        'telephone': telephone,
        'pieceIdentite': pieceIdentite,
        'nomOrganisation': nomOrganisation,
        'photoUrl': photoUrl,
        'role': role.name,
        'statut': statut,
        'statutModeration': statutModeration,
        'points': points,
      };

  Map<String, dynamic> toMap() => toJson();

  UserModel copyWith({
    int? idUsers,
    String? firebaseUid,
    String? email,
    String? nom,
    String? prenom,
    String? adresse,
    String? telephone,
    String? pieceIdentite,
    String? nomOrganisation,
    String? photoUrl,
    UserRole? role,
    String? statut,
    String? statutModeration,
    int? points,
  }) {
    return UserModel(
      idUsers: idUsers ?? this.idUsers,
      firebaseUid: firebaseUid ?? this.firebaseUid,
      email: email ?? this.email,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      adresse: adresse ?? this.adresse,
      telephone: telephone ?? this.telephone,
      pieceIdentite: pieceIdentite ?? this.pieceIdentite,
      nomOrganisation: nomOrganisation ?? this.nomOrganisation,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      statut: statut ?? this.statut,
      statutModeration: statutModeration ?? this.statutModeration,
      points: points ?? this.points,
    );
  }
}
