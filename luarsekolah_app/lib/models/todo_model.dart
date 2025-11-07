class TodoModel {
  final String id;
  final String text;
  final bool completed;
  final DateTime createdAt;
  final DateTime updatedAt;

  TodoModel({
    required this.id,
    required this.text,
    required this.completed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    try {
      return TodoModel(
        id: json['id']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        completed: json['completed'] == true || json['completed'] == 'true',
        createdAt: _parseDateTime(json['createdAt']),
        updatedAt: _parseDateTime(json['updatedAt']),
      );
    } catch (e) {
      print('[TodoModel] Error parsing: $e');
      print('[TodoModel] JSON data: $json');
      rethrow;
    }
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now();
    }

    try {
      if (dateValue is DateTime) {
        return dateValue;
      }

      if (dateValue is String) {
        // Handle ISO 8601 format with .000Z
        return DateTime.parse(dateValue);
      }

      return DateTime.now();
    } catch (e) {
      print('[TodoModel] Error parsing date: $dateValue, error: $e');
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
