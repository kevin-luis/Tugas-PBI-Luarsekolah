// lib/features/todo/presentation/widgets/todo_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/todo_entity.dart';
import '../controllers/todo_controller.dart';

class TodoCard extends StatelessWidget {
  final TodoEntity todo;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const TodoCard({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final localCreatedAt = todo.createdAt.toLocal();
    final bool isOldTask = !todo.completed &&
        DateTime.now().difference(localCreatedAt).inDays >= 7;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: todo.completed
              ? const Color(0xFF26A69A).withOpacity(0.3)
              : isOldTask
                  ? Colors.orange.withOpacity(0.4)
                  : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              InkWell(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: todo.completed
                          ? const Color(0xFF26A69A)
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                    color: todo.completed
                        ? const Color(0xFF26A69A)
                        : Colors.transparent,
                  ),
                  child: todo.completed
                      ? const Icon(
                          Icons.check,
                          size: 18,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),

              // Todo Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: todo.completed
                            ? Colors.grey[500]
                            : Colors.grey[800],
                        decoration: todo.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(todo.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        if (todo.completed) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Selesai',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF26A69A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        // ⚠️ Warning badge for old uncompleted tasks
                        if (isOldTask) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 10,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Lama',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ✅ Reminder Button (only for uncompleted todos)
              if (!todo.completed) ...[
                const SizedBox(width: 8),
                _buildReminderButton(context),
                const SizedBox(width: 8),
              ],

              // Arrow Icon
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

  /// ✅ Reminder Button Widget
  Widget _buildReminderButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Get controller and call remindTodo
          final controller = Get.find<TodoController>();
          controller.remindTodo(todo);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.orange[200]!,
              width: 1,
            ),
          ),
          child: Icon(
            Icons.notifications_active,
            color: Colors.orange[700],
            size: 18,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini';
    } else if (difference.inDays == 1) {
      return 'Kemarin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}