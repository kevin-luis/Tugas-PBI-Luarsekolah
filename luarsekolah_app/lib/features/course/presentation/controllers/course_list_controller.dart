import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/routes/app_routes.dart';
import '../../domain/entities/course_entity.dart';
import '../../domain/usecases/get_all_courses_use_case.dart';
import '../../domain/usecases/delete_course_use_case.dart';

class CourseListController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final GetAllCoursesUseCase getAllCoursesUseCase;
  final DeleteCourseUseCase deleteCourseUseCase;

  CourseListController({
    required this.getAllCoursesUseCase,
    required this.deleteCourseUseCase,
  });

  final allCourses = <CourseEntity>[].obs;
  final filteredCourses = <CourseEntity>[].obs;
  final isLoading = true.obs;
  final currentFilter = 'all'.obs;

  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(_onTabChanged);
    loadCourses();
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.onClose();
  }

  void _onTabChanged() {
    if (!tabController.indexIsChanging) {
      switch (tabController.index) {
        case 0:
          _filterCourses('all');
          break;
        case 1:
          _filterCourses('spl');
          break;
        case 2:
          _filterCourses('prakerja');
          break;
      }
    }
  }

  void _filterCourses(String filter) {
    currentFilter.value = filter;

    if (filter == 'all') {
      filteredCourses.value = allCourses;
    } else {
      filteredCourses.value =
          allCourses.where((c) => c.category.toLowerCase() == filter).toList();
    }
  }

  Future<void> loadCourses() async {
    try {
      isLoading.value = true;

      final courses = await getAllCoursesUseCase.call();

      allCourses.assignAll(courses);
      _onTabChanged();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat kelas: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCourse(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Kelas'),
        content: const Text('Apakah Anda yakin ingin menghapus kelas ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Get.snackbar(
        'Loading',
        'Menghapus kelas...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );

      final success = await deleteCourseUseCase.call(id);

      if (success) {
        Get.snackbar(
          'Sukses',
          'Kelas berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        loadCourses();
      } else {
        Get.snackbar(
          'Error',
          'Gagal menghapus kelas',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    }
  }

  Future<void> navigateToAddCourse() async {
    final result = await Get.toNamed(AppRoutes.courseAdd);

    if (result == true) {
      await loadCourses();
    }
  }

  Future<void> navigateToEditCourse(CourseEntity course) async {
    final result = await Get.toNamed(
      AppRoutes.courseEdit,
      arguments: course,
    );

    if (result == true) {
      Get.snackbar('Sukses', 'Kelas berhasil disimpan');
      await loadCourses();
    }
  }

  String formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'prakerja':
        return const Color(0xFF2D6F5C);
      case 'spl':
        return const Color(0xFFD4A855);
      default:
        return const Color(0xFF2D6F5C);
    }
  }
}
