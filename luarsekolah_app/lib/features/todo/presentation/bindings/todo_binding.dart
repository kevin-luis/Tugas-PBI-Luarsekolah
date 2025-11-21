// import 'package:get/get.dart';
// import '../../data/repositories/todo_repository_impl.dart';
// import '../../domain/repositories/todo_repository.dart';
// import '../../domain/usecases/get_todos_use_case.dart';
// import '../../domain/usecases/create_todo_use_case.dart';
// import '../../domain/usecases/update_todo_use_case.dart';
// import '../../domain/usecases/toggle_todo_use_case.dart';
// import '../../domain/usecases/delete_todo_use_case.dart';
// import '../controllers/todo_controller.dart';

// class TodoBinding extends Bindings {
//   @override
//   void dependencies() {
//     // Repository
//     Get.lazyPut<TodoRepository>(
//       () => TodoRepositoryImpl(),
//     );

//     // Use Cases
//     Get.lazyPut(() => GetTodosUseCase(Get.find<TodoRepository>()));
//     Get.lazyPut(() => CreateTodoUseCase(Get.find<TodoRepository>()));
//     Get.lazyPut(() => UpdateTodoUseCase(Get.find<TodoRepository>()));
//     Get.lazyPut(() => ToggleTodoUseCase(Get.find<TodoRepository>()));
//     Get.lazyPut(() => DeleteTodoUseCase(Get.find<TodoRepository>()));

//     // Controller
//     Get.lazyPut(
//       () => TodoController(
//         getTodosUseCase: Get.find(),
//         createTodoUseCase: Get.find(),
//         updateTodoUseCase: Get.find(),
//         toggleTodoUseCase: Get.find(),
//         deleteTodoUseCase: Get.find(),
        
//       ),
//     );
//   }
// }