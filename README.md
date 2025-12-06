# 🗂️ Tugas-PBI-Luarsekolah

**Name:** Kevin Luis Banamtuan  
**Occupation:** Software Engineer (Mobile) & Captain of Class  
**Internship Duration:** 3 months

This repository is used to store all assignment files completed during the internship process at Luarsekolah. It contains a collection of project-based assignments (PBI) that are independently and systematically organized as a form of individual responsibility during the internship period.

---

# Flutter Application Setup Guide

This guide will help you run the Flutter application after cloning the repository.

## Prerequisites

Before starting, make sure you have installed:

- Flutter SDK (latest version recommended)
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for emulator)
- Git
- Code editor (VS Code / Android Studio)

To check your Flutter installation, run:

```bash
flutter doctor
```

## Installation Steps

### 1. Clone Repository

```bash
git clone https://github.com/Kevin-cmd-bit/Tugas-PBI-Luarsekolah.git
cd Tugas-PBI-Luarsekolah
```

### 2. Install Dependencies

After navigating to the project directory, run the following command to install all required dependencies:

```bash
flutter pub get
```

### 3. Configure Environment (Optional)

If the application uses environment variables or specific configurations:

- Copy `.env.example` to `.env`
- Fill in with appropriate configurations (API keys, base URLs, etc.)

```bash
cp .env.example .env
```

### 4. Generate Code (If needed)

If the project uses code generation (such as freezed, json_serializable, etc.):

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Run Application

#### Using Emulator/Simulator

Make sure Android emulator or iOS simulator is running, then:

```bash
flutter run
```

#### Select Specific Device

List available devices:

```bash
flutter devices
```

Run on specific device:

```bash
flutter run -d <device_id>
```

#### Debug/Release Mode

```bash
# Debug mode (default)
flutter run

# Release mode
flutter run --release

# Profile mode
flutter run --profile
```

## Platform Specific

### Android

1. Open Android Studio
2. Open AVD Manager
3. Start emulator
4. Return to terminal and run `flutter run`

Or build APK:

```bash
flutter build apk --release
```

### iOS (macOS only)

1. Open Xcode
2. Open iOS Simulator
3. Run `flutter run`

Or build for iOS:

```bash
flutter build ios --release
```

### Web

```bash
flutter run -d chrome
```

Build for web:

```bash
flutter build web
```

## Troubleshooting

### Dependencies Error

```bash
flutter clean
flutter pub get
```

### Build Error

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Version Conflict

Make sure your Flutter version is compatible with the project:

```bash
flutter --version
flutter upgrade
```

### Gradle Error (Android)

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

## Project Structure

This project follows **Clean Architecture** principles with **GetX** state management:

```
Tugas-PBI-Luarsekolah/
├── android/                    # Android configuration
├── ios/                        # iOS configuration
├── lib/                        # Main source code
│   ├── main.dart               # Application entry point
│   ├── core/                   # Core utilities, constants, themes
│   │   ├── constants/
│   │   ├── themes/
│   │   └── utils/
│   │
│   └── features/               # Feature modules
│       └── feature_name/       # Each feature follows clean architecture
│           ├── domain/         # Business logic layer
│           │   ├── entities/   # Business objects
│           │   │   └── feature_entity.dart
│           │   ├── repositories/  # Abstract repository contracts
│           │   │   └── feature_repository.dart
│           │   └── usecases/   # Business use cases
│           │       ├── get_feature_use_case.dart
│           │       ├── create_feature_use_case.dart
│           │       └── delete_feature_use_case.dart
│           │
│           ├── data/           # Data layer
│           │   ├── models/     # Data models (DTOs)
│           │   │   └── feature_model.dart
│           │   └── repositories/  # Repository implementations
│           │       └── feature_repository_impl.dart
│           │
│           └── presentation/   # Presentation layer (UI)
│               ├── controllers/   # GetX controllers
│               │   └── feature_controller.dart
│               ├── bindings/      # Dependency injection
│               │   └── feature_binding.dart
│               ├── pages/         # Screen pages
│               │   └── feature_page.dart
│               └── widgets/       # Reusable UI components
│                   └── feature_widget.dart
│
├── test/                       # Unit & widget tests
├── assets/                     # Images, fonts, etc.
├── pubspec.yaml                # Dependencies & assets
└── README.md                   # Documentation
```

### Architecture Layers

**Domain Layer (Business Logic)**

- Pure Dart code with no external dependencies
- Contains entities, repository interfaces, and use cases
- Independent of frameworks and UI

**Data Layer**

- Implements repository interfaces from domain layer
- Handles data sources (API, local database)
- Contains data models and data transformations

**Presentation Layer**

- Contains UI code and state management
- GetX controllers manage state and business logic execution
- Bindings for dependency injection
- Pages and widgets for UI components

## Testing

Run unit tests:

```bash
flutter test
```

Run integration tests:

```bash
flutter drive --target=test_driver/app.dart
```

## Production Build

### Android (APK)

```bash
flutter build apk --release
```

### Android (App Bundle)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Contributing

If you want to contribute:

1. Fork the repository
2. Create a new branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Create a Pull Request

## Contact & Support

If you encounter any issues:

- Open an issue in the repository
- Contact: Kevin Luis Banamtuan
- Read Flutter documentation: https://flutter.dev/docs

## License

This project is created as part of an internship assignment at Luarsekolah.

---

**© 2024 Kevin Luis Banamtuan - Luarsekolah Internship Project**
