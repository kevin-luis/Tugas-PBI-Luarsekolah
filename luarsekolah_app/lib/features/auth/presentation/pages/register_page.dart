import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_widgets.dart';
import '../../../../core/routes/app_routes.dart';

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final emailController = TextEditingController();
    final whatsappController = TextEditingController();
    final passwordController = TextEditingController();

    final RxBool isNamaValid = false.obs;
    final RxBool isEmailValid = false.obs;
    final RxBool isPhoneValid = false.obs;
    final RxBool isPasswordValid = false.obs;
    final RxBool isNotRobot = false.obs;

    Future<void> handleRegister() async {
      if (formKey.currentState!.validate() && isNotRobot.value) {
        final success = await controller.register(
          name: namaController.text.trim(),
          email: emailController.text.trim(),
          phoneNumber: whatsappController.text.trim(),
          password: passwordController.text,
        );

        if (success) {
          await Future.delayed(const Duration(milliseconds: 500));
          Get.offAllNamed(AppRoutes.main);
        }
      }
    }

    Future<void> handleGoogleSignIn() async {
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
                  title: 'Daftarkan Akun Untuk Lanjut Akses ke Luarsekolah',
                ),
                const SizedBox(height: 24),
                GoogleSignInButton(onPressed: handleGoogleSignIn),
                const SizedBox(height: 16),
                const DividerWithText(text: 'atau gunakan email'),
                const SizedBox(height: 24),
                DynamicTextField(
                  label: 'Nama Lengkap',
                  controller: namaController,
                  type: FieldType.generic,
                  hintText: 'Masukkan nama lengkap',
                  rules: [
                    ValidationRule(
                      message: 'Nama tidak boleh kosong',
                      validate: (s) => s.trim().isNotEmpty,
                    ),
                    ValidationRule(
                      message: 'Gunakan hanya huruf dan spasi',
                      validate: (s) => RegExp(r'^[A-Za-z\s]+$').hasMatch(s),
                    ),
                    ValidationRule(
                      message: 'Minimal 2 kata (nama depan & belakang)',
                      validate: (s) => s.trim().split(' ').length >= 2,
                    ),
                  ],
                  onValidationChanged: (v) => isNamaValid.value = v,
                ),
                const SizedBox(height: 16),
                DynamicTextField(
                  label: 'Email',
                  controller: emailController,
                  type: FieldType.email,
                  hintText: 'nama@domain.com',
                  rules: [
                    ValidationRule(
                      message: 'Format email harus valid',
                      validate: (s) =>
                          RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(s),
                    ),
                  ],
                  onValidationChanged: (v) => isEmailValid.value = v,
                ),
                const SizedBox(height: 16),
                DynamicTextField(
                  label: 'Nomor HP',
                  controller: whatsappController,
                  type: FieldType.phone,
                  hintText: '62xxxxxxxxxx',
                  rules: [
                    ValidationRule(
                      message: 'Harus diawali dengan 62',
                      validate: (s) => s.startsWith('62'),
                    ),
                    ValidationRule(
                      message: 'Minimal 10 angka',
                      validate: (s) => s.length >= 10,
                    ),
                  ],
                  onValidationChanged: (v) => isPhoneValid.value = v,
                ),
                const SizedBox(height: 16),
                DynamicTextField(
                  label: 'Password',
                  controller: passwordController,
                  type: FieldType.password,
                  hintText: 'Masukkan password Anda',
                  rules: [
                    ValidationRule(
                      message: 'Minimal 8 karakter',
                      validate: (s) => s.length >= 8,
                    ),
                    ValidationRule(
                      message: 'Mengandung 1 huruf kapital',
                      validate: (s) => RegExp(r'[A-Z]').hasMatch(s),
                    ),
                    ValidationRule(
                      message: 'Mengandung 1 angka',
                      validate: (s) => RegExp(r'\d').hasMatch(s),
                    ),
                    ValidationRule(
                      message: 'Mengandung 1 simbol (!,@,#,dll)',
                      validate: (s) =>
                          RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(s),
                    ),
                  ],
                  onValidationChanged: (v) => isPasswordValid.value = v,
                ),
                const SizedBox(height: 16),
                Obx(() => RecaptchaBox(
                      value: isNotRobot.value,
                      onChanged: (v) => isNotRobot.value = v,
                    )),
                const SizedBox(height: 24),
                Obx(() {
                  final isFormValid = isNamaValid.value &&
                      isEmailValid.value &&
                      isPhoneValid.value &&
                      isPasswordValid.value &&
                      isNotRobot.value;
                  return PrimaryButton(
                    label: 'Daftarkan Akun',
                    loadingText: 'Mendaftarkan Akunmu...',
                    enabled: isFormValid && !controller.isLoading.value,
                    onPressed: handleRegister,
                  );
                }),
                const SizedBox(height: 16),
                const TermsText(),
                const SizedBox(height: 16),
                LoginInfoBox(
                  questionText: 'Sudah punya akun?',
                  actionText: 'Masuk ke akunmu',
                  onTap: () => Get.toNamed(AppRoutes.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}