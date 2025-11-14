import 'package:flutter/material.dart';

class RecaptchaBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const RecaptchaBox({required this.value, required this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(4)),
      child: Row(children: [
        Checkbox(value: value, onChanged: (v) => onChanged(v ?? false), materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
        const Text("I'm not a robot", style: TextStyle(fontSize: 14)),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Image.network('https://www.gstatic.com/recaptcha/api2/logo_48.png', width: 32, height: 32),
          const Text('reCAPTCHA', style: TextStyle(fontSize: 8, color: Colors.grey)),
          const Text('Privacy - Terms', style: TextStyle(fontSize: 7, color: Colors.grey)),
        ]),
      ]),
    );
  }
}
