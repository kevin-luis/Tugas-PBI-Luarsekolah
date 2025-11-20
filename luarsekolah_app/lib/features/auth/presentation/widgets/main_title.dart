import 'package:flutter/material.dart';

class MainTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const MainTitle({
    super.key,
    required this.title,
    this.subtitle = 'Satu akun untuk akses Luarsekolah dan BelajarBekerja',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
