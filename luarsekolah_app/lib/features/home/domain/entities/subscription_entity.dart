// lib/features/home/domain/entities/subscription_entity.dart

import 'package:flutter/material.dart';

class SubscriptionEntity {
  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final List<Color> gradientColors;
  final IconData icon;
  final Color backgroundColor;
  final int totalClasses;

  SubscriptionEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.gradientColors,
    required this.icon,
    required this.backgroundColor,
    this.totalClasses = 5,
  });
}