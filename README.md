# Neighbours Flutter App

A Flutter application built with clean architecture principles.

## Project Structure

```
lib/
├── core/
│   ├── di/           # Dependency injection
│   ├── network/      # Network configuration
│   ├── router/       # Navigation
│   ├── storage/      # Local storage (Isar)
│   └── themes/        # App theme
├── features/         # Feature modules
│   └── auth/         # Authentication feature
│       ├── data/     # Data layer
│       │   ├── models/
│       │   └── repositories/
│       └── presentation/
│           ├── bloc/
│           └── pages/
└── main.dart         # App entry point
```

## Getting Started

1. Install dependencies:
```bash
fvm flutter pub get
```

2. Generate code:
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

3. Run the app:
```bash
fvm flutter run
```

## Architecture

The project follows clean architecture principles with the following layers:

- **Presentation Layer**: Contains UI components (pages, widgets) and BLoC for state management
- **Domain Layer**: Contains business logic and repository interfaces
- **Data Layer**: Contains repository implementations and data sources

## Dependencies

- **State Management**: flutter_bloc
- **Navigation**: go_router
- **Dependency Injection**: get_it, injectable
- **Network**: dio
- **Local Storage**: isar, shared_preferences
- **UI**: flutter_screenutil, cached_network_image
- **Version Management**: fvm

## Code Generation

The project uses code generation for:
- JSON serialization
- Dependency injection
- Isar database models

Run the following command to generate code:
```bash
fvm flutter pub run build_runner build --delete-conflicting-outputs
```
---

Если возникнут вопросы — пишите!
