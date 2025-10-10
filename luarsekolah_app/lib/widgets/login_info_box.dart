import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginInfoBox extends StatelessWidget {
  final String emoji;
  final String questionText;
  final String actionText;
  final Widget navigateTo; // halaman tujuan saat teks diklik
  final Color? backgroundColor;

  const LoginInfoBox({
    super.key,
    this.emoji = '👋',
    required this.questionText,
    required this.actionText,
    required this.navigateTo,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Color(0xFF2570EB)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(text: '$questionText '),
                  TextSpan(
                    text: actionText,
                    style: DefaultTextStyle.of(context).style.copyWith(
                      fontSize: 14,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => navigateTo),
                        );
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
