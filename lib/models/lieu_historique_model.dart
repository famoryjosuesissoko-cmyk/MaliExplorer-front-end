/// Modèle représentant un lieu ou monument historique du Mali.
class LieuHistoriqueModel {
  final int idLieu;
  final String nomLieuHisto;
  final String? description;
  final String? epoque;
  final String? cordonnees;
  final double? latitude;
  final double? longitude;
  final String? panorama360Url;
  final String? villeNom;
  final int? villeId;

  const LieuHistoriqueModel({
    required this.idLieu,
    required this.nomLieuHisto,
    this.description,
    this.epoque,
    this.cordonnees,
    this.latitude,
    this.longitude,
    this.panorama360Url,
    this.villeNom,
    this.villeId,
  });

  bool get has360 => panorama360Url != null && panorama360Url!.trim().isNotEmpty;

  factory LieuHistoriqueModel.fromJson(Map<String, dynamic> json) {
    String? vNom;
    int? vId;
    if (json['ville'] != null && json['ville'] is Map<String, dynamic>) {
      vNom = json['ville']['nomVille'] as String?;
      vId = json['ville']['idVille'] as int?;
    } else {
      vNom = json['villeNom'] as String?;
      vId = json['villeId'] as int?;
    }

    return LieuHistoriqueModel(
      idLieu: (json['idLieu'] as num?)?.toInt() ?? 0,
      nomLieuHisto: json['nomLieuHisto'] as String? ?? json['nom'] as String? ?? '',
      description: json['description'] as String?,
      epoque: json['epoque'] as String?,
      cordonnees: json['cordonnees'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      panorama360Url: json['panorama360Url'] as String?,
      villeNom: vNom,
      villeId: vId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idLieu': idLieu,
      'nomLieuHisto': nomLieuHisto,
      'description': description,
      'epoque': epoque,
      'cordonnees': cordonnees,
      'latitude': latitude,
      'longitude': longitude,
      'panorama360Url': panorama360Url,
      'villeNom': villeNom,
      'villeId': villeId,
    };
  }
}
