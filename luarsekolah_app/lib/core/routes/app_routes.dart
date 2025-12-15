// lib/core/routes/app_routes.dart

class AppRoutes {
  AppRoutes._();
  
  // Splash
  static const String splash = '/';

  //home
  static const home = '/home';
  
  // Auth routes
  static const String login = '/login';
  static const String register = '/register';
  
  // Main
  static const String main = '/main';
  
  // Course routes
  static const String courseList = '/courses';
  static const String courseAdd = '/courses/add';
  static const String courseEdit = '/courses/edit';
  
  // Todo routes
  static const String todoList = '/todos';
  static const String todoDetail = '/todos/detail';
  
  // Account routes
  static const String accountMenu = '/account';
  static const String editProfile = '/account/edit-profile';
}