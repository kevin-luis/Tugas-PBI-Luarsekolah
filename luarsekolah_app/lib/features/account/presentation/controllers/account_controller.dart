// lib/features/account/presentation/controllers/account_controller.dart

import 'package:get/get.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/usecases/update_profile_use_case.dart';

class AccountController extends GetxController {
  final AuthController authController;
  final UpdateProfileUseCase updateProfileUseCase;

  AccountController({
    required this.authController,
    required this.updateProfileUseCase,
  });

  // Convert UserEntity to UserProfileEntity
  Rx<UserProfileEntity?> get currentUser {
    final user = authController.currentUser.value;
    if (user == null) return Rx<UserProfileEntity?>(null);
    
    return Rx<UserProfileEntity?>(UserProfileEntity(
      id: user.id,
      name: user.name,
      email: user.email,
      phoneNumber: user.phoneNumber,
      photoUrl: null, // UserEntity doesn't have photoUrl, so set to null
    ));
  }
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to AuthController changes and update UI
    ever(authController.currentUser, (_) => update());
  }

  Future<bool> updateProfile({
    required String name,
    String? photoUrl,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final success = await updateProfileUseCase(
        name: name,
        photoUrl: photoUrl,
      );

      if (success) {
        // Update the AuthController's user profile
        await authController.updateProfile(name: name);
      }

      return success;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await authController.logout();
    } catch (e) {
      errorMessage.value = e.toString();
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}