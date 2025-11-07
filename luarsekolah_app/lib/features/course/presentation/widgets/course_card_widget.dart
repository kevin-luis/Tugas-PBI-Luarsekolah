import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/course_entity.dart';
import '../controllers/course_list_controller.dart';

class CourseCardWidget extends StatelessWidget {
  final CourseEntity course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CourseCardWidget({
    Key? key,
    required this.course,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CourseListController>();

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
            _buildThumbnail(controller),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildMetadata(),
                  const SizedBox(height: 8),
                  _buildPrice(controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail(CourseListController controller) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: controller.getCategoryColor(course.category),
      ),
      child: course.thumbnail != null && course.thumbnail!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: course.thumbnail!.startsWith('http')
                  ? Image.network(
                      course.thumbnail!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultThumbnail(),
                    )
                  : Image.file(
                      File(course.thumbnail!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildDefaultThumbnail(),
                    ),
            )
          : _buildDefaultThumbnail(),
    );
  }

  Widget _buildDefaultThumbnail() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.school, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            course.name,
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            course.name,
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
                  Icon(Icons.delete_outline, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
        ),
      ],
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        _buildCategoryChip(
          course.category,
          course.category.toLowerCase() == 'spl' ? Colors.green : Colors.blue,
        ),
        if (course.rating != null) ...[
          const SizedBox(width: 8),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                course.rating!,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildPrice(CourseListController controller) {
    return Text(
      'Rp ${controller.formatPrice(course.price)}',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
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
}