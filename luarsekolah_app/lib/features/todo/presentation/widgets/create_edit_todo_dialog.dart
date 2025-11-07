import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/todo_entity.dart';
import '../controllers/todo_controller.dart';

class CreateEditTodoDialog extends GetView<TodoController> {
  final TodoEntity? todo;

  const CreateEditTodoDialog({super.key, this.todo});

  @override
  Widget build(BuildContext context) {
    final isEditing = todo != null;
    final textController = TextEditingController(text: todo?.text ?? '');
    final isSubmitting = false.obs;

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
                    color: const Color(0xFFE0F2F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isEditing ? Icons.edit : Icons.add,
                    color: const Color(0xFF26A69A),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isEditing ? 'Edit Todo' : 'Buat Todo Baru',
                    style: const TextStyle(
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

            // Text Field
            TextField(
              controller: textController,
              maxLines: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Masukkan todo Anda...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF26A69A),
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() => ElevatedButton.icon(
                      onPressed: isSubmitting.value
                          ? null
                          : () => _handleSubmit(
                                textController.text,
                                isEditing,
                                isSubmitting,
                              ),
                      icon: isSubmitting.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(isEditing ? Icons.save : Icons.add),
                      label: Text(isEditing ? 'Simpan' : 'Buat'),
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
                        elevation: 0,
                      ),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(
    String text,
    bool isEditing,
    RxBool isSubmitting,
  ) async {
    if (text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Todo tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
      );
      return;
    }

    isSubmitting.value = true;

    try {
      if (isEditing && todo != null) {
        await controller.updateTodo(id: todo!.id, text: text.trim());
      } else {
        await controller.createTodo(text: text.trim());
      }

      Get.back();
    } catch (e) {
      // Error handling is done in controller
      print('[CreateEditTodoDialog] Error: $e');
    } finally {
      isSubmitting.value = false;
    }
  }
}