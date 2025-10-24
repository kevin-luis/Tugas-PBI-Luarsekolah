import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/todo_service.dart';
import 'todo_detail_page.dart';
import 'create_edit_todo_dialog.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

enum TodoFilter { all, active, completed }

// ✅ FIX: Tambahkan AutomaticKeepAliveClientMixin untuk keep state alive
class _TodoPageState extends State<TodoPage>
    with AutomaticKeepAliveClientMixin {
  final TodoService _todoService = TodoService();
  List<TodoModel> _allTodos = [];
  bool _isLoading = true;
  String? _errorMessage;
  TodoFilter _currentFilter = TodoFilter.all;

  // ✅ PENTING: Override ini untuk keep state alive
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // Filter todos on client side - more efficient
  List<TodoModel> get _filteredTodos {
    switch (_currentFilter) {
      case TodoFilter.active:
        return _allTodos.where((todo) => !todo.completed).toList();
      case TodoFilter.completed:
        return _allTodos.where((todo) => todo.completed).toList();
      case TodoFilter.all:
      default:
        return _allTodos;
    }
  }

  int get _activeCount => _allTodos.where((todo) => !todo.completed).length;
  int get _completedCount => _allTodos.where((todo) => todo.completed).length;
  int get _totalCount => _allTodos.length;

  Future<void> _loadTodos() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final todos = await _todoService.fetchTodos();

      if (!mounted) return;

      // ✅ Sort by createdAt descending (newest first)
      todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      setState(() {
        _allTodos = todos;
        _isLoading = false;
      });

      print('[TodoPage] Loaded ${todos.length} todos successfully');
    } catch (e) {
      print('[TodoPage] Error loading todos: $e');

      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showCreateDialog() async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (context) => const CreateEditTodoDialog(),
    );

    if (result == null || !mounted) return;

    // ✅ Handle create/update without fetching all data
    final action = result['action'] as String?;
    final todo = result['todo'] as TodoModel?;

    if (todo == null) return;

    setState(() {
      if (action == 'created') {
        // Add new todo to list
        _allTodos.insert(0, todo); // Insert at beginning
      } else if (action == 'updated') {
        // Update existing todo in list
        final index = _allTodos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _allTodos[index] = todo;
        }
      }
    });

    // ✅ Show success message AFTER dialog closed
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            action == 'created'
                ? '✓ Todo berhasil dibuat!'
                : '✓ Todo berhasil diupdate!',
          ),
          backgroundColor: const Color(0xFF26A69A),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
    }
  }

  Future<void> _toggleComplete(TodoModel todo) async {
    // ✅ SOLUSI: Update local state langsung tanpa reload
    try {
      // Kirim request ke server
      final updatedTodo = await _todoService.toggleTodoCompletion(todo.id);

      if (!mounted) return;

      // Update hanya 1 item di list, tanpa fetch ulang
      setState(() {
        final index = _allTodos.indexWhere((t) => t.id == todo.id);
        if (index != -1) {
          _allTodos[index] = updatedTodo; // Ganti dengan data dari server
        }
      });

      // Optional: Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedTodo.completed
                ? '✓ Todo ditandai selesai'
                : '○ Todo ditandai belum selesai',
          ),
          backgroundColor:
              updatedTodo.completed ? const Color(0xFF26A69A) : Colors.orange,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengupdate: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        ),
      );
    }
  }

  Future<void> _navigateToDetail(TodoModel todo) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoDetailPage(todo: todo),
      ),
    );

    if (!mounted) return;

    // ✅ Handle different return types
    if (result == 'deleted') {
      // Todo was deleted, remove from list
      setState(() {
        _allTodos.removeWhere((t) => t.id == todo.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Todo telah dihapus'),
          backgroundColor: Color(0xFF26A69A),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (result is TodoModel) {
      // Todo was updated, replace in list
      setState(() {
        final index = _allTodos.indexWhere((t) => t.id == result.id);
        if (index != -1) {
          _allTodos[index] = result;
        }
      });
    }
    // If result is null, nothing was changed, no need to update
  }

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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadTodos,
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: const Color(0xFF26A69A),
            child: _buildFilterTabs(),
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Todo'),
        backgroundColor: const Color(0xFF26A69A),
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildFilterChip(
            TodoFilter.all,
            'Semua',
            _totalCount,
            Icons.list_alt,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            TodoFilter.active,
            'Aktif',
            _activeCount,
            Icons.radio_button_unchecked,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            TodoFilter.completed,
            'Selesai',
            _completedCount,
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    TodoFilter filter,
    String label,
    int count,
    IconData icon,
  ) {
    final isSelected = _currentFilter == filter;

    return Expanded(
      child: InkWell(
        onTap: _isLoading
            ? null
            : () {
                setState(() => _currentFilter = filter);
              },
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
                  style: TextStyle(
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

  Widget _buildBody() {
    if (_isLoading) {
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

    if (_errorMessage != null) {
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
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadTodos,
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

    if (_allTodos.isEmpty) {
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

    final filteredTodos = _filteredTodos;

    if (filteredTodos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _currentFilter == TodoFilter.completed
                  ? Icons.task_alt
                  : Icons.inbox,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _currentFilter == TodoFilter.completed
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
              _currentFilter == TodoFilter.completed
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
      onRefresh: _loadTodos,
      child: Column(
        children: [
          // Statistics Bar
          if (_allTodos.isNotEmpty) _buildStatisticsBar(),

          // Todo List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = filteredTodos[index];
                return _buildTodoCard(todo, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsBar() {
    final total = _totalCount;
    final completed = _completedCount;
    final percentage = total > 0 ? (completed / total * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF26A69A), Color(0xFF80CBC4)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF26A69A).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$completed/$total selesai',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total > 0 ? completed / total : 0,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage% tercapai',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoCard(TodoModel todo, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: todo.completed
              ? const Color(0xFF26A69A).withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToDetail(todo),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Checkbox
              InkWell(
                onTap: () => _toggleComplete(todo),
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
                            child: Text(
                              'Selesai',
                              style: TextStyle(
                                fontSize: 10,
                                color: const Color(0xFF26A69A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

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
