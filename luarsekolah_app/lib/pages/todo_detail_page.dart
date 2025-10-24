import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';
import 'create_edit_todo_dialog.dart';

class TodoDetailPage extends StatefulWidget {
  final TodoModel todo;

  const TodoDetailPage({super.key, required this.todo});

  @override
  State<TodoDetailPage> createState() => _TodoDetailPageState();
}

class _TodoDetailPageState extends State<TodoDetailPage> {
  final _todoService = TodoService();
  late TodoModel _currentTodo;
  bool _isDeleting = false;

  // 🎨 Palet warna utama
  final Color _primaryColor = const Color(0xFF26A69A);
  final Color _softPrimary = const Color(0xFFE0F2F1);

  // 🎨 Palet status tambahan
  final Color _doneBg1 = const Color(0xFFB2DFDB); // Toska pastel
  final Color _doneBg2 = const Color(0xFF26A69A); // Toska tua
  final Color _pendingBg1 = const Color(0xFFFFF8E1); // Lemon pastel
  final Color _pendingBg2 = const Color(0xFFFFE082); // Kuning lembut
  final Color _alertBg1 = const Color(0xFFFFE0B2); // Oranye pastel
  final Color _alertBg2 = const Color(0xFFFFB74D); // Oranye lembut
  final Color _textPending = const Color(0xFF6D4C41);

  @override
  void initState() {
    super.initState();
    _currentTodo = widget.todo;
  }

  Future<void> _toggleComplete() async {
    try {
      final updatedTodo =
          await _todoService.toggleTodoCompletion(_currentTodo.id);

      setState(() => _currentTodo = updatedTodo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedTodo.completed
                  ? 'Todo ditandai selesai! 🎯'
                  : 'Todo ditandai belum selesai 🔄',
            ),
            backgroundColor:
                updatedTodo.completed ? _doneBg2 : Colors.amber[700],
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengupdate: ${e.toString()}'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _editTodo() async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => CreateEditTodoDialog(todo: _currentTodo),
    );

    if (result == null || !mounted) return;

    final action = result['action'] as String?;
    final updatedTodo = result['todo'] as TodoModel?;

    if (action == 'updated' && updatedTodo != null) {
      setState(() => _currentTodo = updatedTodo);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✓ Todo berhasil diupdate!'),
            backgroundColor: _primaryColor,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteTodo() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);

    try {
      await _todoService.deleteTodo(_currentTodo.id);

      if (mounted) {
        Navigator.pop(context, 'deleted');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Todo berhasil dihapus!'),
            backgroundColor: _primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _isDeleting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: ${e.toString()}'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🚨 Contoh sederhana: kalau todo sudah lebih dari 7 hari belum selesai → alert
    // PERBAIKAN: Gunakan waktu lokal untuk perhitungan hari
    final localCreatedAt = _currentTodo.createdAt.toLocal();
    final bool isAlert = !_currentTodo.completed &&
        DateTime.now().difference(localCreatedAt).inDays >= 7;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _currentTodo);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text('Detail Todo'),
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _currentTodo),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _isDeleting ? null : _editTodo,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isDeleting ? null : _deleteTodo,
            ),
          ],
        ),
        body: _isDeleting
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Menghapus todo...'),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Status Card dengan kondisi 3 warna
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: _currentTodo.completed
                                ? [_doneBg1, _doneBg2]
                                : isAlert
                                    ? [_alertBg1, _alertBg2]
                                    : [_pendingBg1, _pendingBg2],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: _currentTodo.completed
                                ? _doneBg2
                                : isAlert
                                    ? _alertBg2
                                    : _pendingBg2,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _currentTodo.completed
                                  ? Icons.check_circle
                                  : isAlert
                                      ? Icons.warning_amber_rounded
                                      : Icons.pending_actions,
                              color: _currentTodo.completed
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
                                    _currentTodo.completed
                                        ? 'Selesai'
                                        : isAlert
                                            ? 'Perlu Diperhatikan'
                                            : 'Belum Selesai',
                                    style: TextStyle(
                                      color: _currentTodo.completed
                                          ? Colors.white
                                          : isAlert
                                              ? Colors.orange[900]
                                              : _textPending,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _currentTodo.completed
                                        ? 'Todo sudah dikerjakan 🎉'
                                        : isAlert
                                            ? 'Sudah terlalu lama belum dikerjakan ⚠️'
                                            : 'Masih ada pekerjaan yang belum selesai',
                                    style: TextStyle(
                                      color: _currentTodo.completed
                                          ? Colors.white.withOpacity(0.9)
                                          : _textPending.withOpacity(0.8),
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
                    ),

                    const SizedBox(height: 16),

                    // ✅ Todo Content Card
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Todo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _primaryColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _currentTodo.text,
                              style: const TextStyle(
                                fontSize: 18,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ✅ Info Card
                    Card(
                      color: Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.calendar_today,
                              'Dibuat',
                              _formatDateTime(_currentTodo.createdAt),
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              Icons.update,
                              'Terakhir diupdate',
                              _formatDateTime(_currentTodo.updatedAt),
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              Icons.fingerprint,
                              'ID',
                              _currentTodo.id,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ✅ Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _toggleComplete,
                        icon: Icon(
                          _currentTodo.completed
                              ? Icons.undo
                              : Icons.check_circle_outline,
                        ),
                        label: Text(
                          _currentTodo.completed
                              ? 'Tandai Belum Selesai'
                              : 'Tandai Selesai',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _currentTodo.completed ? _alertBg2 : _doneBg2,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                      ),
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
            color: _softPrimary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: _primaryColor),
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

  // 🕐 PERBAIKAN: Konversi ke waktu lokal sebelum formatting
  String _formatDateTime(DateTime date) {
    // Konversi UTC ke waktu lokal HP
    final localDate = date.toLocal();

    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    return '${localDate.day} ${months[localDate.month - 1]} ${localDate.year}, '
        '${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}';
  }
}
