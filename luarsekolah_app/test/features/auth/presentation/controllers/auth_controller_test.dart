// test/features/auth/presentation/controllers/auth_controller_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:luarsekolah_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:luarsekolah_app/features/auth/domain/entities/user_entity.dart';
import 'package:luarsekolah_app/features/auth/domain/usecases/login_use_case.dart';
import 'package:luarsekolah_app/features/auth/domain/usecases/register_use_case.dart';
import 'package:luarsekolah_app/features/auth/domain/usecases/login_with_google_use_case.dart';
import 'package:luarsekolah_app/features/auth/domain/usecases/logout_use_case.dart';
import 'package:luarsekolah_app/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:luarsekolah_app/features/auth/domain/usecases/update_user_profile_use_case.dart';
import 'package:luarsekolah_app/core/error/failures.dart';

import 'auth_controller_test.mocks.dart';

@GenerateMocks([
  LoginUseCase,
  RegisterUseCase,
  LoginWithGoogleUseCase,
  LogoutUseCase,
  GetCurrentUserUseCase,
  UpdateUserProfileUseCase,
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late AuthController authController;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLoginWithGoogleUseCase mockLoginWithGoogleUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockUpdateUserProfileUseCase mockUpdateUserProfileUseCase;

  setUp(() {
    // Initialize GetX
    Get.testMode = true;

    // Create mocks
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLoginWithGoogleUseCase = MockLoginWithGoogleUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockUpdateUserProfileUseCase = MockUpdateUserProfileUseCase();

    // Mock getCurrentUser untuk onInit
    when(mockGetCurrentUserUseCase.call()).thenAnswer(
      (_) async => const Right(null),
    );

    // Create controller
    authController = AuthController(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      loginWithGoogleUseCase: mockLoginWithGoogleUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      updateUserProfileUseCase: mockUpdateUserProfileUseCase,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('AuthController - Login', () {
    const testEmail = 'test@example.com';
    const testPassword = 'Password123!';
    final testUser = UserEntity(
      id: '123',
      name: 'Test User',
      email: testEmail,
      phoneNumber: '628123456789',
      createdAt: DateTime(2024, 1, 1),
    );

    test('should return true and set currentUser when login is successful', () async {
      // Arrange
      when(mockLoginUseCase.call(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Right(testUser));

      // Act
      final result = await authController.login(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result, true);
      expect(authController.currentUser.value, testUser);
      expect(authController.isLoading.value, false);
      expect(authController.errorMessage.value, '');
      
      verify(mockLoginUseCase.call(
        email: testEmail,
        password: testPassword,
      )).called(1);
    });

    test('should return false and set errorMessage when login fails', () async {
      // Arrange
      const errorMessage = 'Email tidak terdaftar';
      when(mockLoginUseCase.call(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => Left(AuthFailure(errorMessage)));

      // Act
      final result = await authController.login(
        email: testEmail,
        password: testPassword,
      );

      // Assert
      expect(result, false);
      expect(authController.currentUser.value, null);
      expect(authController.isLoading.value, false);
      expect(authController.errorMessage.value, errorMessage);
      
      verify(mockLoginUseCase.call(
        email: testEmail,
        password: testPassword,
      )).called(1);
    });
  });
}