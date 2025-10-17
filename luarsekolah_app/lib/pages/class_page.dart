import 'package:flutter/material.dart';

class ClassPage extends StatelessWidget {
  const ClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Class Page')),
      body: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: double.infinity,
          minHeight: double.infinity,
        ),
        child: const Center(
          child: Text(
            'Class Page',
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}