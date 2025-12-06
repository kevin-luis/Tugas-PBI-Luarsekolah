// lib/features/todo/presentation/bindings/todo_firebase_binding.dart

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/todo_firebase_repository_impl.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../domain/usecases/get_todos_use_case.dart';
import '../../domain/usecases/get_todos_paginated_use_case.dart';
import '../../domain/usecases/create_todo_use_case.dart';
import '../../domain/usecases/update_todo_use_case.dart';
import '../../domain/usecases/toggle_todo_use_case.dart';
import '../../domain/usecases/delete_todo_use_case.dart';
import '../controllers/todo_controller.dart';
import '../../../../core/services/notification_service.dart';

class TodoFirebaseBinding extends Bindings {
  @override
  void dependencies() {
    // Firebase instances (lazy singleton)
    Get.lazyPut<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
      fenix: true,
    );

    Get.lazyPut<FirebaseAuth>(
      () => FirebaseAuth.instance,
      fenix: true,
    );

    // Notification Service (singleton)
    Get.put<NotificationService>(
      NotificationService(),
      permanent: true,
    );

    // Repository - Firebase Implementation
    Get.lazyPut<TodoRepository>(
      () => TodoFirebaseRepositoryImpl(
        firestore: Get.find<FirebaseFirestore>(),
        auth: Get.find<FirebaseAuth>(),
      ),
    );

    // Use Cases
    Get.lazyPut(() => GetTodosUseCase(Get.find<TodoRepository>()));
    Get.lazyPut(() => GetTodosPaginatedUseCase(Get.find<TodoRepository>()));
    Get.lazyPut(() => CreateTodoUseCase(Get.find<TodoRepository>()));
    Get.lazyPut(() => UpdateTodoUseCase(Get.find<TodoRepository>()));
    Get.lazyPut(() => ToggleTodoUseCase(Get.find<TodoRepository>()));
    Get.lazyPut(() => DeleteTodoUseCase(Get.find<TodoRepository>()));

    // Controller
    Get.lazyPut(
      () => TodoController(
        getTodosUseCase: Get.find(),
        getTodosPaginatedUseCase: Get.find(),
        createTodoUseCase: Get.find(),
        updateTodoUseCase: Get.find(),
        toggleTodoUseCase: Get.find(),
        deleteTodoUseCase: Get.find(),
        notificationService: Get.find(),
      ),
    );
  }
}