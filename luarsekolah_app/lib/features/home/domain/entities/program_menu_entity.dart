// lib/features/home/domain/entities/program_menu_entity.dart

import 'package:flutter/material.dart';

class ProgramMenuEntity {
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final String? route;

  ProgramMenuEntity({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    this.route,
  });
}