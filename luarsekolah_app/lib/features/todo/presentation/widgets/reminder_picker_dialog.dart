// lib/features/todo/presentation/widgets/reminder_picker_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/todo_entity.dart';
import '../controllers/todo_controller.dart';

class ReminderPickerDialog extends GetView<TodoController> {
  final TodoEntity todo;

  const ReminderPickerDialog({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final selectedDate = Rx<DateTime?>(null);
    final selectedTime = Rx<TimeOfDay?>(null);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
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
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Atur Reminder',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                  color: Colors.grey[600],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Todo Preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.task_alt, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      todo.text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Pilih Waktu Reminder',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),

            // Quick reminder options
            _buildQuickReminderButton(
              'Dalam 1 Jam',
              Icons.schedule,
              () => _setQuickReminder(const Duration(hours: 1)),
            ),
            const SizedBox(height: 8),
            _buildQuickReminderButton(
              'Besok Pagi (08:00)',
              Icons.wb_sunny_outlined,
              () => _setTomorrowMorningReminder(),
            ),
            const SizedBox(height: 8),
            _buildQuickReminderButton(
              'Besok Siang (12:00)',
              Icons.light_mode_outlined,
              () => _setTomorrowNoonReminder(),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Custom Date & Time
            const Text(
              'Atau Pilih Waktu Custom',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),

            // Date Picker
            Obx(() => OutlinedButton.icon(
                  onPressed: () => _pickDate(context, selectedDate),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    selectedDate.value == null
                        ? 'Pilih Tanggal'
                        : _formatDate(selectedDate.value!),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )),

            const SizedBox(height: 12),

            // Time Picker
            Obx(() => OutlinedButton.icon(
                  onPressed: () => _pickTime(context, selectedTime),
                  icon: const Icon(Icons.access_time),
                  label: Text(
                    selectedTime.value == null
                        ? 'Pilih Waktu'
                        : _formatTime(selectedTime.value!),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                )),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 12),
                Obx(() => ElevatedButton.icon(
                      onPressed: selectedDate.value != null &&
                              selectedTime.value != null
                          ? () => _setCustomReminder(
                                selectedDate.value!,
                                selectedTime.value!,
                              )
                          : null,
                      icon: const Icon(Icons.alarm_add),
                      label: const Text('Atur Reminder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF26A69A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickReminderButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF26A69A), size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, Rx<DateTime?> selectedDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF26A69A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> _pickTime(BuildContext context, Rx<TimeOfDay?> selectedTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF26A69A),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      selectedTime.value = picked;
    }
  }

  void _setQuickReminder(Duration delay) {
    final scheduledDate = DateTime.now().add(delay);
    controller.scheduleReminder(todo: todo, scheduledDate: scheduledDate);
    Get.back();
  }

  void _setTomorrowMorningReminder() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final scheduledDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 8, 0);
    controller.scheduleReminder(todo: todo, scheduledDate: scheduledDate);
    Get.back();
  }

  void _setTomorrowNoonReminder() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final scheduledDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12, 0);
    controller.scheduleReminder(todo: todo, scheduledDate: scheduledDate);
    Get.back();
  }

  void _setCustomReminder(DateTime date, TimeOfDay time) {
    final scheduledDate = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(DateTime.now())) {
      Get.snackbar(
        'Error',
        'Waktu reminder tidak boleh di masa lalu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return;
    }

    controller.scheduleReminder(todo: todo, scheduledDate: scheduledDate);
    Get.back();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final tomorrow = DateTime.now().add(const Duration(days: 1));

    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Hari ini';
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'Besok';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}