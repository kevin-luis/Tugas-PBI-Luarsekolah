import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_widgets.dart';
import '../../../../core/routes/app_routes.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    final RxBool isEmailValid = false.obs;
    final RxBool isPasswordValid = false.obs;
    final RxBool isNotRobot = false.obs;

    // void checkForm() {
    //   // Form validation handled by Obx
    // }

    Future<void> handleLogin() async {
      if (formKey.currentState!.validate() && isNotRobot.value) {
        final success = await controller.login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        if (success) {
          Get.snackbar(
            'Login Berhasil',
            'Selamat datang, ${controller.currentUser.value?.name}!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade900,
          );
          await Future.delayed(const Duration(milliseconds: 500));
          Get.offAllNamed(AppRoutes.main);
        } else {
          Get.snackbar(
            'Login Gagal',
            controller.errorMessage.value,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
        }
      }
    }

    Future<void> handleGoogleLogin() async {
      final success = await controller.loginWithGoogle();
      if (success) {
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(AppRoutes.main);
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LogoImage(),
                const SizedBox(height: 24),
                const MainTitle(
                  title: 'Masuk ke Akunmu Untuk Lanjut Akses ke Luarsekolah',
                ),
                const SizedBox(height: 24),
                GoogleLoginButton(onPressed: handleGoogleLogin),
                const SizedBox(height: 16),
                const DividerWithText(text: 'atau gunakan email'),
                const SizedBox(height: 24),
                DynamicTextField(
                  label: 'Email',
                  displayMode: ValidationDisplayMode.hideOnValid,
                  controller: emailController,
                  type: FieldType.email,
                  hintText: 'Masukkan email terdaftar',
                  rules: [
                    ValidationRule(
                      message: 'Format email @domain.com',
                      validate: (s) =>
                          RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(s),
                    ),
                  ],
                  onValidationChanged: (v) {
                    isEmailValid.value = v;
                  },
                ),
                const SizedBox(height: 16),
                DynamicTextField(
                  label: 'Password',
                  displayMode: ValidationDisplayMode.hideOnValid,
                  controller: passwordController,
                  type: FieldType.password,
                  hintText: 'Masukkan password Anda',
                  rules: [
                    ValidationRule(
                      message: 'Password wajib diisi',
                      validate: (s) => s.trim().isNotEmpty,
                    ),
                  ],
                  onValidationChanged: (v) {
                    isPasswordValid.value = v;
                  },
                ),
                const SizedBox(height: 16),
                Obx(() => RecaptchaBox(
                      value: isNotRobot.value,
                      onChanged: (v) => isNotRobot.value = v,
                    )),
                const SizedBox(height: 24),
                Obx(() {
                  final isFormValid = isEmailValid.value &&
                      isPasswordValid.value &&
                      isNotRobot.value;
                  return PrimaryButton(
                    label: 'Masuk',
                    loadingText: 'Mohon Tunggu...',
                    enabled: isFormValid && !controller.isLoading.value,
                    onPressed: handleLogin,
                  );
                }),
                const SizedBox(height: 24),
                LoginInfoBox(
                  questionText: 'Belum punya akun?',
                  actionText: 'Daftar Sekarang',
                  onTap: () => Get.toNamed(AppRoutes.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
