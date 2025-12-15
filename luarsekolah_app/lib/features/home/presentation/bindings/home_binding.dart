// lib/features/home/presentation/bindings/home_binding.dart

import 'package:get/get.dart';
import '../../data/datasources/home_remote_data_source.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../domain/repositories/home_repository.dart';
import '../../domain/usecases/get_banners_use_case.dart';
import '../../domain/usecases/get_programs_use_case.dart';
import '../../domain/usecases/get_popular_classes_use_case.dart';
import '../../domain/usecases/get_subscriptions_use_case.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    Get.lazyPut<HomeRemoteDataSource>(
      () => HomeRemoteDataSourceImpl(),
    );

    // Repository
    Get.lazyPut<HomeRepository>(
      () => HomeRepositoryImpl(
        remoteDataSource: Get.find(),
      ),
    );

    // Use Cases
    Get.lazyPut(() => GetBannersUseCase(Get.find()));
    Get.lazyPut(() => GetProgramsUseCase(Get.find()));
    Get.lazyPut(() => GetPopularClassesUseCase(Get.find()));
    Get.lazyPut(() => GetSubscriptionsUseCase(Get.find()));

    // Controller
    Get.lazyPut(
      () => HomeController(
        getBannersUseCase: Get.find(),
        getProgramsUseCase: Get.find(),
        getPopularClassesUseCase: Get.find(),
        getSubscriptionsUseCase: Get.find(),
      ),
    );
  }
}