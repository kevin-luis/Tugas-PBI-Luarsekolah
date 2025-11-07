import '../../domain/entities/todo_entity.dart';

class TodoModel extends TodoEntity {
  const TodoModel({
    required super.id,
    required super.text,
    required super.completed,
    required super.createdAt,
    required super.updatedAt,
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

  TodoEntity toEntity() {
    return TodoEntity(
      id: id,
      text: text,
      completed: completed,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}