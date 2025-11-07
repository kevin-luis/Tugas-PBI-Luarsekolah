import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/course_list_controller.dart';
import '../widgets/course_card_widget.dart';

class CourseListPage extends StatelessWidget {
  const CourseListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CourseListController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TabBar(
          controller: controller.tabController,
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
                onPressed: controller.navigateToAddCourse,
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
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredCourses.isEmpty) {
                return Center(
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
                        onPressed: controller.loadCourses,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadCourses,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.filteredCourses.length,
                  itemBuilder: (context, index) {
                    final course = controller.filteredCourses[index];
                    return CourseCardWidget(
                      course: course,
                      onEdit: () => controller.navigateToEditCourse(course),
                      onDelete: () => controller.deleteCourse(course.id),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}