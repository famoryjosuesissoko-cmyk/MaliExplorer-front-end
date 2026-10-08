class HistoriquePointModel {
  final int idHistorique;
  final String action;
  final int pointsGagnes;
  final String? description;
  final String? referenceActivite;
  final DateTime? dateGain;

  const HistoriquePointModel({
    required this.idHistorique,
    required this.action,
    required this.pointsGagnes,
    this.description,
    this.referenceActivite,
    this.dateGain,
  });

  factory HistoriquePointModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['dateGain'] != null) {
      try {
        parsedDate = DateTime.parse(json['dateGain'].toString());
      } catch (_) {
        parsedDate = null;
      }
    }

    return HistoriquePointModel(
      idHistorique: (json['idHistorique'] as num?)?.toInt() ?? 0,
      action: json['action']?.toString() ?? 'ACTIVITE',
      pointsGagnes: (json['pointsGagnes'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString(),
      referenceActivite: json['referenceActivite']?.toString(),
      dateGain: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idHistorique': idHistorique,
      'action': action,
      'pointsGagnes': pointsGagnes,
      'description': description,
      'referenceActivite': referenceActivite,
      'dateGain': dateGain?.toIso8601String(),
    };
  }
}

