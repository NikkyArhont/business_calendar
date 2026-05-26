class AssistantAccess {
  final String assistantId; // Это ID документа в коллекции assistants
  final String assistantName; // Временно "Новый помощник", пока не реализовано
  final String role; // "Читатель", "Редактор", "Полные права"
  final String accessScope; // "Все события", "Только рабочие"
  final List<String> permissions; // На будущее

  AssistantAccess({
    required this.assistantId,
    required this.assistantName,
    required this.role,
    required this.accessScope,
    required this.permissions,
  });

  Map<String, dynamic> toMap() {
    return {
      'assistantName': assistantName,
      'role': role,
      'accessScope': accessScope,
      'permissions': permissions,
    };
  }

  factory AssistantAccess.fromMap(Map<String, dynamic> map, String docId) {
    return AssistantAccess(
      assistantId: docId,
      assistantName: map['assistantName'] ?? 'Неизвестный помощник',
      role: map['role'] ?? 'Читатель',
      accessScope: map['accessScope'] ?? 'Все события',
      permissions: List<String>.from(map['permissions'] ?? []),
    );
  }
}
