import 'package:flutter/material.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          'Halaman Akun Saya',
          style: TextStyle(fontSize: 24, color: Colors.red),
        ),
      ),
    );
  }
}