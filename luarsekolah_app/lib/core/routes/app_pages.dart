// lib/core/routes/app_pages.dart

import 'package:get/get.dart';
import '../../features/auth/presentation/bindings/auth_binding.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/course/presentation/bindings/course_binding.dart';
import '../../features/course/presentation/pages/course_list_page.dart';
import '../../features/course/presentation/pages/course_form_page.dart';
import '../../features/todo/presentation/bindings/todo_firebase_binding.dart';
import '../../features/todo/presentation/pages/todo_list_page.dart';
import '../../features/todo/presentation/pages/todo_detail_page.dart';
import '../../pages/main_navigation.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.login;

  static final routes = [
    // Auth routes
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    // Main navigation
    GetPage(
      name: AppRoutes.main,
      page: () => const MainNavigation(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 700),
    ),

    // Course routes
    GetPage(
      name: AppRoutes.courseList,
      page: () => const CourseListPage(),
      binding: CourseBinding(),
    ),
    GetPage(
      name: AppRoutes.courseAdd,
      page: () => const CourseFormPage(),
      binding: CourseBinding(),
    ),
    GetPage(
      name: AppRoutes.courseEdit,
      page: () => const CourseFormPage(),
      binding: CourseBinding(),
    ),

    // Todo routes
    GetPage(
      name: AppRoutes.todoList,
      page: () => const TodoListPage(),
      binding: TodoFirebaseBinding(),
    ),
    GetPage(
      name: AppRoutes.todoDetail,
      page: () => TodoDetailPage(
        todoId: Get.parameters['id'] ?? '',
      ),
      binding: TodoFirebaseBinding(),
    ),
  ];
}
