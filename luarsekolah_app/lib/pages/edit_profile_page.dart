// lib/pages/edit_profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../features/auth/presentation/controllers/auth_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final AuthController _authController = Get.find<AuthController>();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? _profileImagePath;
  bool _isLoading = false;
  bool _isSaving = false;
  bool isFormChanged = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Listen to text changes
    _nameController.addListener(_checkFormChanged);
    // Hapus listener untuk phoneController karena tidak bisa diubah
  }

  void _checkFormChanged() {
    final user = _authController.currentUser.value;
    if (user == null) return;

    setState(() {
      isFormChanged =
          _nameController.text.trim() != user.name || _profileImagePath != null;
    });
  }

  void _loadUserData() {
    final user = _authController.currentUser.value;
    if (user != null) {
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phoneNumber ?? '';
      });
    }
  }

  Future<void> _saveUserData() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Nama lengkap tidak boleh kosong');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Update Firebase Auth Display Name
      final currentFirebaseUser = _firebaseAuth.currentUser;
      if (currentFirebaseUser != null) {
        await currentFirebaseUser
            .updateDisplayName(_nameController.text.trim());
        await currentFirebaseUser.reload();
      }

      // Update ke Firestore menggunakan controller
      final success = await _authController.updateProfile(
        name: _nameController.text.trim(),
      );

      if (success) {
        _showSuccessSnackBar('Perubahan berhasil disimpan');
        setState(() => isFormChanged = false);
      } else {
        _showErrorSnackBar(_authController.errorMessage.value);
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan: $e');
    } finally {
      setState(() => _isSaving = false);
    }
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

  void _showSuccessSnackBar(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: theme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: theme.colorScheme.onError),
        ),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Obx(() {
              final user = _authController.currentUser.value;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Semangat Belajarnya,',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      user?.name ?? 'Pengguna Baru',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Foto Profil
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFF26A69A),
                            backgroundImage: _profileImagePath != null
                                ? FileImage(File(_profileImagePath!))
                                : null,
                            child: _profileImagePath == null
                                ? Text(
                                    user?.name[0].toUpperCase() ?? 'U',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFF26A69A),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
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

                    _buildLabel('Nama Lengkap'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: _inputDecoration("Masukkan Nama Lengkapmu"),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('Email'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      enabled: false,
                      decoration: _inputDecoration("Email tidak dapat diubah"),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Nomor Telepon'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      enabled:
                          false, // Ubah menjadi false agar tidak bisa diubah
                      keyboardType: TextInputType.phone,
                      decoration:
                          _inputDecoration('Nomor telepon tidak dapat diubah'),
                      style: TextStyle(
                          color: Colors.grey[600]), // Tambahkan style abu-abu
                    ),
                    const SizedBox(height: 30),

                    ElevatedButton(
                      onPressed:
                          isFormChanged && !_isSaving ? _saveUserData : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        backgroundColor: isFormChanged
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
                              "Simpan Perubahan",
                              style: TextStyle(
                                fontSize: 16,
                                color: isFormChanged
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            }),
    );
  }

  Widget _buildLabel(String text) => Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      );
  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
