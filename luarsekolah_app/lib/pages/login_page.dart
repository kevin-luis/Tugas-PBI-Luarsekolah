import 'package:flutter/material.dart';
import 'register_page.dart';
import '../widgets/widgets.dart';
import 'main_navigation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  bool _isNotRobot = false;
  bool _isFormValid = false;

  void _checkForm() {
    setState(() {
      _isFormValid = _isEmailValid && _isPasswordValid && _isNotRobot;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
  if (_formKey.currentState!.validate() && _isNotRobot) {
    // tampilkan snackbar atau lakukan aksi awal
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Masuk ke akun...')),
    );

    // tunggu 1 detik (loading simulasi)
    await Future.delayed(const Duration(seconds: 3));

    // setelah itu navigasi dan hapus semua route sebelumnya
    if (!mounted) return; // amankan context
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (Route<dynamic> route) => false,
    );
  }
}


  void _handleGoogleLogIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Masuk dengan Google...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LogoImage(),
                const SizedBox(height: 24),
                const MainTitle(title: 'Masuk ke Akunmu Untuk Lanjut Akses ke Luarsekolah'),
                const SizedBox(height: 24),

                GoogleLoginButton(onPressed: _handleGoogleLogIn),
                const SizedBox(height: 16),
                const DividerWithText(text: 'atau gunakan email'),
                const SizedBox(height: 24),

                // Email Field
                DynamicTextField(
                  label: 'Email',
                  displayMode: ValidationDisplayMode.hideOnValid,
                  controller: _emailController,
                  type: FieldType.email,
                  hintText: 'Masukkan email terdaftar',
                  rules: [
                    ValidationRule(
                      message: 'Format email @domain.com',
                      validate: (s) => RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(s),
                    ),
                  ],
                  onValidationChanged: (v) {
                    _isEmailValid = v;
                    _checkForm();
                  },
                ),

                const SizedBox(height: 16),

                // Password Field (hanya wajib diisi)
                DynamicTextField(
                  label: 'Password',
                  displayMode: ValidationDisplayMode.hideOnValid,
                  controller: _passwordController,
                  type: FieldType.password,
                  hintText: 'Masukkan password Anda',
                  rules: [
                    ValidationRule(
                      message: 'Password wajib diisi',
                      validate: (s) => s.trim().isNotEmpty,
                    ),
                  ],
                  onValidationChanged: (v) {
                    _isPasswordValid = v;
                    _checkForm();
                  },
                ),

                const SizedBox(height: 16),
                RecaptchaBox(
                  value: _isNotRobot,
                  onChanged: (v) {
                    setState(() {
                      _isNotRobot = v;
                    });
                    _checkForm();
                  },
                ),

                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Masuk',
                  loadingText: 'Mohon Tunggu...',
                  enabled: _isFormValid,
                  onPressed: _handleLogin,
                ),

                const SizedBox(height: 24),
                const LoginInfoBox(
                  questionText: 'Belum punya akun?',
                  actionText: 'Daftar Sekarang',
                  navigateTo: RegisterPage(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
