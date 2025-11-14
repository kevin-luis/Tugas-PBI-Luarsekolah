import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/auth_controller.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/login_with_google_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/get_current_user_use_case.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Firebase Auth Instance
    Get.lazyPut(() => FirebaseAuth.instance, fenix: true);

    // Data Source
    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(firebaseAuth: Get.find()),
      fenix: true,
    );

    // Repository
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find()),
      fenix: true,
    );

    // Use Cases
    Get.lazyPut(() => LoginUseCase(Get.find()));
    Get.lazyPut(() => RegisterUseCase(Get.find()));
    Get.lazyPut(() => LoginWithGoogleUseCase(Get.find()));
    Get.lazyPut(() => LogoutUseCase(Get.find()));
    Get.lazyPut(() => GetCurrentUserUseCase(Get.find()));

    // Controller
    Get.lazyPut(
      () => AuthController(
        loginUseCase: Get.find(),
        registerUseCase: Get.find(),
        loginWithGoogleUseCase: Get.find(),
        logoutUseCase: Get.find(),
        getCurrentUserUseCase: Get.find(),
      ),
    );
  }
}