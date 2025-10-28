import 'package:flutter/material.dart';
import 'add_class_page.dart';
import '../services/api_service.dart';
import '../models/class_model.dart';
import 'dart:io';

class ClassPage extends StatefulWidget {
  const ClassPage({Key? key}) : super(key: key);

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ClassModel> _allClasses = [];
  List<ClassModel> _filteredClasses = [];
  bool _isLoading = true;
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadClasses();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        switch (_tabController.index) {
          case 0:
            _currentFilter = 'all';
            _filteredClasses = _allClasses;
            break;
          case 1:
            _currentFilter = 'spl';
            _filteredClasses = _allClasses
                .where((c) => c.category.toLowerCase() == 'spl')
                .toList();
            break;
          case 2:
            _currentFilter = 'prakerja';
            _filteredClasses = _allClasses
                .where((c) => c.category.toLowerCase() == 'prakerja')
                .toList();
            break;
        }
      });
    }
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    
    try {
      final classes = await ApiService.getAllCourses();
      
      setState(() {
        _allClasses = classes;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat kelas: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _applyFilter() {
    switch (_currentFilter) {
      case 'all':
        _filteredClasses = _allClasses;
        break;
      case 'spl':
        _filteredClasses = _allClasses
            .where((c) => c.category.toLowerCase() == 'spl')
            .toList();
        break;
      case 'prakerja':
        _filteredClasses = _allClasses
            .where((c) => c.category.toLowerCase() == 'prakerja')
            .toList();
        break;
    }
  }

  Future<void> _deleteClass(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kelas'),
        content: const Text('Apakah Anda yakin ingin menghapus kelas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Menghapus kelas...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final result = await ApiService.deleteCourse(id);
      
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kelas berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          _loadClasses();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal menghapus kelas'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _navigateToAddClass() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddClassPage()),
    );
    if (result == true) {
      _loadClasses();
    }
  }

  Future<void> _navigateToEditClass(ClassModel classModel) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddClassPage(classModel: classModel),
      ),
    );
    if (result == true) {
      _loadClasses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2D6F5C),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2D6F5C),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          tabs: const [
            Tab(text: 'Semua Kelas'),
            Tab(text: 'Kelas SPL'),
            Tab(text: 'Prakerja'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _navigateToAddClass,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Tambah Kelas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6F5C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredClasses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school_outlined,
                                size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada kelas',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _loadClasses,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadClasses,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredClasses.length,
                          itemBuilder: (context, index) {
                            final classItem = _filteredClasses[index];
                            return _buildClassCard(classItem);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(ClassModel classItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: _getCategoryColor(classItem.category),
              ),
              child:
                  classItem.thumbnail != null && classItem.thumbnail!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: classItem.thumbnail!.startsWith('http')
                              ? Image.network(
                                  classItem.thumbnail!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildDefaultThumbnail(classItem),
                                )
                              : Image.file(
                                  File(classItem.thumbnail!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildDefaultThumbnail(classItem),
                                ),
                        )
                      : _buildDefaultThumbnail(classItem),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          classItem.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline,
                                    size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _navigateToEditClass(classItem);
                          } else if (value == 'delete') {
                            _deleteClass(classItem.id);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildCategoryChip(
                        classItem.category,
                        classItem.category.toLowerCase() == 'spl'
                            ? Colors.green
                            : Colors.blue,
                      ),
                      if (classItem.rating != null) ...[
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              classItem.rating!,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${_formatPrice(classItem.price)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildDefaultThumbnail(ClassModel classItem) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            classItem.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 3,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'prakerja':
        return const Color(0xFF2D6F5C);
      case 'spl':
        return const Color(0xFFD4A855);
      default:
        return const Color(0xFF2D6F5C);
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}