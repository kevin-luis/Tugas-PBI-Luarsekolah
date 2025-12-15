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
import '../../features/account/presentation/bindings/account_binding.dart';
import '../../features/account/presentation/pages/account_menu_page.dart';
import '../../features/account/presentation/pages/edit_profile_page.dart';
import '../../features/home/presentation/bindings/home_binding.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../pages/main_navigation.dart';
import '../../pages/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    // Splash Screen
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: AuthBinding(), // Inject AuthController
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),

    //Home Routes
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),

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

    // Account routes
    GetPage(
      name: AppRoutes.accountMenu,
      page: () => const AccountMenuPage(),
      binding: AccountBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfilePage(),
      binding: AccountBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),

    
  ];
}