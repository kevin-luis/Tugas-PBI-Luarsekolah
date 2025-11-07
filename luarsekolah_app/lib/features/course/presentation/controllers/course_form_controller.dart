import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/usecases/create_course_use_case.dart';
import '../../domain/usecases/update_course_use_case.dart';

class CourseFormController extends GetxController {
  final CreateCourseUseCase createCourseUseCase;
  final UpdateCourseUseCase updateCourseUseCase;

  CourseFormController({
    required this.createCourseUseCase,
    required this.updateCourseUseCase,
  });

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final thumbnailUrlController = TextEditingController();
  final ratingController = TextEditingController();
  final createdByController = TextEditingController();

  final selectedCategory = Rxn<String>();
  final thumbnailPath = Rxn<String>();
  final isLoading = false.obs;

  CourseEntity? courseEntity;

  @override
  void onInit() {
    super.onInit();
    courseEntity = Get.arguments as CourseEntity?;

    if (courseEntity != null) {
      _initializeEditMode();
    }
  }

  void _initializeEditMode() {
    nameController.text = courseEntity!.name;

    final priceInt = courseEntity!.price.toInt();
    priceController.text = _formatNumber(priceInt);

    selectedCategory.value = _normalizeCategory(courseEntity!.category);
    
    thumbnailUrlController.text = courseEntity!.thumbnail ?? '';
    ratingController.text = courseEntity!.rating ?? '';
    createdByController.text = courseEntity!.createdBy ?? '';
    thumbnailPath.value = courseEntity!.thumbnail;
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

  Future<void> saveCourse() async {
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

      bool success;

      if (courseEntity != null) {
        // UPDATE MODE
        if (!_hasChanges(priceValue, thumbnailUrl, rating)) {
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

        success = await updateCourseUseCase.call(
          id: courseEntity!.id,
          name: nameController.text.trim(),
          price: priceString,
          categoryTag: [selectedCategory.value!.toLowerCase()],
          thumbnail: thumbnailUrl,
          rating: rating,
        );
      } else {
        // CREATE MODE
        success = await createCourseUseCase.call(
          name: nameController.text.trim(),
          price: priceString,
          categoryTag: [selectedCategory.value!.toLowerCase()],
          thumbnail: thumbnailUrl,
          rating: rating,
          createdBy: createdBy,
        );
      }

      isLoading.value = false;

      if (success) {
        Get.back(result: true);
      } else {
        Get.snackbar(
          'Error',
          'Terjadi kesalahan saat menyimpan',
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

  bool _hasChanges(double priceValue, String? thumbnailUrl, String? rating) {
    final hasNameChanged = nameController.text.trim() != courseEntity!.name;
    final hasPriceChanged = priceValue.round() != courseEntity!.price.round();
    final hasCategoryChanged = selectedCategory.value?.toLowerCase() != 
        courseEntity!.category.toLowerCase();
    final hasThumbnailChanged = thumbnailUrl != courseEntity!.thumbnail;
    final hasRatingChanged = rating != courseEntity!.rating;

    return hasNameChanged ||
        hasPriceChanged ||
        hasCategoryChanged ||
        hasThumbnailChanged ||
        hasRatingChanged;
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