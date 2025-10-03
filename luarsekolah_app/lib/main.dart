import 'package:flutter/material.dart';
import 'pages/register_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luarsekolah App',
      initialRoute: '/register',
      routes: {
        '/register': (context) => const RegisterPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
