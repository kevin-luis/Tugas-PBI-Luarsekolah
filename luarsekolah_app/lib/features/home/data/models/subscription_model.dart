// lib/features/home/data/models/subscription_model.dart

import 'package:flutter/material.dart';
import '../../domain/entities/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  SubscriptionModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.color,
    required super.gradientColors,
    required super.icon,
    required super.backgroundColor,
    super.totalClasses,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      color: Color(json['color'] ?? 0xFF8B5CF6),
      gradientColors: _parseGradientColors(json['gradient_colors']),
      icon: _parseIcon(json['icon']),
      backgroundColor: Color(json['background_color'] ?? 0xFFF3E5F5),
      totalClasses: json['total_classes'] ?? 5,
    );
  }

  static IconData _parseIcon(dynamic iconData) {
    if (iconData is int) {
      return IconData(iconData, fontFamily: 'MaterialIcons');
    }
    return Icons.school;
  }

  static List<Color> _parseGradientColors(dynamic colors) {
    if (colors is List && colors.length >= 2) {
      return [
        Color(colors[0] ?? 0xFF8B5CF6),
        Color(colors[1] ?? 0xFF7C3AED),
      ];
    }
    return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'color': color.value,
      'gradient_colors': gradientColors.map((c) => c.value).toList(),
      'icon': icon.codePoint,
      'background_color': backgroundColor.value,
      'total_classes': totalClasses,
    };
  }
}