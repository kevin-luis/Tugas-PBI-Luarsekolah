import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormInputWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? helperText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const FormInputWidget({
    Key? key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.helperText,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            helperText: helperText,
            helperStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
            prefixIcon: prefixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2D6F5C)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }
}