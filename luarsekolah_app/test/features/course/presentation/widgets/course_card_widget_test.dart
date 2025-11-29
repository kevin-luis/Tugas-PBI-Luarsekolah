import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Import files yang dibutuhkan - sesuaikan path dengan struktur project Anda
import 'package:luarsekolah_app/features/course/domain/entities/course_entity.dart';
import 'package:luarsekolah_app/features/course/presentation/widgets/course_card_widget.dart';
import 'package:luarsekolah_app/features/course/presentation/controllers/course_list_controller.dart';
import 'package:luarsekolah_app/features/course/domain/usecases/get_all_courses_use_case.dart';
import 'package:luarsekolah_app/features/course/domain/usecases/delete_course_use_case.dart';
import 'package:luarsekolah_app/features/course/domain/repositories/course_repository.dart';

// Mock Repository
class MockCourseRepository extends GetxService implements CourseRepository {
  @override
  Future<List<CourseEntity>> getAllCourses() async => [];

  @override
  Future<List<CourseEntity>> getCoursesByCategory(String category) async => [];

  @override
  Future<CourseEntity?> getCourseById(String id) async => null;

  @override
  Future<bool> createCourse({
    required String name,
    required String price,
    required List<String> categoryTag,
    String? thumbnail,
    String? rating,
    String? createdBy,
  }) async =>
      true;

  @override
  Future<bool> updateCourse({
    required String id,
    required String name,
    required String price,
    List<String>? categoryTag,
    String? thumbnail,
    String? rating,
  }) async =>
      true;

  @override
  Future<bool> deleteCourse(String id) async => true;
}

void main() {
  // Setup GetX dependencies sebelum test
  setUpAll(() {
    Get.testMode = true;
  });

  // Cleanup setelah setiap test
  tearDown(() {
    Get.reset();
  });

  testWidgets('CourseCardWidget displays course information correctly',
      (WidgetTester tester) async {
    // Arrange: Buat mock course entity
    const testCourse = CourseEntity(
      id: '1',
      name: 'Marketing Communication',
      price: 1000000,
      category: 'Prakerja',
      rating: '4.5',
      thumbnail: null,
    );

    // Setup dependencies untuk GetX
    final mockRepository = MockCourseRepository();
    Get.put<CourseRepository>(mockRepository);
    
    final getAllCoursesUseCase = GetAllCoursesUseCase(mockRepository);
    final deleteCourseUseCase = DeleteCourseUseCase(mockRepository);
    
    Get.put(CourseListController(
      getAllCoursesUseCase: getAllCoursesUseCase,
      deleteCourseUseCase: deleteCourseUseCase,
    ));

    // Act: Build widget dengan MaterialApp wrapper
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: CourseCardWidget(
            course: testCourse,
            onEdit: () {},
            onDelete: () {},
          ),
        ),
      ),
    );

    // Wait for widget to settle
    await tester.pumpAndSettle();

    // Assert: Verifikasi bahwa informasi course ditampilkan
    // Text muncul di 2 tempat (thumbnail dan header), jadi expect at least one
    expect(find.text('Marketing Communication'), findsWidgets);
    expect(find.text('Rp 1.000.000'), findsOneWidget);
    expect(find.text('Prakerja'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    
    // Verifikasi icon rating muncul
    expect(find.byIcon(Icons.star), findsOneWidget);
    
    // Verifikasi menu button muncul
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    
    // Verifikasi icon school muncul (default thumbnail)
    expect(find.byIcon(Icons.school), findsOneWidget);
  });
}