// lib/features/todo/presentation/pages/todo_detail_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/todo_entity.dart';
import '../controllers/todo_controller.dart';
import '../widgets/create_edit_todo_dialog.dart';
import '../widgets/reminder_picker_dialog.dart';

class TodoDetailPage extends GetView<TodoController> {
  final String todoId;

  const TodoDetailPage({super.key, required this.todoId});

  TodoEntity? get todo => controller.allTodos.firstWhereOrNull((t) => t.id == todoId);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentTodo = todo;
      
      if (currentTodo == null) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Todo'),
            backgroundColor: const Color(0xFF26A69A),
            foregroundColor: Colors.white,
          ),
          body: const Center(
            child: Text('Todo tidak ditemukan'),
          ),
        );
      }

      final localCreatedAt = currentTodo.createdAt.toLocal();
      final bool isAlert = !currentTodo.completed &&
          DateTime.now().difference(localCreatedAt).inDays >= 7;

      return Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Detail Todo'),
          backgroundColor: const Color(0xFF26A69A),
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editTodo(currentTodo),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteTodo(currentTodo.id),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(currentTodo, isAlert),
              const SizedBox(height: 16),
              _buildContentCard(currentTodo),
              const SizedBox(height: 16),
              _buildInfoCard(currentTodo),
              const SizedBox(height: 16),
              if (!currentTodo.completed) _buildReminderCard(currentTodo),
              if (!currentTodo.completed) const SizedBox(height: 24),
              _buildActionButton(currentTodo),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatusCard(TodoEntity todo, bool isAlert) {
    final Color doneBg1 = const Color(0xFFB2DFDB);
    final Color doneBg2 = const Color(0xFF26A69A);
    final Color pendingBg1 = const Color(0xFFFFF8E1);
    final Color pendingBg2 = const Color(0xFFFFE082);
    final Color alertBg1 = const Color(0xFFFFE0B2);
    final Color alertBg2 = const Color(0xFFFFB74D);
    final Color textPending = const Color(0xFF6D4C41);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: todo.completed
                ? [doneBg1, doneBg2]
                : isAlert
                    ? [alertBg1, alertBg2]
                    : [pendingBg1, pendingBg2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: todo.completed
                ? doneBg2
                : isAlert
                    ? alertBg2
                    : pendingBg2,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              todo.completed
                  ? Icons.check_circle
                  : isAlert
                      ? Icons.warning_amber_rounded
                      : Icons.pending_actions,
              color: todo.completed
                  ? Colors.white
                  : isAlert
                      ? Colors.orange[900]
                      : Colors.orange[800],
              size: 48,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    todo.completed
                        ? 'Selesai'
                        : isAlert
                            ? 'Perlu Diperhatikan'
                            : 'Belum Selesai',
                    style: TextStyle(
                      color: todo.completed
                          ? Colors.white
                          : isAlert
                              ? Colors.orange[900]
                              : textPending,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    todo.completed
                        ? 'Todo sudah dikerjakan 🎉'
                        : isAlert
                            ? 'Sudah terlalu lama belum dikerjakan ⚠️'
                            : 'Masih ada pekerjaan yang belum selesai',
                    style: TextStyle(
                      color: todo.completed
                          ? Colors.white.withOpacity(0.9)
                          : textPending.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentCard(TodoEntity todo) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Todo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF26A69A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              todo.text,
              style: const TextStyle(
                fontSize: 18,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(TodoEntity todo) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildInfoRow(
              Icons.calendar_today,
              'Dibuat',
              _formatDateTime(todo.createdAt),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              Icons.update,
              'Terakhir diupdate',
              _formatDateTime(todo.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(TodoEntity todo) {
    return Card(
      color: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showReminderPicker(todo),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: Colors.orange[700],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Atur Reminder',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ingatkan saya untuk menyelesaikan todo ini',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2F1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF26A69A)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(TodoEntity todo) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => controller.toggleComplete(todo.id),
        icon: Icon(
          todo.completed ? Icons.undo : Icons.check_circle_outline,
        ),
        label: Text(
          todo.completed ? 'Tandai Belum Selesai' : 'Tandai Selesai',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: todo.completed
              ? const Color(0xFFFFB74D)
              : const Color(0xFF26A69A),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final localDate = date.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];

    return '${localDate.day} ${months[localDate.month - 1]} ${localDate.year}, '
        '${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
  }

  void _editTodo(TodoEntity todo) async {
    await Get.dialog(
      CreateEditTodoDialog(todo: todo),
      barrierDismissible: true,
    );
  }

  void _deleteTodo(String id) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Hapus Todo'),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus todo ini? Aksi ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.deleteTodo(id);
      Get.back();
    }
  }

  void _showReminderPicker(TodoEntity todo) async {
    await Get.dialog(
      ReminderPickerDialog(todo: todo),
      barrierDismissible: true,
    );
  }
}