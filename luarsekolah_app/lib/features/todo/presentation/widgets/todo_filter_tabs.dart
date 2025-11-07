import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/todo_controller.dart';

class TodoFilterTabs extends GetView<TodoController> {
  const TodoFilterTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFilterChip(
                TodoFilter.all,
                'Semua',
                controller.totalCount,
                Icons.list_alt,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                TodoFilter.active,
                'Aktif',
                controller.activeCount,
                Icons.radio_button_unchecked,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                TodoFilter.completed,
                'Selesai',
                controller.completedCount,
                Icons.check_circle,
              ),
            ],
          ),
        ));
  }

  Widget _buildFilterChip(
    TodoFilter filter,
    String label,
    int count,
    IconData icon,
  ) {
    final isSelected = controller.currentFilter == filter;

    return Expanded(
      child: InkWell(
        onTap: controller.isLoading
            ? null
            : () => controller.setFilter(filter),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : const Color(0xFF26A69A),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? const Color(0xFF26A69A) : Colors.white,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF26A69A) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF26A69A)
                      : Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}