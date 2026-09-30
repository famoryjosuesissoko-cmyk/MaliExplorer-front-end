/// Modèle représentant une ethnie et ses traditions culturelles au Mali.
class EthnieModel {
  final int idEthnie;
  final String nomEthnie;
  final String? description;
  final String? langue;
  final String? tradition;
  final String? imageEthnie;

  const EthnieModel({
    required this.idEthnie,
    required this.nomEthnie,
    this.description,
    this.langue,
    this.tradition,
    this.imageEthnie,
  });

  factory EthnieModel.fromJson(Map<String, dynamic> json) {
    return EthnieModel(
      idEthnie: json['idEthnie'] as int? ?? 0,
      nomEthnie: json['nomEthnie'] as String? ?? '',
      description: json['description'] as String?,
      langue: json['langue'] as String?,
      tradition: json['tradition'] as String?,
      imageEthnie: json['imageEthnie'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idEthnie': idEthnie,
      'nomEthnie': nomEthnie,
      'description': description,
      'langue': langue,
      'tradition': tradition,
      'imageEthnie': imageEthnie,
    };
  }
}
