class Task {
  final int taskId;
  final String btsId;
  final String userId;
  final String titre;
  final String description;
  final String priorite;
  final String statutTask;
  
  // Les informations de la BTS qui sont récupérées via la jointure SQL du backend
  final double btsX;
  final double btsY;
  final String btsStatut;

  Task({
    required this.taskId,
    required this.btsId,
    required this.userId,
    required this.titre,
    required this.description,
    required this.priorite,
    required this.statutTask,
    required this.btsX,
    required this.btsY,
    required this.btsStatut,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      taskId: json['Task_ID'] ?? 0,
      btsId: json['bts_id']?.toString() ?? '',
      userId: json['User_ID']?.toString() ?? '',
      titre: json['Titre']?.toString() ?? '',
      description: json['Description']?.toString() ?? '',
      priorite: json['Priorite']?.toString() ?? '',
      statutTask: json['Statut_Task']?.toString() ?? '',
      btsX: double.tryParse(json['bts_x']?.toString() ?? '') ?? 0.0,
      btsY: double.tryParse(json['bts_y']?.toString() ?? '') ?? 0.0,
      btsStatut: json['statut']?.toString() ?? '',
    );
  }
}
