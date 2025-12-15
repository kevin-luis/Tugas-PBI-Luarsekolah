// lib/features/account/presentation/pages/account_menu_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/account_controller.dart';
import 'edit_profile_page.dart';
import '../widgets/user_info_card.dart';
import '../widgets/logout_dialog.dart';

class AccountMenuPage extends GetView<AccountController> {
  const AccountMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Akun Saya'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = controller.currentUser.value;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Info Card
            if (user != null) UserInfoCard(user: user),
            const SizedBox(height: 16),

            // Menu Items
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF26A69A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Color(0xFF26A69A),
                      ),
                    ),
                    title: const Text('Edit Profil'),
                    subtitle: const Text('Ubah informasi profil Anda'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Get.to(() => const EditProfilePage()),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.red,
                      ),
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    subtitle: const Text('Keluar dari akun Anda'),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),

            // App Info
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Text(
                    'Luarsekolah App',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => LogoutDialog(
        onConfirm: () async {
          Get.back(); // Close dialog
          
          // Show loading
          Get.dialog(
            const Center(child: CircularProgressIndicator()),
            barrierDismissible: false,
          );

          try {
            await controller.logout();
            Get.back(); // Close loading
            Get.offAllNamed('/login'); // Navigate to login
          } catch (e) {
            Get.back(); // Close loading
            Get.snackbar(
              'Error',
              'Gagal logout: ${e.toString()}',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }
}