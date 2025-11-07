import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../domain/repositories/course_repository.dart';
import '../../domain/usecases/create_course_use_case.dart';
import '../../domain/usecases/delete_course_use_case.dart';
import '../../domain/usecases/get_all_courses_use_case.dart';
import '../../domain/usecases/update_course_use_case.dart';
import '../controllers/course_form_controller.dart';
import '../controllers/course_list_controller.dart';

class CourseBinding extends Bindings {
  @override
  void dependencies() {
    // Dio instance (should be singleton in real app)
    Get.lazyPut<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: 'https://ls-lms.zoidify.my.id/api',
          headers: {'Content-Type': 'application/json'},
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          validateStatus: (status) => status != null && status < 500,
        ),
      )..interceptors.add(
          LogInterceptor(
            request: true,
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            error: true,
          ),
        ),
    );

    // Repository
    Get.lazyPut<CourseRepository>(
      () => CourseRepositoryImpl(Get.find<Dio>()),
    );

    // Use Cases
    Get.lazyPut(() => GetAllCoursesUseCase(Get.find<CourseRepository>()));
    Get.lazyPut(() => CreateCourseUseCase(Get.find<CourseRepository>()));
    Get.lazyPut(() => UpdateCourseUseCase(Get.find<CourseRepository>()));
    Get.lazyPut(() => DeleteCourseUseCase(Get.find<CourseRepository>()));

    // Controllers
    Get.lazyPut(
      () => CourseListController(
        getAllCoursesUseCase: Get.find<GetAllCoursesUseCase>(),
        deleteCourseUseCase: Get.find<DeleteCourseUseCase>(),
      ),
    );

    Get.lazyPut(
      () => CourseFormController(
        createCourseUseCase: Get.find<CreateCourseUseCase>(),
        updateCourseUseCase: Get.find<UpdateCourseUseCase>(),
      ),
    );
  }
}