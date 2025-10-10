import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  const DividerWithText({required this.text, super.key});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Divider(color: Colors.grey[300])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[600]))),
      Expanded(child: Divider(color: Colors.grey[300])),
    ]);
  }
}