// lib/features/account/presentation/pages/edit_profile_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../controllers/account_controller.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_form_field.dart';

class EditProfilePage extends GetView<AccountController> {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return const _EditProfileForm();
      }),
    );
  }
}

class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm();

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _profileImagePath;
  bool _isSaving = false;
  bool _isFormChanged = false;

  AccountController get _controller => Get.find<AccountController>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _nameController.addListener(_checkFormChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = _controller.currentUser.value;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  void _checkFormChanged() {
    final user = _controller.currentUser.value;
    if (user == null) return;

    setState(() {
      _isFormChanged = _nameController.text.trim() != user.name ||
          _profileImagePath != null;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });
        _checkFormChanged();
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih gambar');
    }
  }

  Future<void> _saveUserData() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Nama lengkap tidak boleh kosong');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final success = await _controller.updateProfile(
        name: _nameController.text.trim(),
        photoUrl: _profileImagePath,
      );

      if (success) {
        _showSuccessSnackBar('Perubahan berhasil disimpan');
        setState(() {
          _isFormChanged = false;
          _profileImagePath = null;
        });
      } else {
        _showErrorSnackBar(_controller.errorMessage.value);
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _controller.currentUser.value;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Semangat Belajarnya,',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            user?.name ?? 'Pengguna Baru',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Profile Avatar
          ProfileAvatar(
            user: user,
            imagePath: _profileImagePath,
            onEditPressed: _pickImage,
          ),
          const SizedBox(height: 15),

          const Center(
            child: Text(
              'Upload foto baru dengan ukuran < 1 MB,\ndan bertipe JPG atau PNG.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 10),

          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.upload),
            label: const Text('Upload Foto'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44),
            ),
          ),
          const SizedBox(height: 30),

          const Text(
            'Data Diri',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),

          ProfileFormField(
            label: 'Nama Lengkap',
            controller: _nameController,
            hint: 'Masukkan Nama Lengkapmu',
            enabled: true,
          ),
          const SizedBox(height: 20),

          ProfileFormField(
            label: 'Email',
            controller: _emailController,
            hint: 'Email tidak dapat diubah',
            enabled: false,
          ),
          const SizedBox(height: 20),

          ProfileFormField(
            label: 'Nomor Telepon',
            controller: _phoneController,
            hint: 'Nomor telepon tidak dapat diubah',
            enabled: false,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: _isFormChanged && !_isSaving ? _saveUserData : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: _isFormChanged
                  ? const Color(0xFF0EA782)
                  : const Color(0xFFF4F5F7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isFormChanged
                          ? Colors.white
                          : Colors.grey[600],
                    ),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}