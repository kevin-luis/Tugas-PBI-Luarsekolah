import 'package:flutter/material.dart';
import '../widgets/widgets.dart';
import 'main_navigation.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isNamaValid = false;
  bool _isEmailValid = false;
  bool _isPhoneValid = false;
  bool _isPasswordValid = false;
  bool _isNotRobot = false;
  bool _isFormValid = false;
  bool _isLoading = false;

  void _checkForm() {
    final valid = _isNamaValid && _isEmailValid && _isPhoneValid && _isPasswordValid && _isNotRobot;
    if (valid != _isFormValid) {
      setState(() => _isFormValid = valid);
    }
  }



  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _whatsappController.dispose();
    _passwordController.dispose();
    super.dispose();
  }



  Future<void> _handleRegister() async {
  if (_formKey.currentState!.validate() && _isNotRobot) {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (Route<dynamic> route) => false,
    );

    setState(() => _isLoading = false);
  }
}


  void _handleGoogleSignIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mendaftar dengan Google...')),
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
                const MainTitle(title: 'Daftarkan Akun Untuk Lanjut Akses ke Luarsekolah'),
                const SizedBox(height: 24),
                GoogleSignInButton(onPressed: _handleGoogleSignIn),
                const SizedBox(height: 16),
                const DividerWithText(text: 'atau gunakan email'),
                const SizedBox(height: 24),
                DynamicTextField(
                  label: 'Nama Lengkap',
                  controller: _namaController,
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
                  onValidationChanged: (v) {
                    _isNamaValid = v;
                    _checkForm();
                  },
                ),

                const SizedBox(height: 16),
                DynamicTextField(
                label: 'Email',
                controller: _emailController,
                type: FieldType.email,
                hintText: 'nama@domain.com',
                rules: [
                  ValidationRule(
                    message: 'Format email harus valid',
                    validate: (s) => RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(s),
                  ),
                ],
                onValidationChanged: (v) {
                  _isEmailValid = v;
                  _checkForm();
                },
              ),

              
                const SizedBox(height: 16),
                DynamicTextField(
                  label: 'Nomor HP',
                  controller: _whatsappController,
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
                  onValidationChanged: (v) {
                    _isPhoneValid = v;
                    _checkForm();
                  },
                ),

                const SizedBox(height: 16),
                DynamicTextField(
                  label: 'Password',
                  controller: _passwordController,
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
                      validate: (s) => RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(s),
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
                  label: 'Daftarkan Akun',
                  loadingText: 'Mendaftarkan Akunmu...',
                  enabled: _isFormValid,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 16),
                const TermsText(),
                const SizedBox(height: 16),
                const LoginInfoBox(
                  questionText: 'Sudah punya akun?',
                  actionText: 'Masuk ke akunmu',
                  navigateTo: LoginPage(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
