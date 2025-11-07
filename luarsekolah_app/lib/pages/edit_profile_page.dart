import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../services/shared_preferences_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedGender;
  String? _selectedJobStatus;
  String? _birthDate;
  String? _profileImagePath;
  bool _isLoading = false;
  bool _isSaving = false;
  bool isFormActive = false;

  @override
  void initState() {
    super.initState();
    _addressController.addListener(checkFormActive);
    WidgetsBinding.instance.addPostFrameCallback((_) => checkFormActive());
    _loadUserData();
  }

  void checkFormActive() {
    setState(() {
      isFormActive = _profileImagePath != null &&
          _addressController.text.trim().isNotEmpty &&
          _selectedGender != null &&
          _selectedJobStatus != null &&
          _birthDate != null;
    });
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final profile = await SharedPreferencesService.getUserProfile();
      setState(() {
        _nameController.text = "Michael Ehrmantraut";
        _birthDate = profile.birthDate;
        _selectedGender = profile.gender;
        _selectedJobStatus = profile.jobStatus;
        _addressController.text = profile.address ?? '';
        _profileImagePath = profile.profileImage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Gagal memuat data profil');
    }
  }

  Future<void> _saveUserData() async {
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Nama lengkap tidak boleh kosong');
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 2));

    try {
      final profile = UserProfile(
        fullName: _nameController.text.trim(),
        birthDate: _birthDate,
        gender: _selectedGender,
        jobStatus: _selectedJobStatus,
        address: _addressController.text.trim(),
        profileImage: _profileImagePath,
      );

      final success = await SharedPreferencesService.saveUserProfile(profile);

      if (success) {
        _showSuccessSnackBar('Perubahan berhasil disimpan');
        await _loadUserData();
        setState(() => isFormActive = false);
      } else {
        _showErrorSnackBar('Gagal menyimpan perubahan');
      }
    } catch (e) {
      _showErrorSnackBar('Terjadi kesalahan saat menyimpan data');
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
        setState(() => _profileImagePath = image.path);
        checkFormActive();
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memilih gambar');
    }
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
      helpText: 'Pilih Tanggal Lahir',
      cancelText: 'Batal',
      confirmText: 'OK',
    );
    if (picked != null) {
      setState(() => _birthDate = DateFormat('dd/MM/yyyy').format(picked));
      checkFormActive();
    }
  }

  Future<void> _clearUserData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content:
            const Text('Apakah Anda yakin ingin menghapus semua data profil?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      final success = await SharedPreferencesService.clearUserData();
      if (success) {
        setState(() {
          _nameController.clear();
          _addressController.clear();
          _birthDate = null;
          _selectedGender = null;
          _selectedJobStatus = null;
          _profileImagePath = null;
        });
        _showSuccessSnackBar('Data profil berhasil dihapus');
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: TextStyle(color: theme.colorScheme.onPrimary)),
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
        content:
            Text(message, style: TextStyle(color: theme.colorScheme.onError)),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearUserData,
            tooltip: 'Hapus semua data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Semangat Belajarnya,',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                  Text(
                    _nameController.text.isEmpty
                        ? 'Pengguna Baru'
                        : _nameController.text,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Foto Profil
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _profileImagePath != null
                              ? FileImage(File(_profileImagePath!))
                              : null,
                          child: _profileImagePath == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.red,
                            child: IconButton(
                              icon: const Icon(Icons.edit,
                                  size: 16, color: Colors.white),
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

                  const Text('Data Diri',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),

                  _buildLabel('Nama Lengkap'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    enabled: false,
                    decoration: _inputDecoration("Masukkan Nama Lengkapmu"),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Tanggal Lahir'),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _selectBirthDate,
                    child: InputDecorator(
                      decoration: _inputDecoration('Masukkan tanggal lahirmu')
                          .copyWith(
                              suffixIcon: const Icon(Icons.calendar_today)),
                      child: Text(_birthDate ?? 'Masukkan tanggal lahirmu'),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Jenis Kelamin'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    hint: const Text('Pilih laki-laki atau perempuan'),
                    decoration: _inputDecoration(''),
                    items: ['Laki-laki', 'Perempuan']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedGender = v);
                      checkFormActive();
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Status Pekerjaan'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedJobStatus,
                    hint: const Text('Pilih status pekerjaanmu'),
                    decoration: _inputDecoration(''),
                    items: ['Pelajar', 'Mahasiswa', 'Pekerja', 'Lainnya']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      setState(() => _selectedJobStatus = v);
                      checkFormActive();
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Alamat Lengkap'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: _inputDecoration('Masukkan alamat lengkap'),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed:
                        isFormActive && !_isSaving ? _saveUserData : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: isFormActive
                          ? const Color(0xFF0EA782)
                          : const Color(0xFFF4F5F7),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
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
                        : const Text("Simpan Perubahan",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500));

  InputDecoration _inputDecoration(String hint) => InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
