// lib/features/account/presentation/bindings/account_binding.dart

import 'package:get/get.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../controllers/account_controller.dart';

class AccountBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<AccountRepository>(
      () => AccountRepositoryImpl(),
    );

    // Use Case
    Get.lazyPut(
      () => UpdateProfileUseCase(Get.find<AccountRepository>()),
    );

    // Controller - menggunakan AuthController yang sudah ada
    Get.lazyPut(
      () => AccountController(
        authController: Get.find<AuthController>(),
        updateProfileUseCase: Get.find(),
      ),
    );
  }
}