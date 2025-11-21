// lib/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import '../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    // Tunggu sebentar untuk tampilan splash
    await Future.delayed(const Duration(seconds: 2));

    final authController = Get.find<AuthController>();
    
    // Check current user
    await authController.checkCurrentUser();

    // Navigate berdasarkan auth state
    if (authController.isLoggedIn) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo atau animasi
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(
                'assets/lottie/sandy_loading.json',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Luarsekolah',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26A69A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}