import 'package:flutter/material.dart';
import 'pages/register_page.dart';
import 'pages/main_navigation.dart';
import 'pages/login_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luarsekolah App',
      // Tambahkan ini untuk localization
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Daftar bahasa yang didukung
      supportedLocales: const [
        Locale('id', 'ID'), // Bahasa Indonesia
        Locale('en', 'US'), // English
      ],

      // Set locale default ke Bahasa Indonesia
      locale: const Locale('id', 'ID'),
      theme: ThemeData(
        // textTheme: GoogleFonts.poppinsTextTheme(
        //   Theme.of(context).textTheme,
        // ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF077E60)),
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      initialRoute: '/main',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) => const MainNavigation(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
