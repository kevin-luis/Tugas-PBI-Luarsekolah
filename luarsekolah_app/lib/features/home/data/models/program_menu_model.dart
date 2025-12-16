// lib/features/home/data/models/program_menu_model.dart

import 'package:flutter/material.dart';
import 'package:luarsekolah_app/features/home/domain/entities/program_menu_entity.dart';

class ProgramMenuModel extends ProgramMenuEntity {
  ProgramMenuModel({
    required super.id,
    required super.label,
    required super.icon,
    required super.color,
    super.route,
  });

  factory ProgramMenuModel.fromJson(Map<String, dynamic> json) {
    return ProgramMenuModel(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      icon: _parseIcon(json['icon']),
      color: Color(json['color'] ?? 0xFF26A69A),
      route: json['route'],
    );
  }

  static IconData _parseIcon(dynamic iconData) {
    if (iconData is int) {
      return IconData(iconData, fontFamily: 'MaterialIcons');
    }
    return Icons.apps;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'icon': icon.codePoint,
      'color': color.toARGB32(),
      'route': route,
    };
  }
}