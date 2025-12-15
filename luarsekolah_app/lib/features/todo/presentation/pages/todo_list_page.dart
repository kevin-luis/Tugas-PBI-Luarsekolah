// lib/features/todo/presentation/pages/todo_list_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/todo_controller.dart';
import '../widgets/todo_filter_tabs.dart';
import '../widgets/todo_statistics_bar.dart';
import '../widgets/todo_card.dart';
import '../widgets/create_edit_todo_dialog.dart';
import 'todo_detail_page.dart';

class TodoListPage extends GetView<TodoController> {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'My Todos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.isLoading ? null : controller.loadTodos,
                tooltip: 'Refresh',
              )),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: const Color(0xFF26A69A),
            child: const TodoFilterTabs(),
          ),
        ),
      ),
      body: Obx(() => _buildBody()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Todo'),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat todos...'),
          ],
        ),
      );
    }

    if (controller.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Terjadi Kesalahan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                controller.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: controller.loadTodos,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF26A69A),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (controller.allTodos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Todo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap tombol + untuk membuat todo baru',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    final filteredTodos = controller.filteredTodos;

    if (filteredTodos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              controller.currentFilter == TodoFilter.completed
                  ? Icons.task_alt
                  : Icons.inbox,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              controller.currentFilter == TodoFilter.completed
                  ? 'Belum Ada yang Selesai'
                  : 'Tidak Ada Todo Aktif',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.currentFilter == TodoFilter.completed
                  ? 'Selesaikan todomu untuk melihat di sini'
                  : 'Semua todo sudah selesai! 🎉',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.loadTodos,
      child: Column(
        children: [
          if (controller.allTodos.isNotEmpty) const TodoStatisticsBar(),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!controller.isLoadingMore &&
                    controller.hasMoreData &&
                    scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 200) {
                  controller.loadMoreTodos();
                }
                return false;
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredTodos.length + (controller.hasMoreData ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == filteredTodos.length) {
                    return Obx(() => controller.isLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 8),
                                  Text('Memuat lebih banyak...'),
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink());
                  }

                  final todo = filteredTodos[index];
                  return TodoCard(
                    todo: todo,
                    onTap: () => _navigateToDetail(todo),
                    onToggle: () => controller.toggleComplete(todo.id),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog() async {
    await Get.dialog(
      const CreateEditTodoDialog(),
      barrierDismissible: true,
    );
  }

  void _navigateToDetail(todo) async {
    await Get.to(() => TodoDetailPage(todoId: todo.id));
  }
}