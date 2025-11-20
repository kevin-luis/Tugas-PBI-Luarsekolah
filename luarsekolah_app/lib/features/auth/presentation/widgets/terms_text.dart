import 'package:flutter/material.dart';

class TermsText extends StatelessWidget {
  const TermsText({super.key});
  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(style: const TextStyle(fontSize: 14, color: Colors.black87), children: [
        const TextSpan(text: 'Dengan mendaftar di Luarsekolah, kamu menyetujui '),
        TextSpan(text: 'syarat dan ketentuan kami', style: TextStyle(color: Colors.blue[700])),
      ]),
    );
  }
}
