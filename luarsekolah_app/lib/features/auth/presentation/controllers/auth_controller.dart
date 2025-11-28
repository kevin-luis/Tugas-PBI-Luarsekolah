import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/login_with_google_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/update_user_profile_use_case.dart'; // Tambahkan ini
import '../../../../core/error/failures.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final UpdateUserProfileUseCase updateUserProfileUseCase; // Tambahkan ini

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.loginWithGoogleUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    required this.updateUserProfileUseCase, // Tambahkan ini
  });

  final Rx<UserEntity?> currentUser = Rx<UserEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  bool get isLoggedIn => currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    checkCurrentUser();
  }

  Future<void> checkCurrentUser() async {
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) => currentUser.value = null,
      (user) => currentUser.value = user,
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await loginUseCase(email: email, password: password);

    return result.fold(
      (failure) {
        isLoading.value = false;
        errorMessage.value = _mapFailureToMessage(failure);
        Get.snackbar(
          'Login Gagal',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 3),
        );
        return false;
      },
      (user) {
        isLoading.value = false;
        currentUser.value = user;
        Get.snackbar(
          'Login Berhasil',
          'Selamat datang, ${user.name}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
        );
        return true;
      },
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await registerUseCase(
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      password: password,
    );

    return result.fold(
      (failure) {
        isLoading.value = false;
        errorMessage.value = _mapFailureToMessage(failure);
        Get.snackbar(
          'Registrasi Gagal',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 3),
        );
        return false;
      },
      (user) {
        isLoading.value = false;
        currentUser.value = user;
        Get.snackbar(
          'Registrasi Berhasil',
          'Akun berhasil didaftarkan!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
        );
        return true;
      },
    );
  }

  Future<bool> loginWithGoogle() async {
    isLoading.value = true;
    errorMessage.value = '';

    final result = await loginWithGoogleUseCase();

    return result.fold(
      (failure) {
        isLoading.value = false;
        errorMessage.value = _mapFailureToMessage(failure);
        Get.snackbar(
          'Login Gagal',
          errorMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 3),
        );
        return false;
      },
      (user) {
        isLoading.value = false;
        currentUser.value = user;
        Get.snackbar(
          'Login Berhasil',
          'Selamat datang, ${user.name}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
        );
        return true;
      },
    );
  }

  Future<void> logout() async {
    isLoading.value = true;
    final result = await logoutUseCase();
    
    result.fold(
      (failure) {
        isLoading.value = false;
        Get.snackbar(
          'Logout Gagal',
          _mapFailureToMessage(failure),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          duration: const Duration(seconds: 3),
        );
      },
      (_) {
        isLoading.value = false;
        currentUser.value = null;
        Get.snackbar(
          'Logout Berhasil',
          'Sampai jumpa lagi!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 2),
        );
      },
    );
  }

  // Tambahkan method ini
  Future<bool> updateProfile({
    required String name,
  }) async {
    if (currentUser.value == null) return false;

    isLoading.value = true;
    errorMessage.value = '';

    final result = await updateUserProfileUseCase(
      userId: currentUser.value!.id,
      name: name,
    );

    return result.fold(
      (failure) {
        isLoading.value = false;
        errorMessage.value = _mapFailureToMessage(failure);
        return false;
      },
      (_) async {
        isLoading.value = false;
        // Refresh current user data
        await checkCurrentUser();
        return true;
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is AuthFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return 'Koneksi internet bermasalah';
    } else if (failure is ServerFailure) {
      return 'Terjadi kesalahan server';
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}