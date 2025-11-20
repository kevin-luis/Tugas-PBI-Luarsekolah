import 'package:flutter/material.dart';

class LogoImage extends StatelessWidget {
  const LogoImage({super.key});
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ls-logo-text.png',
      width: 78,
      height: 40,
      fit: BoxFit.contain,
    );
  }
}