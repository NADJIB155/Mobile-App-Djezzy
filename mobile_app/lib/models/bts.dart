class Bts {
  final String btsId;
  final double btsX;
  final double btsY;
  final String typeAntenne;
  final String statut;

  Bts({
    required this.btsId,
    required this.btsX,
    required this.btsY,
    required this.typeAntenne,
    required this.statut,
  });

  factory Bts.fromJson(Map<String, dynamic> json) {
    return Bts(
      btsId: json['bts_id']?.toString() ?? '',
      btsX: double.tryParse(json['bts_x']?.toString() ?? '') ?? 0.0,
      btsY: double.tryParse(json['bts_y']?.toString() ?? '') ?? 0.0,
      typeAntenne: json['type_antenne']?.toString() ?? '',
      statut: json['statut']?.toString() ?? '',
    );
  }
}
