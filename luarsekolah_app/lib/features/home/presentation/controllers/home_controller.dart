// lib/features/home/presentation/controllers/home_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/banner_entity.dart';
import '../../domain/entities/program_menu_entity.dart';
import '../../domain/entities/class_entity.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/usecases/get_banners_use_case.dart';
import '../../domain/usecases/get_programs_use_case.dart';
import '../../domain/usecases/get_popular_classes_use_case.dart';
import '../../domain/usecases/get_subscriptions_use_case.dart';

class HomeController extends GetxController {
  final GetBannersUseCase getBannersUseCase;
  final GetProgramsUseCase getProgramsUseCase;
  final GetPopularClassesUseCase getPopularClassesUseCase;
  final GetSubscriptionsUseCase getSubscriptionsUseCase;

  HomeController({
    required this.getBannersUseCase,
    required this.getProgramsUseCase,
    required this.getPopularClassesUseCase,
    required this.getSubscriptionsUseCase,
  });

  // Observable states
  final banners = <BannerEntity>[].obs;
  final programs = <ProgramMenuEntity>[].obs;
  final popularClasses = <ClassEntity>[].obs;
  final subscriptions = <SubscriptionEntity>[].obs;

  final isLoadingBanners = false.obs;
  final isLoadingPrograms = false.obs;
  final isLoadingClasses = false.obs;
  final isLoadingSubscriptions = false.obs;

  final currentBannerIndex = 0.obs;
  final bannerController = PageController();

  // Auth controller
  late final AuthController authController;

  @override
  void onInit() {
    super.onInit();
    authController = Get.find<AuthController>();
    loadAllData();
  }

  @override
  void onClose() {
    bannerController.dispose();
    super.onClose();
  }

  // Get user display name
  String get displayName => authController.currentUser.value?.name ?? 'Pengguna';

  // Load all data
  Future<void> loadAllData() async {
    await Future.wait([
      loadBanners(),
      loadPrograms(),
      loadPopularClasses(),
      loadSubscriptions(),
    ]);
  }

  // Load banners
  Future<void> loadBanners() async {
    try {
      isLoadingBanners.value = true;
      final result = await getBannersUseCase.call();
      banners.value = result;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat banner: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingBanners.value = false;
    }
  }

  // Load programs
  Future<void> loadPrograms() async {
    try {
      isLoadingPrograms.value = true;
      final result = await getProgramsUseCase.call();
      programs.value = result;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat program: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingPrograms.value = false;
    }
  }

  // Load popular classes
  Future<void> loadPopularClasses() async {
    try {
      isLoadingClasses.value = true;
      final result = await getPopularClassesUseCase.call();
      popularClasses.value = result;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat kelas populer: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingClasses.value = false;
    }
  }

  // Load subscriptions
  Future<void> loadSubscriptions() async {
    try {
      isLoadingSubscriptions.value = true;
      final result = await getSubscriptionsUseCase.call();
      subscriptions.value = result;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat subscription: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingSubscriptions.value = false;
    }
  }

  // Refresh page
  Future<void> refreshPage() async {
    await authController.checkCurrentUser();
    await loadAllData();
  }

  // Change banner index
  void onBannerPageChanged(int index) {
    currentBannerIndex.value = index;
  }

  // Handle program menu tap
  void onProgramMenuTap(ProgramMenuEntity program) {
    if (program.route != null) {
      Get.toNamed(program.route!);
    } else {
      Get.snackbar(
        'Info',
        'Menu ${program.label} belum tersedia',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Handle class card tap
  void onClassTap(ClassEntity classEntity) {
    Get.snackbar(
      'Info',
      'Membuka kelas: ${classEntity.title}',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to class detail page
  }

  // Handle subscription card tap
  void onSubscriptionTap(SubscriptionEntity subscription) {
    Get.snackbar(
      'Info',
      'Membuka subscription: ${subscription.title}',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to subscription detail page
  }

  // Handle voucher redeem
  void onRedeemVoucher() {
    Get.snackbar(
      'Info',
      'Fitur redeem voucher akan segera hadir',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to voucher redeem page
  }

  // View all popular classes
  void viewAllPopularClasses() {
    Get.snackbar(
      'Info',
      'Menampilkan semua kelas populer',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to all classes page
  }

  // View all subscriptions
  void viewAllSubscriptions() {
    Get.snackbar(
      'Info',
      'Menampilkan semua subscription',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Navigate to all subscriptions page
  }
}