import 'package:get/get.dart';
import '../../features/course/presentation/bindings/course_binding.dart';
import '../../features/course/presentation/pages/course_list_page.dart';
import '../../features/course/presentation/pages/course_form_page.dart';
import '../../features/todo/presentation/bindings/todo_binding.dart';
import '../../features/todo/presentation/pages/todo_list_page.dart';
import '../../features/todo/presentation/pages/todo_detail_page.dart';
import '../../pages/main_navigation.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();
  
  static const initial = AppRoutes.main;
  
  static final routes = [
    GetPage(
      name: AppRoutes.main,
      page: () => const MainNavigation(),
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
      binding: TodoBinding(),
    ),
    GetPage(
      name: AppRoutes.todoDetail,
      page: () => TodoDetailPage(
        todoId: Get.parameters['id'] ?? '',
      ),
      binding: TodoBinding(),
    ),
  ];
}