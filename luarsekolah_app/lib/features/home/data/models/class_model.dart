// lib/features/home/data/models/class_model.dart

import 'package:flutter/material.dart';
import '../../domain/entities/class_entity.dart';

class ClassModel extends ClassEntity {
  ClassModel({
    required super.id,
    required super.title,
    required super.price,
    required super.rating,
    required super.color,
    required super.icon,
    required super.category,
    super.totalStudents,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      price: json['price'] ?? 'Rp 0',
      rating: (json['rating'] ?? 0.0).toDouble(),
      color: Color(json['color'] ?? 0xFF4CAF50),
      icon: _parseIcon(json['icon']),
      category: json['category'] ?? '',
      totalStudents: json['total_students'] ?? 0,
    );
  }

  static IconData _parseIcon(dynamic iconData) {
    if (iconData is int) {
      return IconData(iconData, fontFamily: 'MaterialIcons');
    }
    return Icons.book;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'rating': rating,
      'color': color.value,
      'icon': icon.codePoint,
      'category': category,
      'total_students': totalStudents,
    };
  }
}