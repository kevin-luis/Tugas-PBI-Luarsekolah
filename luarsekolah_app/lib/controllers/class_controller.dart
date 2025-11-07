import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/class_model.dart';
import '../services/api_service.dart';
import '../pages/add_class_page.dart';

class ClassController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Observable variables
  final allClasses = <ClassModel>[].obs;
  final filteredClasses = <ClassModel>[].obs;
  final isLoading = true.obs;
  final currentFilter = 'all'.obs;

  late TabController tabController;

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(_onTabChanged);
    loadClasses();
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
          currentFilter.value = 'all';
          filteredClasses.value = allClasses;
          break;
        case 1:
          currentFilter.value = 'spl';
          filteredClasses.value = allClasses
              .where((c) => c.category.toLowerCase() == 'spl')
              .toList();
          break;
        case 2:
          currentFilter.value = 'prakerja';
          filteredClasses.value = allClasses
              .where((c) => c.category.toLowerCase() == 'prakerja')
              .toList();
          break;
      }
    }
  }

  Future<void> loadClasses() async {
    try {
      print('📡 loadClasses() started');
      isLoading.value = true;

      final classes = await ApiService.getAllCourses();

      print('📦 Received ${classes.length} classes from API');
      for (var c in classes) {
        print('  - ${c.name}');
      }

      allClasses.value = classes;
      print('✅ allClasses updated: ${allClasses.length} items');

      _onTabChanged();
      print('✅ Filter applied: ${filteredClasses.length} items showing');
    } catch (e) {
      print('❌ Error in loadClasses: $e');
      Get.snackbar(
        'Error',
        'Gagal memuat kelas: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
      print('🏁 loadClasses() finished');
    }
  }

  void applyFilter() {
    switch (currentFilter.value) {
      case 'all':
        filteredClasses.value = allClasses;
        break;
      case 'spl':
        filteredClasses.value =
            allClasses.where((c) => c.category.toLowerCase() == 'spl').toList();
        break;
      case 'prakerja':
        filteredClasses.value = allClasses
            .where((c) => c.category.toLowerCase() == 'prakerja')
            .toList();
        break;
    }
  }

  Future<void> deleteClass(String id) async {
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

      final result = await ApiService.deleteCourse(id);

      if (result['success'] == true) {
        Get.snackbar(
          'Sukses',
          'Kelas berhasil dihapus',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
        );
        loadClasses();
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Gagal menghapus kelas',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    }
  }

  Future<void> navigateToAddClass() async {
    print('🚀 navigateToAddClass() called');
    print('Controller hash: ${hashCode}');

    // ✅ FIX: Properly await the navigation result
    final result = await Get.to(() => const AddClassPage());

    print('🔙 Back from AddClassPage');
    print('Controller hash after back: ${hashCode}');
    print('Result received: $result');
    print('Result type: ${result.runtimeType}');
    print('Result == true: ${result == true}');

    // ✅ FIX: Check if result is explicitly true
    if (result == true) {
      print('♻️ Condition met, reloading...');
      await loadClasses();
      print('✅ Reload complete');
    } else {
      print('❌ Result is not true, skipping reload');
    }
  }

  Future<void> navigateToEditClass(ClassModel classModel) async {
    print('🚀 Navigate to EditClass');

    // ✅ FIX: Properly await the navigation result
    final result = await Get.to(() => const AddClassPage(), arguments: classModel);

    print('🔙 Back from EditClass - Result: $result');

    // ✅ FIX: Check if result is explicitly true
    if (result == true) {
      print('♻️ Reloading classes...');
      await loadClasses();
      print('✅ Reload complete');
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