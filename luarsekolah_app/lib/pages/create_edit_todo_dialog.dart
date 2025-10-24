import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';

class CreateEditTodoDialog extends StatefulWidget {
  final TodoModel? todo;

  const CreateEditTodoDialog({super.key, this.todo});

  @override
  State<CreateEditTodoDialog> createState() => _CreateEditTodoDialogState();
}

class _CreateEditTodoDialogState extends State<CreateEditTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  final _todoService = TodoService();
  bool _completed = false;
  bool _completedChanged = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _textController.text = widget.todo!.text;
      _completed = widget.todo!.completed;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _saveTodo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      TodoModel savedTodo;

      if (widget.todo == null) {
        // ✅ CREATE: Return todo baru
        savedTodo = await _todoService.createTodo(
          text: _textController.text.trim(),
          completed: _completed,
        );

        if (mounted) {
          // ✅ FIX: Pop dulu, SnackBar akan ditampilkan di parent
          Navigator.pop(context, {'action': 'created', 'todo': savedTodo});
        }
      } else {
        // ✅ UPDATE: Return todo yang diupdate
        final textChanged = _textController.text.trim() != widget.todo!.text;

        savedTodo = await _todoService.updateTodo(
          id: widget.todo!.id,
          text: textChanged ? _textController.text.trim() : null,
          completed: _completedChanged ? _completed : null,
        );

        if (mounted) {
          // ✅ FIX: Pop dulu, SnackBar akan ditampilkan di parent
          Navigator.pop(context, {'action': 'updated', 'todo': savedTodo});
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        // Error masih oke karena dialog belum di-pop
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.todo != null;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2F1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEdit ? Icons.edit : Icons.add_task,
                      color:const Color(0xFF26A69A),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEdit ? 'Edit Todo' : 'Buat Todo Baru',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Text Field
              TextFormField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Todo',
                  hintText: 'Masukkan todo...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.text_fields),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Todo tidak boleh kosong';
                  }
                  if (value.trim().length < 3) {
                    return 'Todo minimal 3 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Completed Checkbox
              InkWell(
                onTap: () {
                  setState(() {
                    _completed = !_completed;
                    _completedChanged = true;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _completed ? Colors.green : Colors.grey,
                            width: 2,
                          ),
                          color: _completed ? Colors.green : Colors.transparent,
                        ),
                        child: _completed
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Tandai sebagai selesai',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _saveTodo,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(isEdit ? Icons.save : Icons.add),
                    label: Text(isEdit ? 'Simpan' : 'Buat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26A69A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
