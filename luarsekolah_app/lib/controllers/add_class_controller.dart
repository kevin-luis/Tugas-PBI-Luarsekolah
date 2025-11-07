import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/class_model.dart';
import '../services/api_service.dart';

class AddClassController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final thumbnailUrlController = TextEditingController();
  final ratingController = TextEditingController();
  final createdByController = TextEditingController();

  final selectedCategory = Rxn<String>();
  final thumbnailPath = Rxn<String>();
  final isLoading = false.obs;

  ClassModel? classModel;

  @override
  void onInit() {
    super.onInit();
    // Get argument jika ada (untuk edit mode)
    classModel = Get.arguments as ClassModel?;

    if (classModel != null) {
      _initializeEditMode();
    }
  }

  void _initializeEditMode() {
    nameController.text = classModel!.name;

    final priceInt = classModel!.price.toInt();
    priceController.text = _formatNumber(priceInt);

    final category = classModel!.category;
    if (category.isNotEmpty && category != 'Prakerja' && category != 'SPL') {
      selectedCategory.value = _normalizeCategory(category);
    } else if (category.isEmpty) {
      selectedCategory.value = null;
    } else {
      selectedCategory.value = category;
    }

    thumbnailUrlController.text = classModel!.thumbnail ?? '';
    ratingController.text = classModel!.rating ?? '';
    createdByController.text = classModel!.createdBy ?? '';
    thumbnailPath.value = classModel!.thumbnail;
  }

  String _normalizeCategory(String category) {
    final normalized = category.toLowerCase();
    if (normalized == 'prakerja') return 'Prakerja';
    if (normalized == 'spl') return 'SPL';
    return 'Prakerja';
  }

  String _formatNumber(int number) {
    if (number == 0) return '0';
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  void onThumbnailChanged(String value) {
    if (value.startsWith('http')) {
      thumbnailPath.value = value;
    }
  }

  void onCategoryChanged(String? value) {
    selectedCategory.value = value;
  }

  Future<void> saveClass() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory.value == null) {
      Get.snackbar(
        'Error',
        'Pilih kategori kelas terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final priceValue = double.parse(priceController.text.replaceAll('.', ''));
      final priceString = priceValue.toStringAsFixed(2);

      final thumbnailUrl = thumbnailUrlController.text.trim().isNotEmpty
          ? thumbnailUrlController.text.trim()
          : null;

      final rating = ratingController.text.trim().isNotEmpty
          ? ratingController.text.trim()
          : null;

      final createdBy = createdByController.text.trim().isNotEmpty
          ? createdByController.text.trim()
          : null;

      Map<String, dynamic> result;

      if (classModel != null) {
        // UPDATE MODE
        final hasNameChanged = nameController.text.trim() != classModel!.name;
        final originalPrice = classModel!.price.round();
        final currentPrice = priceValue.round();
        final hasPriceChanged = currentPrice != originalPrice;

        final originalCategory = classModel!.category.toLowerCase();
        final currentCategory = selectedCategory.value?.toLowerCase() ?? '';
        final hasCategoryChanged =
            currentCategory != originalCategory && currentCategory.isNotEmpty;

        final hasThumbnailChanged = thumbnailUrl != classModel!.thumbnail;
        final hasRatingChanged = rating != classModel!.rating;

        print('=== UPDATE COMPARISON ===');
        print(
            'Name: "${classModel!.name}" → "${nameController.text.trim()}" | Changed: $hasNameChanged');
        print(
            'Price: ${classModel!.price} → $priceValue | Changed: $hasPriceChanged');
        print(
            'Category: "${classModel!.category}" → "$selectedCategory" | Changed: $hasCategoryChanged');
        print(
            'Thumbnail: "${classModel!.thumbnail}" → "$thumbnailUrl" | Changed: $hasThumbnailChanged');
        print(
            'Rating: "${classModel!.rating}" → "$rating" | Changed: $hasRatingChanged');

        if (!hasNameChanged &&
            !hasPriceChanged &&
            !hasCategoryChanged &&
            !hasThumbnailChanged &&
            !hasRatingChanged) {
          Get.snackbar(
            'Info',
            'Tidak ada perubahan untuk disimpan',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          isLoading.value = false;
          return;
        }

        result = await ApiService.updateCourse(
          id: classModel!.id,
          name: nameController.text.trim(),
          price: priceString,
          categoryTag: currentCategory.isNotEmpty ? [currentCategory] : null,
          thumbnail: thumbnailUrl,
          rating: rating,
        );
      } else {
        // CREATE MODE
        result = await ApiService.createCourse(
          name: nameController.text.trim(),
          price: priceString,
          categoryTag: [selectedCategory.value!.toLowerCase()],
          thumbnail: thumbnailUrl,
          rating: rating,
          createdBy: createdBy,
        );
      }

      // ✅ FIX: Proper success handling
      if (result['success'] == true) {
        print('✅ SAVE SUCCESS');

        // Show success message
        Get.snackbar(
          'Sukses',
          classModel != null
              ? 'Kelas berhasil diperbarui'
              : 'Kelas berhasil ditambahkan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // ✅ Wait a bit for snackbar to show
        await Future.delayed(const Duration(milliseconds: 300));

        // ✅ Go back with result AFTER isLoading is set to false
        isLoading.value = false;
        
        print('🔙 Going back with result: true');
        Get.back(result: true);
      } else {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          result['message'] ?? 'Terjadi kesalahan',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    priceController.dispose();
    thumbnailUrlController.dispose();
    ratingController.dispose();
    createdByController.dispose();
    super.onClose();
  }
}