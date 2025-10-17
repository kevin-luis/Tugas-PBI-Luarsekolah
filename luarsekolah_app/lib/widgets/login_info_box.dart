import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginInfoBox extends StatelessWidget {
  final String emoji;
  final String questionText;
  final String actionText;
  final Widget navigateTo;
  final Color? backgroundColor;

  const LoginInfoBox({
    super.key,
    this.emoji = '👋',
    required this.questionText,
    required this.actionText,
    required this.navigateTo,
    this.backgroundColor,
  });

  void _navigateWithAnimation(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, __) => navigateTo,
        transitionsBuilder: (_, animation, __, child) {
          final slide = Tween<Offset>(
            begin: const Offset(1, 0), // dari kanan
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));

          return SlideTransition(
            position: slide,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.blue[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2570EB)),
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => _navigateWithAnimation(context),
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
