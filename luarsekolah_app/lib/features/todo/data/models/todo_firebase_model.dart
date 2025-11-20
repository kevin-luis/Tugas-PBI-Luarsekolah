import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/todo_entity.dart';

/// Extended TodoModel specifically for Firebase Firestore
/// Handles Timestamp conversion properly
class TodoFirebaseModel extends TodoEntity {
  const TodoFirebaseModel({
    required super.id,
    required super.text,
    required super.completed,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from Firestore document
  factory TodoFirebaseModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Document data is null');
    }

    return TodoFirebaseModel(
      id: doc.id,
      text: data['text']?.toString() ?? '',
      completed: data['completed'] == true,
      createdAt: _parseTimestamp(data['createdAt']),
      updatedAt: _parseTimestamp(data['updatedAt']),
    );
  }

  /// Create from JSON (with Timestamp support)
  factory TodoFirebaseModel.fromJson(Map<String, dynamic> json) {
    try {
      return TodoFirebaseModel(
        id: json['id']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        completed: json['completed'] == true,
        createdAt: _parseTimestamp(json['createdAt']),
        updatedAt: _parseTimestamp(json['updatedAt']),
      );
    } catch (e) {
      print('[TodoFirebaseModel] Error parsing: $e');
      print('[TodoFirebaseModel] JSON data: $json');
      rethrow;
    }
  }

  /// Parse Timestamp from Firestore
  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }

    try {
      // If it's a Firestore Timestamp
      if (value is Timestamp) {
        return value.toDate();
      }

      // If it's already a DateTime
      if (value is DateTime) {
        return value;
      }

      // If it's a String (ISO 8601)
      if (value is String) {
        return DateTime.parse(value);
      }

      // If it's an int (milliseconds since epoch)
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }

      print('[TodoFirebaseModel] Unknown date format: ${value.runtimeType}');
      return DateTime.now();
    } catch (e) {
      print('[TodoFirebaseModel] Error parsing timestamp: $value, error: $e');
      return DateTime.now();
    }
  }

  /// Convert to Firestore format (for saving)
  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'completed': completed,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Convert to JSON (for debugging or API)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'completed': completed,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to Entity
  TodoEntity toEntity() {
    return TodoEntity(
      id: id,
      text: text,
      completed: completed,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create a copy with updated fields
  @override
  TodoFirebaseModel copyWith({
    String? id,
    String? text,
    bool? completed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoFirebaseModel(
      id: id ?? this.id,
      text: text ?? this.text,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}