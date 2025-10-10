import 'package:flutter/material.dart';
import 'pages/register_page.dart';
import 'pages/main_navigation.dart';
import 'pages/login_page.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luarsekolah App',
      theme: ThemeData(
        // textTheme: GoogleFonts.poppinsTextTheme(
        //   Theme.of(context).textTheme,
        // ),
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) => const MainNavigation(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

