class User {
  final String userId;
  final String nom;
  final String role;
  final String specialite;
  final String wilayaAssignee;

  User({
    required this.userId,
    required this.nom,
    required this.role,
    required this.specialite,
    required this.wilayaAssignee,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['User_ID'] ?? '',
      nom: json['Nom'] ?? '',
      role: json['Role'] ?? '',
      specialite: json['Specialite'] ?? '',
      wilayaAssignee: json['Wilaya_Assignee'] ?? '',
    );
  }
}
