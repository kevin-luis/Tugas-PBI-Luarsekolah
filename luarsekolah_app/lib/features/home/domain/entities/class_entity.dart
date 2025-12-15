// lib/features/home/domain/entities/class_entity.dart

import 'package:flutter/material.dart';

class ClassEntity {
  final String id;
  final String title;
  final String price;
  final double rating;
  final Color color;
  final IconData icon;
  final String category;
  final int totalStudents;

  ClassEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.rating,
    required this.color,
    required this.icon,
    required this.category,
    this.totalStudents = 0,
  });
}