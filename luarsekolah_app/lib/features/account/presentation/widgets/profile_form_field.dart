// lib/features/account/presentation/widgets/profile_form_field.dart

import 'package:flutter/material.dart';

class ProfileFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool enabled;
  final TextInputType? keyboardType;

  const ProfileFormField({
    Key? key,
    required this.label,
    required this.controller,
    required this.hint,
    this.enabled = true,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: enabled
              ? null
              : TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}