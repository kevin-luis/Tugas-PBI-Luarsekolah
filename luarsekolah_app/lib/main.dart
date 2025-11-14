// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Get.put<ClassController>(ClassController(), permanent: true);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Luarsekolah App',
      
      // ✅ Gunakan GetX routing
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      locale: const Locale('id', 'ID'),
      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF077E60),
        ),
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      
      debugShowCheckedModeBanner: false,
    );
  }
}
